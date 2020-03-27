/*********************************/
/* Graph FLFP by ICAT and Region */
/*********************************/

/* A) Merge country-level averages to regional dataset */
/* B) Create FLFP, ICAT, regional graphs */

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
gen emp_f_share = emp_f / (emp_f + emp_m)
gen count_f_share = count_f / (count_f + count_m)
gen emp_owner_f_share = emp_f_owner / (emp_m_owner + emp_f_owner)

/* save new dataset with national averages */
save $tmp/flfp_regional_analysis.dta, replace

/*****************************************/
/* B) Create FLFP, ICAT, regional graphs */
/*****************************************/

/* open dataset */
use $tmp/flfp_regional_analysis.dta, clear

/* loops over FLFP variables */
foreach y in emp_f_share emp_owner_f_share count_f_share {

  /* creates rmax() for ICAT loop */
  su icat, meanonly

  /* loops over ICATs */
  forvalues i = 1/`r(max)' {

    /* sets local for ICAT labeling in combined graphs */
    local v : label (icat) `i'

      /* graphs FLFP variable against year by region in a certain icat */
      twoway ///
	  (line `y' year if region == "total" & icat == `i', lcolor(black)) ///
	  (line `y' year if region == "hilly" & icat == `i', lcolor(red)) ///
	  (line `y' year if region == "south" & icat == `i', lcolor(blue)) ///
	  (line `y' year if region == "northeast" & icat == `i', lcolor(green)) ///
	  (line `y' year if region == "north" & icat == `i', lcolor(orange)), ///
          graphregion(color(white)) ///
          xtitle("Year") ytitle("`y'") ///
          ylabel(, angle(0) format(%9.2f) nogrid) ///
          legend(label(1 India (Total)) label(2 Hilly) label(3 South) ///
		  label(4 Northeast) label(5 North)) ///
		  title("`v'")
		  
	/* saves graphs */
	graphout `i'_`y'_regional_graph
}

}
