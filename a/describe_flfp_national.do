**************************
*** NATIONAL ANALYSIS ****
**************************

use $flfp/ec_flfp_icat_india.dta, clear

/* Gen emp_f share variable */

gen emp_f_share = emp_f/(emp_m+emp_f)
gen count_f_share = count_f/(count_f+count_m)
gen emp_f_owner_share = emp_f_owner/(emp_f_owner+emp_m_owner)

/* Gen emp_f share growth variable */

gen fshare_growth = .

forval i = 1/17 {
  display `i'
  reg emp_f_share year if icat == `i'
  replace fshare_growth = _b["year"] if icat == `i'
}

/* tabulate fshare growth */

tabstat fshare_growth, by(icat)

/* generate overall fshare growth */

xtset icat year

by icat (year), sort: gen empfgrowth = L0.emp_f - L23.emp_f

/* Gen total emp_f variable */

gen emp_tot = emp_f + emp_m

/* generate empfpredicted: (female share in 1990)*(emp_f in 2013) */

gen fshare1990 = emp_f_share if year==1990

replace fshare1990 = fshare1990[_n-1] if fshare1990==.

by icat (year): gen empfpredicted = fshare1990 * emp_tot if year==2013

/* gen residual emp_f: predicted emp_f - actual emp_f in 2013 */

by icat (year): gen empfresidual = (emp_f) - (empfpredicted) if year==2013

/* output a table with all variables */

outsheet icat empfgrowth fshare_growth empfpredicted empfresidual emp_f emp_m using $tmp/empfshare1.csv if year == 2013, comma replace

outsheet emp_f emp_m using $tmp/empfshare2.csv if year==1990, replace

/* generate total variables for all industries */

bysort year: egen tot_emp_f=total(emp_f)
bysort year: egen tot_count_f=total(count_f)
bysort year: egen tot_emp_m=total(emp_m)
bysort year: egen tot_count_m=total(count_m)
bysort year: egen tot_emp_f_owner=total(emp_f_owner)
bysort year: egen tot_emp_m_owner=total(emp_m_owner)

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


*************************
**** Generate graphs ****
*************************

/* generate graphs for female employment share, female entrepreneur share and employment in female owned firms, overall */

graph twoway line tot_emp_f_share year, title(Female Employment Share) ytitle(Female Employment Share) xtitle(Year)
gr export $graphs/nationaltotempfshare.png, replace as (png)

foreach var in tot_emp_f_owner_share tot_count_f_share {
     graph twoway line `var' year if year~=1990, title(``var'') xtitle("year") ytitle(``var'')
	 gr export $graphs/national`var'.png, replace as (png)
}	 

/* using combine option for better formatting for industry-wise graphs */

/* female employment share */

forval i= 1(1)17 {
      local v : label (icat) `i'
	  graph twoway line emp_f_share year if icat==`i', title("`v'") xtitle("Year") ytitle("Female Employment Share") name(g`i', replace) nodraw
      local graphs "`graphs' g`i'"
}

grc1leg2 `graphs', title (Female Employment Share by Industry) legendfrom(g1) xtob1title ytol1title 
graph export $graphs/nationalempfsharecombine.png, replace as (png)

/* female entrepreneurship share */

forval i= 1(1)17 {
      local v : label (icat) `i'
	  graph twoway line count_f_share year if icat==`i' & year~=1990, title("`v'") xtitle("Year") ytitle("Female Entrepreneurship Share") name(h`i', replace) nodraw
      local graphs2 "`graphs2' h`i'"
}

grc1leg2 `graphs2', title (Female Entrepreneurship Share by Industry) legendfrom(h1) xtob1title ytol1title 
graph export $graphs/nationalcountfsharecombine.png, replace as (png)

/*  share of employment in female owned firms share */

forval i= 1(1)17 {
      local v : label (icat) `i'
	  graph twoway line emp_f_owner_share year if icat==`i' & year~=1990, title("`v'") xtitle("Year") ytitle("Share of Employees in Female Owned Firms") name(j`i', replace) nodraw
      local graphs3 "`graphs3' j`i'"
}

grc1leg2 `graphs3', title (Share of Employees in Female Owned Firms) legendfrom(j1) xtob1title ytol1title 
graph export $graphs/nationalempfownersharecombine.png, replace as (png)

