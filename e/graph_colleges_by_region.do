** This do file describes the relationship between female employment and ownership with regard to population sizes **

/* set global macro */
global flfp $iec1/flfp

//Load EC90
use $flfp/shrug_pc91_td, clear 
gen year = 1991
foreach y in 2001 2011 {
  append using $flfp/shrug_pc01_td
  replace year = 2001 if mi(year)
  append using $flfp/shrug_pc11_td
  replace year = 2011 if mi(year)
}

/* collapse by year and shrid */
collapse (sum) pc*_td_college, by (year shrid)

/* save the collapsed dataset as a temporary file and open it again */
save $tmp/college_collapse, replace
use $tmp/college_collapse, clear

/* merge to the shrug names dataset */
merge m:1 shrid using $flfp/shrug_names.dta

/* drop any observations without shrid */
drop if shrid == ""

/* encode South India dummy */
gen south_india_dummy = 0
replace south_india_dummy = 1 if inlist(state_name, "andaman nicobar islands", "andhra pradesh", ///
 "karnataka", "kerala", "lakshadweep", "puducherry", "tamil nadu")

/* encode North India dummy */
gen north_india_dummy = 0
replace north_india_dummy = 1 if inlist(state_name, "cahndigarh", "nct of delhi", "haryana", ///
 "himachal pradesh", "jammu kashmir", "punjab", "rajasthan", "uttarakhand", "uttar pradesh")

/* encode Hindi Belt dummy */
gen hindi_belt_dummy = 0
replace hindi_belt_dummy = 1 if inlist(state_name, "bihar", "chhattisgarh", "nct of delhi", ///
"haryana", "himachal pradesh", "jharkand") | inlist(state_name, "madhya pradesh", ///
"rajasthan", "uttar pradesh", "uttarakhand")

/* collapse again, but now with the regional dummies */
collapse (sum) pc*_td_college, by (state_name year south_india_dummy north_india_dummy hindi_belt_dummy)
 
/* save the collapsed dataset as a temporary file and open it again */
save $tmp/regional_flfp_collapse, replace
use $tmp/regional_flfp_collapse, clear

/* consolidate college variables */
egen college = rowtotal(pc91_td_college pc01_td_college pc11_td_college)

/* graphing the prior regressions */
twoway (qfit college year if south_india_dummy==1, lcolor(red)) ///
	(qfit college year if north_india_dummy==1, lcolor(blue)) ///
	(qfit college year if hindi_belt_dummy==1, lcolor(green)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("Number of Colleges") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 South India) label(2 North India) ///
	label(3 Hindi Belt))
