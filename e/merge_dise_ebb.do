******************************************************
**** CLEAN AND MERGE DISE DATA WITH PC01 AND EBBS ****
******************************************************

/* use new-old dise dataset */
use $tmp/dise_old_new, clear

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
  
/* fix roman numerals  */
replace pc01_block_name = regexr(pc01_block_name, "ii$", "2")

/* collapse at state-disttrict-block level */
collapse (sum) facility* enr*, by(year pc01_state_name pc01_district_name pc01_block_name)

/* remove  leading and trailing spaces */
replace pc01_block_name=strtrim(pc01_block_name)

/* save dataset */
save $tmp/dise_cleaned.dta, replace

********************************
*** MERGE WITH DISE-PC01 KEY ***
********************************

/* use dise all dataset */
use $tmp/dise_cleaned.dta, replace

/*remove spaces */
replace pc01_block_name=strtrim(pc01_block_name)

/*merge with dise-pc01 key */
merge m:1 pc01_state_name pc01_district_name pc01_block_name using $tmp/dise_pc01_key

/* keep matches */
keep if _merge == 3

/* drop merge variable*/
drop _merge

/* merge EBB data */
merge m:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/ebbs_list_clean

/* drop unmatched obs */
keep if _merge==3

/* drop merge variable  */
drop _merge

/* save dataset */
save $tmp/dise_pc01_ebb, replace
save $iec/flfp/dise_pc01_ebb, replace
