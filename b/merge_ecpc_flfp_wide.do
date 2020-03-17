/*******************************************/
/* Generate Merged EC and PC for all Years */
/*******************************************/

/* Load EC by year dataset */
use $flfp/ec_flfp_all_years.dta, clear

/* Collapse all relevant data (except shric) by year-shrid pair */
collapse (sum) count* emp*, by (year shrid)

/* Merge all PC years onto all EC year */
foreach x in 91 01 11 {	
	merge m:1 shrid using $flfp/shrug_pc`x'_pca.dta
	drop _merge //Drop _merge to allow loop to continue
	}

/* Save to new dataset */
save $flfp/flfp_ecpc.dta, replace
