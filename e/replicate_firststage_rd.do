/***********************************/
/* Replicate first stage RD graphs */
/***********************************/

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

/* binscatter for literacy rate RD */
binscatter ebb_dummy pc01_pca_f_lit_rate, rd(0.4613) ///
    xtitle("Female Rural Literacy Rate") ///
    ytitle("Fraction of EBB Observations in Bin") ///
    name(litraterd, replace)

/* binscatter for gender gap in literacy rates RD */
binscatter ebb_dummy pc01_pca_lit_gender_gap, rd(0.2159) ///
    xtitle("Gender Gap in Rural Literacy") ///
    ytitle("Fraction of EBB Observations in Bin") ///
    name(gendergaprd, replace)

/* combine binscatter graphs */
graph combine litraterd gendergaprd, ycommon r(1) name(combinedrd, replace)

/* export combined graph */
graphout combinedrd
