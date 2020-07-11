/* Merge DISE data to PC01 */

**** MERGE NEW DISE DATA ****

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

/*
***************************
**** ADD OLD DISE DATA ****
***************************

/* create vilcd key to match old dise */

use $tmp/dise_0, clear

collapse (sum) enr*, by(year dise_state district dise_block vilcd)

keep if year == "2005-2006"

keep dise_state district dise_block vilcd

foreach var in dise_state district dise_block vilcd {
replace `var'=strtrim(`var')
}

sort dise_state district dise_block vilcd
quietly by dise_state district dise_block vilcd: gen dup = cond(_N==1,0,_n)
drop if dup >1

drop dup

save $tmp/vilcd_key, replace

***************************

/* clean old dise data */

use /scratch/pn/dise/education.dta, clear

rename vilid vilcd

rename blkid pc01_block_id

rename distid pc01_district_id

rename state pc01_state_id

keep enr_sc* year pc01_state_id pc01_district_id pc01_block_id vilcd schcd

drop pc01_state_id pc01_district_id pc01_block_id

keep if inlist(year, 1, 2, 3, 4)

tostring year, replace

replace year = "2001-2002" if year == "1"
replace year = "2002-2003" if year == "2"
replace year = "2003-2004" if year == "3"
replace year = "2004-2005" if year == "4"

sort year vilcd schcd
quietly by year vilcd schcd: gen dup = cond(_N==1,0,_n)
drop if dup > 1

collapse (sum) enr*, by(year vilcd)

save $tmp/dise_old.dta, replace

***************************

/* merge old dise with new dise identifiers */

use $tmp/dise_old, replace

merge m:1  vilcd using $tmp/vilcd_key

keep if _merge == 3

drop _merge

save $tmp/dise_old1, replace

***************************

/* merge old dise with new dise data */




***************************
*/
***************************
*** CLEAN MERGED DATA *****
***************************

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

*/
********************************
*** MERGE WITH DISE-PC01 KEY ***
********************************

/* use dise all dataset */
use $tmp/dise_2_all.dta, replace

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
save $iec/flfp/dise_pc01_all, replace
