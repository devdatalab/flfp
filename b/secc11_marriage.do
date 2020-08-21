/***********/
/* Globals */
/***********/

/* global of state names */
global statelist andamanandnicobarislands andhrapradesh arunachalpradesh assam bihar chandigarh chhattisgarh dadraandnagarhaveli damananddiu goa gujarat haryana himachalpradesh jammukashmir jharkhand karnataka kerala lakshadweep madhyapradesh maharashtra manipur meghalaya mizoram nagaland nctofdelhi odisha puducherry punjab rajasthan sikkim tamilnadu tripura uttarakhand uttarpradesh westbengal

/* states with PC01 IDs in household dataset */
global statelist1 andamanandnicobarislands andhrapradesh arunachalpradesh assam bihar chandigarh chhattisgarh dadraandnagarhaveli damananddiu goa gujarat haryana himachalpradesh jammukashmir jharkhand kerala lakshadweep madhyapradesh maharashtra manipur meghalaya mizoram nagaland nctofdelhi odisha puducherry sikkim tamilnadu tripura uttarakhand uttarpradesh westbengal

/* these states don't have PC01 IDs in the SECC datasets */
global statelist2 karnataka punjab rajasthan

/*********************************/
/* Add PC01 Codes to SECC States */
/*********************************/

/* add codes using household data for statelist 1 */
foreach state in $statelist1 {

  /* open household dataset */
  use $secc/final/dta/`state'_household_clean, clear

  /* drop duplicates so it's unique on household ID */
  drop if flag_duplicates == 1

  /* merge with members dataset (household data was necessary for PC01 IDs) */
  merge 1:m  mord_hh_id using $secc/final/dta/`state'_members_clean

  /* drop unmerged */
  drop if _merge != 3
  drop _merge

  /* save as temporary dataset */
  save $tmp/`state'_members_clean, replace

}  

/* add codes using PC01 ID key for remaining states */
foreach state in $statelist2 {

  /* open members dataset */
  use $secc/final/dta/`state'_members_clean, clear

  /* add PC01 codes to datasets */
  merge m:1 pc11_state_id pc11_village_id using $keys/pcec/pc01r_pc11r_key

  /* drop unmerged */
  drop if _merge != 3
  drop _merge

  /* save as temporary dataset */
  save $tmp/`state'_members_clean, replace

}

/******************************************************************/
/* Add Age-Specific Educational Attainment Data from SECC to PC01 */
/******************************************************************/

foreach state in $statelist {

  /*********************/
  /* Drop Missing Data */
  /*********************/

  /* open dataset */
  use $tmp/`state'_members_clean, clear
  
  /* drop if missing village ID */
  drop if mi(pc01_village_id)

  /* drop if educational attainment is missing or "other" */
  drop if marital == -9999 | marital == -9998

  /* drop if sex is not male or female */
  drop if sex != 1 & sex != 2

  /* drop if outside age boundaries */
  drop if age < 0 | age > 80

  /* drop bad caste data */
  drop if sc_st == -9999 | sc_st == -9998
  
  /***************************************/
  /* Define Education/Marriage Variables */
  /***************************************/
  
  /* generate marital dummy  */
  gen secc11_evermarried = 0 if marital == 1
  replace secc11_evermarried = 1 if inlist(marital, 2, 3, 4, 5)

  /* generate sex-based marriage variables */
  gen secc11_evermarried_f = secc11_evermarried if sex == 2
  gen secc11_evermarried_m = secc11_evermarried if sex == 1

  /* drop sex-less intermediate variable */
  drop secc11_evermarried
  
  /* generate ST/SC educational attainment variables */
  foreach var of varlist secc11* {
    gen `var'_sc = `var' if sc_st == 1
    gen `var'_st = `var' if sc_st == 2
  }
  
  /* collapse again, but now unique on household ID and age */
  collapse (mean) secc11*, ///
      by(pc01_state_id pc01_village_id age)

  /**********************************/
  /* Merge with Master PC01 Dataset */
  /**********************************/
  
  /* reshape age as wide (unique on just village ID now) */
  reshape wide secc11*, ///
      i(pc01_state_id pc01_village_id) j(age)

  /* merge with PC01 data */
  merge 1:1 pc01_state_id pc01_village_id using $pc01/pc01r_pca_clean
  keep if _merge == 3
  drop _merge

  /* save merged dataset */
  save $tmp/`state'_marriage_merge, replace

}

/**********************************/
/* Append Temporary SECC Datasets */
/**********************************/

clear

/* declare temporary variable name */
tempvar temp
set obs 0

/* set temporary variable to missing */
gen `temp' = .

/* append PC01 and SECC merge temporary files to create master file */
foreach state in $statelist {
  append using $tmp/`state'_marriage_merge
}

/* drop villages with low populations */
drop if pc01_pca_tot_p < 100

/* destring */
destring pc01_state_id pc01_district_id pc01_block_id pc01_village_id, replace

/***************************/
/* Save Collapsed Datasets */
/***************************/

/* collapse to village level */
collapse (mean) secc11* [w = pc01_pca_tot_p], ///
    by(pc01_state_id pc01_state_name pc01_district_id pc01_district_name ///
    pc01_block_id pc01_block_name pc01_village_id pc01_village_name)

/* save dataset */
save $ebb/secc_village_marriage, replace

/* collapse to block level */
collapse (mean) secc11*, ///
    by(pc01_state_id pc01_state_name pc01_district_id pc01_district_name ///
    pc01_block_id pc01_block_name)

/* save dataset */
save $ebb/secc_block_marriage, replace
