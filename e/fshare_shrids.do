
********************************************
//*****CHECK MISSING SHRICS HYPOTHESIS****//
********************************************


******************************
//Merging datasets
******************************

// Use EC2013 as base dataset

use $flfp/ec_flfp_13.dta, clear

/* drop any observations without "shrid" */
drop if shrid == ""


/* collapse employment numbers */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner

// gen a common variable for merging datasets
gen same = 1


ds

foreach var in `r(varlist)' {
      rename `var' `var'13
}

rename same13 same

// save edited EC13

save $tmp/work/ec13newshrid.dta, replace

// Merge EC2005

// Use EC05 for editing
use $flfp/ec_flfp_05.dta, clear

/* drop any observations without "shrid" */

drop if shrid == ""

/* collapse employment numbers */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner

gen same =1

// rename all EC05 varibles with unique suffix

ds

foreach var in `r(varlist)' {
      rename `var' `var'5 
}

rename same5 same

// Merge with edited EC13

merge 1:1 same using $tmp/work/ec13newshrid.dta
drop _merge

// Save merged dataset
save $tmp/work/ec05newshrid.dta, replace


// Merge EC1998

use $flfp/ec_flfp_98.dta, clear

/* drop any observations without "shrid" */

drop if shrid == ""

/* collapse employment numbers */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner

gen same =1

ds

foreach var in `r(varlist)' {
      rename `var' `var'98
}

rename same98 same

merge 1:1 same using $tmp/work/ec05newshrid.dta

drop _merge

save $tmp/work/ec98newshrid.dta, replace

// Merge EC1990

use $flfp/ec_flfp_90.dta, clear

/* drop any observations without "shrid" */

drop if shrid == ""


/* collapse employment numbers */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner

gen same =1

// rename all EC98 varibles with unique suffix

ds

foreach var in `r(varlist)' {
      rename `var' `var'90
}

rename same90 same

// Merge with edited dataset containg EC13 and EC05

merge 1:1 same using $tmp/work/ec98newshrid.dta

drop _merge

// Save merged dataset
save $tmp/work/ec90newshrid.dta, replace

use $tmp/work/ec90newshrid.dta, clear


******************************
//RESHAPING
******************************



// Reshape to make same-year pairs

reshape long emp_f count_f emp_f_owner emp_m count_m emp_m_owner, i(same) j(year)


// Keep employment and ownership related variables

keep same year emp_f count_f emp_f_owner emp_m count_m emp_m_owner


// Recode the year variable as actual numbers

replace year = 1990 if year == 90 
replace year = 1998 if year == 98
replace year = 2005 if year == 5
replace year = 2013 if year == 13

save $tmp/work/ecnewshrid.dta, replace

gen fshare= emp_f/(emp_m+emp_f)

sort same year

// graphing

graph twoway line fshare year, title(Female Employment Share by Year) note(Drops only missing shrids.) ytitle(Female Share of Employment) xtitle(Year)
graph export $tmp/work/missingshridsempf.png, replace as(png)
