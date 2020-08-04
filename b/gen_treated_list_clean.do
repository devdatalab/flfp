/**********************************/
/* COMBINES KGBV AND NPEGEL LISTS */
/**********************************/

/* open KGBV dataset */
use $ebb/kgbvs_list_clean, clear

/* merge with NPEGEL list */
merge 1:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/npegel_list_clean
drop _merge

/* generate treatment variable */
gen treatment = .
replace treatment = 0 if kgbvs_operational == 0 & npegel == 0
replace treatment = 1 if kgbvs_operational == 0 & mi(npegel)
replace treatment = 2 if kgbvs_operational > 0 & npegel == 0
replace treatment = 3 if kgbvs_operational > 0 & mi(npegel)
replace treatment = 4 if kgbvs_operational == 0 & npegel == 1
replace treatment = 5 if kgbvs_operational > 0 & npegel == 1

/* label values of treated dummy */
label define treatment_label 0 "No Treatment" 1 "No KGBV, Missing NPEGEL" 2 "KGBV Only" ///
    3 "KGBV, Missing NPEGEL" 4 "NPEGEL Only" 5 "KGBV & NPEGEL"
label values treatment treatment_label

/* generate treated dummy */
gen treatment_dummy = .
replace treatment_dummy = 0 if treatment == 0
replace treatment_dummy = 1 if treatment > 1

/* label treatment variable */
label var treatment "KGBV/NPEGEL treatment"
label var treatment_dummy "Dummy variable for any treatment"

/* save dataset */
save $ebb/treated_list_clean, replace
