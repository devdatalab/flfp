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
  use $secc/final/dta/`state'_members_clean, clear

  /* drop duplicates so it's unique on household ID */
  drop if flag_duplicates == 1

  /* merge with members dataset (household data was necessary for PC01 IDs) */
  merge 1:m  mord_hh_id using $secc/final/dta/`state'_members_clean

  /* save as temporary dataset */
  save $tmp/`state'_members_clean

}  

/* add codes using PC01 ID key for remaining states */
foreach state in $statelist2 {

  /* open members dataset */
  use $secc/final/dta/`state'_members_clean, clear

  /* add PC01 codes to datasets */
  merge m:1 pc11_state_id pc11_village_id using $keys/pcec/pc01r_pc11r_key

  /* save as temporary dataset */
  save $tmp/`state'_members_clean

}

/******************************************************************/
/* Add Age-Specific Educational Attainment Data from SECC to PC01 */
/******************************************************************/

foreach state in $statelist {

  /*********************/
  /* Drop Missing Data */
  /*********************/
  
  /* drop if missing village ID */
  drop if mi(pc01_village_id)

  /* drop if educational attainment is missing or "other" */
  drop if ed == 8 | ed == -9999

  /* drop if sex is not male or female */
  drop if sex != 1 & sex != 2

  /* drop if outside age boundaries */
  drop if age < 0 | age > 80

  /*******************************************/
  /* Define Educational Attainment Variables */
  /*******************************************/
  
  /* recode educational attainment to total years in school */
  recode ed (1 = 0) (2 = 2) (3 = 5) (4 = 8) (5 = 10) (6 = 12) (7 = 14), gen(educ_years)
  drop if mi(educ_years)

  /* generate all dummy variables */
  foreach edu in lit primary middle {
    gen `edu' = 0
  }
  
  /* at least literate */
  replace lit = 1 if ed > 1

  /* at least primary */
  replace primary = 1 if ed > 2

  /* at least middle */
  replace middle = 1 if ed > 3

  /* collapse educational attainment variables on village ID and age */
  collapse (mean) educ_years lit primary middle, ///
      by(pc01_state_id pc01_village_id age sex)

  /* generate sex-based educational attainment variables */
  foreach edu in educ_years lit primary middle {
    gen m_`edu' = `edu' if sex == 1
    gen f_`edu' = `edu' if sex == 2
  }

  /* collapse again, but now unique on household ID and age */
  collapse (mean) m_educ_years m_lit m_primary m_middle ///
      f_educ_years f_lit f_primary f_middle, ///
      by(pc01_state_id pc01_village_id age)

  /**********************************/
  /* Merge with Master PC01 Dataset */
  /**********************************/
  
  /* reshape age as wide (unique on just village ID now) */
  reshape wide m_educ_years m_lit m_primary m_middle ///
      f_educ_years f_lit f_primary f_middle, ///
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

/*********************************/
/* Standardize Formatting & Save */
/*********************************/

/* collapse to block level */
collapse (mean) m_educ_years* m_lit* m_primary* m_middle* ///
    f_educ_years* f_lit* f_primary* f_middle* (first) match_rate, ///
    by(pc01_state_id pc01_state_name pc01_district_id pc01_district_name ///
    pc01_block_id pc01_block_name)

/* destring IDs */
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* make all string variables lowercase */
foreach var of varlist _all {
	local vartype: type `var'
	if substr("`vartype'", 1,3) == "str" {
		replace `var'= ustrlower(`var')
	}
}

/* save final dataset */
save $ebb/secc_block_ed_age_clean.dta, replace
