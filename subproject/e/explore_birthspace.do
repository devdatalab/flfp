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
stop
/*************************************************************************/
/* Check if average diff between siblings varies by gender of first born */
/*************************************************************************/

/* drop difference for oldest child */
replace diff = . if oldest == 1

/* compute avg difference between ages of siblings in hh */
by `hhid': egen avg_diff = mean(diff)

/* create tag by gender of oldest child */
gen old_girl = 1 if sex == 2 & oldest == 1
replace old_girl = 2 if sex == 1 & oldest == 1

/* tag entire household as eldest son or eldest daughter holding */
sort `hhid' birthorder
bys `hhid': egen flag = max(old_girl)
replace old_girl = 1 if old_girl == . & flag == 1
replace old_girl = 2 if old_girl == . & flag == 2
replace old_girl = 0 if old_girl == 2

/* label values */
label define og 1 "Oldest is a daughter" 0 "Oldest is a son"
label values old_girl og

/* plot outcome over the two groups */
set scheme pn
cibar avg_diff, over(old_girl) graphopts(xtitle("Sex of oldest child") ytitle("Avg age diff between successive siblings"))
graphout diff_1

/********************************************************************************/
/* Check sex ratios of younger siblings conditional on gender of older siblings */
/********************************************************************************/

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

set scheme s1color

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
cibar m if youngest == 1, over(girl) graphopts(ytitle("Likelihood of being a boy", margin(medium)) xtitle("Sex of older sibling") ylabel(0 (0.2) 1))
graphout twoperson

/*********************/
/* 3 person families */
/*********************/

/* categories - eldest two are both girls */
gen girl1 = 1 if highestorder == 3 & sex == 2 & oldest == 1
replace girl1 = 1 if highestorder == 3 & sex == 2 & secondoldest == 1

bys `hhid': egen flag1 = total(girl1)

replace girl1 = 1 if flag1 == 2 & girl1 == .
replace girl1 = 2 if girl1 == . & highestorder == 3

label define g1 1 "Girl-Girl" 2 "Mixed/Boy-Boy", modify
label values girl1 g1

/* probability of the youngest being a boy by sex of older sibling */
cibar m if youngest == 1, over(girl1) graphopts(ytitle("Likelihood of being a boy", margin(medium)) xtitle("Sex of older siblings") ylabel(0 (0.2) 1))
graphout threeperson

