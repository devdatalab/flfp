/*******************************************/
/* Generate Merged EC and PC for all Years */
/*******************************************/

/* Load EC by year dataset */
use $flfp/ec_flfp_all_years, clear

/* Collapse all relevant data (except shric) by year-shrid pair */
collapse (sum) count* emp*, by (year shrid)

/* bring in data from all pop censuses */
foreach x in 91 01 11 {
  
  /* Merge all PC years onto all EC year */
	merge m:1 shrid using $flfp/shrug_pc`x'_pca

  /* drop the PCA places that didn't match the EC */
  drop if _merge == 2
	drop _merge
}

/* Save an FLFP dataset with the merged PCAs */
save $flfp/flfp_ecpc, replace
