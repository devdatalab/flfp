*********************************************
**** CLEAN AND MERGE OLD & NEW DISE DATA ****
*********************************************

**********************************************************
/* merge new dise data with enrollment and facility data */
**********************************************************

/* use basic DISE dataset */
use $iec/dise/dise_basic_clean, clear

/* merge with DISE enrollment data */
merge m:1 dise_state year vilcd schcd using $iec/dise/dise_enr_clean

keep if _merge == 3

drop _merge

/* merge witth  facility data */
merge m:1 dise_state year vilcd schcd using $iec/dise/dise_facility_clean.dta

keep if _merge == 3

drop _merge

/* merge with sc enrolmentt data */
merge m:1 dise_state year vilcd schcd using $iec/dise/dise_enr_sc
keep if _merge == 3
drop _merge

/* save dataset */
save $tmp/dise_0, replace

****************************************
/* create vilcd key to match old dise */
****************************************

/* use new dise data */
use $tmp/dise_0, clear

/* destring variables for collapse */
destring blackboard num_classrooms toilet_boys elec library toilet_common toilet_girls wall playground water, replace

/* collapse enr and facility varaibles at vilcd level */
collapse (sum) enr_all_g* enr_all_b* pass* m60*  blackboard num_classrooms toilet_boys elec library ///
    toilet_common toilet_girls wall playground water, by(year dise_state district dise_block vilcd)

/* save collapse dataset */
save $tmp/dise_0_c, replace

/* keep only single year of data for key */
keep if year == "2005-2006"

/* keep only id variables */
keep dise_state district dise_block vilcd

/* remove leading and trailing spaces in all obs */
foreach var in dise_state district dise_block vilcd {
replace `var'=strtrim(`var')
}

/* drop duplicates */
sort dise_state district dise_block vilcd
quietly by dise_state district dise_block vilcd: gen dup = cond(_N==1,0,_n)
drop if dup >1

/* drop dup variable */
drop dup

/* save vilcd level key */
save $tmp/vilcd_key, replace

*************************
/* clean old dise data */
*************************

/* use uncleaned old dise data */
use /scratch/pn/dise/education.dta, clear

/* rename vilid var */
rename vilid vilcd

/* keep enr, facility, id variables */
keep enr_sc* pass* m60* year vilcd schcd lib  blackboard clrooms toilet_g toilet_c toiletb elec bndrywall water play

/* keep data from 2001-04 */
keep if inlist(year, 1, 2, 3, 4)

/*  convert year to string */
tostring year, replace

/* edit year var to match new dise */
replace year = "2001-2002" if year == "1"
replace year = "2002-2003" if year == "2"
replace year = "2003-2004" if year == "3"
replace year = "2004-2005" if year == "4"

/* drop duplicates */
sort year vilcd schcd
quietly by year vilcd schcd: gen dup = cond(_N==1,0,_n)
drop if dup > 1

/* collapse at vilcd level */
collapse (sum) enr* pass* m60* lib blackboard clrooms toilet_g toilet_c toiletb elec bndrywall water play, by(year vilcd)

/* save cleaned dise data */
save $tmp/dise_old.dta, replace

**********************************************
/* merge old dise with new dise identifiers */
**********************************************

/* use cleaned dise data */
use $tmp/dise_old, replace

/* mergr with vilcd key */
merge m:1  vilcd using $tmp/vilcd_key

/* keep only matched obs */
keep if _merge == 3

/* drop merge variable */
drop _merge

/* save new dataset */
save $tmp/dise_old1, replace

***************************************
/* merge old dise with new dise data */
***************************************

/* use new dise collapsed data */
use $tmp/dise_0_c, clear

/* merge with old dise collapsed data */
merge m:1 year dise_state district dise_block_name vilcd using $tmp/dise_old1

/* replace enr vars from old dise */
foreach var in b1 b2 b3 b4 b5 b6 b7 b8 g1 g2 g3 g4 g5 g6 g7 g8 {
  replace enr_all_`var' = enr_sc`var' if mi(enr_all_`var')
}

/* replace pass and m60 vars from old dise */
foreach var in pass m60 {
  replace `var'_5g = `var'_g5 if mi(`var'_5g)
  replace `var'_5b = `var'_b5 if mi(`var'_5b)
  replace `var'_7g = `var'_g7 if mi(`var'_7g)
  replace `var'_7b = `var'_b7 if mi(`var'_7b)
}

/* drop old enr vars */
drop enr_sc* pass_b* pass_g* m60_g* m60_b*

/* replace facility vars from old dise */
replace num_classrooms = clrooms if mi(num_classrooms)
replace toilet_boys = toiletb if mi(toilet_boys)
replace toilet_girls = toilet_g if mi(toilet_girls)
replace toilet_common = toilet_c if mi(toilet_common)
replace library = lib if mi(library)
replace wall = bndrywall if mi(wall)
replace playground = play if mi(playground)

/* drop old facility vars */
drop clrooms toilet_g toilet_c toiletb lib bndrywall play

/* drop merge var */
drop _merge

/* drop enr vars other than primary */
foreach var in b9 b10 b11 b12 g9 g10 g11 g12 g b {
  drop enr_all_`var'
}

/* drop extra vars */
drop pass5 pass7 m605 m607

/* save old-new dise data */
save $tmp/dise_old_new, replace
