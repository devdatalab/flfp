
************************************************
*** MAKE THE DISE DATASET READY FOR ANALYSIS ***
************************************************

/* use dataset */
use $iec/flfp/dise_pc01_ebb, clear

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

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id

/* save dataset */
save $iec/flfp/dise_ebb_analysis
