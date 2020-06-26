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

/* collapse to block level */
collapse (sum) pc01_pca_f_lit_rate pc01_pca_tot_f, by(pc01_state_name pc01_state_id ///
    pc01_district_name pc01_district_id pc01_block_name pc01_block_id)

/* generate female literacy rate in each block */
gen pc01_female_literacy_rate = (pc01_pca_f_lit_rate / pc01_pca_tot_f)

/* destring ID values (need standard data type for masala merge) */
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* recode roman numerals to avoid masala merge error */
replace pc01_block_name = regexr(pc01_block_name, "ii$", "2")

/* manually fix some observations */
replace pc01_block_name = "jharia cum jorapokhar cum sindri" if ///
    pc01_block_name == "jhariacumjorapokharcumsindri"
replace pc01_block_name = "tamar i" if pc01_block_name == "tamari"

/* generate unique identifiers (necessary for masala merge) */
gen id = _n
tostring id, replace

/******************************/
/* Merge Cleaned EBB and PC01 */
/******************************/

/* use masala merge to fuzzy merge datasets */
masala_merge pc01_state_id pc01_district_id using $tmp/ebbs_list_clean, ///
    s1(pc01_block_name) idmaster(id) idusing(id)

/* drop merge variable */
drop _merge

/* merge using and master block names into one variable */
gen pc01_block_name = pc01_block_name_master
replace pc01_block_name = pc01_block_name_using if mi(pc01_block_name_master)

/* generate unique identifiers for observations */
gen id = _n
tostring id, replace

/* drop variables which will be generates in future masala merges */
drop id_using id_master pc01_block_name_master pc01_block_name_using

/* save merged dataset */
save $ebb/ebbs_list_clean, replace
