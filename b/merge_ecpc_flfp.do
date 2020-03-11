/*******************************************/
/* Generate Merged EC and PC for all Years */
/*******************************************/

/* Load EC by year dataset */
use $flfp/ec_flfp_all_years.dta, clear

/* collapse all relevant data by year-shrid pair */
collapse (sum) count* emp*, by (year shrid)

/* merge 2013 EC with 2011 PC */
use $flfp/shrug_pc11_pca.dta, clear
gen year = 2013
merge m:1 shrid year using $tmp/collapsed_ec_flfp_all_years.dta
drop _merge

/* save as temporary file */
save $tmp/collapsed_ec_flfp_all_years.dta, replace

/* merge 2005 EC with 2001 PC */
use $flfp/shrug_pc01_pca.dta, clear
gen year = 2005
merge m:1 shrid year using $tmp/collapsed_ec_flfp_all_years.dta
drop _merge

/* save as temporary file */
save $tmp/collapsed_ec_flfp_all_years.dta, replace

/* merge 1990 EC with 1991 PC */
use $flfp/shrug_pc91_pca.dta, clear
gen year = 1990
merge m:1 shrid year using $tmp/collapsed_ec_flfp_all_years.dta
drop _merge

/* drop 1998, since we have no PC to match with it */
drop if year == 1998

/* save to new dataset */
save $flfp/flfp_ecpc.dta, replace
