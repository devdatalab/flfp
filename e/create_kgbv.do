/* import csv file */
import delimited "$iec/ebb/KGBV_list.csv", clear varnames(1) colrange(2:13)

/* rename blocks var */
rename blocks block

/* rename identifier vars */
 foreach var in state district block {
 replace `var' = lower(`var')
 rename `var' pc01_`var'_name
 }

/* rename data vars */
ren totalkgbvsapproved kgbvs_approved
ren noofkgbvsoperational kgbvs_operational

/* replace non-numeric obs to destring */
replace kgbvs_operational = "0" if kgbvs_operational == "NO"
replace sc = "." if sc == "S"

/* destring vars */
destring kgbvs_operational sc, replace

/* drop misc rows */
drop if pc01_block_name == "total"

/* replace state names */
replace pc01_state_name = "dadar nagar haveli" if pc01_state_name == "dadar & nagar haveli"
replace pc01_state_name = "jammu kashmir" if pc01_state_name == "j&k"

/* drop duplicates */
sort pc01_state_name pc01_district_name pc01_block_name
quietly by pc01_state_name pc01_district_name pc01_block_name: gen dup = cond(_N==1,0,_n)
drop if dup > 1

/* save dataset */
save $iec/ebb/kgbvs, replace
