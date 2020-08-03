/**********************************/
/* Prepare SECC Data for Graphing */
/**********************************/

/* open dataset */
use $ebb/secc_block_ed_age_clean.dta, clear

/* merge with EBBs list */
merge 1:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/treated_list_clean

/* reshape to allow graphs with age as axis */
reshape long secc11_educ_years_m secc11_educ_years_m_sc secc11_educ_years_m_st ///
    secc11_educ_years_f secc11_educ_years_f_sc secc11_educ_years_f_st ///
    secc11_lit_m secc11_lit_m_sc secc11_lit_m_st ///
    secc11_lit_f secc11_lit_f_sc secc11_lit_f_st ///
    secc11_primary_m secc11_primary_m_sc secc11_primary_m_st ///
    secc11_primary_f secc11_primary_f_sc secc11_primary_f_st ///
    secc11_middle_m secc11_middle_m_sc secc11_middle_m_st ///
    secc11_middle_f secc11_middle_f_sc secc11_middle_f_st ///
    pc01_pca_f_st_ pc01_pca_f_sc_ pc01_pca_m_st_ pc01_pca_m_sc_, ///
    i(pc01_state_id pc01_district_id pc01_block_id treated_dummy pc01_pca_tot_p) j(age)

/* collapse to age level, since the plots are national */
collapse (mean) m_educ_years m_lit m_primary m_middle f_educ_years f_lit f_primary ///
    f_middle (sum) pc01_pca_tot_p [w = pc01_pca_tot_p], ///
    by(age kgbv_treatment_dummy)

/* save dataset */
save $tmp/collapsed_secc_pc01, replace

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

/**************************************/
/* RD with UP Attainment (Binscatter) */
/**************************************/

/* open dataset */
use $tmp/collapsed_secc_pc01, clear

/* loop through either sex and treatment dummy and generate RDs */
foreach sex in m f {
  foreach dummy in 1 0 {
    binscatter `sex'_middle age ///
        if kgbv_treatment == `dummy'  & age > 10 & age < 30 ///
        & `sex'_middle > 0.2, ///
        absorb(pc01_state_id) controls(ln_pc01_pca_tot_p) ///
        rd(15) linetype(none) ///
        title(`sex' Enrollment `dummy', size(medlarge)) ///
        xtitle(Age) ///
        ytitle(% Attended Upper Primary) ///
        ylabel(0.2(0.2)0.8) ///
        ytick(0.2(0.1)0.8) ///
        xlabel(10(5)30) ///
        xtick(10(1)30) ///
        xline(15, lcolor(black) lwidth(medthick)) ///
        mcolor(maroon) msymbol(circle) ///
        lcolor(black) ///
        name(secc_rd_`sex'_`dummy', replace)
  }
}

/* combine four graphs */
graph combine secc_rd_f_0 secc_rd_f_1 secc_rd_m_0 secc_rd_m_1, ///
    xsize(8) ysize(10) ///
    title("Upper Primary Enrollment and KGBV Treatment" "(SECC-2011)", size(medlarge)) ///
    note("Includes block-level population control and state-level fixed effects") ///
    name(secc_rd, replace)

/* export graph */
graphout secc_rd

/***************/
/* Regressions */
/***************/

/* open dataset */
use $ebb/secc_block_ed_age_clean.dta, clear

/* merge with EBBs list */
merge 1:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/kgbvs_list_clean

/* reshape to allow graphs with age as axis */
reshape long m_educ_years m_lit m_primary m_middle f_educ_years f_lit f_primary ///
    f_middle, i(pc01_state_id pc01_district_id pc01_block_id ebb_dummy ///
    pc01_pca_tot_p pc01_pca_f_lit_rate pc01_pca_m_lit_rate) j(age)

keep if age == 15 | age == 16

gen ln_pc01_pca_tot_p = ln(pc01_pca_tot_p)

drop if pc01_pca_f_lit_rate < .4213 | pc01_pca_f_lit_rate > .5013

rd f_middle pc01_pca_f_lit_rate, ///
    degree(2) bins(50) start(-.1) end(.1) ///
    absorb(pc01_state_id) control(ln_pc01_pca_tot_p)

gr save $tmp/secc_f_lit.gph, replace

graphout $tmp/secc_f_lit.gph
