/* Merge DISE data to PC01 */

/* use basic DISE dataset */
use $iec/dise/dise_basic_clean, clear

/* merge with DISE enrollment data */
merge m:1 dise_state year vilcd schcd using $iec/dise/dise_enr_clean

/* make all variables lower case */
replace dise_block_name = lower(dise_block_name)
replace dise_state = lower(dise_state)
replace district = lower(district)

/* rename state names */
foreach var in andhra arunachal himachal madhya uttar {
replace dise_state = "`var' pradesh" if dise_state == "`var'-pradesh"
}

replace dise_state = "west bengal" if dise_state == "west-bengal"
replace dise_state = "tamil nadu" if dise_state == "tamil-nadu"
replace dise_state = "andaman & nicobar island" if dise_state == "andaman-and-nicobar-islands"
replace dise_state = "dadra & nagar haveli" if dise_state == "dadra-and-nagar-haveli"
replace dise_state = "daman & diu" if dise_state == "daman-and-diu"
replace dise_state = "jammu & kashmir" if dise_state == "jammu-and-kashmir"

/* drop collective  NE states entry*/
drop if dise_state == "north-eastern-states"

/* rename key variables */
ren dise_block_name pc01_block_name
ren district pc01_district_name
ren dise_state pc01_state_name

/* keep only year 2007-2008 */
keep if year=="2007-2008"

/* save temp dise dataset */
save $tmp/dise_1.dta, replace

/* collapse at state-disttrict-block level */
collapse (sum) enr*, by(pc01_state_name pc01_district_name pc01_block_name)

/* save new dataset */
save $tmp/dise_2.dta, replace

/* gen district level ebbs dataset */

use $ebb/ebbs_list_clean, clear

/* keep district and state ideentifies */
keep pc01_state_name pc01_state_id pc01_district_name pc01_district_id

/* gen  duplicates idenitiifies variable */
sort pc01_state_id pc01_district_id
quietly by pc01_state_id pc01_district_id: gen dup = cond(_N==1,0,_n)

/* drop all duplicate occurences */
drop if dup > 1
drop dup

/* save pc01 dataset */
save $mp/ebbs_district2, replace

/* use temp dise dataset*/
use $tmp/dise_2, clear

/* masala merge with PC01 */

/*  generate unique identifiers for observations (necessary for masala merge) */
gen id = _n
tostring id, replace

/* use masala merge to fuzzy merge datasets */
masala_merge pc01_state_name using $tmp/ebbs_district2, s1(pc01_district_name) idmaster(id) idusing(id)

/* merge using and master names */
gen pc01_district_name = pc01_district_name_master
replace pc01_district_name = pc01_district_name_using if mi(pc01_district_name_master)

/* drop merge variable */
drop _merge

/* drop unmatched variable */
drop if match_source == 6

/* gen unique identifies */
gen id = _n
tostring id, replace

/* drop merge variables */
drop id_using id_master pc01_district_name_master pc01_district_name_using

/* save temp dataset */
save $tmp/dise_3, replace

use $tmp/dise_3, clear

/* drop merge variables */
drop match_source masala_dist

/* drop missing block names obs */
drop if mi(pc01_block_name)

/* masala merge with block names from pc01 */
masala_merge pc01_state_name pc01_state_id pc01_district_id pc01_district_name using $ebb/ebbs_list_clean, s1(pc01_block_name) idmaster(id) idusing(id)

/* drop merge variable */
drop _merge

/* merge using and master block names into one variable */
gen pc01_block_name = pc01_block_name_master
replace pc01_block_name = pc01_block_name_using if mi(pc01_block_name_master)

/* generate unique identifiers for observations */
gen id = _n
tostring id, replace

/* drop variables which will be generates in future masala merges */
drop id_using id_master pc01_block_name_master pc01_block_name_using
