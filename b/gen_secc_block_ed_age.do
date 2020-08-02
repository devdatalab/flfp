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
  drop if ed == 8 | ed == -9999

  /* drop if sex is not male or female */
  drop if sex != 1 & sex != 2

  /* drop if outside age boundaries */
  drop if age < 0 | age > 80

  /* drop bad caste data */
  drop if sc_st == -9999 | sc_st == -9998
  
  /*******************************************/
  /* Define Educational Attainment Variables */
  /*******************************************/
  
  /* recode educational attainment to total years in school */
  recode ed (1 = 0) (2 = 2) (3 = 5) (4 = 8) (5 = 10) (6 = 12) (7 = 14), gen(secc11_educ_years)
  drop if mi(secc11_educ_years)
  
  /* generate all dummy variables */
  foreach edu in secc11_lit secc11_primary secc11_middle {
    gen `edu' = 0
  }

  /* at least literate */
  replace secc11_lit = 1 if ed > 1

  /* at least primary */
  replace secc11_primary = 1 if ed > 2

  /* at least middle */
  replace secc11_middle = 1 if ed > 3

  /* generate sex-based educational attainment variables */
  foreach edu of varlist secc11* {
    gen `edu'_m = `edu' if sex == 1
    gen `edu'_f = `edu' if sex == 2
  }

  /* drop intermediate variables */
  drop secc11_educ_years secc11_lit secc11_primary secc11_middle

  /* generate ST/SC educational attainment variables */
  foreach edu of varlist secc11* {
    gen `edu'_sc = `edu' if sc_st == 1
    gen `edu'_st = `edu' if sc_st == 2
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

  /* generate %  match rate */
  egen unmatched = total(_merge == 1)
  egen matched = total(_merge == 3)
  gen match_rate = matched / (unmatched + matched)

  /* drop unmatched observations */
  keep if _merge == 3

  /* drop extraneous variables */
  drop _merge matched unmatched

  /* save merged dataset */
  save $tmp/`state'_pc01_secc_merge, replace

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
  append using $tmp/`state'_pc01_secc_merge
}

/* drop villages with low populations */
drop if pc01_pca_tot_p < 100

/*******************************************/
/* Generate ST/SC Population Counts by Age */
/*******************************************/

/* female SC/ST population by age cohort (via population pyramid) */
/* use population pyramid to get absolute estimates for SC/ST pop */
foreach caste of varlist pc01_pca_f_sc pc01_pca_f_st {
  forvalues age = 0/4 {
    gen `caste'_`age' = `caste' * 0.0208
  }
  forvalues age = 5/9 {
    gen `caste'_`age' = `caste' * 0.0214
  }
  forvalues age = 10/19 {
    gen `caste'_`age' = `caste' * 0.0224
  }
  forvalues age = 20/24 {
    gen `caste'_`age' = `caste' * 0.0219
  }
  forvalues age = 25/29 {
    gen `caste'_`age' = `caste' * 0.0208
  }
  forvalues age = 30/34 {
    gen `caste'_`age' = `caste' * 0.0203
  }
  forvalues age = 35/39 {
    gen `caste'_`age' = `caste' * 0.0188
  }
}

/* male SC/ST population by age cohort (via population pyramid) */
/* use population pyramid to get absolute estimates for SC/ST pop */
foreach caste of varlist pc01_pca_m_sc pc01_pca_m_st {
  forvalues age = 0/4 {
    gen `caste'_`age' = `caste' * 0.0212
  }
  forvalues age = 5/9 {
    gen `caste'_`age' = `caste' * 0.0216
  }
  forvalues age = 10/19 {
    gen `caste'_`age' = `caste' * 0.0231
  }
  forvalues age = 20/24 {
    gen `caste'_`age' = `caste' * 0.0226
  }
  forvalues age = 25/29 {
    gen `caste'_`age' = `caste' * 0.0216
  }
  forvalues age = 30/34 {
    gen `caste'_`age' = `caste' * 0.0207
  }
  forvalues age = 35/39 {
    gen `caste'_`age' = `caste' * 0.0188
  }
}

/* drop intermediate variables */
drop pc01_pca_f_sc pc01_pca_f_st pc01_pca_m_sc pc01_pca_m_st

/*********************************/
/* Standardize Formatting & Save */
/*********************************/

/* collapse to block level */
collapse (mean) secc11* (sum) pc01_pca_f_s* pc01_pca_m_s* (first) match_rate ///
    [w = pc01_pca_tot_p], ///
    by(pc01_state_id pc01_state_name pc01_district_id pc01_district_name ///
    pc01_block_id pc01_block_name)

/* destring */
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* save final dataset */
save $ebb/secc_block_ed_age_clean.dta, replace
