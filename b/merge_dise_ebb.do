********************************************
**** MERGE DISE DATA WITH PC01 AND EBBS ****
********************************************

/* use new-old dise dataset */
use $tmp/dise_old_new, clear

/* merge with DISE-PC01 key */
merge m:1 dise_state district dise_block_name using $ebb/pc01_dise_key

/* keep matches */
keep if _merge == 3

/* drop merge variable*/
drop _merge

/* add prefix to faciliy variables for collapse */
foreach var in blackboard num_classrooms toilet_boys elec library ///
     toilet_common toilet_girls wall playground water {
  rename `var' facility_`var'
}

/* collapse at block level */
collapse (sum) pass* m60* facility* enr*, by(year ///
    pc01_state_id pc01_district_id pc01_block_id pc01_state_name pc01_district_name pc01_block_name)

/* merge EBB-NPEGEL-KGBV data */
merge m:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/treated_list_clean

/* drop unmatched obs */
keep if _merge == 3

/* drop merge variable  */
drop _merge

/* save dataset */
save $iec/flfp/dise_pc01_ebb, replace
