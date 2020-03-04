** Generate Merged EC and PC for all Year **

use $flfp/ec_flfp_all_years.dta, clear //Load EC by year dataset

collapse (sum) count* emp*, by (year shrid) //Collapse all relevant data (except shric) by year-shrid pair

foreach x in 91 01 11 {		//Merge all PC years onto all EC year
	merge m:1 shrid using $flfp/shrug_pc`x'_pca.dta
	drop _merge //Drop _merge to allow loop to continue
	}
	
save $flfp/flfp_ecpc.dta, replace //Save to new dataset
