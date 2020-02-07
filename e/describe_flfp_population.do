** This do file describes the relationship between female employment and ownership with regard to population sizes **

//Load EC90
use $flfp/ec_flfp_90, clear 

//Generate year variable 
gen year = 1990

//For each of the other ECs, append to EC90 and add respective years
foreach y in 1998 2005 2013 {
  append using $flfp/ec_flfp_98
  replace year = 1998 if mi(year)
  append using $flfp/ec_flfp_05
  replace year = 2005 if mi(year)
  append using $flfp/ec_flfp_98
  replace year = 2013 if mi(year)
}

//Drop any observations without shrids or shrics
drop if shrid == ""
drop if shric == .

//Collapse all variables of interest by shrid-year pair
collapse (sum) emp* count*, by (year shrid)

/*Merge all PCs onto the combined EC dataset. This is a little weird because it means each year-shrid combination in the EC 
 also has PC data for every year in the PC but I could not figure out how to do this without having years that do not overlap */
foreach y in 91 01 11 {
	merge m:1 shrid using $flfp/shrug_pc`y'_pca.dta
	drop _merge
	}

//Generate log variables for EC variables
gen ln_emp_f = ln(emp_f + 1)
gen ln_count_f = ln(count_f + 1)

//Generate logs of relevant PC variables
foreach y in pc91_pca_tot_p pc01_pca_tot_p pc11_pca_tot_p pc91_pca_tot_f pc01_pca_tot_f pc11_pca_tot_f {
	gen ln_`y' = ln(`y' + 1)
	}

//Regress log employment and log female ownership on log total population for each year. I use the closest PC estimate to each relevant EC year
foreach y in ln_emp_f ln_count_f {
	reg `y' ln_pc91_pca_tot_p if year == 1990, robust
	reg `y' ln_pc01_pca_tot_p if year == 1998, robust
	reg `y' ln_pc01_pca_tot_p if year == 2005, robust
	reg `y' ln_pc11_pca_tot_p if year == 2013, robust
}

//Regress log female employment and log female ownership on log female population for each EC year. Again I have used the closest PC estimate. 
foreach y in ln_emp_f ln_count_f {
	reg `y' ln_pc91_pca_tot_f if year == 1990, robust
	reg `y' ln_pc01_pca_tot_f if year == 1998, robust
	reg `y' ln_pc01_pca_tot_f if year == 2005, robust
	reg `y' ln_pc11_pca_tot_f if year == 2013, robust
}

