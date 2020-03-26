**FLFP vs SCST Share Analysis**

use $flfp/flfp_ecpc.dta, clear

** Generate FLFP share variables for each EC year **
foreach x in 1990 1998 2005 2013 {
	gen emp_f_share_`x' = emp_f / (emp_f + emp_m) if year == `x'
}

** Generate SCST share variable for each EC year using closest PC data **
foreach x in 91 01 11 {
	gen scst_share_`x' = (pc`x'_pca_p_sc + pc`x'_pca_p_st) / pc`x'_pca_tot_p 
	gen st_share_`x' = (pc`x'_pca_p_st) / pc`x'_pca_tot_p
	gen sc_share_`x' = pc`x'_pca_p_sc / pc`x'_pca_tot_p
}

**Generate Binscatters for FLFP vs SCST share and combine graphs **
binscatter emp_f_share_1990 scst_share_91, linetype(connect) title(1990) xtitle(SCST Share) ytitle(Female Employment Share) name(scst_90, replace)
binscatter emp_f_share_1998 scst_share_01, linetype(connect) title(1998) xtitle(SCST Share) ytitle(Female Employment Share) name(scst_98, replace)
binscatter emp_f_share_2005 scst_share_01, linetype(connect) title(2005) xtitle(SCST Share) ytitle(Female Employment Share) name(scst_05, replace)
binscatter emp_f_share_2013 scst_share_11, linetype(connect) title(2013) xtitle(SCST Share) ytitle(Female Employment Share) name(scst_13, replace)

graph combine scst_90 scst_98 scst_05 scst_13, xcommon ycommon title(Female Employment Share vs. SCST Share)
graphout scst_total

**Generate Binscatters for FLFP vs SC share and combine graphs **
binscatter emp_f_share_1990 sc_share_91, linetype(connect) title(1990) xtitle(SC Share) ytitle(Female Employment Share) name(sc_90, replace)
binscatter emp_f_share_1998 sc_share_01, linetype(connect) title(1998) xtitle(SC Share) ytitle(Female Employment Share) name(sc_98, replace)
binscatter emp_f_share_2005 sc_share_01, linetype(connect) title(2005) xtitle(SC Share) ytitle(Female Employment Share) name(sc_05, replace)
binscatter emp_f_share_2013 sc_share_11, linetype(connect) title(2013) xtitle(SC Share) ytitle(Female Employment Share) name(sc_13, replace)

graph combine sc_90 sc_98 sc_05 sc_13, xcommon ycommon title(Female Employment Share vs. SC Share)
graphout sc_total

**Generate Binscatters for FLFP vs ST share and combine graphs **
binscatter emp_f_share_1990 st_share_91, linetype(connect) title(1990) xtitle(ST Share) ytitle(Female Employment Share) name(st_90, replace)
binscatter emp_f_share_1998 st_share_01, linetype(connect) title(1998) xtitle(ST Share) ytitle(Female Employment Share) name(st_98, replace)
binscatter emp_f_share_2005 st_share_01, linetype(connect) title(2005) xtitle(ST Share) ytitle(Female Employment Share) name(st_05, replace)
binscatter emp_f_share_2013 st_share_11, linetype(connect) title(2013) xtitle(ST Share) ytitle(Female Employment Share) name(st_13, replace)

graph combine st_90 st_98 st_05 st_13, xcommon ycommon title(Female Employment Share vs. ST Share)
graphout st_total

