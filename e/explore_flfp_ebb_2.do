/* use ec-pc01-ebb dataset */
use $iec/flfp/ec_pc01_ebb, clear

/* generate log emp count vars */
foreach var in emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
  gen ln_`var' = ln(`var' + 1)
}
drop if (emp_m + emp_f)/(pc01_pca_tot_p) > 0.5
/***************************************************************/
/* /\* drop gender gap obs to compare only with f lit rate *\/ */
/* drop if pc01_pca_lit_gender_gap < 0.2159                    */
/***************************************************************/

/* normalize running variable */
replace pc01_pca_lit_gender_gap = pc01_pca_lit_gender_gap - 0.2159

/* create a treatment variable for the RD */
gen treatment_lit = pc01_pca_lit_gender_gap < 0

/* create a right side slope for the RD estimation */
gen lit_right = pc01_pca_lit_gender_gap * treatment_lit

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id
 
/* generate and save RD graphs */

foreach var in emp_f count_f emp_f_owner {
    foreach i in 1998 2005 2013 {
    rd ln_`var' pc01_pca_lit_gender_gap if year == `i', ///
      bw degree(1) xtitle("Literacy Gap") ytitle("Log `var'") ///
      title(`var'_`i') bins(50) name(`var'_`i') nodraw
    local graphs_`var' "`graphs_`var'' `var'_`i'"
}
gr combine `graphs_`var'', title(Reduced Form - `var')
graphout `var'
}

/* regressions */

foreach var in emp_f count_f emp_f_owner {
  foreach y in 1990 1998 2005 2013 {
    quireg ln_`var' treatment pc01_pca_lit_gender_gap lit_right if year == `y', ///
        cluster(sdgroup) title(`var' in `y') absorb(sgroup)
}
}
