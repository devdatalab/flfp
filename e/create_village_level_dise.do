/* village level DISE */

*** TEST FILE ***

***********************

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


/* collapse at village level */
collapse (firstnm) y, by(pc01_block_id pc01_block_name pc01_district_id ///
    pc01_district_name pc01_state_id pc01_state_name dise_village_name)


/* gen id vars for masala merge */
gen id = pc01_state_name +  pc01_district_name +  pc01_block_name + dise_village_name

/* rename for masala merge */
ren dise_village_name pc01_village_name

/* add kgbv identification at block level */

merge m:m pc01_state_id pc01_district_id pc01_block_id using $iec/flfp/dise_pc01_ebb, keepusing(kgbvs_app)

drop _merge

tostring pc01_state_id pc01_block_id pc01_district_id, replace

/* save dataset */
save $tmp/village_1, replace

************************

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

/***********************************/
/* create dise and pc01 state-by-state files*/
***********************************/
foreach state in assam bihar chhattisgarh gujarat haryana orissa rajasthan tripura jharkhand karnataka maharashtra meghalaya punjab {
  use $tmp/village_1, clear
  keep if kgbvs_approved > 0
  keep if pc01_state_name == "`state'"
  tostring pc01_state_id pc01_district_id pc01_block_id, replace
  save $tmp/village_`state', replace

  use $tmp/pc01_id, clear
  keep if pc01_state_name == "`state'"
  save $tmp/pc01_id_`state', replace
}

foreach state in andhra arunachal himachal madhya uttar {
  use $tmp/village_1, clear
  keep if kgbvs_approved > 0
  keep if pc01_state_name == "`state' pradesh"
  tostring pc01_state_id pc01_district_id pc01_block_id, replace
  save $tmp/village_`state', replace

  use $tmp/pc01_id, clear
  keep if pc01_state_name =="`state' pradesh"
  save $tmp/pc01_id_`state', replace
}

use $tmp/village_1, clear
keep if kgbvs_approved > 0
keep if pc01_state_name == "jammu kashmir"
tostring pc01_state_id pc01_district_id pc01_block_id, replace
save $tmp/villlage_jammukashmir, replace

use $tmp/pc01_id, clear
keep if pc01_state_name == "jammu kashmir"
save $tmp/pc01_id_jammukashmir, replace

use $tmp/village_1, clear
keep if kgbvs_approved > 0
keep if pc01_state_name == "tamil nadu"
tostring pc01_state_id pc01_district_id pc01_block_id, replace
save $tmp/villlage_tamilnadu, replace

use $tmp/pc01_id, clear
keep if pc01_state_name == "tamil nadu"
save $tmp/pc01_id_tamilnadu, replace

use $tmp/village_1, clear
keep if kgbvs_approved > 0
keep if pc01_state_name == "west bengal"
tostring pc01_state_id pc01_district_id pc01_block_id, replace
save $tmp/villlage_westbengal, replace

use $tmp/pc01_id, clear
keep if pc01_state_name == "west bengal"
save $tmp/pc01_id_westbengal, replace

/***************************************/
/* Masala merge for each of the states */
/**************************************/


/* Run masala merge on states without issues */
foreach state in arunachal assam gujarat jharkhand karnataka maharashtra meghalaya punjab {
  use $tmp/village_`state', clear
  masala_merge pc01_state_name pc01_district_name pc01_block_name ///
      using $tmp/pc01_id_`state', s1(pc01_village_name) idmaster(id) idusing(id)

  save $tmp/village_dise_`state', replace
}


/* Run masala merge on states with unique id issues */
foreach state in andhra bihar jammukashmir tripura westbengal {
  use $tmp/village_`state', clear

  /* Drop duplicate ids since they should be unique */
  duplicates drop id, force

  masala_merge pc01_state_name pc01_district_name pc01_block_name ///
      using $tmp/pc01_id_`state', s1(pc01_village_name) idmaster(id) idusing(id)

  save $tmp/village_dise_`state', replace
}

/* Run masala merge on states with syntax issues */
foreach state in chhattisgarh orissa rajasthan uttar tamilnadu madhya {
  use $tmp/village_`state', clear

  /* Drop all special characters from pc01_village_name and id */
  forvalues i = 0/255 {
    if !inrange(`i',48,57) ///
      & !inrange(`i',65,90) ///
      & !inrange(`i',97,122) {
      replace id = subinstr(id, `=`"char(`i')"' ',"",.)
      replace pc01_village_name = subinstr(pc01_village_name, `=`"char(`i')"' ',"",.)
    }
  }
  /* Drop duplicates */
  duplicates drop id, force
  /* masala merge with pc01 village names*/
  masala_merge pc01_state_name pc01_district_name pc01_block_name ///
      using $tmp/pc01_id_`state', s1(pc01_village_name) idmaster(id) idusing(id)

  save $tmp/village_dise_`state', replace
}


/************************************************************************/
/* Himachal and Haryana yet to be merged. No matches appearing in merge */
/************************************************************************/
