** This do file describes the relationship between female employment and region **

/* set global macro */
global flfp $iec1/flfp

/* merge every EC dataset, '90-'13 */
use $flfp/ec_flfp_90, clear
gen year = 1990
foreach y in 1998 2005 2013 {
  append using $flfp/ec_flfp_98
  replace year = 1998 if mi(year)
  append using $flfp/ec_flfp_05
  replace year = 2005 if mi(year)
  append using $flfp/ec_flfp_13
  replace year = 2013 if mi(year)
}

/* drop any observations without shric */
drop if shric == .

/* collapse by year and shrid */
collapse (sum) emp_m emp_f emp_m_owner emp_f_owner emp_o_owner, by (year shrid)

/* save the collapsed dataset as a temporary file and open it again */
save $tmp/regional_flfp_collapse, replace
use $tmp/regional_flfp_collapse

/* merge to the shrug names dataset */
merge m:1 shrid using $flfp/shrug_names.dta

/* drop any observations without shrid */
drop if shrid == ""

/* create regional dummy */
gen region = .

/* code South Indian states */
replace region = 0 if inlist(state_name, "andaman nicobar islands", "andhra pradesh", ///
 "karnataka", "kerala", "lakshadweep", "puducherry", "tamil nadu")
 
/* code North Indian states */
 replace region = 1 if inlist(state_name, "cahndigarh", "nct of delhi", "haryana", ///
 "himachal pradesh", "jammu kashmir", "punjab", "rajasthan", "uttarakhand", "uttar pradesh")
 
/* /* encode Hindi Belt dummy */
gen hindi_belt_dummy = 0
replace hindi_belt_dummy = 1 if inlist(state_name, "bihar", "chhattisgarh", "nct of delhi", ///
"haryana", "himachal pradesh", "jharkand") | inlist(state_name, "madhya pradesh", ///
"rajasthan", "uttar pradesh", "uttarakhand") */

/* label "region" variable values */
label define region 0 "South India" 1 "North India"

/* collapse again, but now with the regional dummies */
collapse (sum) emp_f emp_m emp_m_owner emp_f_owner emp_o_owner, by (year region)

/* generate "female employment share" variable */
gen f_emp_share = (emp_f / (emp_f + emp_m))

/* generate "female owner employment share" variable */
gen f_emp_owner_share = (emp_f_owner / (emp_m_owner + emp_f_owner + emp_o_owner))
 
/* save the collapsed dataset as a temporary file and open it again */
save $tmp/regional_flfp_collapse, replace
use $tmp/regional_flfp_collapse, clear

/* graph the relationship between year and female employment share, by region */
twoway (scatter f_emp_share year, mcolor(black)) ///
	(scatter f_emp_share year if region == 0, mcolor(red)) ///
	(scatter f_emp_share year if region == 1, mcolor(blue)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("f_emp_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 India (Total)) label(2 South India) label(3 North India))

/* run it back, but now observing female firm owner numbers */
use $tmp/regional_flfp_collapse, clear
drop if year==1990

/* graph the relationship between year and female employment share, by region */
twoway (scatter f_emp_owner_share year, mcolor(black)) ///
	(scatter f_emp_owner_share year if region == 0, mcolor(red)) ///
	(scatter f_emp_owner_share year if region == 1, mcolor(blue)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("f_emp_owner_share") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 India (Total)) label(2 South India) label(3 North India))
