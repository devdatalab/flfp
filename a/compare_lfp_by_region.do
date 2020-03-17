/*********************************/
/* Graph FLFP vs. MLFP by Region */
/*********************************/

/* A) Merge country-level averages to regional dataset */
/* B) Female vs. male employment share graph  */
/* C) Female vs. male employment ownership share graph  */
/* D) Female vs. male employment count share graph */

/*******************************************************/
/* A) Merge country-level averages to regional dataset */
/*******************************************************/

/* open country-wide dataset */
use $flfp/ec_flfp_country_level.dta, clear

/* create regional variable */
gen region = "total"

/* merge with region-level dataset */
append using $flfp/ec_flfp_region_level.dta

/* generate mlfp statistics */
gen emp_m_share = emp_m/(emp_f + emp_m)
gen count_m_share = count_m/(count_f + count_m)
gen emp_owner_m_share = emp_m_owner/(emp_m_owner + emp_f_owner)

/* save new dataset with national averages */
save $tmp/flfp_regional_analysis.dta, replace

/**********************************************/
/* B) Female vs. male employment share graph  */
/**********************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* create levels so the loop will work across "region" (a string variable) */
levelsof region, local(levels)

/* loop over the levels of region */
foreach 1 of local levels {
	twoway (scatter emp_f_share year if region == "`1'", mcolor(blue)) ///
	(scatter emp_m_share year if region == "`1'", mcolor(red)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("emp_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 female) label(2 male)) ///
	title("`1'")
	graph save "`1'_regional_lfp", replace
}

/* combine graphs */
grc1leg total_regional_lfp.gph north_regional_lfp.gph south_regional_lfp.gph ///
north-east_regional_lfp.gph central_regional_lfp.gph, ///
legendfrom(total_regional_lfp.gph) ///
ycommon xcommon ///
title(Male Employment Share vs. Female Employment Share by Region)

/* export graph */
graph export $tmp/emp_share_comparison_regional_graph.png, replace

/********************************************************/
/* C) Female vs. male employment ownership share graph  */
/********************************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* drop 1990, since f_emp_owner was not a variable in that dataset */
drop if year==1990

/* create levels so the loop will work across "region" (a string variable) */
levelsof region, local(levels)

/* graph lfp loop over the levels of region */
foreach 1 of local levels {
	twoway (scatter emp_owner_f_share year if region == "`1'", mcolor(blue)) ///
	(scatter emp_owner_m_share year if region == "`1'", mcolor(red)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("emp_owner_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 female) label(2 male)) ///
	title("`1'")
	graph save "`1'_regional_lfp", replace
}

/* combine graphs */
grc1leg total_regional_lfp.gph north_regional_lfp.gph south_regional_lfp.gph ///
north-east_regional_lfp.gph central_regional_lfp.gph, ///
legendfrom(total_regional_lfp.gph) ///
ycommon xcommon ///
title("Male Employment Share vs. Female Employment" "Ownership Share by Region")

/* export graph */
graph export $tmp/emp_ownership_share_comparison_regional_graph.png, replace

/****************************************************/
/* D) Female vs. male employment count share graph  */
/****************************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* drop 1990, since f_emp_owner was not a variable in that dataset */
drop if year==1990

/* create levels so the loop will work across "region" (a string variable) */
levelsof region, local(levels)

/* loop over the levels of region */
foreach 1 of local levels {
	twoway (scatter count_f_share year if region == "`1'", mcolor(blue)) ///
	(scatter count_m_share year if region == "`1'", mcolor(red)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("count_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 female) label(2 male)) ///
	title("`1'")
	graph save "`1'_regional_lfp", replace
}

/* combine graphs */
grc1leg total_regional_lfp.gph north_regional_lfp.gph south_regional_lfp.gph ///
north-east_regional_lfp.gph central_regional_lfp.gph, ///
legendfrom(total_regional_lfp.gph) ///
ycommon xcommon ///
title("Male Employment Share vs. Female Employment" "Count Share by Region")

/* export graph */
graph export $tmp/count_share_comparison_regional_graph.png, replace
