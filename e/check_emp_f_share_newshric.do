********************************************
// FEMALE EMPLOYMENT AND ENTREPRENEURSHIP //
********************************************

********************************************
/////////// TABLE OF CONTENTS //////////////
********************************************
//1. Collapse & Merge EC13, 05, 98, and 90//
//2. Create a table with summary statistics/
//3. Generate graphs, total and by industry/
********************************************

********************************************
//1. Collapse & Merge EC13, 05, 98, and 90//
********************************************


// Use EC2013 as base dataset

use $flfp/ec_flfp_13.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

/* collapse employment numbers by "shric" */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)

// rename all EC13 varibles with unique suffix
ds

foreach var in `r(varlist)' {
      rename `var' `var'13
}

rename shric13 shric

// save edited EC13

save $tmp/work/ec13new.dta, replace

// Merge EC2005

// Use EC05 for editing
use $flfp/ec_flfp_05.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

/* collapse employment numbers by "shric" */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)

// rename all EC05 varibles with unique suffix

ds

foreach var in `r(varlist)' {
      rename `var' `var'5 
}

rename shric5 shric

// Merge with edited EC13

merge 1:1 shric using $tmp/work/ec13new.dta
drop _merge

// Save merged dataset
save $tmp/work/ec05new.dta, replace

// Merge EC1998

use $flfp/ec_flfp_98.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

/* collapse employment numbers by "shric" */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)

ds

foreach var in `r(varlist)' {
      rename `var' `var'98
}

rename shric98 shric

merge 1:1 shric using $tmp/work/ec05new.dta

drop _merge

save $tmp/work/ec98new.dta, replace

// Merge EC1990

use $flfp/ec_flfp_90.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

/* collapse employment numbers by "shric" */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)

// rename all EC98 varibles with unique suffix

ds

foreach var in `r(varlist)' {
      rename `var' `var'90
}

rename shric90 shric

// Merge with edited dataset containg EC13 and EC05
merge 1:1 shric using $tmp/work/ec98new.dta

drop _merge

// Save merged dataset
save $tmp/work/ec90new.dta, replace

use $tmp/work/ec90new.dta, clear

// Merge with new shric classification (17 industries)

merge 1:1 shric using $tmp/new_shric_descriptions.dta

drop shric shric_desc

rename new_shric shric

rename new_shric_desc shric_desc

collapse (sum) emp* count*, by(shric shric_desc)

// Reshape to make shric-year pairs

reshape long emp_f count_f emp_f_owner emp_m count_m emp_m_owner, i(shric) j(year)


// Keep employment and ownership related variables

keep shric year shric_desc emp_f count_f emp_f_owner emp_m count_m emp_m_owner


// Recode the year variable as actual numbers

replace year = 1990 if year == 90 
replace year = 1998 if year == 98
replace year = 2005 if year == 5
replace year = 2013 if year == 13

save $tmp/work/ecnew.dta, replace

********************************************
//2. Create a table with key statistics/////
********************************************


// Gen emp_f share variable 

gen emp_f_share = emp_f/(emp_m+emp_f)
gen count_f_share = count_f/(count_f+count_m)
gen emp_f_owner_share = emp_f_owner/(emp_f_owner+emp_m_owner)

sort shric year


// Gen fshare_growth


gen fshare_growth = .
forval i = 1/17 {
  display `i'
  reg emp_f_share year if shric == `i'
  replace fshare_growth = _b["year"] if shric == `i'
}

// fshare summary stats

tabstat fshare_growth, by(shric)

// Gen absolute emp_f growth variable

xtset shric year

by shric (year), sort: gen empfgrowth = L0.emp_f - L23.emp_f

// Gen total emp_f variable

gen emp_tot = emp_f + emp_m

// empfpredicted: (female share in 1990)*(emp_f in 2013)

gen fshare1990 = emp_f_share if year==1990

replace fshare1990 = fshare1990[_n-1] if fshare1990==.

by shric (year): gen empfpredicted = fshare1990 * emp_tot if year==2013

// Gen residual emp_f: predicted emp_f - actual emp_f in 2013

by shric (year): gen empfresidual = (emp_f) - (empfpredicted) if year==2013

// Create a table with all interest variables


outsheet shric shric_desc empfgrowth fshare_growth empfpredicted empfresidual emp_f emp_m using $tmp/empfshare1.csv if year == 2013, comma replace

outsheet emp_f emp_m using $tmp/empfshare2.csv if year==1990, replace

appendfile $tmp/empfshare2.csv $tmp/empfshare1.csv

********************************************
//3. Generate graphs, total and by industry/
********************************************

// Total emp_f/count_f/emp_f_owner

// Gen total variables

bysort year: egen tot_emp_f=total(emp_f)
bysort year: egen tot_emp_m=total(emp_m)
bysort year: egen tot_count_f=total(count_f)
bysort year: egen tot_count_m=total(count_m)
bysort year: egen tot_emp_f_owner=total(emp_f_owner)
bysort year: egen tot_emp_m_owner=total(emp_m_owner)

// Gen total share variables

gen tot_emp_f_share = tot_emp_f/(tot_emp_f+tot_emp_m)
gen tot_count_f_share = tot_count_f/(tot_count_f+tot_count_m)
gen tot_emp_f_owner_share=tot_emp_f_owner/(tot_emp_f_owner+tot_emp_m_owner)

// Graph total emp_f/count_f/emp_f_owner

// emp_f_share

line tot_emp_f_share year, title( Female Employment Share by Year) xtitle(Year) ytitle(Female Employment Share)
graph export $tmp/work/newtotempf.png, replace as(png)

// count_f_share

line tot_count_f_share year if year~=1990, title( Female Owned Firms Share by Year) xtitle(Year) ytitle(Female Owned Firms Share)
graph export $tmp/work/newtotcountf.png, replace as(png) 

//emp_f_owner_share

line tot_emp_f_owner_share year if year~=1990, title( Employment in Female Owned Firms Share by Year) xtitle(Year) ytitle(Employment in female Owned Firms Share)
graph export $tmp/work/newtotemp_f_share.png, replace as(png)


// Graph by industry: emp_f/count_f/emp_f_owner

//emp_f_share

graph twoway line emp_f_share year, by(shric_desc) xtitle(Year) ytitle(Female Employment Share)
graph export $tmp/work/newempfindustry.png, replace as(png) width(16000) height(13000)

//count_f_share

graph twoway line count_f_share year if year~=1990, by(shric_desc) xtitle(Year) ytitle(Female Owned Firms Share)
graph export $tmp/work/newcountfindustry.png, replace as(png) width(16000) height(13000)

//emp_f_owner_share
graph twoway line emp_f_owner_share year if year~=1990, by(shric_desc) xtitle(Year) ytitle(Employment in female Owned Firms Share)
graph export $tmp/work/newempfshareindustry.png, replace as(png) width(16000) height(13000)

********************************************************************************
