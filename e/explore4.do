/* use ec-pc01-ebb dataset */
use $iec/flfp/ec_pc01_ebb, clear

/* generate log emp count vars */
foreach var in emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
  gen ln_`var' = ln(`var')
}

/* drop gender gap obs to compare only with f lit rate */
drop if pc01_pca_lit_gender_gap < 0.2159

/* normalize running variable */
replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - 0.4613

/* create a treatment variable for the RD */
gen treatment_lit = pc01_pca_f_lit_rate < 0

/* create a right side slope for the RD estimation */
gen lit_right = pc01_pca_f_lit_rate * treatment_lit

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id
 
/* generate and save RD graphs */

foreach var in emp_f count_f emp_f_owner {
    foreach i in 1998 2005 2013 {
    rd ln_`var' pc01_pca_f_lit_rate if year == `i' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), ///
      bw degree(1) ylabel(6(.5)9) xtitle("Female Literacy Rate") ytitle("Log `var'") ///
      title(`var'_`i') bins(50) name(`var'_`i') nodraw
  local graphs_`var' "`graphs_`var'' `var'_`i'"
}
  gr combine `graphs_`var'', title(Reduced Form - `var')
  graphout `var'
}




  /*
gr combine `graphs_emp_f', title(Reduced Form - Log Female Employment)
graphout emp_f_ebb




/* regression */

foreach y in 1990 1998 2005 2013 {
  quireg ln_emp_f treatment pc01_pca_f_lit_rate lit_right if year == `y' ///
 & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), cluster(sdgroup) title(`y') absorb(sgroup)
}
