/****************************************************/
/* Creates datasets for masala merge bug (Issue #2) */
/****************************************************/

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
collapse (sum) pc01_pca_f_lit pc01_pca_tot_f pc01_pca_f_06 ///
    pc01_pca_m_lit pc01_pca_tot_m pc01_pca_m_06, ///
    by(pc01_state_name pc01_state_id pc01_district_name pc01_district_id ///
    pc01_block_name pc01_block_id)

/* destring ID values (need standard data type for masala merge) */
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* recode roman numerals to avoid masala merge error */
replace pc01_block_name = regexr(pc01_block_name, "ii$", "2")

/* manually fix some observations */
replace pc01_block_name = "jharia cum jorapokhar cum sindri" if ///
    pc01_block_name == "jhariacumjorapokharcumsindri"
replace pc01_block_name = "hansi-1" if pc01_block_name == "hans2"
replace pc01_block_name = "tamar-1" if pc01_block_name == "tamari"

/* generate unique identifiers (necessary for masala merge) */
gen id = _n
tostring id, replace

/* save as clean data file */
save $tmp/masala_merge_bug, replace

/* masala merge with list of EBBs */
masala_merge pc01_state_id pc01_district_id using $tmp/ebbs_list_clean, ///
    s1(pc01_block_name) idmaster(id) idusing(id)
