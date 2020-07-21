/***************************************************/
/* REPLICATE FIGURES FROM MELLER & LITSCHIG (2015) */
/***************************************************/

/**********/
/* Fig. 3 */
/**********/

/* open dataset */
use $ebb/ebbs_list_clean, clear

/* graph a scatterplot with black dots representing EBBs
(based on ebbs_list.dta coding, rather than the raw qualification metrics) */
twoway (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if ebb_dummy == 0 & pc01_pca_lit_gender_gap >= 0 ///
    & pc01_pca_f_lit_rate <= 0.8, msymbol(Oh) mlwidth(vvthin) msize(vsmall) mlcolor(black)) ///
    (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if ebb_dummy == 1, msymbol(O) mcolor(black) msize(vsmall)) ///
    (scatteri .5 .3813 .2159 .3813, recast(line) lcolor(black) lpattern(shortdash)) ///
    (scatteri .5 .5413 .2159 .5413, recast(line) lcolor(black) lpattern(shortdash)) ///
    (scatteri .2159 .3813 .2159 .5413, recast(line) lcolor(black) lpattern(shortdash)) ///
    (scatteri .5 .3813 .5 .5413, recast(line) lcolor(black) lpattern(shortdash)), ///
    graphregion(color(white)) ///
    xsize(8) ysize(4.5) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Gender Gap in Rural Literacy") ///
    ylabel(, angle(0) format(%9.2f) nogrid) ///
    legend(off) ///
    xline(.4613, lcolor(black)) ///
    yline(.2159, lcolor(black)) ///
    ylabel(0(0.1)0.5) ///
    xlabel(0(0.2)0.8) ///
    ysc(reverse) ///
    title(NPEGEL/KGBV Eligibility of Rural Blocks) ///
    name(lit_rate_rd_scatter, replace)

/* export graph */
graphout lit_rate_rd_scatter

/***********/
/* Fig. 4a */
/***********/

/* open dataset */
use $ebb/ebbs_list_clean, clear

/* binscatter for literacy rate RD */
binscatter kgbv_treatment_dummy pc01_pca_f_lit_rate ///
    if pc01_pca_f_lit_rate >= 0.3813 & pc01_pca_f_lit_rate <= 0.5413, ///
    rd(0.4613) ///
    title(Program Participation) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Fraction of KGBV Blocks in Bin") ///
    xlabel(0.3813(0.02)0.5413) ///
    xtick(0.3813(0.01)0.5413) ///
    ylabel(0(0.2)1) ///
    ytick(0(0.05)1) ///
    xline(.4613, lcolor(black) lwidth(medthick)) ///
    mcolor(maroon) msymbol(circle) ///
    lcolor(black) ///
    name(lit_rate_rd_bin, replace)

/* export combined graph */
graphout lit_rate_rd_bin

/***********/
/* Fig. 4b */
/***********/

/* import EBB and PC01 merged dataset */
use $ebb/ebbs_list_clean, clear

/* graph frequency of literacy rate in the blocks */
histogram pc01_pca_f_lit_rate if kgbv_treatment_dummy == 1 & ///
    pc01_pca_f_lit_rate >= 0.3813 & pc01_pca_f_lit_rate <= 0.5413, ///
    freq bin(16) gap(20) ///
    title(Female Literacy Rate Prevalence by Block) ///
    ytitle("Number of Blocks in Bin") ///
    xtitle("Female Rural Literacy Rate") ///
    xlabel(0.3813(0.02)0.5413) ///
    xtick(0.3813(0.01)0.5413) ///
    xline(.4613, lcolor(black) lwidth(medthick)) ///
    fcolor(maroon) lcolor(black) ///
    name(lit_rate_rd_hist, replace)

/* export graph */
graphout lit_rate_rd_hist

/**********/
/* Fig. 6 */
/**********/

/* use dataset */
use $iec/flfp/dise_ebb_analysis_2, clear

/* gen RD graph for girls */
rd diff_total_g pc01_pca_f_lit_rate if year == 2003, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
    ytitle ("Change in Enrollment 2003 - 2008") ///
    title ("Girls- Change in Enrollment between 2003 and 2008")

/* export graph */
graphout girls0308

/* gen RD graph for boys */
rd diff_total_b pc01_pca_f_lit_rate if year == 2003, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Change in Enrollment 2003 - 2008") ///
      title ("Boys - Change in Enrollment between 2003 and 2008")

/* export graph */
graphout boys0308
