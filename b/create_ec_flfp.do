/*************************************************************/
/* CREATE SHRUG-ECONOMIC CENSUS WITH FEMALE WORK BY INDUSTRY */
/*************************************************************/

/* loop over economic census years */
foreach y in 90 98 05 13 {

  /* FIRST, COLLAPSE TO GET FEMALE EMPLOYMENT */
  
  /* open the pre-collapsed economic census with firm-level data */
  use $ec_collapsed/ec`y'_uncollapsed_clean, clear

  /* drop if the shric is missing-- these places are not consistently coded across years */
  drop if mi(shric)
  
  /* drop if missing shrids-- can't match them to anything */
  drop if mi(shrid)
  
  /* if this is 1990, just set all owners to men so we can collapse w/the same code */
  if `y' == 90 gen owner_sex = 1
  
  /* keep vars we need for female ownership */
  keep shrid shric owner_sex emp_all emp_m emp_f

  /* Note: keep gender other -- seems to be a subset of firms that was
           not classified by owner, e.g. gov-owned, and some others */

  /* create separate employment vars so we can collapse into one row */
  gen emp_m_owner = emp_all if owner_sex == 1
  gen emp_f_owner = emp_all if owner_sex == 2
  gen emp_o_owner = emp_all if owner_sex == 9

  /* calculate female employment in firms of different owner genders */
  gen emp_f_with_m_owner = emp_f if owner_sex == 1
  gen emp_f_with_f_owner = emp_f if owner_sex == 2
  gen emp_f_with_o_owner = emp_f if owner_sex == 9

  /* create count variables for male, female, and other owned firms */
  gen count_m = 1 if owner_sex == 1
  gen count_f = 1 if owner_sex == 2
  gen count_o = 1 if owner_sex == 9

  collapse (sum) count_* emp_*_owner emp_m emp_f, by(shrid shric)

  compress
  save $tmp/ec_flfp_`y', replace
}


/* append all the EC FLFP files and add a year variable */
use $tmp/ec_flfp_90
gen year = 90

foreach y in 98 05 13 {
  append using $tmp/ec_flfp_`y'
  replace year = `y' if mi(year)
}

recode year 90=1990 98=1998 5=2005 13=2013
compress
save $tmp/ec_flfp_all_years, replace
