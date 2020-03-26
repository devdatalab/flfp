
**************************
** URBAN RURAL ANALYSIS **
**************************

use $flfp/ec_flfp_icat_ur.dta, clear

/* drop mixed urban-rural observations */

drop if sector == 3

/* create dummy for urban */

gen urban = (sector == 1)

/* create dummy for years */

gen yr1998 = (year == 1998)
gen yr2005 = (year == 2005)
gen yr2013 = (year == 2013)

/* generate log variables */

foreach y in emp_f emp_m emp_f_owner emp_m_owner count_f count_m {
  gen ln_`y' = ln(`y' + 1)
}

/* generate interaction variables */

foreach var in yr1998 yr2005 yr2013 {
  gen urban_`var' = urban*`var'
}

/* generate share variables */

gen emp_f_share = emp_f/(emp_f+emp_m)

gen count_f_share = count_f/(count_f+count_m)

gen emp_f_owner_share = emp_f_owner/(emp_f_owner+emp_m_owner)


/* generate total variables for all industries */

bysort sector year: egen tot_emp_f = total(emp_f)
bysort sector year: egen tot_count_f = total(count_f)
bysort sector year: egen tot_emp_m = total(emp_m)
bysort sector year: egen tot_count_m = total(count_m)
bysort sector year: egen tot_emp_f_owner = total(emp_f_owner)
bysort sector year: egen tot_emp_m_owner = total(emp_m_owner)

gen tot_emp_f_share = tot_emp_f/(tot_emp_f+tot_emp_m)
gen tot_count_f_share = tot_count_f/(tot_count_f+tot_count_m)
gen tot_emp_f_owner_share = tot_emp_f_owner/(tot_emp_f_owner+tot_emp_m_owner)

/* set local for variables */

local emp_f_share "Female Employment Share"
local count_f_share "Female Ownership Share"
local emp_f_owner_share "Employment in Female Owned Firms Share"
local tot_emp_f_share "Female Employment Share"
local tot_count_f_share "Female Ownership Share"
local tot_emp_f_owner_share "Employment in Female Owned Firms Share"

**************************
******** GRAPHING ********
**************************


/* generate graphs for female employment share, female entrepreneur share and employment in female owned firms */

graph twoway line tot_emp_f_share year if urban == 0 || line tot_emp_f_share year if urban == 1, legend(label(1 "Rural") label(2 "Urban")) title(Female Employment Share) ytitle(Female Employment Share) xtitle(Year)
graphout totempfshare

foreach var in tot_emp_f_owner_share tot_count_f_share {
  graph twoway line `var' year if urban == 0 & year~=1990 || line `var' year if urban == 1 & year~=1990, legend(label(1 "Rural") label(2 "Urban")) title(``var'') xtitle("year") ytitle(``var'')
  graphout `var'
}	 

/* generate graphs for female employment share, female entrepreneur share and employment in female owned firms by industry */

sort icat year sector

graph twoway line emp_f_share year if urban == 0 || line emp_f_share year if urban == 1, sort by(icat) legend(label(1 "Rural") label(2 "Urban"))
graphout empfshare


foreach var in count_f_share emp_f_owner_share {
  graph twoway line `var' year if urban == 0 & year~=1990 || line `var' year if urban == 1 & year~=1990, sort by(icat) legend(label(1 "Rural") label(2 "Urban"))
  graphout `var'
}


/* using combine option for better formatting for industry-wise graphs */

/* female employment share */

forval i= 1(1)17 {
  local v : label (icat) `i'
  graph twoway line emp_f_share year if urban == 0 & icat == `i' || line emp_f_share year if urban == 1 & icat == `i', legend(label(1 "Rural") label(2 "Urban")) title("`v'") xtitle("Year") ytitle("Female Employment Share") name(g`i', replace) nodraw
  local graphs "`graphs' g`i'"
}

grc1leg2 `graphs', title (Female Employment Share by Industry) legendfrom(g1) xtob1title ytol1title 
graphout empfsharecombine

/* female entrepreneurship share */

forval i= 1(1)17 {
  local v : label (icat) `i'
  graph twoway line count_f_share year if urban == 0 & icat == `i' & year~=1990|| line count_f_share year if urban == 1 & icat == `i'& year~=1990, legend(label(1 "Rural") label(2 "Urban")) title("`v'") xtitle("Year") ytitle("Female Entrepreneurship Share") name(h`i', replace) nodraw
  local graphs2 "`graphs2' h`i'"
}

grc1leg2 `graphs2', title (Female Entrepreneurship Share by Industry) legendfrom(h1) xtob1title ytol1title 
graphout countfsharecombine

/*  employment in female owned firms share */

forval i= 1(1)17 {
  local v : label (icat) `i'
  graph twoway line emp_f_owner_share year if urban == 0 & icat == `i' & year~=1990|| line emp_f_owner_share year if urban == 1 & icat == `i'& year~=1990, legend(label(1 "Rural") label(2 "Urban")) title("`v'") xtitle("Year") ytitle("Share of Employees in Female Owned Firms") name(j`i', replace) nodraw
  local graphs3 "`graphs3' j`i'"
}

grc1leg2 `graphs3', title (Share of Employees in Female Owned Firms) legendfrom(j1) xtob1title ytol1title 
graphout empfownersharecombine


**************************
******* REGRESSIONS ******
**************************

sort icat year sector

/* log(emp_f) regressions */

reg ln_emp_f yr1998 yr2005 yr2013 urban urban_yr1998 urban_yr2005 urban_yr2013 if icat == 1
outreg2 using $tmp/icat_urban_rural, excel ctitle("log_emp_f","shric=1") replace

forval i= 2(1)17 {
  display "icat=`i'"
  reg ln_emp_f yr1998 yr2005 yr2013 urban urban_yr1998 urban_yr2005 urban_yr2013 if icat == `i'
  outreg2 using $tmp/icat_urban_rural, excel ctitle("log_emp_f","icat=`i'") append
}

/* log(count_f) regressions */

forval i= 1(1)17 {
  display "icat=`i'"
  reg ln_count_f yr1998 yr2005 yr2013 urban urban_yr1998 urban_yr2005 urban_yr2013 if icat == `i'
  outreg2 using $tmp/icat_urban_rural, excel ctitle ("log_count_f","icat=`i'") append
}
