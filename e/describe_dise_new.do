/* use combined dise dataset */
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

/* drop gender gap obs to compare only with f lit rate */
drop if pc01_pca_lit_gender_gap < 0.2159

/* normalize running variable */
replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - 0.4613

/* sort by state district block year */
sort pc01_state_id pc01_district_id pc01_block_id year

**************************
*** AVERAGE ENROLLMENT ***
**************************

foreach x in g b {

/* gen enrollment variables by year and gender */
foreach var in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 {
 gen var`var'`x' = enr_all_mid_`x' if year == `var'
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace var`var'`x' = var`var'`x'[_n-1] if mi(var`var'`x')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace var`var'`x' = var`var'`x'[_n+1] if mi(var`var'`x')
 }
 
/* gen average enrollment variables */
gen avg0203_`x' = (var2002`x' + var2003`x')/2 if year == 2012
gen avg0406_`x' = (var2004`x' + var2005`x' + var2006`x')/3 if year == 2012
gen avg0709_`x' = (var2007`x' + var2008`x' + var2009`x')/3 if year == 2012
gen avg1012_`x' = (var2010`x' + var2011`x' + var2012`x')/3 if year == 2012

/* gen log variables and replace missing values */
foreach var in avg0203 avg0406 avg0709 avg1012 {
 gen ln_`var'_`x' = ln(`var'_`x' + 1)
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace `var'_`x' = `var'_`x'[_n-1] if mi(`var'_`x')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace `var'_`x' = `var'_`x'[_n+1] if mi(`var'_`x')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace ln_`var'_`x' = ln_`var'_`x'[_n-1] if mi(ln_`var'_`x')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace ln_`var'_`x' = ln_`var'_`x'[_n+1] if mi(ln_`var'_`x')
 }
}

/* RD graphs */

foreach x in g b {
foreach var in ln_avg0203 ln_avg0406 ln_avg0709 ln_avg1012 {
rd `var'_`x' pc01_pca_f_lit_rate if year==2012, degree(2) bins(50) start(-.1) end(0.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("`var'") title ("Reduced Form")

gr save $tmp/`var'_`x'_mid.gph, replace
}
}

/* combine all graphs */

foreach x in g b {
gr combine $tmp/ln_avg0203_`x'_mid.gph $tmp/ln_avg0406_`x'_mid.gph $tmp/ln_avg0709_`x'_mid.gph $tmp/ln_avg1012_`x'_mid.gph, ///
title(Reduced Form - Average Middle School Enrollment for `x') ycommon xcommon
graphout reduced_enr_`x'_middle
}

************************************************
*** CHANGE IN ENROLLMENT BETWEEN 2003 & 2008 ***
************************************************

/* keep data from 2003-2008 */
keep if inrange( year, 2003, 2008)

foreach x in g b {

/* gen enr diff var by year */
by pc01_state_id pc01_district_id pc01_block_id, sort: gen diff_`x' = enr_all_mid_`x' - enr_all_mid_`x'[ _n - 1]

/* gen enr diff total var between 2003 and 2008 */
by pc01_state_id pc01_district_id pc01_block_id, sort: egen diff_total_`x' = total(diff_`x')

/* gen log variable */
gen ln_diff_total_`x' = ln(diff_total_`x')
gen ln_enr_all_mid_`x' = ln(enr_all_mid_`x' + 1)
}

/* generate RD graphs */

/* girls */
rd diff_total_g pc01_pca_f_lit_rate if year == 2003, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
    ytitle ("Change in Enrollment 2003 - 2008") ///
    title ("Girls- Change in Enrollment between 2003 and 2008")

graphout reduced_change_mid_g

/* boys */
rd diff_total_b pc01_pca_f_lit_rate if year == 2003, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Change in Enrollment 2003 - 2008") ///
      title ("Boys - Change in Enrollment between 2003 and 2008")

graphout reduced_change_mid_b


/* ols regressions */

/* gen interaction variable */
gen ebb_year = ebb_dummy * year

/* fixed effects regression */
areg ln_enr_all_mid_g ebb_dummy year ebb_year ln_pc01_pca_tot_p, absorb(pc01_state_id)
areg ln_enr_all_mid_b ebb_dummy year ebb_year ln_pc01_pca_tot_p, absorb(pc01_state_id)
areg ln_enr_all_mid_g ebb_dummy year ebb_year ln_pc01_pca_tot_p if inrange(pc01_pca_f_lit_rate, -0.1, 0.1), absorb(pc01_state_id)
areg ln_enr_all_mid_b ebb_dummy year ebb_year ln_pc01_pca_tot_p if inrange(pc01_pca_f_lit_rate, -0.1, 0.1), absorb(pc01_state_id)
