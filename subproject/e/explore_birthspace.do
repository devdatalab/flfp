use $tmp/urban_birthorder, clear

/* keep only children to make dataset smaller */
keep if age <= 18

/* drop upper right tail of birthorder ( 3 % of data)*/
drop if birthorder > 5

local hhid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_block_id  pc11_ward_id pc11_town_id house_no 

/* tag oldest child in each households */
/* WARNING: bc of high N, takes ~7 mins */
bys `hhid': egen highestorder = max(birthorder)

/* drop one child families */
drop if highestorder == 1

/* tag kids in reverse order of birth */
gen youngest = 1 if birthorder == 1
gen oldest = 1 if birthorder == highestorder
gen counter = highestorder - 1 
gen secondoldest = 1 if birthorder == counter & youngest != 1
replace counter = counter - 1
gen thirdoldest = 1 if birthorder == counter & youngest != 1
replace counter = counter - 1
gen fourtholdest = 1 if birthorder == counter & youngest != 1
drop counter

/********************************************************************************/
/* Check sex ratios of younger siblings conditional on gender of older siblings */
/********************************************************************************/

set scheme pn

/* outcome vars */
gen f = sex == 2 
gen m = sex == 1 

foreach i of var f m{
  replace `i' = . if sex == .
  }

/* gen sexratio */
egen males = total(m)
egen females = total(f)
gen sr = males/females

/* no of girls in fam */
bys `hhid': egen girls = total(f)
bys `hhid': egen boys = total(m)

/*********************/
/* 2 person families */
/*********************/

/* categories - eldest is a girl or a boy*/
gen girl = 1 if highestorder == 2 & sex == 2 & oldest == 1
replace girl = 2 if highestorder == 2 & sex == 1 & oldest == 1

/* tag entire household as eldest son or eldest daughter holding */
sort `hhid' birthorder
bys `hhid': egen flag = max(girl)

replace girl = 1 if girl == . & flag == 1
replace girl = 2 if girl == . & flag == 2

label define g 1 "Girl" 2 "Boy", modify
label values girl g

/* probability of the youngest being a boy by sex of older sibling */
cibar m if youngest == 1, over(girl) graphopts(ytitle("Likelihood of being a boy") xtitle("Sex of older sibling"))
graphout trial

/* Becky: do you have ideas on what exactly to plot to replicate the bar graph in the paper you sent me? */
/* I got stuck thinking through it I'm sure it'll come if I think harder/with a fresh mind */


