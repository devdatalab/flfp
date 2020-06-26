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
replace dsie_state = "daman & diu" if dise_state == "daman-and-diu"
replace dise_state = "jammu & kashmir" if dise_state == "jammu-and- kashmir"

/* drop collective  NE states entry*/
drop if dise_state = "north-eastern-states"

/* rename key variables */
ren dise_block_name pc01_block_name
ren district pc01_district_name
ren dise_state pc01_state_name

/* keep only year 2007-2008 */
keep if year=="2007-2008"

/* save temp dise dataset */
save $tmp/dise_1.dta, replace

collapse (sum) enr*, by(pc01_state_name pc01_district_name pc01_block_name)

save $tmp/dise_2.dta, replace
/*

/* masala merge with PC01 */

/*  generate unique identifiers for observations (necessary for masala merge) */
gen id = _n
tostring id, replace

/* use masala merge to fuzzy merge datasets */
masala_merge pc01_state_name pc01_district_name using $ebb/ebbs_list_clean, s1(pc01_block_name) idmaster(id) idusing(id)

drop _merge
merge m:1 pc01_state_name pc01_district_name pc01_block_name using $ebb/ebbs_list_clean
