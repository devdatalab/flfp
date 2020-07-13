/***********/
/* Globals */
/***********/

global statelist andamanandnicobarislands andhrapradesh arunachalpradesh assam bihar chandigarh chhattisgarh dadraandnagarhaveli damananddiu goa gujarat haryana himachalpradesh jammukashmir jharkhand karnataka kerala lakshadweep madhyapradesh maharashtra manipur meghalaya mizoram nagaland nctofdelhi odisha puducherry punjab rajasthan sikkim tamilnadu telangana tripura uttarakhand uttarpradesh westbengal

/***************************/
/* Prepare Master  Dataset */
/***************************/

/* generate temporary dataset */
use $pc01/pc01r_pca_clean, clear

/* generate unmatched observations variable, to test later SECC and PC01 merge efficacy */
gen match_rate = .
label variable match_rate "% of villages matched between PC01 and SECC, by state"

/* save temporary dataset, for later merges */
save $tmp/pc01_secc_merge, replace

/******************************************************************/
/* Add Age-Specific Educational Attainment Data from SECC to PC01 */
/******************************************************************/

foreach state in $statelist {

  /* open household dataset */
  use $secc/final/dta/`state'_household_clean, clear

  /* drop duplicates so it's unique on household ID */
  drop if flag_duplicates == 1

  /* merge with members dataset (household data was necessary for PC01 IDs) */
  merge 1:m  mord_hh_id using $secc/final/dta/`state'_members_clean

  /* drop if missing village ID */
  drop if mi(pc01_village_id)

  /* drop if educational attainment is missing or "other" */
  drop if ed == 8 | ed == -9999

  /* drop if sex is not male or female */
  drop if sex != 1 & sex != 2

  /* drop if missing age or if age is  high */
  drop if age == -9999 | age > 80

  /*******************************************/
  /* Define Educational Attainment Variables */
  /*******************************************/
  
  /* recode educational attainment to total years in school */
  recode ed (1 = 0) (2 = 2) (3 = 5) (4 = 8) (5 = 10) (6 = 12) (7 = 14), gen(educ_years)

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
  
  /* reshape age as wide (unique on just household ID now) */
  reshape wide m_educ_years m_lit m_primary m_middle ///
      f_educ_years f_lit f_primary f_middle, ///
      i(pc01_state_id pc01_village_id) j(age)

  /* merge with PC01 data */
  merge 1:1 pc01_state_id pc01_village_id using $tmp/pc01_secc_merge

  /* generate match rate */
  egen unmatched = total(_merge == 1)
  egen matched = total(_merge == 3)
  replace match_rate = matched / (unmatched + matched)

  /* drop unmatched observations */
  drop if _merge == 1

  /* drop extraneous variables to facilitate next state merge */
  drop _merge matched unmatched

  /* save merged dataset */
  save $tmp/pc01_secc_merge, replace

}
