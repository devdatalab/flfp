** EC FLFP vs Population Analysis **

//Load merged EC-PC wide dataset
use $flfp/flfp_ecpc.dta, clear 

//Generate relevant employment share variables for each EC year
foreach x in 1990 1998 2005 2013 {
	gen emp_f_share_`x' = emp_f/(emp_f + emp_m) if year == `x'
	gen count_f_share_`x' = count_f/(count_f + count_m) if year == `x'
	gen emp_f_owner_share_`x' = emp_f_owner/(emp_f_owner + emp_m_owner) if year == `x'
	}
	
//Binscatter emp_f_share against population
binscatter emp_f_share_1990 pc91_pca_tot_p, linetype(connect) xscale(log) title(1990) xtitle(Population (Log Scale)) ytitle(Female Employment Share)
graph save emp_f_share_1990.gph, replace

binscatter emp_f_share_1998 pc01_pca_tot_p, linetype(connect) xscale(log) title(1998) xtitle(Population (Log Scale)) ytitle(Female Employment Share)
graph save emp_f_share_1998.gph, replace

binscatter emp_f_share_2005 pc01_pca_tot_p, linetype(connect) xscale(log) title(2005) xtitle(Population (Log Scale)) ytitle(Female Employment Share)
graph save emp_f_share_2005.gph, replace

binscatter emp_f_share_2013 pc11_pca_tot_p, linetype(connect) xscale(log) title(2013) xtitle(Population (Log Scale)) ytitle(Female Employment Share)
graph save emp_f_share_2013.gph, replace

graph combine emp_f_share_1990.gph emp_f_share_1998.gph emp_f_share_2005.gph emp_f_share_2013.gph, xcommon ycommon title(Female Employment Share vs. Population)
graph export combined_emp_f_share, as(png) replace

//Binscatter count_f_share against population
binscatter count_f_share_1990 pc91_pca_tot_p, linetype(connect) xscale(log) title(1990) xtitle(Population (Log Scale)) ytitle(Female Ownership Share)
graph save count_f_share_1990.gph, replace

binscatter count_f_share_1998 pc01_pca_tot_p, linetype(connect) xscale(log) title(1998) xtitle(Population (Log Scale)) ytitle(Female Ownership Share)
graph save count_f_share_1998.gph, replace

binscatter count_f_share_2005 pc01_pca_tot_p, linetype(connect) xscale(log) title(2005) xtitle(Population (Log Scale)) ytitle(Female Ownership Share)
graph save count_f_share_2005.gph, replace

binscatter count_f_share_2013 pc11_pca_tot_p, linetype(connect) xscale(log) title(2013) xtitle(Population (Log Scale)) ytitle(Female Ownership Share)
graph save count_f_share_2013.gph, replace

graph combine count_f_share_1990.gph count_f_share_1998.gph count_f_share_2005.gph count_f_share_2013.gph, xcommon ycommon title(Female Ownership Share vs. Population)
graph export combined_count_f_share, as(png) replace

//Binscatter emp_f_owner_share against population
binscatter emp_f_owner_share_1990 pc91_pca_tot_p, linetype(connect) xscale(log) title(1990) xtitle(Population (Log Scale)) ytitle(Employment in Female Owned Firm Share)
graph save emp_f_owner_share_1990.gph, replace

binscatter emp_f_owner_share_1998 pc01_pca_tot_p, linetype(connect) xscale(log) title(1998) xtitle(Population (Log Scale)) ytitle(Employment in Female Owned Firm Share)
graph save emp_f_owner_share_1998.gph, replace

binscatter emp_f_owner_share_2005 pc01_pca_tot_p, linetype(connect) xscale(log) title(2005) xtitle(Population (Log Scale)) ytitle(Employment in Female Owned Firm Share)
graph save emp_f_owner_share_2005.gph, replace

binscatter emp_f_owner_share_2013 pc11_pca_tot_p, linetype(connect) xscale(log) title(2013) xtitle(Population (Log Scale)) ytitle(Employment in Female Owned Firm Share)
graph save emp_f_owner_share_2013.gph, replace

graph combine emp_f_owner_share_1990.gph emp_f_owner_share_1998.gph emp_f_owner_share_2005.gph emp_f_owner_share_2013.gph, xcommon ycommon title(Employment in Female Owned Firm Share vs. Population)
graph export combined_emp_f_owner_share, as(png) replace

**Male Share Analysis**

//Generate male population share variable for each PC year
gen male_share_91 = pc91_pca_tot_m/pc91_pca_tot_p 
gen male_share_01 = pc01_pca_tot_m/pc01_pca_tot_p  
gen male_share_11 = pc11_pca_tot_m/pc11_pca_tot_p 

//Binscatter male share against log total population and save graphs for future graph combine
binscatter male_share_91 pc91_pca_tot_p, linetype(connect) xscale(log) title(1991) xtitle(Population (Log Scale)) ytitle(Male Share of Population)
graph save male_share_91, replace

binscatter male_share_01 pc01_pca_tot_p, linetype(connect) xscale(log) title(2001) xtitle(Population (Log Scale)) ytitle(Male Share of Population)
graph save male_share_01, replace

binscatter male_share_11 pc11_pca_tot_p, linetype(connect) xscale(log) title(2011) xtitle(Population (Log Scale)) ytitle(Male Share of Population)
graph save male_share_11, replace

//Combine male share vs population graphs and export as PNG
graph combine male_share_91.gph male_share_01.gph male_share_11.gph, xcommon ycommon title(Male Share vs Population)
graph export combined_male_share, as(png) replace

