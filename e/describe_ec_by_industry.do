/**************************************/
/* Describe EC by Industry and Gender */
/**************************************/

/* A) List top industry employment by gender for EC13 */
/* B) List top industry employment by gender for EC05 */
/* C) List top industry employment by gender for EC98 */
/* D) List top industry employment by gender for EC90 */
/* E) List industry changes in female employment over all EC datasets */
/* F) List major changes in female industry employment over all EC datasets */
/* G) List female-owned enterprise industry changes over all EC datasets */
/* H) List employment at female-owned enterprise industry changes over all EC datasets */

/* set global macro */
global flfp $iec1/flfp

/******************************************************/
/* A) List top industry employment by gender for EC13 */
/******************************************************/

/* load ec13 */
use $flfp/ec_flfp_13.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

/* collapse employment numbers by "shric" */
collapse (sum) emp_m emp_f count_m count_f count_o emp_m_owner emp_f_owner emp_o_owner, by (shric)

/* merge with "shric descriptions" data file */
merge m:1 shric using $flfp/shric_descriptions.dta

/* drop extraneous "_merge" variable */
drop _merge

/* generate "total employment" variable */
gen emp_total = emp_f + emp_m

/* generate "% female employment" variable */
gen perc_f_13 = emp_f/(emp_total)

/* sort by "total female employment" and list top 10 */
gsort - emp_f
list shric_desc emp_f in 1/10, string(40)

/* sort by "% female employment" and list top 10 */
gsort - perc_f_13
list shric_desc perc_f_13 in 1/10, string(40)

/* sort by "female-owned firms" and list top 10 */
gsort - count_f
list shric_desc count_f in 1/10, string(40)

/* sort by "total employment in female-owned firms" and list top 10 */
gsort - emp_f_owner
list shric_desc emp_f_owner in 1/10, string(40)

/* repeat prior 2 steps, but for male-owned firms */
gsort - count_m
list shric_desc count_m in 1/10, string(40)
gsort - emp_m_owner
list shric_desc emp_m_owner in 1/10, string(40)

/* rename variables for future merge */
ren emp_f emp_f_13
ren count_m count_m_13
ren count_f count_f_13
ren emp_m_owner emp_m_owner_13
ren emp_f_owner emp_f_owner_13
ren emp_o_owner emp_o_owner_13

/* save temporary file */
save $tmp/ec_13_industry.dta, replace

/******************************************************/
/* B) List top industry employment by gender for EC05 */
/******************************************************/

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

/******************************************************/
/* C) List top industry employment by gender for EC98 */
/******************************************************/

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

/******************************************************/
/* D) List top industry employment by gender for EC90 */
/******************************************************/

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

/*******************************************************************/
/* E) List female industry employment changes over all EC datasets */
/*******************************************************************/

/* use new file which includes the previously generated employment variables */
use $flfp/ec_by_industry.dta, clear

/* generate "absolute female employment difference" variables and "% change in female employment" variables */
gen dif_90_98 = emp_f_98-emp_f_90
gen dif_90_98_percent = (emp_f_98-emp_f_90)/emp_f_90

gen dif_98_05 = emp_f_05-emp_f_98
gen dif_98_05_percent = (emp_f_05-emp_f_98)/emp_f_98

gen dif_05_13 = emp_f_13-emp_f_05
gen dif_05_13_percent = (emp_f_13-emp_f_05)/emp_f_05

gen dif_90_13 = emp_f_13-emp_f_90
gen dif_90_13_percent = (emp_f_13-emp_f_90)/emp_f_90

/* sort by "absolute female employment difference" and list top 10 industries */
gsort - dif_90_98
list shric_desc dif_90_98 in 1/10, string(40)

gsort - dif_98_05
list shric_desc dif_98_05 in 1/10, string(40)

gsort - dif_05_13
list shric_desc dif_05_13 in 1/10, string(40)

gsort - dif_90_13
list shric_desc dif_90_13 in 1/10, string(40)

/* sort by "% change in female employment" and list top 10 industries */
gsort - dif_90_98_percent
list shric_desc dif_90_98_percent in 1/10, string(40)

gsort - dif_98_05_percent
list shric_desc dif_98_05_percent in 1/10, string(40)

gsort - dif_05_13_percent
list shric_desc dif_05_13_percent in 1/10, string(40)

gsort - dif_90_13_percent
list shric_desc dif_90_13_percent in 1/10, string(40)

/****************************************************************************/
/* F) List major changes in female industry employment over all EC datasets */
/****************************************************************************/

/* sort by "absolute female employment difference, 1990-2013" and list top 10 */
gsort - dif_90_13
list shric_desc dif_90_98 dif_98_05 dif_05_13 dif_90_13 dif_90_98_percent dif_98_05_percent //
dif_05_13_percent dif_90_13_percent in 1/10, string(40)

/* sort by "% change in female employment, 1990-2013" and list top 10 */
gsort - dif_90_13_percent
list shric_desc dif_90_98_percent dif_98_05_percent dif_05_13_percent dif_90_13_percent //
 dif_90_98 dif_98_05 dif_05_13 dif_90_13 in 1/10, string(40)

/*************************************************************************/
/* G) List female-owned enterprise industry changes over all EC datasets */
/*************************************************************************/

/* generate "absolute female-owned enteprise difference" and "% change" variables */
gen dif_count_98_05 = count_f_05-count_f_98
gen dif_count_98_05_percent = (count_f_05-count_f_98)/count_f_98

gen dif_count_05_13 = count_f_13-count_f_05
gen dif_count_05_13_percent = (count_f_13-count_f_05)/count_f_05

gen dif_count_98_13 = count_f_13-count_f_98
gen dif_count_98_13_percent = (count_f_13-count_f_98)/count_f_98

/* sort by "absolute female-owned enteprise difference" and list top 10 industries */
gsort - dif_count_98_05
list shric_desc count_f_98 count_f_05 dif_count_98_05 in 1/10, string (40)

gsort - dif_count_05_13
list shric_desc count_f_05 count_f_13 dif_count_05_13 in 1/10, string (40)

gsort - dif_count_98_13
list shric_desc count_f_98 count_f_05 count_f_13 dif_count_98_05 dif_count_05_13 //
 dif_count_98_13 in 1/10, string (40)

/***************************************************************************************/
/* H) List employment at female-owned enterprise industry changes over all EC datasets */
/***************************************************************************************/

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
