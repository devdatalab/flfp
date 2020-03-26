/************************/
/* Graph FLFP by Region */
/************************/

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
gen str region = "total"

/* merge with region-level dataset */
append using $flfp/ec_flfp_region_level.dta

/* save new dataset with national averages */
save $tmp/flfp_regional_analysis.dta, replace

/************************************/
/* B) Female employment share graph */
/************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* graph the relationship between year and female employment share, by region */
twoway (scatter emp_f_share year if region == "total", mcolor(black)) ///
	(scatter emp_f_share year if region == "hilly", mcolor(red)) ///
	(scatter emp_f_share year if region == "south", mcolor(blue)) ///
	(scatter emp_f_share year if region == "northeast", mcolor(green)) ///
	(scatter emp_f_share year if region == "north", mcolor(orange)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("emp_f_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 India (Total)) label(2 Hilly) label(3 South) ///
	label(4 Northeast) label(5 North)) ///
	title(Female Employment Share by Region)
	
/* export graph to temporary files */
graphout emp_f_share_regional_graph


/**********************************************/
/* C) Female employment ownership share graph */
/**********************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* drop 1990, since f_emp_owner was not a variable in that dataset */
drop if year==1990

/* graph the relationship between year and female employment ownership share, by region */
twoway (scatter emp_owner_f_share year if region == "total", mcolor(black)) ///
	(scatter emp_owner_f_share year if region == "hilly", mcolor(red)) ///
	(scatter emp_owner_f_share year if region == "south", mcolor(blue)) ///
	(scatter emp_owner_f_share year if region == "northeast", mcolor(green)) ///
	(scatter emp_owner_f_share year if region == "north", mcolor(orange)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("emp_owner_f_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 India (Total)) label(2 Hilly) label(3 South) ///
	label(4 Northeast) label(5 North)) ///
	title(Female Employment Ownership Share by Region)
	
/* export graph to temporary files */
graphout emp_f_ownership_share_regional_graph

/******************************************/
/* D) Female employment count share graph */
/******************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* drop 1990, since f_count was not a variable in that dataset */
drop if year==1990

/* graph the relationship between year and female employment ownership share, by region */
twoway (scatter count_f_share year if region == "total", mcolor(black)) ///
	(scatter count_f_share year if region == "hilly", mcolor(red)) ///
	(scatter count_f_share year if region == "south", mcolor(blue)) ///
	(scatter count_f_share year if region == "northeast", mcolor(green)) ///
	(scatter count_f_share year if region == "north", mcolor(orange)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("count_f_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 India (Total)) label(2 Hilly) label(3 South) ///
	label(4 Northeast) label(5 North)) ///
	title(Female Employment Count Share by Region)
	
/* export graph to temporary files */
graphout count_f_share_regional_graph
