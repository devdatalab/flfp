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
    if ebb_dummy == 1, mcolor(black) msize(tiny)) ///
    (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if ebb_dummy == 0, mcolor(gs8) msize(tiny)), ///
    graphregion(color(white)) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Gender Gap in Rural Literacy") ///
    ylabel(, angle(0) format(%9.2f) nogrid) ///
    legend(off) ///
    xline(.4613, lcolor(black)) ///
    yline(.2159, lcolor(black)) ///
    ylabel(-0.2 0 0.2 0.4 0.6) ///
    title(NPEGEL/KGBV Eligibility of Rural Blocks) ///
    name(firststagerd, replace)

/* export graph */
graphout firststagerd

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
    name(litraterd, replace)

/* export combined graph */
graphout litraterd

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
    name(female_lit_hist, replace)

/* export graph */
graphout female_lit_hist

/**********/
/* Fig. 6 */
/**********/
