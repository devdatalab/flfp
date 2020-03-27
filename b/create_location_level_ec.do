/*******************************/
/* Create Local Level Datasets */
/*******************************/

/* A) SHRID Level Dataset */
/* B) District Level Dataset */
/* C) State Level Dataset */
/* D) Classify and label regions */
/* E) Region Level Dataset */
/* F) Country Averages Dataset */

/****************************/
/* A) SHRID Level Dataset   */
/****************************/

/* Load EC dataset with all years */
use $flfp/ec_flfp_all_years, clear

/* Collapse to shrid-level dataset */
collapse (sum) count* emp*, by (shrid year) 

/* Generate share of shrid employment that is female */
gen emp_f_share = emp_f / (emp_f + emp_m)

/* generate count of female-owned firms (not counting firms with missing owner) */
gen count_f_share = count_f / (count_f + count_m)

/* generate employment in female-owned firms */
gen emp_owner_f_share = emp_f_owner / (emp_m_owner + emp_f_owner)

/* Save to new shrid-level dataset */
save $flfp/ec_flfp_shrid_level, replace

/*******************************/
/* B) District Level Dataset   */
/*******************************/

/* Load EC dataset with all years */
use $flfp/ec_flfp_all_years, clear

/* Get the 2011 PC district code for each shrid */
merge m:1 shrid using $flfp/shrug_pc11_district_key
keep if _merge == 3
drop _merge

/* Collapse to district level */
drop if mi(pc11_district_id)
collapse (sum) count* emp*, by(pc11_district_id year)

/* Generate female worker share, firm share, and employment share in female-owned firms */
gen emp_f_share = emp_f / (emp_f + emp_m)
gen count_f_share = count_f / (count_f + count_m)
gen emp_owner_f_share = emp_f_owner / (emp_m_owner + emp_f_owner)

/* Save to new district-level dataset */
save $flfp/ec_flfp_district_level, replace

/****************************/
/* C) State Level Dataset   */
/****************************/

/* Load EC dataset with all years */
use $flfp/ec_flfp_all_years, clear

/* Merge with 2011 PC State Key */
merge m:1 shrid using $flfp/shrug_pc11_state_key
keep if _merge == 3
drop _merge

/* Collapse by state name */
drop if mi(pc11_state_id)
collapse (sum) count* emp*, by(pc11_state_id year)

/* Generate relevant employment statistics */
gen emp_f_share = emp_f / (emp_f + emp_m)
gen count_f_share = count_f / (count_f + count_m)
gen emp_owner_f_share = emp_f_owner / (emp_m_owner + emp_f_owner)

/* Save to new state-level dataset */
save $flfp/ec_flfp_state_level, replace

/*********************************/
/* D) Classify and label regions */
/*********************************/

/* load state key */
use $flfp/shrug_pc11_state_key, clear

/* drop if missing state name */
drop if mi(pc11_state_name) | mi(pc11_state_id)

/* create regional variable */
gen str13 region = ""

/* code hilly states */
replace region = "hilly" if inlist(pc11_state_name, "jammu kashmir", "himachal pradesh", "punjab", ///
    "uttarakhand", "haryana", "chandigarh")
 
/* code South states */
replace region = "south" if inlist(pc11_state_name, "maharashtra", "goa", "karnataka", "andhra pradesh", "kerala", "tamil nadu")
 
/* code Northeast states */
replace region = "northeast" if inlist(pc11_state_name, "sikkim", "arunachal pradesh", "assam", "nagaland", "meghalya", ///
    "manipur", "tripura", "mizoram", "meghalaya")

/* code northern states */
replace region = "north" if inlist(pc11_state_name, "rajasthan", "uttar pradesh", "bihar", "madhya pradesh", ///
    "gujarat", "jharkhand") | inlist(pc11_state_name, "nct of delhi", "odisha", "west bengal", "chhattisgarh")

/* save new regional key */
save $flfp/shrug_pc11_region_key, replace

/*****************************/
/* E) Region Level Dataset   */
/*****************************/

/* Load EC dataset with all years */
use $flfp/ec_flfp_all_years, clear

/* get the state ids for each shrid */
merge m:1 shrid using $flfp/shrug_pc11_region_key
keep if _merge == 3
drop _merge

/* drop if missing year or region */
drop if mi(year) | mi(region)

/* Collapse by region */
collapse (sum) count* emp*, by(region year)

/* Generate the female employment/entrepreneurship stats */
gen emp_f_share = emp_f / (emp_f + emp_m)
gen count_f_share = count_f / (count_f + count_m)
gen emp_owner_f_share = emp_f_owner / (emp_m_owner + emp_f_owner)

/* Save to new state-level dataset */
save $flfp/ec_flfp_region_level, replace

/*******************************************************************/
/* F) Country Averages Dataset                                     */
/* This is to be appended to the other data sets, to compare with  */
/* national trends, avoiding weighting issues                      */
/*******************************************************************/

/* Load EC dataset with all years */
use $flfp/ec_flfp_all_years, clear

/* Collapse by year */
collapse (sum) count* emp*, by (year) 

/* Generate relevant employment and ownership statistics */
gen emp_f_share = emp_f / (emp_f + emp_m)
gen count_f_share = count_f / (count_f + count_m)
gen emp_owner_f_share = emp_f_owner / (emp_m_owner + emp_f_owner)

/* Save to country-wide dataset */
save $flfp/ec_flfp_country_level, replace
