/************************************************************************/
/* Fix Problems with Some of the States in the DISE-village-level merge */
/************************************************************************/

/* Drop duplicate IDs for each state since these should be unique */
foreach state in andhra bihar jammukashmir tripura westbengal {
  use $tmp/village_`state', clear
  duplicates drop id, force
  save $tmp/village_`state'_clean, replace
}

/* Create pc01 ID keys for all states */
use $tmp/pc01_id, clear
keep if pc01_state_name == "andhra pradesh"
save $tmp/pc01_id_andhra, replace

use $tmp/pc01_id, clear
keep if pc01_state_name == "bihar"
save $tmp/pc01_id_bihar, replace


use $tmp/pc01_id, clear
keep if pc01_state_name == "jammu kashmir"
save $tmp/pc01_id_jammukashmir, replace


use $tmp/pc01_id, clear
keep if pc01_state_name == "tripura"
save $tmp/pc01_id_tripura, replace


use $tmp/pc01_id, clear
keep if pc01_state_name == "west bengal"
save $tmp/pc01_id_westbengal, replace

/* Masala merge for each of these states */
local states andhra bihar jammukashmir tripura westbengal

foreach x of local states {
  use $tmp/village_`x'_clean, clear

  /* masala merge with pc01 village names*/
  masala_merge pc01_state_name pc01_district_name pc01_block_name ///
    using $tmp/pc01_id_`x', s1(pc01_village_name) idmaster(id) idusing(id)

  save $tmp/village_dise_`x', replace
}

/***********************/
/* Fix Haryana Problem */
/***********************/

/* Drop dashes from village names */
use $tmp/pc01_id, clear
keep if pc01_state_name == "haryana"

replace id = subinstr(id,"-","",.)
replace id = regexr(id,"[0-9]+","")

duplicates drop id, force
save $tmp/pc01_id_haryana, replace

/* Run Masala Merge on Haryana */
use $tmp/village_haryana, clear

/* masala merge with pc01 village names*/
masala_merge pc01_state_name pc01_district_name pc01_block_name ///
  using $tmp/pc01_id_haryana, s1(pc01_village_name) idmaster(id) idusing(id)

save $tmp/village_dise_haryana, replace

/**************************/
/* Fix Too Few Quotes and Syntax Errors */
/**************************/
/* Create pc01 ID keys for all states */
use $tmp/pc01_id, clear
keep if pc01_state_name == "chhattisgarh"
save $tmp/pc01_id_chhattisgarh, replace

use $tmp/pc01_id, clear
keep if pc01_state_name == "orissa"
save $tmp/pc01_id_orissa, replace

use $tmp/pc01_id, clear
keep if pc01_state_name == "rajasthan"
save $tmp/pc01_id_rajasthan, replace

use $tmp/pc01_id, clear
keep if pc01_state_name == "uttar pradesh"
save $tmp/pc01_id_uttar, replace

use $tmp/pc01_id, clear
keep if pc01_state_name == "madhya pradesh"
save $tmp/pc01_id_madhya, replace

use $tmp/pc01_id, clear
keep if pc01_state_name == "tamil nadu"
save $tmp/pc01_id_tamilnadu, replace

/* Run Masala Merge on all states with too few quotes issue */
local states chhattisgarh orissa rajasthan uttar tamilnadu madhya

foreach state of local states {
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
 
