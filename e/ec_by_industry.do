/* Finding total female employment and percentage of employees female divided by Industry */
use $flfp/ec_flfp_13.dta, clear // Load EC 13
drop if shric == .  //Drop any observations that don't have any shrics or shrids
drop if shrid == ""
collapse (sum) emp_m emp_f, by (shric) // Collapse employment numbers by shric
merge m:1 shric using $flfp/shric_descriptions.dta // Merge with shric descriptions and drop merge 
drop _merge
gen emp_total = emp_f + emp_m //Generate total employed variable
gen perc_f_13 = emp_f/(emp_total) //Generate percentage female variable
gsort - emp_f   //Sort by total employment in descending order
list shric_desc emp_f in 1/10, string(40) //Display top 10 industries by total female employment
gsort - perc_f_13 //Sort by Percentage of employed that are female 
list shric_desc perc_f_13 in 1/10, string(40) //Display top 10 industries by female percentage
ren emp_f emp_f_13 //Rename for future merge
save $tmp/ec_13_industry.dta, replace //Save in temporary file
** Repeat process for each of the ECs **
use $flfp/ec_flfp_05.dta, clear 
drop if shric ==.           
drop if shrid == ""
collapse(sum) emp_m emp_f, by (shric)   
merge m:1 shric using $flfp/shric_descriptions.dta 
drop _merge
gen emp_total = emp_f + emp_m   
gen perc_f_05 = emp_f/emp_total 
gsort - emp_f
list shric_desc emp_f in 1/10, string(40)
gsort - perc_f_05
list shric_desc perc_f_05 in 1/10, string(40)
ren emp_f emp_f_05
merge 1:1 shric using $tmp/ec_13_industry.dta //Merge onto saved results from EC13
drop _merge emp_m emp_total
save $tmp/ec_13_05_industry.dta, replace
use $flfp/ec_flfp_98.dta, clear 
drop if shric ==.   
drop if shrid == ""
collapse(sum) emp_m emp_f, by (shric) 
merge m:1 shric using $flfp/shric_descriptions.dta 
drop _merge
gen emp_total = emp_f + emp_m   
gen perc_f_98 = emp_f/emp_total 
gsort - emp_f
list shric_desc emp_f in 1/10, string(40)
gsort - perc_f_98
list shric_desc perc_f_98 in 1/10, string(40)
ren emp_f emp_f_98
drop emp_m emp_total
merge 1:1 shric using $tmp/ec_13_05_industry.dta //Merge onto saved results from EC13 and EC05
drop _merge
save $tmp/ec13050_industry.dta, replace
use $flfp/ec_flfp_90, clear 
drop if shric ==.   
drop if shrid == ""
collapse(sum) emp_m emp_f, by (shric) 
merge m:1 shric using $flfp/shric_descriptions.dta 
drop _merge
gen emp_total = emp_f + emp_m   
gen perc_f_90 = emp_f/emp_total
gsort - emp_f
list shric_desc emp_f in 1/10, string(40)
gsort - perc_f_90
list shric_desc perc_f_90 in 1/10, string(40)
ren emp_f emp_f_90
drop emp_m emp_total
merge 1:1 shric using $tmp/ec13050_industry.dta //Merge onto saved results from EC13,05and 98
drop _merge
save $flfp/ec_by_industry.dta, replace //Save file with percentages and total employment numbers for each EC
rename emp_f_05 emp_f_5 //I had to change the 05 to a 5 here so that the reshape would work properly in the next line. 
rename perc_f_05 perc_f_5
reshape long emp_f_ perc_f_, i(shric_desc) j(year) //Reshape it into long form data so that each observation is a SHRIC-year pair
rename perc_f_ percentage //Rename for ease
rename emp_f_ employment
replace year = 1990 if year == 90 //Recode the year variable as actual numbers so that graphing is possible
replace year = 1998 if year == 98
replace year = 2005 if year == 5
replace year = 2013 if year == 13
graph twoway line employment year, sort by(shric_desc) //Graph both employment and percentage against year divided by industry to see any signficant jumps.
graphout emp
graph twoway line percentage year, sort by(shric_desc)
graphout perc
