/***************************************************/
/* REPLICATE FIGURES FROM MELLER & LITSCHIG (2015) */
/***************************************************/

/************************/
/* Program Installation */
/************************/

/* program to generate descritpive statistics tables */
ssc install asdoc

/***********/
/* Table 4 */
/***********/

/* open dataset */
use $ebb/treated_list_clean, clear

/* sample restricted to blocks that meet gender gap lit rate restriction */
drop if pc01_pca_lit_gender_gap < .2159

/* regressions with varying buffer size around female lit rate discontinuity */
reg treated_dummy ebb_dummy ///
    if pc01_pca_f_lit_rate > .4413 & pc01_pca_f_lit_rate < .4813
estimates store reg1

reg treated_dummy ebb_dummy pc01_pca_lit_gender_gap ///
    if pc01_pca_f_lit_rate > .4413 & pc01_pca_f_lit_rate < .4813
estimates store reg2

reg treated_dummy ebb_dummy ///
    if pc01_pca_f_lit_rate > .4213 & pc01_pca_f_lit_rate < .5013
estimates store reg3

reg treated_dummy ebb_dummy pc01_pca_lit_gender_gap ///
    if pc01_pca_f_lit_rate > .4213 & pc01_pca_f_lit_rate < .5013
estimates store reg4

reg treated_dummy ebb_dummy ///
    if pc01_pca_f_lit_rate > .4013 & pc01_pca_f_lit_rate < .5213
estimates store reg5

reg treated_dummy ebb_dummy pc01_pca_lit_gender_gap ///
    if pc01_pca_f_lit_rate > .4213 & pc01_pca_f_lit_rate < .5013
estimates store reg6

reg kgbvs_approved ebb_dummy ///
    if pc01_pca_f_lit_rate > .3813 & pc01_pca_f_lit_rate < .5413
estimates store reg7

reg treated_dummy ebb_dummy pc01_pca_lit_gender_gap ///
    if pc01_pca_f_lit_rate > .3813 & pc01_pca_f_lit_rate < .5413
estimates store reg8

/* generate table with regression results */
esttab reg1 reg2 reg3 reg4 reg5 reg6 reg7 reg8, ///
    drop(_cons) ///
    coeflabels(ebb_dummy "NPEGEL/KGBV participation in 2007-08") ///
    indicate("Pre-program controls = pc01_pca_lit_gender_gap") ///
    mgroups("2% Range" "4% Range" "6% Range" "8% Range", pattern(1 0 1 0 1 0 1 0)) ///
    nonumbers nomtitles ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    title(First Stage Estimates: Effect of EBB Status on Program Participation)

/**********/
/* Fig. 3 */
/**********/

/* open dataset */
use $ebb/treated_list_clean, clear

/* graph a scatterplot with black dots representing EBBs
(based on ebbs_list.dta coding, rather than the raw qualification metrics) */
twoway (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if treatment == 0 & pc01_pca_lit_gender_gap >= 0 ///
    & pc01_pca_f_lit_rate <= 0.8, msymbol(O) msize(tiny) mcolor(red)) ///
    (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if treatment == 1 & pc01_pca_lit_gender_gap >= 0 ///
    &  pc01_pca_f_lit_rate <= 0.8, msymbol(O) mcolor(blue) msize(tiny)) ///
    (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if treatment == 2 & pc01_pca_lit_gender_gap >= 0 ///
    &  pc01_pca_f_lit_rate <= 0.8, msymbol(O) mcolor(orange) msize(tiny)) ///
    (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if treatment == 3 & pc01_pca_lit_gender_gap >= 0 ///
    &  pc01_pca_f_lit_rate <= 0.8, msymbol(O) mcolor(green) msize(tiny)) ///
    (scatteri .5 .3813 .2159 .3813, recast(line) lcolor(black) lpattern(shortdash)) ///
    (scatteri .5 .5413 .2159 .5413, recast(line) lcolor(black) lpattern(shortdash)) ///
    (scatteri .2159 .3813 .2159 .5413, recast(line) lcolor(black) lpattern(shortdash)) ///
    (scatteri .5 .3813 .5 .5413, recast(line) lcolor(black) lpattern(shortdash)), ///
    graphregion(color(white)) ///
    xsize(8) ysize(6) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Gender Gap in Rural Literacy") ///
    ylabel(, angle(0) format(%9.2f) nogrid) ///
    legend(order(1 2 3 4) label(1 "No Treatment") label(2 "KGBV") label(3 "NPEGEL") ///
    label(4 "KGBV & NPEGEL") ring(0) position(4)) ///
    xline(.4613, lcolor(black)) ///
    yline(.2159, lcolor(black)) ///
    ylabel(0(0.1)0.5) ///
    xlabel(0(0.2)0.8) ///
    ysc(reverse) ///
    title(NPEGEL/KGBV Eligibility of Rural Blocks) ///
    name(fig3, replace)

/* export graph */
graphout fig3

/**********/
/* Fig. 4 */
/**********/

/* open dataset */
use $ebb/treated_list_clean, clear

/* binscatter for literacy rate RD */
binscatter treated_dummy pc01_pca_f_lit_rate ///
    if pc01_pca_f_lit_rate >= 0.3813 & pc01_pca_f_lit_rate <= 0.5413 ///
    & pc01_pca_lit_gender_gap > 0.2159, ///
    rd(0.4613) ///
    title(Program Participation, size(medlarge)) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("NPEGEL/KGBV Blocks in Bin") ///
    xlabel(0.3813(0.02)0.5413) ///
    xtick(0.3813(0.01)0.5413) ///
    ylabel(0(0.2)1) ///
    ytick(0(0.05)1) ///
    xline(.4613, lcolor(black) lwidth(medthick)) ///
    mcolor(maroon) msymbol(circle) ///
    lcolor(black) ///
    name(fig4a, replace)

/* graph frequency of literacy rate in the blocks */
histogram pc01_pca_f_lit_rate ///
    if pc01_pca_f_lit_rate >= 0.3813 & pc01_pca_f_lit_rate <= 0.5413 ///
    & pc01_pca_lit_gender_gap > 0.2159, ///, ///
    freq bin(16) gap(20) ///
    title(Histogram, size(medlarge)) ///
    ytitle("Number of Blocks in Bin") ///
    xtitle("Female Rural Literacy Rate") ///
    xlabel(0.3813(0.02)0.5413) ///
    xtick(0.3813(0.01)0.5413) ///
    xline(.4613, lcolor(black) lwidth(medthick)) ///
    fcolor(maroon) lcolor(black) ///
    name(fig4b, replace)

/* combine graphs */
graph combine fig4a fig4b, col(1) imargin(medium) ///
    xsize(6) ysize(7.5) name(fig4, replace)

/* export figure */
graphout fig4

/**********/
/* Fig. 6 */
/**********/

/* use dataset */
use $iec/flfp/dise_ebb_analysis_2, clear

/* gen RD graph for girls */
rd diff_total_g pc01_pca_f_lit_rate if year == 2003, ///
    degree(2) bins(50) start(-.1) end(.1) ///
    absorb(pc01_state_id) control(ln_pc01_pca_tot_p) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Change in Enrollment 2003 - 2008") ///
    title("Girls- Change in Enrollment between 2003 and 2008")

gr save $tmp/fig6a.gph, replace

/* gen RD graph for boys */
rd diff_total_b pc01_pca_f_lit_rate if year == 2003, ///
    degree(2) bins(50) start(-.1) end(.1) ///
    absorb(pc01_state_id) control(ln_pc01_pca_tot_p) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Change in Enrollment 2003 - 2008") ///
    title("Boys - Change in Enrollment between 2003 and 2008")

gr save $tmp/fig6b.gph, replace

/* combine graphs */
graph combine $tmp/fig6a.gph $tmp/fig6b.gph, col(1) imargin(medium) ///
    name(fig6, replace)

graphout fig6
