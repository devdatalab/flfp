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
  append using $flfp/ec_flfp_98
  replace year = 2013 if mi(year)
}

/* collapse by year and shrid */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (year shrid)

/* merge to the shrug names dataset */
merge m:1 shrid using $flfp/shrug_names.dta

/* drop any observations without shrid */
drop if shrid == ""

/* encode South India dummy */
gen south_india_dummy = 0
replace south_india_dummy = 1 if inlist(state_name, "andaman nicobar islands", "andhra pradesh", "karnataka", "kerala", "lakshadweep", "puducherry", "tamil nadu")

/* encode North India dummy */
gen north_india_dummy = 0
replace north_india_dummy = 1 if inlist(state_name, "cahndigarh", "nct of delhi", "haryana", "himachal pradesh", "jammu kashmir", "punjab", "rajasthan", "uttarakhand", "uttar pradesh")

/* encode Hindi Belt dummy */
gen hindi_belt_dummy = 0
replace hindi_belt_dummy = 1 if inlist(state_name, "bihar", "chhattisgarh", "nct of delhi", "haryana", "himachal pradesh", "jharkand") | inlist(state_name, "madhya pradesh", "rajasthan", "uttar pradesh", "uttarakhand")

/* collapse again, but now with the regional dummies */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (state_name year south_india_dummy north_india_dummy hindi_belt_dummy)

/* run a bunch of regressions */
reg emp_f i.south_india_dummy##i.year, robust 
estimates store reg1

reg emp_f i.north_india_dummy##i.year, robust
estimates store reg2

reg emp_f i.hindi_belt_dummy##i.year, robust
estimates store reg3

reg count_f i.south_india_dummy##i.year, robust 
estimates store reg4

reg count_f i.north_india_dummy##i.year, robust
estimates store reg5

reg count_f i.hindi_belt_dummy##i.year, robust
estimates store reg6
