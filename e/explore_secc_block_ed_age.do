/**********************************/
/* Prepare SECC Data for Graphing */
/**********************************/

/* open dataset */
use $ebb/secc_block_ed_age_clean.dta, clear

/* merge with EBBs list */
merge 1:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/ebbs_list_clean

/* reshape to allow graphs with age as axis */
reshape long m_educ_years m_lit m_primary m_middle f_educ_years f_lit f_primary ///
    f_middle, i(pc01_state_id pc01_district_id pc01_block_id kgbv_treatment_dummy) j(age)

/* collapse to age level, since the plots are national */
collapse (mean) m_educ_years m_lit m_primary m_middle f_educ_years f_lit f_primary ///
    f_middle, by(age kgbv_treatment_dummy)

/****************/
/* Graph by Sex */
/****************/

/* graph each of the educational attainment variables for either sex */
foreach sex in m f {
  twoway (scatter `sex'_lit age, mfcolor(black)) ///
      (scatter `sex'_primary age, mcolor(gs8)) ///
      (scatter `sex'_middle age, mlcolor(black) mfcolor(white)), ///
      graphregion(color(white)) ///
      xtitle("Age") ///
      ytitle("Fraction of People") ///
      ylabel(, angle(0) format(%9.2f) nogrid) ///
      title(`sex') ///
      legend(label(1 "At least literate") ///
      label(2 "At least primary") ///
      label(3 "At least middle")) ///
      name(`sex'_educ_levels, replace)
}

/* combine the two graphs */
grc1leg m_educ_levels f_educ_levels, ycommon r(1) title(National Educational Attainment by Age) ///
    name(combined_educ_levels, replace)

/* export combined graph */
graphout combined_educ_levels

/******************************/
/* Graph by Sex and Treatment */
/******************************/

/* generate scatterplots split by sex and KGBV treatment */
forvalues treat = 0/1 {
  foreach sex in m f {
    twoway (scatter `sex'_lit age if kgbv_treatment_dummy == `treat', mfcolor(black)) ///
        (scatter `sex'_primary age if kgbv_treatment_dummy == `treat', mcolor(gs8)) ///
        (scatter `sex'_middle age if kgbv_treatment_dummy == `treat', mlcolor(black) mfcolor(white)), ///
        graphregion(color(white)) ///
        xtitle("Age") ///
        ytitle("Fraction of People") ///
        ylabel(, angle(0) format(%9.2f) nogrid) ///
        title(`sex' when treatment = `treat') ///
        legend(label(1 "At least literate") ///
        label(2 "At least primary") ///
        label(3 "At least middle")) ///
        name(`sex'_`treat'_educ_levels, replace)
  }
}

/* combine and export the male graph */
grc1leg m_0_educ_levels m_1_educ_levels, ///
    ycommon r(1) title(Educational Attainment and KGBV Treatment (Male)) ///
    name(male_treatment_educ_levels, replace)

graphout male_treatment_educ_levels

/* comboine and export the female graph */
grc1leg f_0_educ_levels f_1_educ_levels, ///
    ycommon r(1) title(Educational Attainment and KGBV Treatment (Female)) ///
    name(female_treatment_educ_levels, replace)

graphout female_treatment_educ_levels
