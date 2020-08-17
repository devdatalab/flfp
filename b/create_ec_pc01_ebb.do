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
sort pc01_state_id pc01_district_id pc01_subdistrict_id pc01_village_id
qui by pc01_state_id pc01_district_id pc01_subdistrict_id pc01_village_id: gen dup = cond(_N==1,0,_n)
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

/* remove outliers */
drop if emp_f/(emp_m + emp_f) > 0.5
drop if count_f/(count_m + count_f) > 0.5
drop if emp_m == 0
drop if count_m == 0

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

****************************
*** BLOCK LEVEL COLLAPSE ***
****************************

/* use dataset */
use $tmp/pc_ec_block, clear

/* collapse at year-block level */
collapse (sum) emp* count*, by (year pc01_state_id pc01_state_name pc01_district_id pc01_district_name ///
    pc01_block_id pc01_block_name)

/* save dataset */
save $tmp/pc_ec_block_collapse, replace

***************************
*** MERGE WITH EBB DATA ***
***************************

/* use ec-pc dataset */
use $tmp/pc_ec_block_collapse, clear

/* destring id variables */
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* merge to ebb/kgbv/npegel data */
merge m:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/treated_list_clean

/* keep merged obs */
keep if _merge == 3

/* save dataset */
save $iec/flfp/ec_pc01_ebb, replace

