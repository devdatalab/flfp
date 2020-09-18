/* set global to where aditi stored secc birthorder data */
global tmp /scratch/adibmk/

// foreach sector in urban  {
// /* append cleaned urban and rural birthorder datasets */
// use $tmp/`sector'_birthorder, clear
// 
// /* set IDs for urban and rural */
// if "`sector'" == "urban"  local hhid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_block_id  pc11_ward_id pc11_town_id house_no 
// if "`sector'" == "rural" local hhid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_village_id mord_hh_id
  //

//use $tmp/urban_birthorder, clear
use $tmp/rural_birthorder, clear
  
//local hhid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_block_id  pc11_ward_id pc11_town_id house_no
local hhid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_village_id mord_hh_id
  
/* keep only children to make dataset smaller */
keep if age <= 18

/* drop upper right tail of birthorder ( 3 % of data)*/
drop if birthorder > 5

/* tag oldest child in each households */
/* WARNING: bc of high N, takes ~7 mins */
bys `hhid': egen highestorder = max(birthorder)

/* drop one child families */
// drop if highestorder == 1

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

  foreach i of var *oldest youngest{
    replace `i' = . if highestorder == 1
    }
  
/*************************************************************************/
/* Check if average diff between siblings varies by gender of first born */
/*************************************************************************/
//local hhid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_block_id  pc11_ward_id pc11_town_id house_no 
local hhid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_village_id house_no 

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
  gen second_old_girl = 1 if sex == 2 & secondoldest == 1 & highestorder > 2
  replace second_old_girl = 1 if sex == 2 & youngest == 1 & highestorder == 2

  replace second_old_girl = 2 if sex == 1 & secondoldest == 1 & highestorder > 2
  replace second_old_girl = 2 if sex == 1 & youngest == 1 & highestorder == 2

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
//set scheme pn
//cibar avg_diff, over(old_girl) graphopts(xtitle("Sex of oldest child") ytitle("Avg age diff between successive siblings"))
//graphout diff_1
//
// /* save intermediate dataset with HH characteristics */
// 
//   save $tmp/`sector'_secc_birthspace_hh, replace
//   
// /* close loop over sectors*/
// }
// 
// /* append urban and rural intermediate datasets */
// use $tmp/urban_secc_birthspace_hh, clear
// append using $tmp/rural_secc_birthspace_hh
// 
/********************************************************************************/
/* Check sex ratios of younger siblings conditional on gender of older siblings */
/********************************************************************************/
/* Note: this is an attempt to replicate Fig 1 from Almond and Edlund (2001) */

/* outcome vars */

set scheme pn

///* oldest child under 18 */
gen birth_group = 4 - birthorder
//replace birth_group = 1 if oldest == 1
//
///* second-oldest child under 18 */
//replace birth_group = 2 if secondoldest == 1 & highestorder > 2
////replace birth_group = 2 if youngest == 1 & highestorder == 2
//
///* third-oldest child under 18 */
//replace birth_group = 3 if thirdoldest == 1 & highestorder > 3
////replace birth_group = 3 if youngest == 1 & highestorder == 3
//
///* limit to 3-child families */
//drop if birth_group == .
drop if highestorder > 3

/* create var that indicates gender-composition of existing kids */
gen prev_children = .

/* for each birth group, fill in possible values of prev_children */

/* first-borns born to fams w/ no previous children */
replace prev_children = 0 if highestorder == 1

/* second borns can be born to fams w/ 1 girl or 1 boy */
replace prev_children = 2 if highestorder == 2 & old_girl == 1
replace prev_children = 3 if highestorder == 2 & old_girl == 0

/* third borns can be born to fams with 2 girls, mixed, or 2 boys */
replace prev_children = 4 if highestorder == 3 & old_girl == 1 & second_old_girl == 1
replace prev_children = 5 if highestorder == 3  & old_girl == 0 & second_old_girl == 0

replace prev_children = 6 if highestorder == 3 & old_girl == 1 & second_old_girl == 0
replace prev_children = 6 if highestorder == 3 & old_girl == 0 & second_old_girl == 1

/* define labels for composition of previous children */
label define prev_children 0 "n.a." 2 "Girl" 3 "Boy" 4 "Girl, Girl" 5 "Boy, Boy" 6 "Mixed", modify
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
replace birth_group = 0 if highestorder == 1
replace prev_children = 0 if highestorder == 1
replace youngest = 99 if highestorder == 1
bys highestorder prev_children birthorder: egen males = total(m)
bys highestorder prev_children birthorder: egen females = total(f)
bys highestorder prev_children birthorder: gen sr = males/females
//bys highestorder prev_children birthorder: gen sr = females/males

/* preserve Ns to calculate standard error of sex ratio */
bys highestorder prev_children birthorder: gen N = males + females

/* save clean individual-level dataset */
save $tmp/secc_birthorder_clean, replace
save /scratch/bcai/secc_birthorder_clean, replace

/* collapse dataset to relevant variables */
keep if inlist(youngest, 1, 99)
keep highestorder prev_children sr N
duplicates drop

/* check whether results are close to expected */
sort highestorder prev_children
list highestorder prev_children sr, sepby(highestorder)

/* calculate standard error of the sex ratio */
/* note: see this link for methods paper on SE or SR:
https://paa2008.princeton.edu/papers/80123*/
bys highestorder prev_children: gen se_sr = (1 + sr) * ((sr / N) ^0.5)

/* define 95% confidence intervals */
bys highestorder prev_children: gen sr_hi = sr + (1.96 * se_sr)
bys highestorder prev_children: gen sr_lo = sr - (1.96 * se_sr)

/* ADITI: ignore below for now  */
/* create a variable that contains info on both birth group and prev_children */
gen group_prev = prev_children if highestorder == 1
replace group_prev = prev_children + 1 if highestorder == 2
replace group_prev = prev_children + 2 if highestorder == 3

sort group_prev
list group_prev birth_group prev_children, sepby(birth_group)

/* set global so graphs will go to my output */
global tmp /scratch/bcai/

/* graph replication of Almond and Edlund */
twoway (bar sr group_prev if highestorder == 1) ///
    (bar sr group_prev if highestorder == 2) ///
    (bar sr group_prev if highestorder == 3) ///
    (rcap sr_hi sr_lo group_prev), ///
    legend(order(1 "1st child" 2 "2nd child" 3 "3rd child" 4 "95% CI")) ///
    xlabel(0 "n.a." 3 "Girl" 4 "Boy" 6"Girl, Girl" 7 "Boy, Boy" 8 "Mixed") ///
    xtitle("Sex of previous children") ytitle("Sex Ratio (male/female)" ) ///
    yline(1.05, lcolor(red))
graphout trial  


graphout sr_birthorder, pdf


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

/****************************/
/* Aditis code starts here */
/****************************/

/* drop hh where youngest child is too old */
gen age_youngest = age if youngest == 1

/* fill in age_youngest variable for the hh */
sort `hhid'
egen hhid = group(`hhid')
bys hhid: egen ay = max(age_youngest)

/* drop hhs where youngest child is too old */
/* bc in these cases we're prob missing older siblings */
drop if ay >= 12

/* check relationship between no. of kids and sex of eldest */
gen sex_oldest = sex if oldest == 1
bys hhid: egen so = max(sex_oldest)

/* label this var */
label define so 1 "Eldest is a son" 2 "Eldest is a daughter"
label values so so

/* graph */
cibar highestorder, over(so) graphopts(ytitle("Family size", margin(medium)) ///
    xtitle("Gender of oldest child", margin(medium)) ylabel(0(0.5)5))
graphout familysize

