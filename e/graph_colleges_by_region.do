** This do file describes the relationship between female employment and ownership with regard to population sizes **

/* set global macro */
global iec1 /Users/philiplindsay/Documents/Research/Novosad/iec1
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
collapse (sum) pc*_td_p_sch pc*_td_m_sch, by (year shrid)

/* save the collapsed dataset as a temporary file and open it again */
save $tmp/school_collapse, replace
use $tmp/school_collapse, clear

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
 
 /* label "region" variable values */
label define region 0 "South India" 1 "North India"

/* collapse again, but now with the regional dummies */
collapse (sum) pc*_td_p_sch pc*_td_m_sch, by (year region)
 
/* save the collapsed dataset as a temporary file and open it again */
save $tmp/school_collapse, replace
use $tmp/school_collapse, clear

/* consolidate college variables */
egen td_p_sch = rowtotal(pc91_td_p_sch pc01_td_p_sch pc11_td_p_sch)
egen td_m_sch = rowtotal(pc91_td_m_sch pc01_td_m_sch pc11_td_m_sch)

/* graph the relationship between p_sch and year by region */
twoway (scatter td_p_sch year, mcolor(black)) ///
	(scatter td_p_sch year if region == 0, mcolor(red)) ///
	(scatter td_p_sch year if region == 1, mcolor(blue)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("td_p_sch") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 India (Total)) label(2 South India) label(3 North India))
	
/* graph the relationship between m_sch and year by region */
twoway (scatter td_m_sch year, mcolor(black)) ///
	(scatter td_m_sch year if region == 0, mcolor(red)) ///
	(scatter td_m_sch year if region == 1, mcolor(blue)), ///
	graphregion(color(white)) ///
	xtitle("Year") ytitle("td_m_sch") ///
	ylabel(, angle(0) format(%9.2f) nogrid) ///
	legend(label(1 India (Total)) label(2 South India) label(3 North India))
