// working do file to check emp_f_share.count_share share/emp_f_owner share



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

*/

use $tmp/work/ec90new.dta, clear

// Merge to new shric classification (17 industries)

merge 1:1 shric using $tmp/new_shric_descriptions.dta

drop shric shric_desc

rename new_shric shric

rename new_shric_desc shric_desc

collapse (sum) emp* count*, by(shric shric_desc)



// Reshape to make shric-year pairs

reshape long emp_f count_f emp_f_owner emp_m count_m emp_m_owner, i(shric) j(year)


keep shric year shric_desc emp_f count_f emp_f_owner emp_m count_m emp_m_owner


//Recode the year variable as actual numbers


replace year = 1990 if year == 90 
replace year = 1998 if year == 98
replace year = 2005 if year == 5
replace year = 2013 if year == 13

// Gen emp_f share variable 

gen emp_f_share = emp_f/(emp_m+emp_f)
gen count_f_share = count_f/(count_f+count_m)
gen emp_f_owner_share = emp_f_owner/(emp_f_owner+emp_m_owner)

sort shric year


// Gen fshare_growth


gen fshare_growth = .
forval i = 1/17 {
  display `i'
  reg share year if shric == `i'
  replace fshare_growth = _b["year"] if shric == `i'
}

tabstat fshare_growth, by(shric)



//*********************************//
//////////////GRAPHING///////////////
//*********************************//

// Total emp_f/count_f/emp_f_owner

// Gen total variables

bysort year: egen tot_emp_f=total(emp_f)
bysort year: egen tot_emp_m=total(emp_m)
bysort year: egen tot_count_f=total(count_f)
bysort year: egen tot_count_m=total(count_m)
bysort year: egen tot_emp_f_owner=total(emp_f_owner)
bysort year: egen tot_emp_m_owner=total(emp_m_owner)

gen tot_emp_f_share = tot_emp_f/(tot_emp_f+tot_emp_m)
gen tot_count_f_share = tot_count_f/(tot_count_f+tot_count_m)
gen tot_emp_f_owner_share=tot_emp_f_owner/(tot_emp_f_owner+tot_emp_m_owner)

// Graph total emp_f/count_f/emp_f_owner

line tot_emp_f_share year, title( Female Employment Share by Year)
graph export $tmp/work/newtotempf.pdf, replace as(pdf)

line tot_count_f_share year if year~=1990, title( Female Owned Firms Share by Year)
graph export $tmp/work/newtotcountf.pdf, replace as(pdf)

line tot_emp_f_owner_share year if year~=1990, title( Employment in Female Owned Firms Share by Year)
graph export $tmp/work/newtotemp_f_share.pdf, replace as(pdf)


// Graph by industry

graph twoway line emp_f_share year, by(shric_desc)
graph export $tmp/work/newempfindustry.pdf, replace as(pdf)

graph twoway line count_f_share year if year~=1990, by(shric_desc)
graph export $tmp/work/newcountfindustry.pdf, replace as(pdf)

graph twoway line emp_f_owner_share year if year~=1990, by(shric_desc)
graph export $tmp/work/newempfshareindustry.pdf, replace as(pdf)
