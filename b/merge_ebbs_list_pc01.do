/*********************/
/* Clean EBB dataset */
/*********************/

/* import EBB datatset */
use $ebb/ebbs_list, clear

/* make state, district, block names lowercase */
replace state_name = lower(state_name)
replace district_name = lower(district_name)
replace cd_block_name = lower(cd_block_name)

/* standardize variable names */
ren state_code pc01_state_id
ren state_name pc01_state_name
ren district_code pc01_district_id
ren district_name pc01_district_name
ren cd_block_name pc01_block_name

/* generate unique identifiers for observations (necessary for masala merge) */
tostring pc01_state_id pc01_district_id, replace
gen id = pc01_state_id + "-" + pc01_district_id + "-" + pc01_block_name
destring pc01_state_id pc01_district_id, replace

/* recode roman numerals */
replace pc01_block_name = regexr(pc01_block_name, "ii$", "2")

/* save as temporary file */
save $tmp/ebbs_list_clean, replace

/**********************/
/* Clean PC01 Dataset */
/**********************/

/* import PC01 dataset */
use $pc01/pc01r_pca_clean, clear

/* make all string variables lowercase */
foreach var of varlist _all {
	local vartype: type `var'
	if substr("`vartype'", 1,3) == "str" {
		replace `var'= ustrlower(`var')
	}
}

/* drop villages with less than 100 residents */
drop if pc01_pca_tot_p < 100

/* collapse to block level */
collapse (sum) pc01_pca_f_lit pc01_pca_tot_f pc01_pca_f_06 ///
    pc01_pca_m_lit pc01_pca_tot_m pc01_pca_m_06 pc01_pca_tot_p, ///
    by(pc01_state_name pc01_state_id pc01_district_name pc01_district_id ///
    pc01_block_name pc01_block_id)

/* calculate female literacy rate */
gen pc01_pca_f_lit_rate = (pc01_pca_f_lit / (pc01_pca_tot_f - pc01_pca_f_06))
label variable pc01_pca_f_lit_rate "Block female literacy rate (PC01)"

/* calculate literacy rate gender gap */
gen pc01_pca_m_lit_rate = (pc01_pca_m_lit / (pc01_pca_tot_m - pc01_pca_m_06))
label variable pc01_pca_m_lit_rate "Block male literacy rate (PC01)"
gen pc01_pca_lit_gender_gap = (pc01_pca_m_lit_rate - pc01_pca_f_lit_rate)
label variable pc01_pca_lit_gender_gap "Block gap in literacy rates by gender (PC01)"

/* drop total variables used to calculate rates */
drop pc01_pca_f_lit pc01_pca_tot_f pc01_pca_f_06 pc01_pca_m_lit pc01_pca_tot_m pc01_pca_m_06 

/* recode roman numerals to avoid masala merge error */
replace pc01_block_name = regexr(pc01_block_name, "ii$", "2")

/* manually fix some observations */
replace pc01_block_name = "jharia cum jorapokhar cum sindri" if ///
    pc01_block_name == "jhariacumjorapokharcumsindri"
replace pc01_block_name = "hansi-1" if pc01_block_name == "hans2"
replace pc01_block_name = "aaaa" if pc01_block_name == "goalpokhar2"
replace pc01_block_name = "bbbb" if pc01_block_name == "gopiballavpur2"
replace pc01_block_name = "cccc" if pc01_block_name == "sikandarpurkaran"
replace pc01_block_name = "dddd" if pc01_block_name == "sagar" ///
    & pc01_state_id == "23"
replace pc01_block_name = "eeee" if pc01_block_name == "peddapalle"
replace pc01_block_name = "ffff" if pc01_block_name == "gudipala"
replace pc01_block_name = "gggg" if pc01_block_name == "mukhed"
replace pc01_block_name = "hhhh" if pc01_block_name == "baisi"
replace pc01_block_name = "iiii" if pc01_block_name == "tandur" ///
    & pc01_district_id == "1"
replace pc01_block_name = "tamar-1" if pc01_block_name == "tamari"

/* fix EBBs which have no name in PC01 ("forest villages" in ebbs_list) */
global uplist kheri jhansi bahraich gonda mahrajganj sonbhadra

foreach district in $uplist {
  replace pc01_block_name = "forest villages" if mi(pc01_block_name) & ///
      pc01_state_name == "uttar pradesh" & pc01_district_name == "`district'"
}

replace pc01_block_name = "forest villages" if mi(pc01_block_name) & ///
    pc01_state_name == "uttarakhand" & pc01_district_name == "udham singh nagar"
replace pc01_block_name = "forest villages" if mi(pc01_block_name) & ///
    pc01_state_name == "uttarakhand" & pc01_district_name == "champawat"

/* generate unique identifiers (necessary for masala merge) */
gen id = pc01_state_id + "-" + pc01_district_id + "-" + pc01_block_name

/* destring IDs */
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* save dataset */
save $tmp/pc01_lit_clean, replace

/******************************/
/* Merge Cleaned EBB and PC01 */
/******************************/

/* open cleaned PC01 dataset */
use $tmp/pc01_lit_clean, clear

/* use masala merge to fuzzy merge datasets */
masala_merge pc01_state_id pc01_district_id using $tmp/ebbs_list_clean, ///
    s1(pc01_block_name) idmaster(id) idusing(id)

/* fix block names that were edited to avoid false positives in the merge */
replace pc01_block_name_master = "goalpokhar2" if pc01_block_name_master == "aaaa"
replace pc01_block_name_master = "gopiballavpur2" if pc01_block_name_master == "bbbb"
replace pc01_block_name_master = "sikandar purkaran" if pc01_block_name_master == "cccc"
replace pc01_block_name_master = "sagar" if pc01_block_name_master == "dddd"
replace pc01_block_name_master = "peddapalle" if pc01_block_name_master == "eeee"
replace pc01_block_name_master = "gudipala" if pc01_block_name_master == "ffff"
replace pc01_block_name_master = "mukhed" if pc01_block_name_master == "gggg"
replace pc01_block_name_master = "baisi" if pc01_block_name_master == "hhhh"
replace pc01_block_name_master = "tandur" if pc01_block_name_master == "iiii"

/* drop merge variable */
drop _merge

/* merge using and master block names into one variable */
gen pc01_block_name = pc01_block_name_master
replace pc01_block_name = pc01_block_name_using if mi(pc01_block_name_master)
label variable pc01_block_name "Block Name"

/* generate EBB dummy */
gen ebb_dummy = 0 
replace ebb_dummy = 1 if match_source != 6
label variable ebb_dummy "Dummy variable for EBB status"
drop match_source masala_dist

/* generate unique identifiers for observations */
tostring pc01_state_id pc01_district_id, replace
gen id = pc01_state_id + "-" + pc01_district_id + "-" + pc01_block_name
destring pc01_state_id pc01_district_id, replace

/* drop variables which will be generates in future masala merges */
drop id_using id_master pc01_block_name_master pc01_block_name_using

/* make EBB lit rates into decimals (same format as PC01) */
gen ebb_f_lit_rate = (female_literacy / 100)
gen ebb_lit_gender_gap = (gender_gap_literacy / 100)
drop female_literacy gender_gap_literacy

/* clean up other variables */
label variable ebb_f_lit_rate "Block female literacy rate (EBB)"
ren cd_block_code ebb_block_id
label variable ebb_lit_gender_gap "Block gap in literacy rates by gender (EBB)"

/* generate treatment variable (treated != EBB, sometimes) */
gen treated_dummy = 0

/* all EBBs should be treated */
replace treated_dummy = 1 if ebb_dummy == 1

/* "expanded to include blocks with rural female literacy rates of less than 45%,
irrespective of the gender gap */
replace treated_dummy = 1 if pc01_pca_f_lit_rate < 0.45

/* save merged dataset */
save $ebb/ebbs_list_clean, replace
