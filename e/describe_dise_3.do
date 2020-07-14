use /scratch/plindsay/dise_pc01_ebb_2.dta, clear

gen year1 = substr(year, 1, 4)

drop year

rename year1 year

drop if year == "2001"

gen enr_all_g = enr_all_g1 + enr_all_g2 + enr_all_g3 + enr_all_g4 + enr_all_g5 + enr_all_g6 + enr_all_g7 + enr_all_g8

gen enr_all_b = enr_all_b1 + enr_all_b2 + enr_all_b3 + enr_all_b4 + enr_all_b5 + enr_all_b6 + enr_all_b7 + enr_all_b8

tostring pc01_state_id pc01_district_id pc01_block_id, replace

gen panel = pc01_state_id + pc01_district_id + pc01_block_id + pc01_district_id

destring panel pc01_state_id pc01_district_id pc01_block_id year, replace

replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - 0.4613

gen ebb_year = ebb_dummy * year

drop if pc01_pca_lit_gender_gap < 0.2159

// reg enr_all_g ebb_dummy year ebb_year


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



************

/* block */

gen var1g  =  enr_all_g if year == 2002
by pc01_state_id pc01_district_id pc01_block_id, sort: replace var1g =  var1g[_n-1] if  mi(var1g)

gen var2g = enr_all_g if year == 2007

gen diff_g = var2g - var1g if year  == 2007

sort pc01_state_id pc01_district_id pc01_block_id
by pc01_state_id, sort: egen count_s1 = count(pc01_block_id) if year == 2007

by pc01_state_id, sort: egen state_diff = total(diff_g) if year == 2007

by pc01_state_id, sort: egen state_initialg = total(var1g) if year == 2007

by pc01_state_id, sort: gen state_diff_percent = state_diff/state_initialg

by pc01_state_id, sort: gen state_diff_av = state_diff/count_s1 if year == 2007

gen diff_changeg = (var2g - var1g)/var1g if year == 2007

/* percentage change in enrollment block - percetnage change in enrollment at state */
gen diff_percent = diff_changeg - state_diff_percent

/*  log of percentage change in enrollment block - percetnage change in enrollment at state */
gen ln_diff_percent = ln(diff_percent)

/* difference in enrollment - state mean */
gen diff_g_1 = diff_g - state_diff_av

/* (difference in enrollment - state mean)/enrollment in 2002) */
gen diff_g_2 = diff_g_1/var1g

/* log of difference in enrollment - state mean */
gen ln_diff_g_1 = ln(diff_g_1)

/* log of (difference in enrollment - state mean)/enrollment in 2002) */
gen ln_diff_g_2 = ln(diff_g_2)

rd diff_g_1 pc01_pca_f_lit_rate if year == 2007, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Log Average Enrollment 2002-04") title ("Reduced Form - 2002-04")
