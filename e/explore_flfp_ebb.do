/* use ec-pc01-ebb dataset */
use $iec/flfp/ec_pc01_ebb, clear

/* drop extremes */
drop if emp_f == 0
drop if emp_f > 40000
drop if emp_f < 10

/* gen fshare var */
gen fshare = emp_f/(emp_m+emp_f)

/* drop gender gap obs to compare only with f lit rate */
drop if pc01_pca_lit_gender_gap < 0.2159

/* normalize running variable */
replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - 0.4613

/* create a treatment variable for the RD */
gen treatment_lit = pc01_pca_f_lit_rate < 0

/* create a right side slope for the RD estimation */
gen lit_right = pc01_pca_f_lit_rate * treatment_lit

/* create var that ideintifies blocks with all years of data */
bysort pc01_state_name pc01_district_name pc01_block_name: egen all_years = count(year)

/* create var that idenitifes it it is a non-m&l block */
gen non_ml = (mi(npegel))

/* generate log emp count vars */
foreach var in fshare emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
  gen ln_`var' = ln(`var' + 1)
}

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id

/* set local for variables */
local emp_f "Female Employment"
local count_f "Female Owned Firms"
local emp_f_owner "Emp. in Female Firms"

/*
/* generate and save RD graphs */

foreach var in emp_f count_f emp_f_owner {
    foreach i in 1998 2005 2013 {
    rd ln_`var' pc01_pca_f_lit_rate if year == `i' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), ///
      bw degree(1) ylabel(6(.5)9) xtitle("Female Literacy Rate") ytitle(Log ``var'') ///
      title(`i') bins(50) name(`var'_`i') nodraw
    local graphs_`var' "`graphs_`var'' `var'_`i'"
}
gr combine `graphs_`var'', title(Reduced Form - ``var'') ycommon xcommon
graphout `var'
}
*/

/* regressions */

foreach var in emp_f count_f emp_f_owner {
  foreach y in 1998 2005 2013 {
    quireg ln_`var' treatment_lit pc01_pca_f_lit_rate lit_right popp if year == `y' ///
    & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), cluster(sdgroup) title(`var' in `y') absorb(sgroup)
}
}

/* regressions for m&l data which exists in all years */

foreach var in emp_f count_f emp_f_owner {
  foreach y in 1998 2005 2013 {
    quireg ln_`var' treatment_lit  pc01_pca_f_lit_rate lit_right popp if year == `y' ///
        & inrange(pc01_pca_f_lit_rate, -0.1, 0.1) & all_years == 4 & non_ml == 0 ///
        , cluster(sdgroup) title(`var' in `y') absorb(sgroup)
}
}
