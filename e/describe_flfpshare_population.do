** EC FLFP vs Population Analysis **

use $flfp/ec_flfp_90, replace //Generate full dataset with EC year variable
gen year = 1990		
foreach y in 1998 2005 2013 {
  append using $flfp/ec_flfp_98
  replace year = 1998 if mi(year)
  append using $flfp/ec_flfp_05
  replace year = 2005 if mi(year)
  append using $flfp/ec_flfp_13
  replace year = 2013 if mi(year)
}

collapse (sum) count* emp*, by (shrid year) // Collapse by shrid and year so that we have all relevant EC data for each shrid-year pair

foreach x in 91 01 11 {
	merge m:1 shrid using $flfp/shrug_pc`x'_pca.dta
	drop _merge 
	gen pop_m_share_`x' = pc`x'_pca_tot_m/pc`x'_pca_tot_p
	drop if pc`x'_pca_tot_p < 100
	}

//Generate FLFP share for each EC-shrid combination
gen emp_f_share_90 = emp_f/(emp_f + emp_m) if year == 1990
gen emp_f_share_98 = emp_f/(emp_f + emp_m) if year == 1998
gen emp_f_share_05 = emp_f/(emp_f + emp_m) if year == 2005
gen emp_f_share_13 = emp_f/(emp_f + emp_m) if year == 2013

save $tmp/full_ec, replace 	//Save as temporary file in order to avoid repeating the collapse 

//Binscatter flfp against log population for each EC year using closest PC estimates saving each graph for future graph combine
binscatter emp_f_share_90 pc91_pca_tot_p, linetype(connect) xscale(log) title(1990) xtitle(Population (Log Scale)) ytitle(Female Share)	
graph save flfp_share_90, replace

binscatter emp_f_share_98 pc01_pca_tot_p, linetype(connect) xscale(log) title(1998) xtitle(Population (Log Scale)) ytitle(Female Share)
graph save flfp_share_98, replace

binscatter emp_f_share_05 pc01_pca_tot_p, linetype(connect) xscale(log) title(2005) xtitle(Population (Log Scale)) ytitle(Female Share)
graph save flfp_share_05, replace

binscatter emp_f_share_13 pc11_pca_tot_p, linetype(connect) xscale(log) title(2013) xtitle(Population (Log Scale)) ytitle(Female Share)
graph save flfp_share_13, replace

//Combine flfp vs population graphs and export as PNG 
graph combine flfp_share_90.gph flfp_share_98.gph flfp_share_05.gph flfp_share_13.gph, xcommon ycommon title(Female Share vs Population)
graph export combined_flfp_share, as(png) replace

//Generate male population share variable for each PC year
gen male_share_91 = pc91_pca_tot_m/pc91_pca_tot_p if year == 1990
gen male_share_01 = pc01_pca_tot_m/pc01_pca_tot_p if year == 1998 | 2005
gen male_share_11 = pc11_pca_tot_m/pc11_pca_tot_p if year == 2013

//Binscatter male share against log total population and save graphs for future graph combine
binscatter male_share_91 pc91_pca_tot_p, linetype(connect) xscale(log) title(1991) xtitle(Population (Log Scale)) ytitle(Male Share of Population)
graph save male_share_91, replace

binscatter male_share_01 pc01_pca_tot_p, linetype(connect) xscale(log) title(2001) xtitle(Population (Log Scale)) ytitle(Male Share of Population)
graph save male_share_01, replace

binscatter male_share_11 pc11_pca_tot_p, linetype(connect) xscale(log) title(2011) xtitle(Population (Log Scale)) ytitle(Male Share of Population)
graph save male_share_11, replace

//Combine male share vs population graphs and export as PNG
graph combine male_share_91.gph male_share_01.gph male_share_11.gph, xcommon ycommon title(Male Share vs Population)
graph export combined_male_share, as(png)replace
