/*********************/
/* Prep FLFP in EC13 */
/*********************/

/* merge ec13 and pc01 */
use $dir/iec/shrug/pca/shrug_pc01_pca.dta, clear
merge 1:1 shrid using $dir/iec/shrug/ec/shrug_ec13.dta

/* merge the new dataset and district key */
drop _merge
merge 1:1 shrid using $dir/iec/shrug/pca/shrug_pc01_district_key.dta

/* collapse by state and district */
collapse ec13_emp_f pc01_pca_tot_f, by (pc01_state_id pc01_state_name pc01_district_id pc01_district_name)

/* generate female labor force participation. The denominator is the total number of
women times the 63.3% of women of working age based on the 2001 population pyramid */
gen ec13_flfp = ec13_emp_f / (pc01_pca_tot_f * 0.633)

/* drop the extraneous variables */
drop ec13_emp_f pc01_pca_tot_f

/* temporarily save the clean dataset for later merge */
save $tmp/ec13_flfp, replace

/**********************/
/* Prep FLFP in NSS68 */
/**********************/

/* open Block 4 */
use $dir/iec/nss/nss-68/10/block-4-members, clear

/* make all the variable names lowercase */
rename *, lower

/* rename and destring a few variables */
ren multiplier_comb wt
ren person_serial_no memid
destring sex, replace

/* temporarily save the cleaned dataset */
keep sex district_code hhid memid wt
save $tmp/nss-68-10-member-list, replace

/* open Block 5.1 */
use $dir/iec/nss/nss-68/10/block-51-usual-act

/* make all the variable names lowercase */
rename *, lower

/* rename and destring a few variables */
ren multiplier_comb wt
ren person_serial_no memid
ren usual_principal_activity_status activity
destring activity, replace

/* generate a dummy indicator for labor force (not included if currently in school) */
gen laborforce = 1
replace laborforce = 0 if age < 15 | age > 70

/* merge cleaned block 5.1 and block 4 */
merge 1:1 hhid memid using $tmp/nss-68-10-member-list

/* generate a dummy for female labor force participation */
gen flfp = 1 if sex == 2 & laborforce == 1
replace flfp = 0 if activity >= 91

/* drop all the males */
drop if sex == 1

/* collapse by district */
collapse (sum) flfp laborforce [aw=wt], by (state district)

/* generate flfp as a percentage of the potential female labor force */
gen nss68_flfp = flfp / laborforce

/* drop extraneous variables */
drop flfp laborforce

/* rename the district and state variables so they correspond with the key code */
ren district pc01_district_id
ren state pc01_state_id

/* temporarily save the dataset */
save $tmp/nss68_flfp, replace

/* collapse the district key by state */
use $dir/iec/shrug/pca/shrug_pc01_district_key.dta, clear
collapse (firstnm) shrid, by (pc01_state_id pc01_state_name pc01_district_id pc01_district_name)

/* drop the extraneous variable */
drop shrid

/* merge the prepped NSS68 with the collapsed district key */
merge 1:1 pc01_state_id pc01_district_id using $tmp/nss68_flfp
drop _merge

/**************************/
/* Merge to final dataset */
/**************************/

/* merge the NSS68 FLFP and EC13 FLFP datasets */
merge 1:1 pc01_state_id pc01_district_id using $tmp/ec13_flfp

