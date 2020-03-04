**SCST Share**

use $flfp/flfp_ecpc.dta, clear //Use merged EC/PC dataset

** Generate FLFP share variables for each EC year **
gen emp_f_share_90 = emp_f/(emp_f + emp_m) if year == 1990
gen emp_f_share_98 = emp_f/(emp_f + emp_m) if year == 1998
gen emp_f_share_05 = emp_f/(emp_f + emp_m) if year == 2005
gen emp_f_share_13 = emp_f/(emp_f + emp_m) if year == 2013

** Generate SCST share variable for each EC year using closest PC data **
gen scst_share_91 = (pc91_pca_p_sc + pc91_pca_p_st)/pc91_pca_tot_p if year == 1990
gen scst_share_01 = (pc01_pca_p_sc + pc01_pca_p_st)/pc01_pca_tot_p if year == 2005 | year == 1998
gen scst_share_11 = (pc11_pca_p_sc + pc11_pca_p_st)/pc11_pca_tot_p if year == 2013

** Generate ST share variable for each EC year using closest PC data **
gen st_share_91 = pc91_pca_p_sc/pc91_pca_tot_p
gen st_share_01 = pc01_pca_p_sc/pc01_pca_tot_p
gen st_share_11 = pc11_pca_p_sc/pc11_pca_tot_p

** Generate SC share variable for each EC year using closest PC data **
gen sc_share_91 = pc91_pca_p_st/pc91_pca_tot_p
gen sc_share_01 = pc01_pca_p_st/pc01_pca_tot_p
gen sc_share_11 = pc11_pca_p_st/pc11_pca_tot_p

**Generate Binscatters for FLFP vs SCST share and combine graphs **
binscatter emp_f_share_90 scst_share_91, linetype(connect) title(1990) xtitle(SCST Share) ytitle(Female Employment Share)
graph save scst_90, replace
binscatter emp_f_share_98 scst_share_01, linetype(connect) title(1998) xtitle(SCST Share) ytitle(Female Employment Share)
graph save scst_98, replace
binscatter emp_f_share_05 scst_share_01, linetype(connect) title(2005) xtitle(SCST Share) ytitle(Female Employment Share)
graph save scst_05, replace
binscatter emp_f_share_13 scst_share_11, linetype(connect) title(2013) xtitle(SCST Share) ytitle(Female Employment Share)
graph save scst_13, replace

graph combine scst_90.gph scst_98.gph scst_05.gph scst_13.gph, xcommon ycommon title(Female Employment Share vs. SCST Share)
graph export scst_total, as(png) replace

**Generate Binscatters for FLFP vs SC share and combine graphs **
binscatter emp_f_share_90 sc_share_91, linetype(connect) title(1990) xtitle(SC Share) ytitle(Female Employment Share)
graph save sc_90, replace
binscatter emp_f_share_98 sc_share_01, linetype(connect) title(1998) xtitle(SC Share) ytitle(Female Employment Share)
graph save sc_98, replace
binscatter emp_f_share_05 sc_share_01, linetype(connect) title(2005) xtitle(SC Share) ytitle(Female Employment Share)
graph save sc_05, replace
binscatter emp_f_share_13 sc_share_11, linetype(connect) title(2013) xtitle(SC Share) ytitle(Female Employment Share)
graph save sc_13, replace

graph combine sc_90.gph sc_98.gph sc_05.gph sc_13.gph, xcommon ycommon title(Female Employment Share vs. SC Share)
graph export sc_total, as(png) replace

**Generate Binscatters for FLFP vs ST share and combine graphs **
binscatter emp_f_share_90 st_share_91, linetype(connect) title(1990) xtitle(ST Share) ytitle(Female Employment Share)
graph save st_90, replace
binscatter emp_f_share_98 st_share_01, linetype(connect) title(1998) xtitle(ST Share) ytitle(Female Employment Share)
graph save st_98, replace
binscatter emp_f_share_05 st_share_01, linetype(connect) title(2005) xtitle(ST Share) ytitle(Female Employment Share)
graph save st_05, replace
binscatter emp_f_share_13 st_share_11, linetype(connect) title(2013) xtitle(ST Share) ytitle(Female Employment Share)
graph save st_13, replace

graph combine st_90.gph st_98.gph st_05.gph st_13.gph, xcommon ycommon title(Female Employment Share vs. ST Share)
graph export st_total, as(png) replace

