/* drop duplicates in household data */
use $secc/final/dta/tripura_household_clean, clear

drop if flag_duplicates == 1

save $tmp/tripura_household_clean, replace

/* load dataset */
use $secc/final/dta/tripura_members_clean, clear
merge m:1 mord_hh_id using $tmp/tripura_household_clean

/* drop if missing village ID */
drop if mi(pc01_village_id)

/* drop if educational attainment is missing or "other" */
drop if ed == 8 | ed == -9999

/* drop if sex is not male or female */
drop if sex != 1 & sex != 2

/* drop if missing age or if age is  high */
drop if age == -9999 | age > 80

/* recode educational attainment to total years in school */
recode ed (1 = 0) (2 = 2) (3 = 5) (4 = 8) (5 = 10) (6 = 12) (7 = 14), gen(educ_years)

/* make certain educational attainment levels into dummies */

/* generate all dummy variables */
foreach edu in lit primary middle {
  gen `edu' = 0
}

replace lit = 1 if ed > 1
replace primary = 1 if ed > 2
replace middle = 1 if ed > 3

/* collapse educational attainment variables on village ID and age */
collapse (mean) educ_years lit primary middle, ///
    by(pc01_state_id pc01_village_id age sex)

/* generate sex-based educational attainment variables */
foreach edu in educ_years lit primary middle {
  gen m_`edu' = `edu' if sex == 1
}

foreach edu in educ_years lit primary middle {
  gen f_`edu' = `edu' if sex == 2
}

/* collapse again, to get rid of sex variables */
collapse (mean) m_educ_years m_lit m_primary m_middle ///
    f_educ_years f_lit f_primary f_middle, ///
    by(pc01_state_id pc01_village_id age)

/* reshape dataset to wide format, indexed by village ID */
reshape wide m_educ_years m_lit m_primary m_middle ///
    f_educ_years f_lit f_primary f_middle, ///
    i(pc01_state_id pc01_village_id) j(age)

/* merge with PC01 data */
merge 1:1 pc01_state_id pc01_village_id using $tmp/pc01_secc_merge

/* drop unmatched observations */
drop if _merge == 1

/* save merged dataset */
save $tmp/pc01_secc_merge, replace
