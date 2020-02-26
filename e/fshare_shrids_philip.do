** This do file describes the relationship between female employment and region **

/* merge every EC dataset, '90-'13 */
use $flfp/ec_flfp_90, clear
gen year = 1990
foreach y in 1998 2005 2013 {
  append using $flfp/ec_flfp_98
  replace year = 1998 if mi(year)
  append using $flfp/ec_flfp_05
  replace year = 2005 if mi(year)
  append using $flfp/ec_flfp_13
  replace year = 2013 if mi(year)
}

/* drop any observations without shrid */
drop if shrid == ""
drop if shric == .

/* collapse by year and shrid */
collapse (sum) emp_m emp_f, by (year)

/* save the collapsed dataset as a temporary file and open it again */
save $tmp/fsharetest_flfp_collapse, replace
use $tmp/fsharetest_flfp_collapse, clear

/* generate "female employment share" variable */
gen f_emp_share = (emp_f / (emp_f + emp_m))

/* graph the relationship between year and female employment share */
graph twoway line f_emp_share year, title(Female Employment Share by Year) ///
ytitle(Female Share of Employment) xtitle(Year)
