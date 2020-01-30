/* Finding total female employment and percentage of employees female divided by Industry */

use $flfp/ec_flfp_13.dta, clear // Load EC 13

drop if shric == .	//Drop any observations that don't have any shrics or shrids
drop if shrid == ""

collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric) // Collapse employment numbers by shric

merge m:1 shric using $flfp/shric_descriptions.dta // Merge with shric descriptions and drop merge 
drop _merge

gen emp_total = emp_f + emp_m //Generate total employed variable
gen perc_f_13 = emp_f/(emp_total) //Generate percentage female variable

gsort - emp_f	//Sort by total employment in descending order
list shric_desc emp_f in 1/10, string(40) //Display top 10 industries by total female employment

gsort - perc_f_13 //Sort by Percentage of employed that are female 
list shric_desc perc_f_13 in 1/10, string(40) //Display top 10 industries by female percentage

// female-owned firms and employment in female owned firms

gsort - count_f	//Sort by total female owned firms in descending order
list shric_desc count_f in 1/10, string(40) //Display top 10 industries by female ownership

gsort - emp_f_owner	//Sort by total employment in female owned firms in descending order
list shric_desc emp_f_owner in 1/10, string(40) //Display top 10 industries by employment in female owned firms

// male-owned firms and employment in male owned firms

gsort - count_m	//Sort by total male owned firms in descending order
list shric_desc count_m in 1/10, string(40) //Display top 10 industries by male ownership

gsort - emp_m_owner	//Sort by total employment in male owned firms in descending order
list shric_desc emp_m_owner in 1/10, string(40) //Display top 10 industries by employment in male owned firms


ren emp_f emp_f_13
ren count_m count_m_13
ren count_f count_f_13
ren emp_m_owner emp_m_owner_13
ren emp_f_owner emp_f_owner_13
ren emp_o_owner emp_o_owner_13 //Rename for future merge

save $tmp/ec_13_industry.dta, replace //Save in temporary file

** Repeat process for each of the ECs **

// 2005


use $flfp/ec_flfp_05.dta, clear 

drop if shric ==.			
drop if shrid == ""

collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)	

merge m:1 shric using $flfp/shric_descriptions.dta 
drop _merge

gen emp_total = emp_f + emp_m	
gen perc_f_05 = emp_f/emp_total 
gsort - emp_f
list shric_desc emp_f in 1/10, string(40)
gsort - perc_f_05
list shric_desc perc_f_05 in 1/10, string(40)

// female-owned firms and employment in female owned firms

gsort - count_f	//Sort by total female owned firms in descending order
list shric_desc count_f in 1/10, string(40) //Display top 10 industries by female ownership

gsort - emp_f_owner	//Sort by total employment in female owned firms in descending order
list shric_desc emp_f_owner in 1/10, string(40) //Display top 10 industries by employment in female owned firms

// male-owned firms and employment in male owned firms

gsort - count_m	//Sort by total male owned firms in descending order
list shric_desc count_m in 1/10, string(40) //Display top 10 industries by male ownership

gsort - emp_m_owner	//Sort by total employment in male owned firms in descending order
list shric_desc emp_m_owner in 1/10, string(40) //Display top 10 industries by employment in male owned firms

ren emp_f emp_f_05
ren count_m count_m_05
ren count_f count_f_05
ren emp_m_owner emp_m_owner_05
ren emp_f_owner emp_f_owner_05
ren emp_o_owner emp_o_owner_05

merge 1:1 shric using $tmp/ec_13_industry.dta //Merge onto saved results from EC13
drop _merge emp_m emp_total

save $tmp/ec_13_05_industry.dta, replace

// 1998


use $flfp/ec_flfp_98.dta, clear 

drop if shric ==.	
drop if shrid == ""

collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)

merge m:1 shric using $flfp/shric_descriptions.dta 
drop _merge

gen emp_total = emp_f + emp_m	
gen perc_f_98 = emp_f/emp_total 
gsort - emp_f
list shric_desc emp_f in 1/10, string(40)
gsort - perc_f_98
list shric_desc perc_f_98 in 1/10, string(40)

// female-owned firms and employment in female owned firms

gsort - count_f	//Sort by total female owned firms in descending order
list shric_desc count_f in 1/10, string(40) //Display top 10 industries by female ownership

gsort - emp_f_owner	//Sort by total employment in female owned firms in descending order
list shric_desc emp_f_owner in 1/10, string(40) //Display top 10 industries by employment in female owned firms


// male-owned firms and employment in male owned firms

gsort - count_m	//Sort by total male owned firms in descending order
list shric_desc count_m in 1/10, string(40) //Display top 10 industries by male ownership

gsort - emp_m_owner	//Sort by total employment in male owned firms in descending order
list shric_desc emp_m_owner in 1/10, string(40) //Display top 10 industries by employment in male owned firms


ren emp_f emp_f_98
ren count_m count_m_98
ren count_f count_f_98
ren emp_m_owner emp_m_owner_98
ren emp_f_owner emp_f_owner_98
ren emp_o_owner emp_o_owner_98

drop emp_m emp_total
merge 1:1 shric using $tmp/ec_13_05_industry.dta //Merge onto saved results from EC13 and EC05
drop _merge

save $tmp/ec13050_industry.dta, replace

// 1990


use $flfp/ec_flfp_90, clear	

drop if shric ==.	
drop if shrid == ""

collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)

merge m:1 shric using $flfp/shric_descriptions.dta 
drop _merge

gen emp_total = emp_f + emp_m	
gen perc_f_90 = emp_f/emp_total
gsort - emp_f
list shric_desc emp_f in 1/10, string(40)
gsort - perc_f_90
list shric_desc perc_f_90 in 1/10, string(40)

// female-owned firms and employment in female owned firms

gsort - count_f	//Sort by total female owned firms in descending order
list shric_desc count_f in 1/10, string(40) //Display top 10 industries by female ownership

gsort - emp_f_owner	//Sort by total employment in female owned firms in descending order
list shric_desc emp_f_owner in 1/10, string(40) //Display top 10 industries by employment in female owned firms

// male-owned firms and employment in male owned firms

gsort - count_m	//Sort by total male owned firms in descending order
list shric_desc count_m in 1/10, string(40) //Display top 10 industries by male ownership

gsort - emp_m_owner	//Sort by total employment in male owned firms in descending order
list shric_desc emp_m_owner in 1/10, string(40) //Display top 10 industries by employment in male owned firms


ren emp_f emp_f_90
ren count_m count_m_90
ren count_f count_f_90
ren emp_m_owner emp_m_owner_90
ren emp_f_owner emp_f_owner_90
ren emp_o_owner emp_o_owner_90

drop emp_m emp_total
merge 1:1 shric using $tmp/ec13050_industry.dta //Merge onto saved results from EC13,05and 98
drop _merge

save $flfp/ec_by_industry.dta, replace //Save file with percentages and total employment numbers for each EC

// seeing differences in emp_f across time periods - which industry added the most female jobs? //

use $flfp/ec_by_industry.dta, clear

// gen variables for difference between each EC and corresponding percentage increases //

gen dif_90_98 = emp_f_98-emp_f_90

gen dif_90_98_percent = (emp_f_98-emp_f_90)/emp_f_90

gen dif_98_05 = emp_f_05-emp_f_98

gen dif_98_05_percent = (emp_f_05-emp_f_98)/emp_f_98

gen dif_05_13 = emp_f_13-emp_f_05

gen dif_05_13_percent = (emp_f_13-emp_f_05)/emp_f_05

gen dif_90_13 = emp_f_13-emp_f_90

gen dif_90_13_percent = (emp_f_13-emp_f_90)/emp_f_90


// list industries that added most female employees (absolute and percentage increase) across time periods //

gsort - dif_90_98
list shric_desc dif_90_98 in 1/10, string(40)

gsort - dif_98_05
list shric_desc dif_98_05 in 1/10, string(40)

gsort - dif_05_13
list shric_desc dif_05_13 in 1/10, string(40)

gsort - dif_90_13
list shric_desc dif_90_13 in 1/10, string(40)

gsort - dif_90_98_percent
list shric_desc dif_90_98_percent in 1/10, string(40)

gsort - dif_98_05_percent
list shric_desc dif_98_05_percent in 1/10, string(40)

gsort - dif_05_13_percent
list shric_desc dif_05_13_percent in 1/10, string(40)

gsort - dif_90_13_percent
list shric_desc dif_90_13_percent in 1/10, string(40)

// trying to put the top 10 together so that we can compare industries across the 4 periods

gsort - dif_90_13 // sorting top 10 with highest increase in female employees between 1990 and 2013
list shric_desc dif_90_98 dif_98_05 dif_05_13 dif_90_13 dif_90_98_percent dif_98_05_percent dif_05_13_percent dif_90_13_percent in 1/10, string(40) // see how much increase between every period in those industries 

// Note: the obove list is top 10 by absolute numbers, while the one below is top 10 by percentage increase. however, it contains both absolute and percentage increases for the corresponding top 10.

gsort - dif_90_13_percent // sorting top 10 with highest increase in female employees between 1990 and 2013
list shric_desc dif_90_98_percent dif_98_05_percent dif_05_13_percent dif_90_13_percent dif_90_98 dif_98_05 dif_05_13 dif_90_13 in 1/10, string(40) // see how much increase between every period in those industries 

// notice that while some industries post high percentage increase, the absolute numbers for the same industries aren't so significant


// look at change in female owned enterprises over the 4 time periods

// gen variables for change in count_f_* in every period

gen dif_count_98_05 = count_f_05-count_f_98
gen dif_count_05_13 = count_f_13-count_f_05
gen dif_count_98_13 = count_f_13-count_f_98

// sorting top 10 with greatest increase in female owned firms between 1998 and 2005

gsort - dif_count_98_05
list shric_desc count_f_98 count_f_05 dif_count_98_05 in 1/10, string (40)

// sorting top 10 with greatest increase in female owned firms between 2005 and 2013

gsort - dif_count_05_13
list shric_desc count_f_05 count_f_13 dif_count_05_13 in 1/10, string (40)

// sorting top 10 with greatest increase in female owned firms between 1998 and 2013 and putting relevant numbers for the same list

gsort - dif_count_98_13
list shric_desc count_f_98 count_f_05 count_f_13 dif_count_98_05 dif_count_05_13 dif_count_98_13 in 1/10, string (40)

// looking at change in employment in female owned enterprises over the 4 time periods

gen dif_emp_f_owner_98_05 = emp_f_owner_05-emp_f_owner_98
gen dif_emp_f_owner_05_13 = emp_f_owner_13-emp_f_owner_05
gen dif_emp_f_owner_98_13 = emp_f_owner_13-emp_f_owner_98

// employees at female owned firms change between 1998 and 2005 

gsort - dif_emp_f_owner_98_05
list shric_desc emp_f_owner_98 emp_f_owner_05 dif_emp_f_owner_98_05 in 1/10, string (40)

// employees at female owned firms change between 2005 and 2013 
gsort - dif_emp_f_owner_05_13
list shric_desc emp_f_owner_05 emp_f_owner_13 dif_emp_f_owner_05_13 in 1/10, string (40)

//overall change between 1998 and 2013
gsort - dif_emp_f_owner_98_13
list shric_desc emp_f_owner_98 emp_f_owner_05 emp_f_owner_13 dif_emp_f_owner_98_05 dif_emp_f_owner_05_13 dif_emp_f_owner_98_13 in 1/10, string (40)


// difference between female and male owned enterprises industry-wise

gen dif_owner_m_f_98 = count_m_98-count_f_98
gen dif_owner_m_f_05 = count_m_05-count_f_05 
gen dif_owner_m_f_13 = count_m_13-count_f_13

//difference in difference - gives us an idea of industries in which the difference between female and male owned enterprises has widened across time periods the most

gen dif_owner_m_f_98_05 = dif_owner_m_f_05-dif_owner_m_f_98
gen dif_owner_m_f_05_13 = dif_owner_m_f_13-dif_owner_m_f_05 
gen dif_owner_m_f_98_13 = dif_owner_m_f_13-dif_owner_m_f_98

gsort - dif_owner_m_f_98_05
list shric_desc dif_owner_m_f_98 dif_owner_m_f_05 dif_owner_m_f_98_05 in 1/10, string (40)

gsort - dif_owner_m_f_05_13
list shric_desc dif_owner_m_f_05 dif_owner_m_f_13 dif_owner_m_f_05_13 in 1/10, string (40)

gsort - dif_owner_m_f_98_13
list shric_desc dif_owner_m_f_98 dif_owner_m_f_05 dif_owner_m_f_13 dif_owner_m_f_98_13 in 1/10, string (40)

/*

the reshaping doesn't make sense after adding variables for all years, feel free to edit the code and make it useful

rename emp_f_05 emp_f_5 //I had to change the 05 to a 5 here so that the reshape would work properly in the next line. 
rename perc_f_05 perc_f_5

reshape long emp_f_ perc_f_, i(shric_desc) j(year) //Reshape it into long form data so that each observation is a SHRIC-year pair
rename perc_f_ percentage //Rename for ease
rename emp_f_ employment

replace year = 1990 if year == 90 //Recode the year variable as actual numbers so that graphing is possible
replace year = 1998 if year == 98
replace year = 2005 if year == 5
replace year = 2013 if year == 13


/*

grpahing takes a lot of time so putting the command as comments for now

graph twoway line employment year, sort by(shric_desc) //Graph both employment and percentage against year divided by industry to see any signficant jumps. 
gr export employmentyear.png, replace as (png)

graph twoway line percentage year, sort by(shric_desc)
gr export percentageyear.png, replace as (png)

*/
