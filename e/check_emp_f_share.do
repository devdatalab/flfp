// working do file to check emp_f_share

use $flfp/ec_flfp_13.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

/* collapse employment numbers by "shric" */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)

ds

foreach var in `r(varlist)' {
      rename `var' `var'13
}

rename shric13 shric

save $tmp/work/ec13new.dta, replace

// 2005

use $flfp/ec_flfp_05.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

/* collapse employment numbers by "shric" */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)

ds

foreach var in `r(varlist)' {
      rename `var' `var'5 
}

rename shric5 shric

merge 1:1 shric using $tmp/work/ec13new.dta
drop _merge

save $tmp/work/ec05new.dta, replace

// 1998

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

// 1990

use $flfp/ec_flfp_90.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

/* collapse employment numbers by "shric" */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)

ds

foreach var in `r(varlist)' {
      rename `var' `var'90
}

rename shric90 shric

merge 1:1 shric using $tmp/work/ec98new.dta

drop _merge

save $tmp/work/ec90new.dta, replace

// Reshape to make shric-year pairs

reshape long emp_f emp_m, i(shric) j(year)

//Recode the year variable as actual numbers


replace year = 1990 if year == 90 
replace year = 1998 if year == 98
replace year = 2005 if year == 5
replace year = 2013 if year == 13

gen share = emp_f/(emp_m+emp_f)

// Gen total variables

bysort year: egen tot_emp_f=total(emp_f)
bysort year: egen tot_emp_m=total(emp_m)

gen tot_emp_f_share = tot_emp_f/(tot_emp_f+tot_emp_m)


// graph

line tot_emp_f_share year, title( Female Employment Share by Year)
graph export $tmp/work/empf.png, replace as(png)


