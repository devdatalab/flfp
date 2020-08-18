/****************************/
/* RD plots of DISE by year */
/****************************/

use $iec/dise/dise_basic_clean, clear
merge m:1 dise_state year vilcd schcd using $iec/dise/dise_enr_clean
keep if _merge == 3
drop _merge

merge m:1 dise_state district dise_block_name using $ebb/pc01_dise_key
drop _merge



/* create middle school enr and log enrollment */
egen enr_up_b = rowtotal(enr_all_b6 enr_all_b7 enr_all_b8 )
egen enr_up_g = rowtotal(enr_all_g6 enr_all_g7 enr_all_g8 )
gen ln_enr_up_b = ln(enr_up_b + 1)
gen ln_enr_up_g = ln(enr_up_g + 1)

/* loop over all years */
forval y = 2003/2008 {
  rd ln_enr_up_g pc01_pca_f_lit_rate if year == `y' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), bw degree(1) ylabel(6(.5)9)
  graphout ln_enr_g_`y'

  rd ln_enr_up_b pc01_pca_f_lit_rate if year == `y' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), bw degree(1) ylabel(6(.5)9)
  graphout ln_enr_b_`y'
}

/* create a treatment variable for the RD */
gen treatment = pc01_pca_f_lit_rate < 0

/* create a right side slope for the RD estimation */
gen lit_right = pc01_pca_f_lit_rate * treatment

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id 

/* GIRLS */
forval y = 2003/2008 {
  quireg ln_enr_up_g treatment pc01_pca_f_lit_rate lit_right if year == `y' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), absorb(sgroup) cluster(sdgroup) title(`y')
}

/* BOYS */
forval y = 2003/2008 {
  quireg ln_enr_up_b treatment pc01_pca_f_lit_rate lit_right if year == `y', cluster(sdgroup) absorb(sgroup)
}

/******************************************/
/* study RD on enrollment by birth cohort */
/******************************************/

/* open birth cohort education */
use $ebb/secc_block_ed_age_clean, clear
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* winsorize school enrollment at 1st/99th percentiles */
foreach v of varlist *primary* *middle* {
  di "Winsorizing `v'..."
  qui winsorize `v' 1 99, centile replace
}

/* merge ebb list */
merge 1:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/ebbs_list_clean, keepusing(pc01_pca_f_lit_rate ebb_dummy)
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

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id 

/* recode KGBV to school presence */
winsorize kgbvs_operational 0 1, gen(kg)

/* kgbv first stage with various fixed effects */
quireg kg treatment pc01_pca_f_lit_rate lit_right if inrange(pc01_pca_f_lit_rate, -.08, .08)
quireg kg treatment pc01_pca_f_lit_rate lit_right if inrange(pc01_pca_f_lit_rate, -.08, .08), absorb(sgroup)
quireg kg treatment pc01_pca_f_lit_rate lit_right if inrange(pc01_pca_f_lit_rate, -.08, .08), absorb(sdgroup)

/* store RD estimates on enrollment share for primary and middle school */

/* clear output file and put in header */
global f $tmp/secc_ests.csv
cap erase $f
append_to_file using $f, s(b, se, p, n, est, age)

/* loop over age cohorts 5-30 */
forval age = 5/30 {

  /* estimate impact on primary completion */
  quireg secc11_primary_f_st`age' treatment pc01_pca_f_lit_rate lit_right if inrange(pc01_pca_f_lit_rate, -.08, .08), absorb(sgroup)
  append_est_to_file using $f, b(treatment) s(primary-g,`age')
  
  /* estimate impact on middle completion */
  quireg secc11_middle_f_st`age' treatment pc01_pca_f_lit_rate lit_right if inrange(pc01_pca_f_lit_rate, -.08, .08), absorb(sgroup)
  append_est_to_file using $f, b(treatment) s(middle-g,`age')

  /* repeat estimates for boys */
  quireg secc11_primary_m_st`age' treatment pc01_pca_f_lit_rate lit_right if inrange(pc01_pca_f_lit_rate, -.08, .08), absorb(sgroup)
  append_est_to_file using $f, b(treatment) s(primary-b,`age')
  quireg secc11_middle_m_st`age' treatment pc01_pca_f_lit_rate lit_right if inrange(pc01_pca_f_lit_rate, -.08, .08), absorb(sgroup)
  append_est_to_file using $f, b(treatment) s(middle-b,`age')
}

/********************************************/
/* import the results file and make a graph */
/********************************************/
import delimited using $f, clear

/* create beta confidence interval */
gen b_up = b + 1.96 * se
gen b_down = b - 1.96 * se

/* convert age to birth cohort */
gen bc = 2012 - age
label var bc "Birth Cohort"

/* primary school completion RD by age cohort */
twoway ///
    (rcap b_up b_down bc if est == "primary-g") (scatter b bc if est == "primary-g"), ///
    title("Primary Girls RD Estimate") legend(off) name(pg, replace)
graphout rd_primary_g

/* middle school completion RD by age cohort */
twoway ///
    (rcap b_up b_down bc if est == "middle-g") (scatter b bc if est == "middle-g"), ///
    title("Middle Girls RD Estimate") legend(off) name(mg, replace)
graphout rd_middle_g

/* repeat for boys */
twoway ///
    (rcap b_up b_down bc if est == "primary-b") (scatter b bc if est == "primary-b"), ///
    title("Primary Boys RD Estimate") legend(off) name(pb, replace)
graphout rd_primary_b
twoway ///
    (rcap b_up b_down bc if est == "middle-b") (scatter b bc if est == "middle-b"), ///
    title("Middle Boys RD Estimate") legend(off) name(mb, replace)
graphout rd_middle_b

/* combine the four panels */
graph combine pg pb mg mb, title("Scheduled Tribe")
graphout combined_st
