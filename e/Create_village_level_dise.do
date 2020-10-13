/* village level DISE */

*** TEST FILE ***

/* create DISE basic dataset with pc01 state/district/block */

use $iec/dise/dise_basic_clean, clear

gen y = 1

keep if year == "2005-2006"

collapse (sum) y, by(dise_state district dise_block_name dise_village_name)


/* merge with DISE-PC01 key */
merge m:1 dise_state district dise_block_name using $ebb/pc01_dise_key

/* keep matches */
 keep if _merge == 3

/* drop merge variable*/
drop _merge

save $tmp/village_1, replace


/* add id to pc01 dataset */


use $pc01/pc01r_pca_clean, clear

collapse (sum) pc01_pca_tot_p, by(pc01_state_name pc01_state_id pc01_district_name pc01_district_id pc01_block_name ///
    pc01_block_id pc01_village_name pc01_village_id)

sort pc01_state_name pc01_district_name pc01_block_name pc01_village_name

gen id =  pc01_state_name +  pc01_district_name +  pc01_block_name +  pc01_village_name

quietly by pc01_state_name pc01_district_name pc01_block_name pc01_village_name: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

save $tmp/pc01_id, replace


/* merge dise-pc01 at village level */

use $tmp/village_1, clear

gen x = 1

collapse (firstnm) x, by(pc01_block_id pc01_block_name pc01_district_id ///
    pc01_district_name pc01_state_id pc01_state_name dise_village_name)

gen id = pc01_state_name +  pc01_district_name +  pc01_block_name + dise_village_name

ren dise_village_name pc01_village_name

masala_merge pc01_state_name pc01_district_name pc01_block_name ///
    using $tmp/pc01_id, s1(pc01_village_name) idmaster(id) idusing(id)
