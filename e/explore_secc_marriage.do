/**************************************************/
/* EXPLORES SECC11 MARRIAGE RATES BY BIRTH COHORT */
/**************************************************/

/************************************************/
/* Generate Avg. Marriage Rates by Birth Cohort */
/************************************************/

/* open birth cohort marriage data */
use $ebb/secc_block_marriage.dta, clear

/* add global for reshaping */
global stubs secc11_evermarried_f secc11_evermarried_f_sc secc11_evermarried_f_st secc11_evermarried_m secc11_evermarried_m_sc secc11_evermarried_m_st

/* reshape long */
reshape long $stubs, i(pc01_state_id pc01_district_id pc01_block_id) j(age)

/* save temporary reshaped version */
save $tmp/secc_block_marriage_long, replace

/* collapse to national level */
collapse $stubs, by(age)

/* convert age to birth cohort */
gen bc = 2012 - age
label var bc "Birth Cohort"
drop age

/* graph */
graph twoway scatter secc11_evermarried_f bc, ytitle("All Girls") xtitle("") name(fm, replace)
graph twoway scatter secc11_evermarried_f_sc bc, ytitle("SC Girls") xtitle("") name(fscm, replace)
graph twoway scatter secc11_evermarried_f_st bc, ytitle("ST Girls") xtitle("") name(fstm, replace)

graph combine fm fscm fstm
graphout f_marriage_combined

/**********************/
/* Clean Data for RDs */
/**********************/

use $ebb/secc_block_marriage.dta, clear

/* winsorize marriage rates at 1st/99th percentiles */
foreach v of varlist secc11* {
  di "Winsorizing `v'..."
  qui winsorize `v' 1 99, centile replace
}

/* merge ebb list */
merge 1:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/ebbs_list_clean, ///
    keepusing(pc01_pca_f_lit_rate ebb_dummy pc01_pca_tot_p)
keep if _merge == 3
drop _merge

/* get number of operational kgbvs */
merge 1:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/kgbvs_list_clean, keepusing(kgbvs_operational)
keep if _merge == 3
drop _merge

/* center lit rate at zero */
replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - .4613
gen treatment  = pc01_pca_f_lit_rate < 0
gen lit_right = pc01_pca_f_lit_rate * treatment
gen ln_pc01_pca_tot_p = ln(pc01_pca_tot_p)

/*******************/
/* Run Initial RDs */
/*******************/

rd secc11_evermarried_f27 pc01_pca_f_lit_rate, ///
    absorb(pc01_state_id) control(ln_pc01_pca_tot_p) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Marriage Rates for Women (Age 27)")
gr save $tmp/27f.gph, replace
rd secc11_evermarried_m27 pc01_pca_f_lit_rate, ///
    absorb(pc01_state_id) control(ln_pc01_pca_tot_p) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Marriage Rates for Men (Age 27)")
gr save $tmp/27m.gph, replace

graph combine $tmp/27f.gph $tmp/27m.gph, title("RD of Marriage Rate for 27 Year-Olds")
graphout 27secc

/*********************************/
/* Regress Data for RD Estimates */
/*********************************/

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id 

/* recode KGBV to school presence */
winsorize kgbvs_operational 0 1, gen(kg)

/* store RD estimates on marriage */

/* clear output file and put in header */
global f $tmp/secc_ests.csv
cap erase $f
append_to_file using $f, s(b, se, p, n, est, age)

/* loop over age cohorts 5-30 */
forval age = 5/30 {
  
  quireg secc11_evermarried_f`age' treatment pc01_pca_f_lit_rate lit_right ///
      if inrange(pc01_pca_f_lit_rate, -.08, .08), absorb(sgroup)
  append_est_to_file using $f, b(treatment) s(marriage-g,`age')

  quireg secc11_evermarried_m`age' treatment pc01_pca_f_lit_rate lit_right ///
      if inrange(pc01_pca_f_lit_rate, -.08, .08), absorb(sgroup)
  append_est_to_file using $f, b(treatment) s(marriage-b,`age')

}

/****************************/
/* Graph Regression Results */
/****************************/

import delimited using $f, clear

/* create beta confidence interval */
gen b_up = b + 1.96 * se
gen b_down = b - 1.96 * se

/* convert age to birth cohort */
gen bc = 2012 - age
label var bc "Birth Cohort"

/* marriage RD by age cohort */
twoway ///
    (rcap b_up b_down bc if est == "marriage-g") (scatter b bc if est == "marriage-g"), ///
    title("Girls RD Estimate") legend(off) ylabel(-.02(.02)0.06)  name(mg, replace)
graphout rd_marriage_g

twoway ///
    (rcap b_up b_down bc if est == "marriage-b") (scatter b bc if est == "marriage-b"), ///
    title("Boys RD Estimate") legend(off) name(mb, replace)
graphout rd_marriage_b

/* combine panels */
graph combine mg mb, title("Marriage Rates by Age Cohort")
graphout combined_marriage
