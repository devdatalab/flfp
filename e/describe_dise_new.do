/* use combined dise dataset */
use $iec/flfp/dise_ebb_analysis, clear

/* drop gender gap obs to compare only with f lit rate */
drop if pc01_pca_lit_gender_gap < 0

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

/* gen RD graphs */
foreach var in ln_avg0203 ln_avg0406 ln_avg0709 ln_avg1012 {
rd `var'_`x' pc01_pca_f_lit_rate if year==2012, degree(2) bins(50) start(-.1) end(0.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("`var'") title ("Reduced Form")

/* save graphs */
gr save $tmp/`var'_`x'_mid.gph, replace
}

/* combine all graphs */
gr combine $tmp/ln_avg0203_`x'_mid.gph $tmp/ln_avg0406_`x'_mid.gph $tmp/ln_avg0709_`x'_mid.gph $tmp/ln_avg1012_`x'_mid.gph, ///
title(Reduced Form - Average Middle School Enrollment for `x') ycommon xcommon
graphout reduced_enr_`x'_middle
}

**********************************
*** COMPARE ENROLLMENT BY YEAR ***
**********************************

/* loop rd graphs over all years and generate graphs for boys and girls */

forval i = 2002/2015 {
  rd ln_enr_all_mid_g pc01_pca_f_lit_rate if year == `i' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), ///
      bw degree(1) ylabel(6(.5)9) xtitle("Female Literacy Rate") ytitle("Log Enrollment") ///
      title(`i') bins(20) name(g`i') nodraw
  local graphs_g "`graphs_g' g`i'"

  rd ln_enr_all_mid_b pc01_pca_f_lit_rate if year == `i' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), ///
      bw degree(1) ylabel(6(.5)9) xtitle("Female Literacy Rate") ytitle("Log Enrollment") ///
      title(`i') bins(20) name(g`i') nodraw
  local graphs_b "`graphs_b' b`i'"
}

/* graph combine */

gr combine `graphs_g', cols(2)  title (RD - Middle School Enrollment for Girls) ///
    ysize(20) xsize(7) scheme(w538)
graphout g_combine_all

gr combine `graphs_b', cols(2)  title (RD - Middle School Enrollment for Boys) ///
    ysize(20) xsize(7) scheme(w538)
graphout b_combine_all


/* GIRLS */
forval y = 2002/2015 {
  quireg ln_enr_all_mid_g treatment pc01_pca_f_lit_rate lit_right if year == `y' ///
 & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), cluster(sdgroup) title(`y')
}

/* BOYS */
forval y = 2002/2015 {
  quireg ln_enr_all_mid_b treatment pc01_pca_f_lit_rate lit_right if year == `y' ///
 & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), cluster(sdgroup) title(`y')
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
