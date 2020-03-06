/************************/
/* Graph FLFP by Region */
/************************/

/* A) Merge country-level averages to regional dataset */
/* B) Female employment share graph */
/* C) Female employment ownership share graph */

/*******************************************************/
/* A) Merge country-level averages to regional dataset */
/*******************************************************/

/* open country-wide dataset */
use $flfp/ec_flfp_country_level.dta, clear

/* create regional variable */
gen region = 0

/* merge with region-level dataset */
merge m:1 region using $flfp/ec_flfp_region_level.dta

/* save new dataset with national averages */
save $tmp/flfp_regional_analysis.dta, replace

/************************************/
/* B) Female employment share graph */
/************************************/

/* graph the relationship between year and female employment share, by region */
twoway (scatter f_emp_share year if region == 0, mcolor(black)) ///
	(scatter f_emp_share year if region == 1, mcolor(red)) ///
	(scatter f_emp_share year if region == 2, mcolor(blue)) ///
	(scatter f_emp_share year if region == 3, mcolor(green)) ///
	(scatter f_emp_share year if region == 4, mcolor(orange)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("f_emp_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 India (Total)) label(2 North) label(3 South) ///
	label(4 North-East) label(5 Central))

/**********************************************/
/* C) Female employment ownership share graph */
/**********************************************/

/* drop 1990, since f_emp_owner_share was not a variable in that dataset */
drop if year==1990

/* graph the relationship between year and female employment ownership share, by region */
twoway (scatter f_emp_owner_share year if region == 0, mcolor(black)) ///
	(scatter f_emp_owner_share year if region == 1, mcolor(red)) ///
	(scatter f_emp_owner_share year if region == 2, mcolor(blue)) ///
	(scatter f_emp_owner_share year if region == 3, mcolor(green)) ///
	(scatter f_emp_owner_share year if region == 4, mcolor(orange)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("f_emp_owner_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 India (Total)) label(2 North) label(3 South) ///
	label(4 North-East) label(5 Central))
