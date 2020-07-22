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

/* save dataset */
save $iec/ebb/kgbvs, replace
