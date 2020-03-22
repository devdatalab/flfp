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

/* creates rmax() for regional loop */
levelsof region, local(regionlevels)

/* loops over FLFP variables */
foreach y in emp_f_share emp_owner_f_share count_f_share {

  /* creates rmax() for ICAT loop */
  su icat, meanonly

  /* loops over ICATs */
  forvalues i = 1/`r(max)' {

    /* sets local for ICAT labeling in combined graphs */
    local v : label (icat) `i'

    /* loops over regions, using levels from earlier */
    foreach 1 of local regionlevels {

      /* scatters FLFP variable against year in a certain region & ICAT */
      twoway scatter `y' year if region == "`1'" & icat == `i', ///
          graphregion(color(white)) ///
          xtitle("Year") ytitle("`y'") ///
          ylabel(, angle(0) format(%9.2f) nogrid) ///
          legend(off) ///
          title("`1'")
      
      /* saves graph with regional name to allow for combining */
      graph save "`1'_regional_flfp", replace
    }

    /* combines regional graphs, with a common axis, titled with ICAT and FLFP variable */
    graph combine total_regional_flfp.gph north_regional_flfp.gph south_regional_flfp.gph ///
        northeast_regional_flfp.gph north_regional_flfp.gph, ///
        ycommon xcommon ///
        title("`v'" (`y'))
    
    // graph save $tmp/`i'_`y'_regional_graph.png, replace
    graphout `i'_`y'_regional_graph
  }
}
