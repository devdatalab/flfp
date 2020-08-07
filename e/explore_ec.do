/* use EC dataset */

use $iec/flfp/ec_flfp_all_years, clear

sort year shric shrid
quietly by year shric shrid: gen dup = cond(_N==1,0,_n)
drop if dup >1

/* use shrid-village pc01 */

merge m:1 shrid using $tmp/shrug_01_cleaned

save $tmp/90, replace

use $tmp/90, clear

drop _merge

/* mergr with block pc01*/

merge m:1  pc01_state_id pc01_district_id pc01_subdistrict_id pc01_village_id ///
    using $tmp/shrug_01_cleaned_2

keep if _merge == 3

save $tmp/pc_ec_block, replace

sort pc91_state_id pc91_district_id pc91_subdistrict_id pc91_village_id shrid
qui by pc91_state_id pc91_district_id pc91_subdistrict_id pc91_village_id shrid: gen dup = cond(_N==1,0,_n)


drop dup
sort shrid
qui by shrid: gen dup = cond(_N==1,0,_n)


/* clean pc01 data */

use $iec/flfp/shrug_pc01r_key.dta, clear

sort shrid
qui by shrid: gen dup = cond(_N==1,0,_n)
drop if dup > 1

save $tmp/shrug_01_cleaned, replace

/* clean pc01 2 dtata */

use $iec/pc01/pc01r_pca_clean.dta, clear

keep pc01_state_id pc01_state_name pc01_district_id pc01_district_name ///
    pc01_village_name pc01_village_id pc01_subdistrict_name pc01_subdistrict_id ///
    pc01_block_name pc01_block_id

save $tmp/shrug_01_cleaned_2, replace
