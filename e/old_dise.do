***************************
**** ADD OLD DISE DATA ****
***************************

/* create vilcd key to match old dise */

use $tmp/dise_0, clear

destring blackboard num_classrooms toilet_boys elec library toilet_common toilet_girls wall playground water, replace

collapse (sum) enr_all_g* enr_all_b*  blackboard num_classrooms toilet_boys elec library ///
    toilet_common toilet_girls wall playground water, by(year dise_state district dise_block vilcd)

save $tmp/dise_0_c, replace

keep if year == "2005-2006"

keep dise_state district dise_block vilcd

foreach var in dise_state district dise_block vilcd {
replace `var'=strtrim(`var')
}

sort dise_state district dise_block vilcd
quietly by dise_state district dise_block vilcd: gen dup = cond(_N==1,0,_n)
drop if dup >1

drop dup

save $tmp/vilcd_key, replace

***************************

/* clean old dise data */

use /scratch/pn/dise/education.dta, clear

rename vilid vilcd

keep enr_sc* year vilcd schcd lib  blackboard clrooms toilet_g toilet_c toiletb elec bndrywall water play

keep if inlist(year, 1, 2, 3, 4)

tostring year, replace

replace year = "2001-2002" if year == "1"
replace year = "2002-2003" if year == "2"
replace year = "2003-2004" if year == "3"
replace year = "2004-2005" if year == "4"

sort year vilcd schcd
quietly by year vilcd schcd: gen dup = cond(_N==1,0,_n)
drop if dup > 1

collapse (sum) enr* lib blackboard clrooms toilet_g toilet_c toiletb elec bndrywall water play, by(year vilcd)

save $tmp/dise_old.dta, replace

***************************

/* merge old dise with new dise identifiers */

use $tmp/dise_old, replace

merge m:1  vilcd using $tmp/vilcd_key

keep if _merge == 3

drop _merge

save $tmp/dise_old1, replace

***************************

/* merge old dise with new dise data */

use $tmp/dise_0_c, clear

merge m:1 year dise_state district dise_block_name vilcd using $tmp/dise_old1

foreach var in b1 b2 b3 b4 b5 b6 b7 b8 g1 g2 g3 g4 g5 g6 g7 g8 {
  replace enr_all_`var' = enr_sc`var' if mi(enr_all_`var')
}

drop enr_sc*

replace num_classrooms = clrooms if mi(num_classrooms)
replace toilet_boys = toiletb if mi(toilet_boys)
replace toilet_girls = toilet_g if mi(toilet_girls)
replace toilet_common = toilet_c if mi(toilet_common)
replace library = lib if mi(library)
replace wall = bndrywall if mi(wall)
replace playground = play if mi(playground)

drop clrooms toilet_g toilet_c toiletb lib bndrywall play

drop _merge

foreach var in b9 b10 b11 b12 g9 g10 g11 g12 g b {
  drop enr_all_`var'
}

save $tmp/dise_old_new, replace


/*

******************************************

/* old dise merge new dise */

use /scratch/pn/dise/education.dta, clear

rename vilid vilcd

rename blkid pc01_block_id

rename distid pc01_district_id

rename state pc01_state_id

keep enr_sc* year pc01_state_id pc01_district_id pc01_block_id vilcd schcd

drop pc01_state_id pc01_district_id pc01_block_id

// keep if year == 12

// collapse (sum) enr*, by(year pc01_stat_id pc01_district_id pc01_block_id vilcd)

keep if inlist(year, 1, 2, 3, 4)

tostring year, replace

replace year = "2001-2002" if year == "1"
replace year = "2002-2003" if year == "2"
replace year = "2003-2004" if year == "3"
replace year = "2004-2005" if year == "4"

sort year vilcd schcd
quietly by year vilcd schcd: gen dup = cond(_N==1,0,_n)
drop if dup > 1

collapse (sum) enr*, by(year vilcd)

save $tmp/dise_old.dta, replace

use $tmp/dise_0, clear

collapse (sum) enr*, by(year dise_state district dise_block vilcd)

use $tmp/dise_0_c, clear

merge m:1 year vilcd using $tmp/dise_old, force


*****

use $tmp/dise_0_c, clear

keep if year == "2005-2006"

keep dise_state district dise_block vilcd

foreach var in dise_state district dise_block vilcd {
replace `var'=strtrim(`var')
}

sort dise_state district dise_block vilcd
quietly by dise_state district dise_block vilcd: gen dup = cond(_N==1,0,_n)
drop if dup >1

drop dup

save $tmp/vilcd_key, replace

*****

use $tmp/dise_old, replace

// keep if  year == "2004-2005"

// merge m:1  vilcd using $tmp/vilcd_key
