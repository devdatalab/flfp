** This do file describes the relationship between female employment and region **

/* set global macro */
global iec1 /Users/philiplindsay/Documents/Research/Novosad/iec1
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

/* save the collapsed dataset as a temporary file and open it again */
save $tmp/regional_flfp_collapse, replace
use $tmp/regional_flfp_collapse

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
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner ///
 emp_o_owner, by (state_name year south_india_dummy north_india_dummy hindi_belt_dummy)
 
/* save the collapsed dataset as a temporary file and open it again */
save $tmp/regional_flfp_collapse, replace
use $tmp/regional_flfp_collapse

/* generate "total employment" variable */
gen emp_total = emp_f + emp_m

/* generate "total employment" variable */
gen count_total = count_f + count_m + count_o

/* run regressions of female employment on regional dummies by year */
reg emp_f c.emp_total##i.year i.south_india_dummy##i.year, robust

reg emp_f c.emp_total##i.year i.north_india_dummy##i.year, robust

reg emp_f c.emp_total##i.year i.hindi_belt_dummy##i.year, robust

reg count_f c.count_total##i.year i.south_india_dummy##i.year, robust 

reg count_f c.count_total##i.year i.north_india_dummy##i.year, robust

reg count_f c.count_total##i.year i.hindi_belt_dummy##i.year, robust	

/* graphing the results of the first three regressions, with population control */
reg emp_f c.emp_total##i.year if south_india_dummy == 1
predict xb_southindia, xb
reg emp_f c.emp_total##i.year if north_india_dummy == 1
predict xb_northindia, xb
reg emp_f c.emp_total##i.year if hindi_belt_dummy == 1
predict xb_hindibelt, xb
twoway (scatter xb_southindia year, mcolor(red)) ///
	(qfit xb_southindia year, lcolor(red)) ///
	(scatter xb_northindia year, mcolor(blue)) ///
	(qfit xb_northindia year, lcolor(blue)) ///
	(scatter xb_hindibelt year, mcolor(yellow)) ///
	(qfit xb_hindibelt year, lcolor(yellow)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("Female Employment") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 South India) label(2 South India Fitted) label(3 North India) ///
	label(4 North India Fitted) label(5 Hindi Belt) label(6 Hindi Belt Fitted))
