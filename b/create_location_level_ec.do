**Create Local Level Datasets **


**SHRID Level Dataset**

use $flfp/ec_flfp_all_years.dta, clear //Load EC dataset with all years

collapse (sum) count* emp*, by (shrid year) //Collapse to shrid-level dataset 

gen emp_f_share = emp_f/(emp_f + emp_m)	//Generate relevant employment and ownership statistics 
gen count_f_share = count_f/(count_f + count_m)
gen emp_owner_f_share = emp_f_owner/(emp_m_owner + emp_f_owner)

save $flfp/ec_flfp_shrid_level.dta, replace //Save to new shrid-level dataset

**District Level Dataset**

use $flfp/ec_flfp_all_years.dta, clear //Load EC dataset with all years

merge m:1 shrid using $flfp/shrug_pc11_district_key.dta //Merge with 2011 PC District Key

collapse (sum) count* emp*, by(pc11_district_name year) //Collapse by district name

drop if year ==. //Drop yearless district names

gen emp_f_share = emp_f/(emp_f + emp_m)	//Generate relevant employment statistics
gen count_f_share = count_f/(count_f + count_m)
gen emp_owner_f_share = emp_f_owner/(emp_m_owner + emp_f_owner)

save $flfp/ec_flfp_district_level.dta, replace //Save to new district-level dataset


**State Level Dataset**

use $flfp/ec_flfp_all_years.dta, clear //Load EC dataset with all years

merge m:1 shrid using $flfp/shrug_pc11_state_key.dta //Merge with 2011 PC State Key

collapse (sum) count* emp*, by(pc11_state_name year) //Collapse by state name

drop if year ==.	//Drop yearless state observations 

gen emp_f_share = emp_f/(emp_f + emp_m) //Generate relevant employment statistics
gen count_f_share = count_f/(count_f + count_m)
gen emp_owner_f_share = emp_f_owner/(emp_m_owner + emp_f_owner)

save $flfp/ec_flfp_state_level.dta, replace //Save to new state-level dataset

