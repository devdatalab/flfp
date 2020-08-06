/* create dise-pc01 key */

****************************
*** CREATE EBBS DATASETS ***
****************************

/* create district and block level ebbs datasets */
use $ebb/ebbs_list_clean, clear

/* rename district names to match DISE */

replace pc01_district_name = "dima hasao" if pc01_district_name=="north cachar hills"
replace pc01_district_name = "chikkamangalore" if pc01_district_name == "chikmagalur"
replace pc01_district_name = "khandwa" if pc01_district_name == "east nimar"
replace pc01_district_name = "khargone" if pc01_district_name == "west nimar"
replace pc01_district_name = "balasore" if pc01_district_name == "baleshwar"
replace pc01_district_name = "keonjhar" if pc01_district_name == "kendujhar"

/* manually change block names to prevent fale positive matches */

replace pc01_block_name = "jhariacumjorapokharcumsindri" if ///	
	pc01_block_name == "jharia cum jorapokhar cum sindri"
	replace pc01_block_name = "hans2" if pc01_block_name == "hansi-1"
	replace pc01_block_name = "goalpokhar2" if pc01_block_name == "aaaa"
	replace pc01_block_name = "gopiballavpur2" if pc01_block_name == "bbbb"
	replace pc01_block_name = "sikandarpurkaran" if pc01_block_name == "cccc"
replace pc01_block_name = "tamari" if pc01_block_name == "tamar-1"


/* save temp dataset */
save  $tmp/ebbs_district, replace

/* keep district and state ideentifies */
keep id pc01_state_name pc01_state_id pc01_district_name pc01_district_id

/* gen  duplicates idenitiifies variable */
sort pc01_state_id pc01_district_id
quietly by pc01_state_id pc01_district_id: gen dup = cond(_N==1,0,_n)

/* drop all duplicate occurences */
drop if dup > 1
drop dup

/* save pc01 dataset */
save $tmp/ebbs_district2, replace

*****************************
*** MERGE PC01  with DISE ***
*****************************

/* use basic DISE dataset */
use $iec/dise/dise_basic_clean, clear

/* remove trailing and leading spaces */
replace dise_block_name=strtrim(dise_block_name)

/* gen a year var for merge */
gen year11 = substr(year, 1, 4)
drop year
rename year11 year

/* destring year */
destring year, replace

/* keep when vilcd appears first */
by vilcd, sort: egen min_year = min(year)
keep if year == min_year

/* keep only id variables */
keep dise_block_name dise_state district

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

/* drop duplicates*/
sort pc01_state_name  pc01_district_name  pc01_block_name
quietly by pc01_state_name pc01_district_name pc01_block_name: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

**************
/* DISTRICT */
**************

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

/* drop merge variables */
drop match_source masala_dist

/* drop missing block names obs */
drop if mi(pc01_block_name)

save $tmp/key1, replace

use $tmp/key1, clear
***********
/* BLOCK */
***********
/* masala merge with block names from pc01 */
masala_merge pc01_state_name pc01_state_id pc01_district_id pc01_district_name using $tmp/ebbs_district, s1(pc01_block_name) idmaster(id) idusing(id)

/* insert manual matches */
insert_manual_matches, manual_file(/scratch/pgupta/manual_dise.csv) idmaster(id_master) idusing(id_using)

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

/* drop merge variables */
drop match_source masala_dist

/* keep only key variables */
keep pc01_state_name pc01_district_name pc01_block_name pc01_state_id pc01_district_id pc01_block_id

/* drop missing*/
foreach var in pc01_state_name pc01_state_id pc01_district_name pc01_district_id pc01_block_name pc01_block_id {
  drop if mi(`var')
}

/* remove leading and ttrailing space from block names */
replace pc01_block_name=strtrim(pc01_block_name)

/* save datase to temp and ebb */
save $tmp/dise_pc01_key, replace
save $iec/flfp/dise_pc01_key, replace
