/* village level DISE */

*** TEST FILE ***

/* create DISE basic dataset with pc01 state/district/block */

/* use basic DISE dataset */
use $iec/dise/dise_basic_clean, clear

/* gen var for collapse */
gen y = 1

/* keep only 1 year of data */
keep if year == "2005-2006"

/* collapse at village level */
collapse (sum) y, by(dise_state district dise_block_name dise_village_name)

/* merge with DISE-PC01 block level key */
merge m:1 dise_state district dise_block_name using $ebb/pc01_dise_key

/* keep matches */
 keep if _merge == 3

/* drop merge variable*/
drop _merge

/* save dataset */
save $tmp/village_1, replace


/* add id to pc01 dataset */

/* open pc01 rural dataset */
use $pc01/pc01r_pca_clean, clear

/* collapse at village level */
collapse (sum) pc01_pca_tot_p, by(pc01_state_name pc01_state_id pc01_district_name pc01_district_id pc01_block_name ///
    pc01_block_id pc01_village_name pc01_village_id)

/* sort */
sort pc01_state_name pc01_district_name pc01_block_name pc01_village_name

/* gen id vars */
gen id =  pc01_state_name +  pc01_district_name +  pc01_block_name +  pc01_village_name

/* remove duplicates */
quietly by pc01_state_name pc01_district_name pc01_block_name pc01_village_name: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

/* save dataset */
save $tmp/pc01_id, replace


/* merge dise-pc01 at village level */

/* use DISE village level data */
use $tmp/village_1, clear

/* gen var for collapse */
gen x = 1

/* collapse at village level */
collapse (firstnm) x, by(pc01_block_id pc01_block_name pc01_district_id ///
    pc01_district_name pc01_state_id pc01_state_name dise_village_name)

/* gen id vars for masala merge */
gen id = pc01_state_name +  pc01_district_name +  pc01_block_name + dise_village_name

/* rename for masala merge */
ren dise_village_name pc01_village_name

/* masala merge with pc01 village names*/
masala_merge pc01_state_name pc01_district_name pc01_block_name ///
    using $tmp/pc01_id, s1(pc01_village_name) idmaster(id) idusing(id)
