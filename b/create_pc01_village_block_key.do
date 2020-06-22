/**************************/
/* Clean PC01 state files */
/**************************/

/* create a local for the state file names */
local file_list 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 ///
    17 18 19 20 21 23 24 25 26 27 28 29 30 31 32 33 34 35

/* loop through each of the state files */
foreach i of local file_list {

  /* use each PC01 raw data state file */
  use $pc01/location_codes/CDmain/Village/DIR-`i', clear

  /* the c5 variable contains district and state names, so this creates
  a new state name variable with the observation containing that name */
  gen pc01_state_name = c5 if c2 == "00"

  /* add that state name to all the other observations */
  replace pc01_state_name = pc01_state_name[_n-1] if missing(pc01_state_name)

  /* drop the top variable which lists what c1-c7 mean */
  drop if mi(pc01_state_name)

  /* rename variables using standard DDL formatting */
  ren c1 pc01_state_id
  ren c2 pc01_district_id
  ren c6 pc01_block_id
  ren c7 pc01_block_name

  /* make names lowercase */
  replace pc01_state_name = lower(pc01_state_name)
  replace pc01_block_name = lower(pc01_block_name)

  /* drop higher level observations that indicate no block */
  drop if mi(pc01_block_name)

  /* keep new variables, dropping the rest */
  collapse (firstnm) pc01_state_id pc01_state_name pc01_district_id, ///
      by(pc01_block_id pc01_block_name)
  
  /* save clean dataset as a temporary file */
  save $tmp/DIR-`i'-clean, replace
  
}

/* have to clean chhattisgarh separately, since the block-level variables have
different names than other state files (general commands and logic are the same as the loop) */

use $pc01/location_codes/CDmain/Village/DIR-22, clear

gen pc01_state_name = c5 if c2 == "00"
replace pc01_state_name = pc01_state_name[_n-1] if missing(pc01_state_name)
replace pc01_state_name = lower(pc01_state_name)
drop if mi(pc01_state_name)

ren c1 pc01_state_id
ren c2 pc01_district_id

/* these two commands are the only difference from the former loop */
ren c8 pc01_block_id
ren c9 pc01_block_name

replace pc01_block_name = lower(pc01_block_name)
drop if mi(pc01_block_name)

collapse (firstnm) pc01_state_id pc01_state_name pc01_district_id, ///
    by(pc01_block_id pc01_block_name)

save $tmp/DIR-22-clean, replace

/*************************************************************/
/* Append clean data files to create a master list block key */
/*************************************************************/

clear

/* create another local for the file names */
local file_list 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 ///
    17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35

/* create an empty dataset (an append loop has to append to something
in the first iteration of the loop) */
set obs 1
gen pc01_state_name = "."
gen pc01_state_id = "."
gen pc01_district_id = "."
gen pc01_block_id = "."
gen pc01_block_name = "."

/* append all of the clean PC01 files together */
foreach i of local file_list {
  append using $tmp/DIR-`i'-clean
}

/* drop the empty observation produced when creating an empty dataset */
drop in 1

/* clean block names (was creating issues for masala merge) */
name_clean pc01_block_name, replace

/* generate duplicate observation variable */
sort pc01_state_id pc01_district_id pc01_block_name
quietly by pc01_state_id pc01_district_id pc01_block_name: gen dup = cond(_N==1,0,_n)

/* drop all duplicate occurences */
drop if dup > 1
drop dup

/* generate unique identifiers (necessary for later masala merges) */
gen id = _n

/* convert string IDs to numeric */
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* save dataset */
save $ebb/pc01_village_block_key, replace
