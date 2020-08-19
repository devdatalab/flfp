********************************************
**** MERGE DISE DATA WITH PC01 AND EBBS ****
********************************************

/* use new-old dise dataset */
use $tmp/dise_old_new, clear

/* merge with DISE-PC01 key */
merge m:1 dise_state district dise_block_name using $ebb/pc01_dise_key

/* keep matches */
keep if _merge == 3

/* drop merge variable*/
drop _merge

/* add prefix to faciliy variables for collapse */
foreach var in blackboard num_classrooms toilet_boys elec library ///
     toilet_common toilet_girls wall playground water {
  rename `var' facility_`var'
}

/* collapse at block level */
collapse (sum) pass* m60* facility* enr*, by(year ///
    pc01_state_id pc01_district_id pc01_block_id pc01_state_name pc01_district_name pc01_block_name)

/* merge EBB-NPEGEL-KGBV data */
merge m:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/treated_list_clean

/* drop unmatched obs */
keep if _merge == 3

/* drop merge variable  */
drop _merge

/* save dataset */
save $iec/flfp/dise_pc01_ebb, replace

*******************************************
*** MAKE THE DATASET READY FOR ANALYSIS ***
*******************************************

/* gen numeric year var */
gen year1 = substr(year, 1, 4)
drop year
rename year1 year
destring year, replace

/* drop obs from 2001 */
drop if year == 2001

/* gen combined enr vars */
gen enr_all_g = enr_all_g1 + enr_all_g2 + enr_all_g3 + enr_all_g4 + enr_all_g5 + enr_all_g6 + enr_all_g7 + enr_all_g8
gen enr_all_b = enr_all_b1 + enr_all_b2 + enr_all_b3 + enr_all_b4 + enr_all_b5 + enr_all_b6 + enr_all_b7 + enr_all_b8
gen enr_all_mid_g = enr_all_g6 + enr_all_g7 + enr_all_g8
gen enr_all_mid_b = enr_all_b6 + enr_all_b7 + enr_all_b8

/* gen log */
gen ln_enr_all_mid_b = ln(enr_all_mid_b + 1)
gen ln_enr_all_mid_g = ln(enr_all_mid_g + 1)

/* normalize running variable */
replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - 0.4613
replace pc01_pca_lit_gender_gap = pc01_pca_lit_gender_gap - 0.2159

/* create a treatment variable for the RD */
gen treatment_lit = pc01_pca_f_lit_rate < 0
gen treatment_gap = pc01_pca_lit_gender_gap < 0

/* create a right side slope for the RD estimation */
gen lit_right = pc01_pca_f_lit_rate * treatment_lit
gen gap_right = pc01_pca_lit_gender_gap * treatment_gap

/* sort by state district block year */
sort pc01_state_id pc01_district_id pc01_block_id year

/* save dataset */
save $iec/flfp/dise_ebb_analysis
