
//set global

global flfp $dir/FLFP/flfp

//***********************************//
//Create Rural-Urban Dataset for 2013//
//***********************************//

// create data set for urban

/* load ec13 */
use $flfp/ec_flfp_13.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

// merge popluation data from "pc11"

merge m:1 shrid using $flfp/shrug_pc11_pca.dta

// create dummies for town/village

tab pc11_sector, gen(regdum)

rename regdum1 town
rename regdum2 village

drop if regdum3==1

drop _merge

// keep key employment and population numbers

keep shrid shric emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc11_pca_tot_f pc11_pca_tot_m pc11_pca_tot_p pc11_pca_tot_work_p pc11_pca_tot_work_f pc11_pca_tot_work_m pc11_pca_non_work_p pc11_pca_non_work_f pc11_pca_non_work_m town village

keep if town==1

drop village

//collapse employment and population numbers by "shric"
collapse (sum) emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc11_pca_tot_f pc11_pca_tot_m pc11_pca_tot_p pc11_pca_tot_work_p pc11_pca_tot_work_f pc11_pca_tot_work_m pc11_pca_non_work_p pc11_pca_non_work_f pc11_pca_non_work_m, by (shric)

foreach var in emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
        rename `var' urban_`var'_13
}


foreach var in pc11_pca_tot_f pc11_pca_tot_m pc11_pca_tot_p pc11_pca_tot_work_p pc11_pca_tot_work_f pc11_pca_tot_work_m pc11_pca_non_work_p pc11_pca_non_work_f pc11_pca_non_work_m {
        rename `var' urban_`var'
}

save $tmp/ec13_pc11_urban, replace


// create data set for rural


use $flfp/ec_flfp_13.dta, clear


drop if shric == .
drop if shrid == ""

merge m:1 shrid using $flfp/shrug_pc11_pca.dta

tab pc11_sector, gen(regdum)

rename regdum1 town
rename regdum2 village

drop if regdum3==1

drop _merge

keep shrid shric emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc11_pca_tot_f pc11_pca_tot_m pc11_pca_tot_p pc11_pca_tot_work_p pc11_pca_tot_work_f pc11_pca_tot_work_m pc11_pca_non_work_p pc11_pca_non_work_f pc11_pca_non_work_m town village

keep if village==1

drop town


collapse (sum) emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc11_pca_tot_f pc11_pca_tot_m pc11_pca_tot_p pc11_pca_tot_work_p pc11_pca_tot_work_f pc11_pca_tot_work_m pc11_pca_non_work_p pc11_pca_non_work_f pc11_pca_non_work_m, by (shric)

foreach var in emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
        rename `var' rural_`var'_13
}

foreach var in pc11_pca_tot_f pc11_pca_tot_m pc11_pca_tot_p pc11_pca_tot_work_p pc11_pca_tot_work_f pc11_pca_tot_work_m pc11_pca_non_work_p pc11_pca_non_work_f pc11_pca_non_work_m {
        rename `var' rural_`var'
}


save $tmp/ec13_pc11_rural, replace


// merge previously created "urban" and "rural" data sets



merge 1:1 shric using $tmp/ec13_pc11_urban

drop _merge

/* merge with "shric descriptions" data file */
merge m:1 shric using $flfp/shric_descriptions.dta

drop _merge

save $tmp/ec13_pc11_rural_urban, replace



//=======================================================//


// Note: The following commands construct rural-urban datasets for EC05, EC98 and EC90, as previosuly done for EC13.


//***********************************//
//Create Rural-Urban Dataset for 2005//
//***********************************//


// create data set for urban

/* load ec13 */
use $flfp/ec_flfp_05.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

merge m:1 shrid using $flfp/shrug_pc01_pca.dta

tab pc01_sector, gen(regdum)

rename regdum1 town
rename regdum2 village

drop if regdum3==1

drop _merge

keep shrid shric emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m town village

keep if town==1

drop village

//collapse employment numbers by "shric"
collapse (sum) emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m, by (shric)

foreach var in emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
        rename `var' urban_`var'_5
}

foreach var in pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m {
        rename `var' urban_`var'
}

/*
foreach `x' of emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc11_pca_tot_f pc11_pca_tot_m pc11_pca_tot_p pc11_pca_tot_work_p pc11_pca_tot_work_f pc11_pca_tot_work_m pc11_pca_non_work_p pc11_pca_non_work_f pc11_pca_non_work_m town {
        rename `x' urban_`x'
}
*/

save $tmp/ec05_pc01_urban, replace


// create data set for rural


use $flfp/ec_flfp_05.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

merge m:1 shrid using $flfp/shrug_pc01_pca.dta

tab pc01_sector, gen(regdum)

rename regdum1 town
rename regdum2 village

drop if regdum3==1

drop _merge

keep shrid shric emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m town village

keep if village==1

drop town

/* collapse employment numbers by "shric" */
collapse (sum) emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m, by (shric)

foreach var in emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
        rename `var' rural_`var'_5
}

foreach var in pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m {
        rename `var' rural_`var'
}

save $tmp/ec05_pc01_rural, replace


// merge previously created urban and rural data sets


merge 1:1 shric using $tmp/ec05_pc01_urban

drop _merge

/* merge with "shric descriptions" data file */
merge m:1 shric using $flfp/shric_descriptions.dta

drop _merge

save $tmp/ec05_pc01_rural_urban, replace



//***********************************//
//Create Rural-Urban Dataset for 1998//
//***********************************//


// create data set for urban

/* load ec13 */
use $flfp/ec_flfp_98.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

merge m:1 shrid using $flfp/shrug_pc01_pca.dta

tab pc01_sector, gen(regdum)

rename regdum1 town
rename regdum2 village

drop if regdum3==1

drop _merge

keep shrid shric emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m town village

keep if town==1

drop village

//collapse employment numbers by "shric"
collapse (sum) emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m, by (shric)


foreach var in emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
        rename `var' urban_`var'_98
}

foreach var in pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m {
        rename `var' urban_`var'
}

save $tmp/ec98_pc01_urban, replace


// create data set for rural


use $flfp/ec_flfp_98.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

merge m:1 shrid using $flfp/shrug_pc01_pca.dta

tab pc01_sector, gen(regdum)

rename regdum1 town
rename regdum2 village

drop if regdum3==1

drop _merge

keep shrid shric emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m town village

keep if village==1

drop town

/* collapse employment numbers by "shric" */
collapse (sum) emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m, by (shric)

foreach var in emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
        rename `var' rural_`var'_98
}

foreach var in pc01_pca_tot_f pc01_pca_tot_m pc01_pca_tot_p pc01_pca_tot_work_p pc01_pca_tot_work_f pc01_pca_tot_work_m pc01_pca_non_work_p pc01_pca_non_work_f pc01_pca_non_work_m {
        rename `var' rural_`var'
}
save $tmp/ec98_pc01_rural, replace


// merge previously created urban and rural data sets


merge 1:1 shric using $tmp/ec98_pc01_urban

drop _merge

/* merge with "shric descriptions" data file */
merge m:1 shric using $flfp/shric_descriptions.dta

drop _merge

save $tmp/ec98_pc01_rural_urban, replace



//=======================================================//
//***********************************//
//Create Rural-Urban Dataset for 1991//
//***********************************//

// create data set for urban

/* load ec13 */
use $flfp/ec_flfp_90.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

merge m:1 shrid using $flfp/shrug_pc91_pca.dta

tab pc91_sector, gen(regdum)

rename regdum1 town
rename regdum2 village

drop if regdum3==1

drop _merge

keep shrid shric emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc91_pca_tot_f pc91_pca_tot_m pc91_pca_tot_p pc91_pca_non_work_p pc91_pca_non_work_f pc91_pca_non_work_m town village

keep if town==1

drop village

//collapse employment numbers by "shric"
collapse (sum) emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc91_pca_tot_f pc91_pca_tot_m pc91_pca_tot_p pc91_pca_non_work_p pc91_pca_non_work_f pc91_pca_non_work_m, by (shric)

foreach var in emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
        rename `var' urban_`var'_90
}

foreach var in pc91_pca_tot_f pc91_pca_tot_m pc91_pca_tot_p pc91_pca_non_work_p pc91_pca_non_work_f pc91_pca_non_work_m {
        rename `var' urban_`var'
}


save $tmp/ec90_pc91_urban, replace


// create data set for rural


use $flfp/ec_flfp_90.dta, clear

/* drop any observations without "shric" or "shrid" */
drop if shric == .
drop if shrid == ""

merge m:1 shrid using $flfp/shrug_pc91_pca.dta

tab pc91_sector, gen(regdum)

rename regdum1 town
rename regdum2 village

drop if regdum3==1

drop _merge

keep shrid shric emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc91_pca_tot_f pc91_pca_tot_m pc91_pca_tot_p pc91_pca_non_work_p pc91_pca_non_work_f pc91_pca_non_work_m town village

keep if village==1

drop town

/* collapse employment numbers by "shric" */
collapse (sum) emp_f emp_m count_f count_m emp_f_owner emp_m_owner pc91_pca_tot_f pc91_pca_tot_m pc91_pca_tot_p pc91_pca_non_work_p pc91_pca_non_work_f pc91_pca_non_work_m, by (shric)


foreach var in emp_f emp_m count_f count_m emp_f_owner emp_m_owner {
        rename `var' rural_`var'_90
}

foreach var in pc91_pca_tot_f pc91_pca_tot_m pc91_pca_tot_p pc91_pca_non_work_p pc91_pca_non_work_f pc91_pca_non_work_m {
        rename `var' rural_`var'
}


save $tmp/ec90_pc91_rural, replace


// merge previously created urban and rural data sets


merge 1:1 shric using $tmp/ec90_pc91_urban

drop _merge

/* merge with "shric descriptions" data file */
merge m:1 shric using $flfp/shric_descriptions.dta

drop _merge

save $tmp/ec90_pc91_rural_urban, replace



//======================================================//
//Create Overall Data Set with Data from all ECs and PCs//
//======================================================//

// Merge all datasets created in one file

use $tmp/ec90_pc91_rural_urban, clear

merge 1:1 shric using $tmp/ec13_pc11_rural_urban

drop _merge


merge 1:1 shric using $tmp/ec05_pc01_rural_urban

drop _merge


merge 1:1 shric using $tmp/ec98_pc01_rural_urban

drop _merge


drop if shric==.

save $tmp/all_urban_rural, replace


//======================================================/
/////RESHAPING & CREATING DUMMIES FOR YEARS AND REGION///
//======================================================//

use $tmp/all_urban_rural.dta, clear

// Reshape to make shric-year pairs

reshape long rural_emp_f_ rural_emp_m_ rural_count_f_ rural_count_m_ rural_emp_f_owner_ rural_emp_m_owner_ urban_emp_f_ urban_emp_m_ urban_count_f_ urban_count_m_ urban_emp_f_owner_ urban_emp_m_owner_, i(shric) j(year)

//Recode the year variable as actual numbers

replace year = 1990 if year == 90 
replace year = 1998 if year == 98
replace year = 2005 if year == 05
replace year = 2013 if year == 13


keep shric year rural_emp_f_ rural_emp_m_ rural_count_f_ rural_count_m_ rural_emp_f_owner_ rural_emp_m_owner_ urban_emp_f_ urban_emp_m_ urban_count_f_ urban_count_m_ urban_emp_f_owner_ urban_emp_m_owner_

// reshape to make shric-year-urban combinations


// rename to make reshaping possible

ds rural*

foreach var in `r(varlist)' {
      rename `var' `var'1 
}

ds urban*

foreach var in `r(varlist)' {
      rename `var' `var'2 
}

// remove rural_ prefix

renpfix rural_

// remove urban_ prefix

renpfix urban_

// reshape command


reshape long emp_f_ emp_m_ count_f_ count_m_ emp_f_owner_ emp_m_owner_, i(shric year) j(region)

// remove extra underscores

rename *_ *


// create dummies for urban

gen urban= (region==2)


// create dummies for years


gen yr1998= (year==1998)
gen yr2005= (year==2005)
gen yr2013= (year==2013)



// generate log variables for employment related variables

ds emp* count*

foreach y in `r(varlist)' {
   gen ln_`y' = ln(`y' + 1)
}

merge m:1 shric using $flfp/shric_descriptions.dta

drop _merge

save $tmp/all_urban_rural_reshaped, replace


//======================================================/
//////////////////RELEVANT ANALYSIS BY SHRIC/////////////
//======================================================//


// generate interaction terms

foreach var in yr1998 yr2005 yr2013 {
    gen urban_`var'=urban*`var'
}

// generate variables for share

gen emp_f_share = emp_f/(emp_f+emp_m)

gen count_f_share = count_f/(count_f+count_m)


//*************************//
///// GRAPHING WORK /////////
//*************************//


///////// BY TOTAl (ALL INDUSTRIES) /////////

bysort region year: egen tot_emp_f=total(emp_f)
bysort region year: egen tot_count_f=total(count_f)
bysort region year: egen tot_emp_m=total(emp_m)
bysort region year: egen tot_count_m=total(count_m)
bysort region year: egen tot_emp_f_owner=total(emp_f_owner)
bysort region year: egen tot_emp_m_owner=total(emp_m_owner)

gen tot_emp_f_share = tot_emp_f/(tot_emp_f+tot_emp_m)
gen tot_count_f_share = tot_count_f/(tot_count_f+tot_count_m)
gen tot_emp_f_owner_share = tot_emp_f_owner/(tot_emp_f_owner+tot_emp_m_owner)

// GRAPH CHANGE IN TOTAL EMPLOYMENT FOR FEMALES/MALES

graph twoway line tot_emp_f year if urban==0 || line tot_emp_f year if urban==1 || line tot_emp_m year if urban==0 || line tot_emp_m year if urban==1, legend(label(1 "Rural, Female") label(2 "Urban, Female") label(3 "Rural, Male") label(4 "Urban, Male"))
gr export totemp.pdf, replace as (pdf)

// GRAPH CHANGE IN TOTAL EMPLOYMENT IN FEMALES/MALES OWNED FIRMS

graph twoway line tot_emp_f_owner year if urban==0 || line tot_emp_f_owner year if urban==1 || line tot_emp_m_owner year if urban==0 || line tot_emp_m_owner year if urban==1, legend(label(1 "Rural, Female") label(2 "Urban, Female") label(3 "Rural, Male") label(4 "Urban, Male"))
gr export totempowner.pdf, replace as (pdf)

// GRAPH CHANGE IN SHARE IN TOTAL EMPLOYMENT IN FEMALES/MALES OWNED FIRMS

graph twoway line tot_emp_f_owner_share year if urban==0 || line tot_emp_f_owner_share year if urban==1, legend(label(1 "Rural, Female") label(2 "Urban, Female"))
gr export totempownershare.pdf, replace as (pdf)

// GRAPHING CHANGE IN TOTAL FEMALE EMPLOYMENT SHARE

graph twoway line tot_emp_f_share year if urban==0 || line tot_emp_f_share year if urban==1, legend(label(1 "Rural") label(2 "Urban"))
gr export totempfshare.pdf, replace as (pdf)

// GRAPHING CHANGE IN TOTAL FEMALE OWNERSHIP SHARE

graph twoway line tot_count_f_share year if urban==0 || line tot_count_f_share year if urban==1, legend(label(1 "Rural") label(2 "Urban"))
gr export totcountfshare.pdf, replace as (pdf)

//////// BY INDUSTRY //////////

graph twoway line emp_f_share year if urban==0 || line emp_f_share year if urban==1, sort by(shric_desc) legend(label(1 "Rural") label(2 "Urban"))
gr export empfshare.pdf, replace as (pdf)

graph twoway line count_f_share year if urban==0 || line count_f_share year if urban==1, sort by(shric_desc) legend(label(1 "Rural") label(2 "Urban"))
gr export countfshare.pdf, replace as (pdf)

graph twoway line emp_f_owner_share year if urban==0 || line emp_f_owner_share year if urban==1, sort by(shric_desc) legend(label(1 "Rural") label(2 "Urban"))
gr export empfownershare.pdf, replace as (pdf)

//*************************//
//// REGRESSION ANALYSIS ////
//*************************//

sort shric year region
		
// FOR LOG EMPLOYMENT


// run diff-in-diff regressions for emp_f


reg ln_emp_f yr1998 yr2005 yr2013 urban urban_yr1998 urban_yr2005 urban_yr2013 if shric==1
outreg2 using $tmp/urban_rural, excel ctitle("ln_emp_f","shric=1") replace

forval i= 2(1)90 {
   display "shric=`i'"
   reg ln_emp_f yr1998 yr2005 yr2013 urban urban_yr1998 urban_yr2005 urban_yr2013 if shric==`i'
   outreg2 using $tmp/urban_rural, excel ctitle("log_emp_f","shric=`i'") append
}

// run diff-in-diff regressions for count_f

forval i= 1(1)90 {
   display "shric=`i'"
   reg ln_count_f yr1998 yr2005 yr2013 urban urban_yr1998 urban_yr2005 urban_yr2013 if shric==`i'
   outreg2 using $tmp/urban_rural, excel ctitle ("log_count_f","shric=`i'") append
}

// FOR ABSOLUTE NUMBERS

// run diff-in-diff regressions for emp_f

forval i= 1(1)90 {
   display "shric=`i'"
   reg emp_f yr1998 yr2005 yr2013 urban urban_yr1998 urban_yr2005 urban_yr2013 if shric==`i'
   outreg2 using $tmp/urban_rural, excel ctitle ("emp_f","shric=`i'") append
}

// run diff-in-diff regressions for count_f

forval i= 1(1)90 {
   display "shric=`i'"
   reg count_f yr1998 yr2005 yr2013 urban urban_yr1998 urban_yr2005 urban_yr2013 if shric==`i'
   outreg2 using $tmp/urban_rural, excel ctitle ("count_f","shric=`i'") append
}
