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

/* gen log */
gen ln_enr_all_mid_b = ln(enr_all_mid_b + 1)
gen ln_enr_all_mid_g = ln(enr_all_mid_g + 1)
gen ln_pc01_pca_tot_p = ln(pc01_pca_tot_p)
/* drop gender gap obs to compare only with f lit rate */
drop if pc01_pca_f_lit_rate < 0.4613

/* normalize running variable */
replace pc01_pca_lit_gender_gap = pc01_pca_lit_gender_gap - 0.2159

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

/* gen RD graphs */
foreach var in ln_avg0203 ln_avg0406 ln_avg0709 ln_avg1012 {
    if "`var'" == "ln_avg0203" local locname "2002-2003"
    if "`var'" == "ln_avg0406" local locname "2004-2006"
    if "`var'" == "ln_avg0709" local locname "2007-2009"
    if "`var'" == "ln_avg1012" local locname "2010-2012"
    
    rd `var'_`x' pc01_pca_lit_gender_gap if year==2012, start(-.09) end(0.09) ylabel(-0.5(0.5)0.5) degree(2) bins(50)  ///
        absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Literacy Gap Rate") ///
        ytitle (Log Average Enrollment) title (`locname') 

/* save graphs */
gr save $tmp/`var'_`x'_mid.gph, replace
}

/* combine all graphs */
gr combine $tmp/ln_avg0203_`x'_mid.gph $tmp/ln_avg0406_`x'_mid.gph $tmp/ln_avg0709_`x'_mid.gph $tmp/ln_avg1012_`x'_mid.gph, ///
title(Reduced Form - Average Middle School Enrollment for `x') ycommon xcommon
graphout reduced_enr_`x'_middle
}

/***************************************************************************************/
/* **********************************                                                  */
/* *** COMPARE ENROLLMENT BY YEAR ***                                                  */
/* **********************************                                                  */
/*                                                                                     */
/* /\* loop rd graphs over all years and generate graphs for boys and girls *\/        */
/*                                                                                     */
/* forval i = 2002/2015 {                                                              */
/*   rd ln_enr_all_mid_g pc01_pca_lit_gender_gap if year == `i' , ///                  */
/*       bw degree(1) xtitle("Literacy Gap") ytitle("Log Enrollment") ///              */
/*       title(`i') bins(20) name(g`i') nodraw                                         */
/*   local graphs_g "`graphs_g' g`i'"                                                  */
/*                                                                                     */
/*   rd ln_enr_all_mid_b pc01_pca_lit_gender_gap if year == `i' , ///                  */
/*       bw degree(1) xtitle("Literacy Gap") ytitle("Log Enrollment") ///              */
/*       title(`i') bins(20) name(b`i') nodraw                                         */
/*   local graphs_b "`graphs_b' b`i'"                                                  */
/* }                                                                                   */
/*                                                                                     */
/* /\* graph combine *\/                                                               */
/*                                                                                     */
/* gr combine `graphs_g', cols(2)  title (RD - Middle School Enrollment for Girls) /// */
/*     ysize(20) xsize(7) scheme(w538)                                                 */
/* graphout g_combine_all                                                              */
/*                                                                                     */
/* gr combine `graphs_b', cols(2)  title (RD - Middle School Enrollment for Boys) ///  */
/*     ysize(20) xsize(7) scheme(w538)                                                 */
/* graphout b_combine_all                                                              */
/***************************************************************************************/

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id 

/* create a treatment variable for the RD */
gen treatment = pc01_pca_lit_gender_gap > 0

/* create a right side slope for the RD estimation */
gen lit_right = pc01_pca_lit_gender_gap * treatment


/* GIRLS */
forval y = 2002/2015 {
  quireg ln_enr_all_mid_g treatment pc01_pca_lit_gender_gap lit_right if year == `y' & inrange(pc01_pca_lit_gender_gap, -0.1,0.1), ///
       cluster(sdgroup) absorb(sgroup) title(`y')
}

/* BOYS */
forval y = 2002/2015 {
  quireg ln_enr_all_mid_b treatment pc01_pca_lit_gender_gap lit_right if year == `y', ///
 cluster(sdgroup) title(`y')
}

************************************************
*** CHANGE IN ENROLLMENT BETWEEN 2003 & 2008 ***
************************************************

/********************************************************************************************************************/
/* /\* keep data from 2003-2008 *\/                                                                                 */
/* keep if inrange( year, 2003, 2008)                                                                               */
/*                                                                                                                  */
/* foreach x in g b {                                                                                               */
/*                                                                                                                  */
/* /\* gen enr diff var by year *\/                                                                                 */
/* by pc01_state_id pc01_district_id pc01_block_id, sort: gen diff_`x' = enr_all_mid_`x' - enr_all_mid_`x'[ _n - 1] */
/*                                                                                                                  */
/* /\* gen enr diff total var between 2003 and 2008 *\/                                                             */
/* by pc01_state_id pc01_district_id pc01_block_id, sort: egen diff_total_`x' = total(diff_`x')                     */
/* }                                                                                                                */
/*                                                                                                                  */
/* /\* generate RD graphs *\/                                                                                       */
/*                                                                                                                  */
/* /\* girls *\/                                                                                                    */
/* rd diff_total_g pc01_pca_lit_gender_gap if year == 2003, degree(2) bins(50) ///                                  */
/* absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Literacy Gap") ///                                     */
/*     ytitle ("Change in Enrollment 2003 - 2008") ///                                                              */
/*     title ("Girls- Change in Enrollment between 2003 and 2008")                                                  */
/*                                                                                                                  */
/* graphout reduced_change_mid_g                                                                                    */
/*                                                                                                                  */
/* /\* boys *\/                                                                                                     */
/* rd diff_total_b pc01_pca_lit_gender_gap if year == 2003, degree(2) bins(50)  ///                                 */
/* absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Literacy Gap") ///                                     */
/* ytitle ("Change in Enrollment 2003 - 2008") ///                                                                  */
/*       title ("Boys - Change in Enrollment between 2003 and 2008")                                                */
/*                                                                                                                  */
/* graphout reduced_change_mid_b                                                                                    */
/*                                                                                                                  */
/*                                                                                                                  */
/* /\* ols regressions *\/                                                                                          */
/*                                                                                                                  */
/* /\* gen interaction variable *\/                                                                                 */
/* gen ebb_year = ebb_dummy * year                                                                                  */
/*                                                                                                                  */
/* /\* fixed effects regression *\/                                                                                 */
/* areg ln_enr_all_mid_g ebb_dummy year ebb_year ln_pc01_pca_tot_p, absorb(pc01_state_id)                           */
/* areg ln_enr_all_mid_b ebb_dummy year ebb_year ln_pc01_pca_tot_p, absorb(pc01_state_id)                           */
/* areg ln_enr_all_mid_g ebb_dummy year ebb_year ln_pc01_pca_tot_p, -0.1, 0.1), absorb(pc01_state_id)               */
/* areg ln_enr_all_mid_b ebb_dummy year ebb_year ln_pc01_pca_tot_p, absorb(pc01_state_id)                           */
/********************************************************************************************************************/

