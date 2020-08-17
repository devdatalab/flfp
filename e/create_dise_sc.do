/* merge basic dise data with sc enrollment data */
use $iec/dise/dise_basic_clean, clear
merge m:1 dise_state year vilcd schcd using $iec/dise/dise_enr_sc
keep if _merge == 3
drop _merge

/* merge pc01 identifiers using key */
merge m:1 dise_state district dise_block_name using $ebb/pc01_dise_key
drop _merge

/* collapse at block level */
collapse (sum) enr_sc*, by(year pc01_state_name pc01_district_name pc01_block_name pc01_state_id pc01_district_id pc01_block_id)

/* destring year */
gen year11 = substr(year, 1, 4)
drop year
rename year11 year
destring year, replace

/* drop because of insiffucient matches in 13/14/15 */
drop if inrange(year, 2013, 2015)

/* add treated ebb/kgbv/npegel data */
merge m:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/treated_list_clean

/* drop gender gap obs to compare only with f lit rate */
drop if pc01_pca_lit_gender_gap < 0.2159

/* normalize running variable */
replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - 0.4613

/* create a treatment variable for the RD */
gen treatment_2 = pc01_pca_f_lit_rate < 0

/* create a right side slope for the RD estimation */
gen lit_right = pc01_pca_f_lit_rate * treatment

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id

/* create mid school vars */
gen mid_g_sc = enr_sc_g6 + enr_sc_g7 + enr_sc_g8
gen mid_b_sc = enr_sc_b6 + enr_sc_b7 + enr_sc_b8
gen ln_mid_g_sc = ln(mid_g_sc)
gen ln_mid_b_sc = ln(mid_b_sc)

save $tmp/sc_ebb, replace

use $tmp/sc_ebb, clear

/* GIRLS */
forval y = 2005/2012 {
  quireg ln_mid_g_sc treatment_2 pc01_pca_f_lit_rate lit_right if year == `y' ///
 & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), absorb(sgroup) cluster(sdgroup) title(`y')
}

/* BOYS */
forval y = 2005/2012 {
  quireg ln_mid_b_sc treatment_2 pc01_pca_f_lit_rate lit_right if year == `y' ///
 & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), cluster(sdgroup) absorb(sgroup) title(`y')
}

