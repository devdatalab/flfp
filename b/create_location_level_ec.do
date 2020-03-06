/*******************************/
/* Create Local Level Datasets */
/*******************************/

/* A) SHRID Level Dataset */
/* B) District Level Dataset */
/* C) State Level Dataset */
/* D) Region Level Dataset   */

/****************************/
/* A) SHRID Level Dataset   */
/****************************/

/* Load EC dataset with all years */
use $flfp/ec_flfp_all_years.dta, clear

/* Collapse to shrid-level dataset */
collapse (sum) count* emp*, by (shrid year) 

/* Generate relevant employment and ownership statistics */
gen emp_f_share = emp_f/(emp_f + emp_m)
gen count_f_share = count_f/(count_f + count_m)
gen emp_owner_f_share = emp_f_owner/(emp_m_owner + emp_f_owner)

/* Save to new shrid-level dataset */
save $flfp/ec_flfp_shrid_level.dta, replace

/*******************************/
/* B) District Level Dataset   */
/*******************************/

/* Load EC dataset with all years */
use $flfp/ec_flfp_all_years.dta, clear

/* Merge with 2011 PC District Key */
merge m:1 shrid using $flfp/shrug_pc11_district_key.dta

/* Collapse by district name */
collapse (sum) count* emp*, by(pc11_district_name year)

/* Drop yearless district names */
drop if year == .

/* Generate relevant employment statistics */
gen emp_f_share = emp_f/(emp_f + emp_m)
gen count_f_share = count_f/(count_f + count_m)
gen emp_owner_f_share = emp_f_owner/(emp_m_owner + emp_f_owner)

/* Save to new district-level dataset */
save $flfp/ec_flfp_district_level.dta, replace

/****************************/
/* C) State Level Dataset   */
/****************************/

/* Load EC dataset with all years */
use $flfp/ec_flfp_all_years.dta, clear

/* Merge with 2011 PC State Key */
merge m:1 shrid using $flfp/shrug_pc11_state_key.dta

/* Collapse by state name */
collapse (sum) count* emp*, by(pc11_state_name year)

/* Drop yearless state observations */
drop if year == .

/* Generate relevant employment statistics */
gen emp_f_share = emp_f/(emp_f + emp_m)
gen count_f_share = count_f/(count_f + count_m)
gen emp_owner_f_share = emp_f_owner/(emp_m_owner + emp_f_owner)

/* Save to new state-level dataset */
save $flfp/ec_flfp_state_level.dta, replace

/*****************************/
/* D) Region Level Dataset   */
/*****************************/

/* Load EC dataset with all years */
use $flfp/ec_flfp_all_years.dta, clear

/* Merge with 2011 PC State Key */
merge m:1 shrid using $flfp/shrug_pc11_state_key.dta

/* create regional variable */
gen region = .

/* code North states */
replace region = 1 if inlist(pc11_state_name, "jammu kashmir", "himachal pradesh", "punjab", ///
"uttarakhand", "haryana")
 
/* code South states */
 replace region = 2 if inlist(pc11_state_name, "karnataka", "andhra pradesh", "kerala", "tamil nadu")
 
/* code North-East states */
replace region = 3 if inlist(pc11_state_name, "arunachal pradesh", "assam", "nagaland", "meghalya", ///
"manipur", "tripura", "mizoram")

/* code Central states */
replace region = 4 if inlist(pc11_state_name, "rajasthan", "uttar pradesh", "bihar", "madhya pradesh", ///
"gujarat", "jharkhand", "chattisgrah") | inlist(pc11_state_name, "odisha", "west bengal", "maharashtra")
 
/* label "region" variable values */
label define region 1 "north" 2 "south" 3 "north-east" 4 "central"
 
/* Collapse by region */
collapse (sum) count* emp*, by(region year)

/* Drop yearless observations */
drop if year == .

/* Drop regionless observations */
drop if year == .

/* Generate relevant employment statistics */
gen emp_f_share = emp_f/(emp_f + emp_m)
gen count_f_share = count_f/(count_f + count_m)
gen emp_owner_f_share = emp_f_owner/(emp_m_owner + emp_f_owner)

/* Save to new state-level dataset */
save $flfp/ec_flfp_state_level.dta, replace
