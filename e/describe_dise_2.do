use /scratch/plindsay/dise_pc01_ebb_2.dta, clear

gen year1 = substr(year, 1, 4)

drop year

rename year1 year

drop if year == "2001"

destring year, replace

keep if inrange( year, 2003, 2008)

gen enr_all_g = enr_all_g1 + enr_all_g2 + enr_all_g3 + enr_all_g4 + enr_all_g5 + enr_all_g6 + enr_all_g7 + enr_all_g8

gen enr_all_b = enr_all_b1 + enr_all_b2 + enr_all_b3 + enr_all_b4 + enr_all_b5 + enr_all_b6 + enr_all_b7 + enr_all_b8


drop if pc01_pca_lit_gender_gap < 0.2159

*****

sort pc01_state_id pc01_district_id pc01_block_id year

by pc01_state_id pc01_district_id pc01_block_id, sort: gen diff = enr_all_g - enr_all_g[ _n - 1]

by pc01_state_id pc01_district_id pc01_block_id, sort: egen diff_total = total(diff)

sort pc01_state_id pc01_district_id pc01_block_id year


sort pc01_state_id pc01_district_id pc01_block_id year

by pc01_state_id pc01_district_id pc01_block_id, sort: gen diffb = enr_all_b - enr_all_b[ _n - 1]

by pc01_state_id pc01_district_id pc01_block_id, sort: egen diffb_total = total(diffb)

sort pc01_state_id pc01_district_id pc01_block_id year



gen ln_diff_total = ln(diff_total)

gen ln_diffb_total = ln(diffb_total)

gen diff_total_percent = diff_total/enr_all_g if year == 2003

gen diffb_total_percent = diffb_total/enr_all_b if year == 2003

replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - 0.4613

/* graphs */

rd diff_total_percent pc01_pca_f_lit_rate if year == 2003, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
    ytitle ("Change in Enrollment 2003 - 2008") ///
    title ("Girls- Change in Enrollment between 2003 and 2008")

graphout girls123

rd diffb_total_percent pc01_pca_f_lit_rate if year == 2003, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Change in Enrollment 2003 - 2008") ///
      title ("Boys - Change in Enrollment between 2003 and 2008")

graphout boys123

/* ols regressions */

gen ebb_year = ebb_dummy * year

gen ln_enr_all_g = ln(enr_all_g)

areg ln_enr_all_g ebb_dummy year ebb_year ln_pc01_pca_tot_p, absorb(pc01_state_id)

gen ln_enr_all_b = ln(enr_all_b)

areg ln_enr_all_b ebb_dummy year ebb_year ln_pc01_pca_tot_p, absorb(pc01_state_id)
