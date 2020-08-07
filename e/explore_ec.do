***********************
*** CLEAN PC01 DATA ***
***********************

/* clean pc01 data with village-shrid key */

/* use dataset */
use $iec/flfp/shrug_pc01r_key.dta, clear

/* drop duplicates */
sort shrid
qui by shrid: gen dup = cond(_N==1,0,_n)
drop if dup > 1

/* save temp dataset */
save $tmp/pc01_01_cleaned_1, replace

/* clean pc01 data with village-block data */

/* use dataset  */
use $iec/pc01/pc01r_pca_clean.dta, clear

/* keep relevant vars */
keep pc01_state_id pc01_state_name pc01_district_id pc01_district_name ///
    pc01_village_name pc01_village_id pc01_subdistrict_name pc01_subdistrict_id ///
    pc01_block_name pc01_block_id
	
/* drop duplicates */	
sort pc91_state_id pc91_district_id pc91_subdistrict_id pc91_village_id shrid
qui by pc91_state_id pc91_district_id pc91_subdistrict_id pc91_village_id shrid: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup	

/* save temp dataset  */
save $tmp/pc01_01_cleaned_2, replace


*********************
*** MERGE EC DATA ***
*********************


/* use EC all years dataset */
use $iec/flfp/ec_flfp_all_years, clear

/* drop duplicates */
sort year shric shrid
quietly by year shric shrid: gen dup = cond(_N==1,0,_n)
drop if dup >1
drop dup

/* merge with shrid-village pc01 data */
merge m:1 shrid using $tmp/pc01_01_cleaned_1

/* keep matched obs */
keep if _merge == 3

/* save and use temp dataset */
save $tmp/90, replace
use $tmp/90, clear

/* drop merge var */
drop _merge

/* merge with block-village pc01 data */
merge m:1 pc01_state_id pc01_district_id pc01_subdistrict_id pc01_village_id ///
    using $tmp/pc01_01_cleaned_2

/* keep matched obs */
keep if _merge == 3

/* save dataset */
save $tmp/pc_ec_block, replace
