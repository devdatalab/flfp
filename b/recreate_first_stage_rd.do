/* PACKAGES TO DOWNLOAD */
ssc install binscatter

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

/* drop unnamed forest villages (no match in PC01) */
drop if pc01_block_name == "forest villages"

/* generate unique identifiers for observations (necessary for masala merge) */
gen id = _n
tostring id, replace

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
    pc01_pca_m_lit pc01_pca_tot_m pc01_pca_m_06, ///
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

/* destring ID values (need standard data type for masala merge) */
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* recode roman numerals to avoid masala merge error */
replace pc01_block_name = regexr(pc01_block_name, "ii$", "2")
/* clean_roman_numerals(pc01_state_name), replace */

/* manually fix some observations */
replace pc01_block_name = "jharia cum jorapokhar cum sindri" if ///
    pc01_block_name == "jhariacumjorapokharcumsindri"
replace pc01_block_name = "hansi-1" if pc01_block_name == "hans2"
replace pc01_block_name = "aaaa" if pc01_block_name == "goalpokhar2"
replace pc01_block_name = "bbbb" if pc01_block_name == "gopiballavpur2" 
replace pc01_block_name = "cccc" if pc01_block_name == "sikandarpurkaran"
replace pc01_block_name = "dddd" if pc01_block_name == "sagar" ///
    & pc01_state_id == 23
replace pc01_block_name = "eeee" if pc01_block_name == "peddapalle"
replace pc01_block_name = "ffff" if pc01_block_name == "gudipala"
replace pc01_block_name = "gggg" if pc01_block_name == "mukhed"
replace pc01_block_name = "tamar-1" if pc01_block_name == "tamari"

/* generate unique identifiers (necessary for masala merge) */
gen id = _n
tostring id, replace

/******************************/
/* Merge Cleaned EBB and PC01 */
/******************************/

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
gen id = _n
tostring id, replace

/* drop variables which will be generates in future masala merges */
drop id_using id_master pc01_block_name_master pc01_block_name_using

/* clean up other variables */
ren female_literacy ebb_f_lit_rate
label variable ebb_f_lit_rate "Block female literacy rate (EBB)"
ren cd_block_code ebb_block_id
ren gender_gap_literacy ebb_lit_gender_gap
label variable ebb_lit_gender_gap "Block gap in literacy rates by gender (EBB)"

/* save merged dataset */
save $ebb/ebbs_list_clean, replace

/***********************************/
/* Replicate first stage RD graphs */
/***********************************/

/* graph a scatterplot with black dots representing EBBs
(based on ebbs_list.dta coding, rather than the raw qualification metrics) */
twoway (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if ebb_dummy == 1, mcolor(black) msize(tiny)) ///
    (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if ebb_dummy == 0, mcolor(gs8) msize(tiny)), ///
    graphregion(color(white)) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Gender Gap in Rural Literacy") ///
    ylabel(, angle(0) format(%9.2f) nogrid) ///
    legend(off) ///
    xline(.4613, lcolor(black)) ///
    yline(.2159, lcolor(black)) ///
    ylabel(-0.2 0 0.2 0.4 0.6) ///
    title(NPEGEL/KGBV Eligibility of Rural Blocks) ///
    name(firststagerd, replace)

/* export graph */
graphout firststagerd

/* binscatter for literacy rate RD */
binscatter ebb_dummy pc01_pca_f_lit_rate, rd(0.4613) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Fraction of EBB Observations in Bin") ///
    name(litraterd, replace)

/* binscatter for gender gap in literacy rates RD */
binscatter ebb_dummy pc01_pca_lit_gender_gap, rd(0.2159) ///
    xtitle("Gender Gap in Rural Literacy") ///
    ytitle("Fraction of EBB Observations in Bin") ///
    name(gendergaprd, replace)

/* combine binscatter graphs */
graph combine litraterd gendergaprd, ycommon r(1) name(combinedrd, replace)

/* export combined graph */
graphout combinedrd
