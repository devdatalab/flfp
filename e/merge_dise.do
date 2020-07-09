/* Merge DISE data to PC01 */

/* use basic DISE dataset */
use $iec/dise/dise_basic_clean, clear

/* merge with DISE enrollment data */
merge m:1 dise_state year vilcd schcd using $iec/dise/dise_enr_clean

keep if _merge == 3

drop _merge

/* merge witth  facility data */
merge m:1 dise_state year vilcd schcd using $iec/dise/dise_facility_clean.dta

keep if _merge == 3

drop _merge

save $tmp/dise_0, replace
  
use $tmp/dise_0, replace

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
replace dise_state = "jammu & kashmir" if dise_state == "jammu-&-kashmir"

/* edit district names */

replace district = "aurangabad" if district == "aurangabad (maharashtra)"

foreach var in east west south north {
  replace district = "`var'" if district == "`var' delhi"
  replace district = "`var'" if district == "`var' sikkim"
}

/* drop collective  NE states entry*/
drop if dise_state == "north-eastern-states"

/* rename key variables */
ren dise_block_name pc01_block_name
ren district pc01_district_name
ren dise_state pc01_state_name

/* add prefix to faciliy variables */
foreach var in blackboard num_classrooms toilet_boys elec library ///
     toilet_common toilet_girls wall playground water {
  rename `var' facility_`var'
}

/*  destring facility varaibles*/
destring facility*, replace

/* save temp dise dataset */
save $tmp/dise_1_all.dta, replace

use $tmp/dise_1_all.dta, clear

/* fix roman numerals  */
replace pc01_block_name = regexr(pc01_block_name, "ii$", "2")

/* create girls (>90%) variable */
gen girlsch = 1 if enr_all_g/enr_all > 0.9

/* gen enrollment variables for girlsch == 1 */
ds enr*

foreach var in `r(varlist)' {
gen `var'_girlsch = `var' if girlsch == 1
}

/* collapse at state-disttrict-block level */
collapse (sum) facility* enr*, by(year pc01_state_name pc01_district_name pc01_block_name)

/* remove  leading and trailing spaces */
replace pc01_block_name=strtrim(pc01_block_name)

/* save new dataset */
save $tmp/dise_2_all.dta, replace

********************************
*** MERGE WITH DISE-PC01 KEY ***
********************************

/*merge with dise-pc01 key */
merge m:1 pc01_state_name pc01_district_name pc01_block_name using $tmp/dise_pc01_key

/* keep matches */
keep if_merge == 3

/* drop merge variable*/
drop _merge

/* save dataset */
save $iec/flfp/dise_pc01_all, replace
