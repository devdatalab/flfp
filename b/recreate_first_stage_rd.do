/* import dataset */
use $pc01/pc01r_pca_clean.dta, clear

/* collapse to block level */
collapse (sum) pc01_pca_f_lit_rate pc01_pca_tot_f, by(pc01_state_name pc01_state_id ///
    pc01_district_name pc01_district_id pc01_block_name pc01_block_id)

/* generate female literacy rate in each block */
gen pc01_female_literacy_rate = (pc01_pca_f_lit_rate / pc01_pca_tot_f)

/* destring ID values (need standard data type for masala merge) */
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* standardize jammue kashmir name */
replace pc01_state_name = "jammu & kashmir" if pc01_state_name == "jammu kashmir"

/* generate unique identifiers (necessary for masala merge) */
gen id = _n
tostring id, replace

/* use masala merge to fuzzy merge datasets */
masala_merge pc01_state_id pc01_district_id using $ebb/ebbs_list_clean, ///
    s1(pc01_block_name) idmaster(id) idusing(id)
