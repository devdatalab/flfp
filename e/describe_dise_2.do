/* use combined dise dataset */
use /scratch/plindsay/dise_pc01_ebb_2.dta, clear

/* gen numeric year var */
gen year1 = substr(year, 1, 4)
drop year
rename year1 year
destring year, replace

/* keep data from 2003-2008 */
keep if inrange( year, 2003, 2008)

/* gen combined enr vars */
gen enr_all_g = enr_all_g1 + enr_all_g2 + enr_all_g3 + enr_all_g4 + enr_all_g5 + enr_all_g6 + enr_all_g7 + enr_all_g8
gen enr_all_b = enr_all_b1 + enr_all_b2 + enr_all_b3 + enr_all_b4 + enr_all_b5 + enr_all_b6 + enr_all_b7 + enr_all_b8
gen enr_all_mid_g = enr_all_g6 + enr_all_g7 + enr_all_g8
gen enr_all_mid_b = enr_all_b6 + enr_all_b7 + enr_all_b8

/* drop gender gap obs to compare only with f lit rate */
drop if pc01_pca_lit_gender_gap < 0.2159

/* sort by state district block year */
sort pc01_state_id pc01_district_id pc01_block_id year

foreach x in g b {

/* gen enr diff var by year */
by pc01_state_id pc01_district_id pc01_block_id, sort: gen diff_`x' = enr_all_mid_`x' - enr_all_mid_`x'[ _n - 1]

/* gen enr diff total var between 2003 and 2008 */
by pc01_state_id pc01_district_id pc01_block_id, sort: egen diff_total_`x' = total(diff_`x')

/* gen log variable */
gen ln_diff_total_`x' = ln(diff_total_`x')
gen ln_enr_all_mid_`x' = ln(enr_all_mid_`x' + 1)
}

/* normalize running var - f lit rate */
replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - 0.4613

save $iec/flfp/dise_ebb_analysis_2, replace

/* generate RD graphs */

/* girls */
rd diff_total_g pc01_pca_f_lit_rate if year == 2003, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
    ytitle ("Change in Enrollment 2003 - 2008") ///
    title ("Girls- Change in Enrollment between 2003 and 2008")

graphout girls123_mid

/* boys */
rd diff_total_b pc01_pca_f_lit_rate if year == 2003, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Change in Enrollment 2003 - 2008") ///
      title ("Boys - Change in Enrollment between 2003 and 2008")

graphout boys123_mid

/* ols regressions */

/* gen interaction variable */
gen ebb_year = ebb_dummy * year

/* fixed effects regression */
areg ln_enr_all_mid_g ebb_dummy year ebb_year ln_pc01_pca_tot_p, absorb(pc01_state_id)
areg ln_enr_all_mid_b ebb_dummy year ebb_year ln_pc01_pca_tot_p, absorb(pc01_state_id)
areg ln_enr_all_mid_g ebb_dummy year ebb_year ln_pc01_pca_tot_p if inrange(pc01_pca_f_lit_rate, -0.1, 0.1), absorb(pc01_state_id)
areg ln_enr_all_mid_b ebb_dummy year ebb_year ln_pc01_pca_tot_p if inrange(pc01_pca_f_lit_rate, -0.1, 0.1), absorb(pc01_state_id)
