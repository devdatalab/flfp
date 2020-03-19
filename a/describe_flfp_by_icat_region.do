/*********************************/
/* Graph FLFP by ICAT and Region */
/*********************************/

/* A) Merge country-level averages to regional dataset */
/* B) Female employment share graph  */
/* C) Female ownership share graph  */
/* D) Female =employment count share graph */

/*******************************************************/
/* A) Merge country-level averages to regional dataset */
/*******************************************************/

/* open country-wide ICAT dataset */
use $flfp/ec_flfp_icat_india.dta, clear

/* create national region variable */
gen region = "total"

/* merge with region-level dataset */
append using $flfp/ec_flfp_icat_regional.dta

/* generate share variables */
gen emp_f_share = emp_f/(emp_f + emp_m)
gen count_f_share = count_f/(count_f + count_m)
gen emp_owner_f_share = emp_f_owner/(emp_m_owner + emp_f_owner)

/* save new dataset with national averages */
save $tmp/flfp_regional_analysis.dta, replace

/*************************************/
/* B) Female employment share graph  */
/*************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* creates rmax() for loop */
levelsof region, local(regionlevels)

/* not totally sure what this does, but it leaves behind rmax() for the next step */
su icat, meanonly 

/* loop across each region for each ICAT */
forvalues i = 1/`r(max)' {
foreach 1 of local regionlevels {
	twoway scatter emp_f_share year if region == "`1'" & icat == `i', ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("f_emp_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(off) ///
	title("`1'")
	graph save "`1'_regional_flfp", replace
}
	graph combine total_regional_flfp.gph north_regional_flfp.gph south_regional_flfp.gph ///
	north-east_regional_flfp.gph central_regional_flfp.gph, ///
	ycommon xcommon ///
	title(Female Employment Share in `i' by Region)
	
	graph export $tmp/`i'_flfp_share_regional_graph.png, replace
}

/************************************/
/* B) Female ownership share graph  */
/************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* create local levels variables for loops */
levelsof region, local(regionlevels)

/* creates rmax() for loop */
su icat, meanonly 

/* loop across each region for each ICAT */
forvalues i = 1/`r(max)' {
foreach 1 of local regionlevels {
	twoway scatter emp_owner_f_share year if region == "`1'" & icat == `i', ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("emp_owner_f_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(off) ///
	title("`1'")
	graph save "`1'_regional_flfp", replace
}
	graph combine total_regional_flfp.gph north_regional_flfp.gph south_regional_flfp.gph ///
	north-east_regional_flfp.gph central_regional_flfp.gph, ///
	ycommon xcommon ///
	title(Female Ownership Share in `i' by Region)
	
	graph export $tmp/`i'_ownership_flfp_share_regional_graph.png, replace
}

/******************************************/
/* D) Female employment count share graph */
/******************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* create local levels variables for loops */
levelsof region, local(regionlevels)

/* creates rmax() for loop */
su icat, meanonly 

/* loop across each region for each ICAT */
forvalues i = 1/`r(max)' {
foreach 1 of local regionlevels {
	twoway scatter count_f_share year if region == "`1'" & icat == `i', ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("count_f_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(off) ///
	title("`1'")
	graph save "`1'_regional_flfp", replace
}
	graph combine total_regional_flfp.gph north_regional_flfp.gph south_regional_flfp.gph ///
	north-east_regional_flfp.gph central_regional_flfp.gph, ///
	ycommon xcommon ///
	title(Female Count Share in `i' by Region)
	
	graph export $tmp/`i'_count_flfp_share_regional_graph.png, replace
}
