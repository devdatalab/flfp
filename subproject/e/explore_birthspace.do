/* set global to where aditi stored secc birthorder data */
global tmp /scratch/adibmk/

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

/*************************************************************************/
/* Check if average diff between siblings varies by gender of first born */
/*************************************************************************/
local hhid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_block_id  pc11_ward_id pc11_town_id house_no 
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

/* repeat for second-oldest girl */
gen second_old_girl = 1 if sex == 2 & secondoldest == 1
replace second_old_girl = 2 if sex == 1 & secondoldest == 1

/* tag entire HH as second eldest son or second eldest daughter */
// local hhid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_block_id  pc11_ward_id pc11_town_id house_no 
sort `hhid' birthorder
bys `hhid': egen flag2 = max(second_old_girl)
replace second_old_girl = 1 if second_old_girl == . & flag2 == 1
replace second_old_girl = 2 if second_old_girl == . & flag2 == 2
replace second_old_girl = 0 if second_old_girl == 2

/* label values*/
label define sog 1 "Second oldest is a daughter" 0 "Second oldest is a son"
label values second_old_girl sog

/* drop intermediate variables */
drop flag*

/* plot outcome over the two groups */
set scheme pn
cibar avg_diff, over(old_girl) graphopts(xtitle("Sex of oldest child") ytitle("Avg age diff between successive siblings"))
graphout diff_1

/********************************************************************************/
/* Check sex ratios of younger siblings conditional on gender of older siblings */
/********************************************************************************/
/* Note: this is an attempt to replicate Fig 1 from Almond and Edlund (2001) */

set scheme pn

/*  first limit to 3-child families, create grouping var on birth order */
gen birth_group = .
replace birth_group = 1 if oldest == 1
replace birth_group = 2 if secondoldest == 1
replace birth_group = 3 if thirdoldest == 1
drop if birth_group == .

/* create var that indicates gender-composition of existing kids */
gen prev_children = .

/* for each birth group, fill in possible values of prev_children */

/* first-borns born to fams w/ no previous children */
replace prev_children = 1 if oldest == 1

/* second borns can be born to fams w/ 1 girl or 1 boy */
replace prev_children = 2 if secondoldest == 1 & old_girl == 1
replace prev_children = 3 if secondoldest == 1 & old_girl == 0

/* third borns can be born to fams with 2 girls, mixed, or 2 boys */
replace prev_children = 4 if thirdoldest == 1 & old_girl == 1 & second_old_girl == 1
replace prev_children = 5 if thirdoldest == 1  & old_girl == 0 & second_old_girl == 0

replace prev_children = 6 if thirdoldest == 1 & old_girl == 1 & second_old_girl == 0
replace prev_children = 6 if thirdoldest == 1 & old_girl == 0 & second_old_girl == 1

/* define labels for composition of previous children */
label define prev_children 1 "n.a." 2 "Girl" 3 "Boy" 4 "Girl, Girl" 5 "Boy, Boy" 6 "Mixed"
label values prev_children prev_children

/*  outcome vars */
gen f = sex == 2 
gen m = sex == 1 

foreach i of var f m{
  replace `i' = . if sex == .
  }

// /* gen sexratio  */
// egen males = total(m)
// egen females = total(f)
// gen sr = males/females
// 
// /* no of girls in fam */
// bys `hhid': egen girls = total(f)
// bys `hhid': egen boys = total(m)

/* gen outcome vars (gender) */


/* gen sexratio by birth order and composition of previous children */
bys birth_group prev_children: egen males = total(m)
bys birth_group prev_children : egen females = total(f)
bys birth_group prev_children : gen sr = females/males

/* preserve Ns to calculate standard error of sex ratio */
bys birth_group prev_children: gen N = males + females

/* save clean individual-level dataset */
save /scratch/bcai/secc_birthorder_clean, replace

/* collapse dataset to relevant variables */
keep birth_group prev_children sr N
duplicates drop

/* check whether results are close to expected */
sort birth_group prev_children
list birth_group prev_children sr, sepby(birth_group)

/* calculate standard error of the sex ratio */
/* note: see this link for methods paper on SE or SR:
https://paa2008.princeton.edu/papers/80123*/
bys birth_group prev_children: gen se_sr = (1 + sr) * ((sr / N) ^0.5)

/* define 95% confidence intervals */
bys birth_group prev_children: gen sr_hi = sr + (1.96 * se_sr)
bys birth_group prev_children: gen sr_lo = sr - (1.96 * se_sr)

/* ADITI: ignore below for now  */
/* create a variable that contains info on both birth group and prev_children */
gen group_prev = prev_children if birth_group == 1
replace group_prev = prev_children + 2 if birth_group == 2
replace group_prev = prev_children + 6 if birth_group == 3

sort group_prev
list group_prev birth_group prev_children, sepby(birth_group)

/* create variable that contains info on both birth group and previous children */
graph twoway (bar sr prev_children) (rcap sr_hi sr_lo prev_children) , by(birth_group)

/* graph sex ratio by birth group and previous children w/ 95% CI */
graph bar sr, over1(birth_group) over2(prev_children)

graphout sr_birthorder, pdf






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


