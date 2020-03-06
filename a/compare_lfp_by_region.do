/*********************************/
/* Graph FLFP vs. MLFP by Region */
/*********************************/

/* A) Merge country-level averages to regional dataset */
/* B) Female employment share graph */
/* C) Female employment ownership share graph */
/* D) Female employment count share graph */

/*******************************************************/
/* A) Merge country-level averages to regional dataset */
/*******************************************************/

/* open country-wide dataset */
use $flfp/ec_flfp_country_level.dta, clear

/* create regional variable */
gen region = 0

/* merge with region-level dataset */
append using $flfp/ec_flfp_region_level.dta

/* generate mlfp statistics */
gen emp_m_share = emp_m/(emp_f + emp_m)
gen count_m_share = count_m/(count_f + count_m)
gen emp_owner_m_share = emp_m_owner/(emp_m_owner + emp_f_owner)

/* save new dataset with national averages */
save $tmp/flfp_regional_analysis.dta, replace

/****************************************/
/* D) Female vs. male employment graph  */
/****************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* graph the relationships of mlfp and flfp in each region */
forvalues y = 0/4 {
	twoway (scatter emp_f_share year if region == 'y', mcolor(blue)) ///
	(scatter emp_m_share year if region == 'y', mcolor(red)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("emp_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 emp_f_share) label(2 emp_m_share))
}

/* combine graphs */
