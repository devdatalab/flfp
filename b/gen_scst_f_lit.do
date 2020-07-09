/* drop duplicates in household data */
use $secc/final/dta/tripura_household_clean, clear

drop if flag_duplicates == 1

save $tmp/tripura_household_clean, replace

/* load dataset */
use $secc/final/dta/tripura_members_clean, clear
merge m:1 mord_hh_id using $tmp/tripura_household_clean

keep if sex == 2
keep if sc_st == 1 | sc_st ==  2
keep if age > 6 & age < 100

gen sc_f_lit = 0
replace sc_f_lit = 1 if sc_st == 1 & ed != 1

gen sc_pop = 0
replace sc_pop = 1 if sc_st == 1

gen st_f_lit = 0
replace st_f_lit = 1 if sc_st == 2 & ed != 1

gen st_pop = 0
replace st_pop = 1 if sc_st == 2

collapse (sum) sc_f_lit sc_pop st_f_lit st_pop, ///
    by(pc01_state_id pc01_village_id)

drop if sc_pop == 0 & st_pop == 0

save $tmp/tripura_scst, replace

merge 1:1 pc01_state_id pc01_village_id ///
    using $pc01/pc01r_pca_clean

