/* import PC01 dataset */
use $pc01/pc01r_pca_clean, clear

/* make all string variables lowercase */
foreach var of varlist _all {
	local vartype: type `var'
	if substr("`vartype'", 1,3) == "str" {
		replace `var'= ustrlower(`var')
	}
}

/* drop villages with less than 100 residents */
drop if pc01_pca_tot_p < 100

/* collapse to block level */
collapse (sum) pc01_pca_tot_p, by(pc01_state_id pc01_district_id pc01_block_id)

/* destring ID variables to allow merge */
destring pc01_state_id pc01_district_id pc01_block_id, replace

/* merge with DISE data */
merge 1:m  pc01_state_id pc01_district_id pc01_block_id using $iec/flfp/dise_pc01_ebb

/* drop unmatched observations from master */
keep if _merge == 3

/* make population data into natural log */
gen ln_pc01_pca_tot_p = ln(pc01_pca_tot_p)

/* save temporary dataset */
save $tmp/dise_pc01_ebb_2, replace

