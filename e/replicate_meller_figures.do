/***************************************************/
/* REPLICATE FIGURES FROM MELLER & LITSCHIG (2015) */
/***************************************************/

/**********/
/* Fig. 3 */
/**********/

/* open dataset */
use $ebb/kgbvs_list_clean, clear

/* graph a scatterplot with black dots representing EBBs
(based on ebbs_list.dta coding, rather than the raw qualification metrics) */
twoway (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if kgbvs_operational == 0 & pc01_pca_lit_gender_gap >= 0 ///
    & pc01_pca_f_lit_rate <= 0.8, msymbol(Oh) mlwidth(vvthin) msize(vsmall) mlcolor(black)) ///
    (scatter pc01_pca_lit_gender_gap pc01_pca_f_lit_rate ///
    if kgbvs_operational > 0 & pc01_pca_lit_gender_gap >= 0 ///
    &  pc01_pca_f_lit_rate <= 0.8, msymbol(O) mcolor(black) msize(vsmall)) ///
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
    title(KGBV Eligibility of Rural Blocks) ///
    name(fig3, replace)

/* export graph */
graphout fig3

/**********/
/* Fig. 4 */
/**********/

/* open dataset */
use $ebb/kgbvs_list_clean, clear

/* binscatter for literacy rate RD */
binscatter kgbvs_operational pc01_pca_f_lit_rate ///
    if pc01_pca_f_lit_rate >= 0.3813 & pc01_pca_f_lit_rate <= 0.5413 ///
    & pc01_pca_lit_gender_gap > 0.2159, ///
    rd(0.4613) ///
    title(Program Participation, size(medlarge)) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("KGBV Blocks in Bin") ///
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
