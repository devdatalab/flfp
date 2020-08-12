/*******************************************/
/* CREATES A PC01 AND DISE BLOCK-LEVEL KEY */
/*******************************************/

/***************************************************/
/* Prepare Block- and District-Level PC01 Datasets */
/***************************************************/

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
collapse (firstnm) pc01_pca_tot_p, by(pc01_block_id pc01_block_name pc01_district_id ///
    pc01_district_name pc01_state_id pc01_state_name)

/* recode roman numerals to avoid masala merge error */
replace pc01_block_name = regexr(pc01_block_name, "ii$", "2")

/* fix EBBs which have no name in PC01 ("forest villages" in ebbs_list) */
global uplist kheri jhansi bahraich gonda mahrajganj sonbhadra

foreach district in $uplist {
  replace pc01_block_name = "forest villages" if mi(pc01_block_name) & ///
      pc01_state_name == "uttar pradesh" & pc01_district_name == "`district'"
}

replace pc01_block_name = "forest villages" if mi(pc01_block_name) & ///
    pc01_state_name == "uttarakhand" & pc01_district_name == "udham singh nagar"
replace pc01_block_name = "forest villages" if mi(pc01_block_name) & ///
    pc01_state_name == "uttarakhand" & pc01_district_name == "champawat"

/* generate unique identifiers (necessary for masala merge) */
gen id = pc01_state_id + "-" + pc01_district_id + "-" + pc01_block_name

/* destring block ID */
destring pc01_block_id pc01_state_id pc01_district_id, replace

/* save block level */
save $tmp/pc01_blocks, replace

/* collapse to district level */
collapse (firstnm) pc01_pca_tot_p, by(pc01_district_name pc01_district_id ///
    pc01_state_name pc01_state_id)

/* drop extraneous variable */
drop pc01_pca_tot_p

/* generate unique IDs */
tostring pc01_state_id, replace
gen id = pc01_state_id + "-" + pc01_district_name
destring pc01_state_id, replace

/* save pc01 dataset */
save $tmp/pc01_districts, replace

/************************/
/* Merge PC01 with DISE */
/************************/

/* use basic DISE dataset */
use $iec/dise/dise_basic_clean, clear

/* generate key PC01 variables */
gen pc01_district_name = lower(district)
gen pc01_state_name = lower(dise_state)
gen pc01_block_name1 = lower(dise_block_name)

/* remove trailing and leading spaces */
replace pc01_block_name1 = strtrim(pc01_block_name1)

/* gen a year var for merge */
gen year11 = substr(year, 1, 4)
drop year
rename year11 year

/* destring year */
destring year, replace

/* keep when vilcd appears first */
by vilcd, sort: egen min_year = min(year)
keep if year == min_year

/* keep only id variables */
keep dise_block_name dise_state district pc01_block_name1 pc01_district_name pc01_state_name

/* rename state names */
foreach var in andhra arunachal himachal madhya uttar {
replace pc01_state_name = "`var' pradesh" if pc01_state_name == "`var'-pradesh"
}

replace pc01_state_name = "west bengal" if pc01_state_name == "west-bengal"
replace pc01_state_name = "tamil nadu" if pc01_state_name == "tamil-nadu"
replace pc01_state_name = "andaman nicobar islands" if pc01_state_name == "andaman-and-nicobar-islands"
replace pc01_state_name = "dadra nagar haveli" if pc01_state_name == "dadra-and-nagar-haveli"
replace pc01_state_name = "daman diu" if pc01_state_name == "daman-and-diu"
replace pc01_state_name = "jammu kashmir" if pc01_state_name == "jammu-and-kashmir" ///
    | pc01_state_name == "jammu-&-kashmir"
replace pc01_state_name = "uttarakhand" if pc01_state_name == "uttaranchal"
replace pc01_state_name = "chhattisgarh" if pc01_state_name == "chattisgarh"
replace pc01_state_name = "pondicherry" if pc01_state_name == "puducherry"

/* edit district names */
foreach var in east west south north {
  replace pc01_district_name = "`var'" if pc01_district_name == "`var' delhi"
  replace pc01_district_name = "`var'" if pc01_district_name == "`var' sikkim"
}

/* rename districts */
replace pc01_district_name = "aurangabad" if pc01_district_name == "aurangabad (maharashtra)"
replace pc01_district_name = "kamrup" if pc01_district_name == "kamrup-rural"
replace pc01_district_name = "north cachar hills" if pc01_district_name == "dima hasao"
replace pc01_district_name = "bilaspur" if pc01_district_name == "bilaspur (chhattisgarh)"
replace pc01_district_name = "raigarh" if pc01_district_name == "raigarh (chhattisgarh)"
replace pc01_district_name = "bangalore" if pc01_district_name == "bangalore u south"
replace pc01_district_name = "chikmagalur" if pc01_district_name == "chikkamangalore"
replace pc01_district_name = "east nimar" if pc01_district_name == "khandwa" ///
    | pc01_district_name == "burhanpur"
replace pc01_district_name = "west nimar" if pc01_district_name == "khargone"
replace pc01_district_name = "raigarh" if pc01_district_name == "raigarh (maharashtra)"
replace pc01_district_name = "baleshwar" if pc01_district_name == "balasore"
replace pc01_district_name = "kendujhar" if pc01_district_name == "keonjhar"
replace pc01_district_name = "sant ravidas nagar bhadohi" if pc01_district_name == "bhadoi"
replace pc01_district_name = "medinipur" if pc01_district_name == "paschim medinipur" ///
    | pc01_district_name == "purba medinipur"

/* drop duplicates*/
sort pc01_state_name pc01_district_name pc01_block_name1
quietly by pc01_state_name pc01_district_name pc01_block_name1: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

/*  generate unique identifiers for observations (necessary for masala merge) */
gen id = pc01_state_name + "-" + pc01_district_name + "_" + pc01_block_name1
tostring id, replace

/* save as temporary dataset */
save $tmp/dise_clean, replace

/***************************/
/* Match at District-Level */
/***************************/

/* open temporary DISE dataset */
use $tmp/dise_clean, clear

/* use masala merge to fuzzy merge datasets */
masala_merge pc01_state_name using $tmp/pc01_districts, ///
    s1(pc01_district_name) idmaster(id) idusing(id)

/* merge using and master names */
ren pc01_district_name_using pc01_district_name

/* drop if unmatched */
drop if match_source == 6

/* drop merge variables */
drop id_using id_master pc01_district_name_master match_source masala_dist _merge

/* drop missing block names obs */
drop if mi(pc01_block_name1)

/* drop duplicates */
sort pc01_state_name pc01_district_name pc01_block_name1
quietly by pc01_state_name pc01_district_name pc01_block_name1: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

/* gen unique identifiers */
tostring pc01_state_id pc01_district_id, replace
gen id = pc01_state_id + "-" + pc01_district_id + "-" + pc01_block_name1
destring pc01_state_id pc01_district_id, replace

/* rename PC01 block name to facilitate merge */
ren pc01_block_name1 pc01_block_name

/* save district-level key */
save $tmp/district_level_match, replace

***********
/* BLOCK */
***********

/* use district_level key */
use $tmp/district_level_match, clear

/* masala merge with block names from pc01 */
masala_merge pc01_state_name pc01_district_name ///
    using $tmp/pc01_blocks, s1(pc01_block_name) idmaster(id) idusing(id)

/* process manual matches */
process_manual_matches, outfile($tmp/dise_pc01_manual.csv) ///
    infile(/scratch/plindsay/unmatched_observations_140308.csv) ///
    s1(pc01_block_name) idmaster(id_master) idusing(id_using)

/* open merge results */
use $tmp/merge_results_140308, clear

/* insert manual matches */
insert_manual_matches, manual_file($tmp/manual_dise.csv) ///
    idmaster(id_master) idusing(id_using)

/* merge using and master block names into one variable */
ren pc01_block_name_using pc01_block_name

/* keep only key variables */
keep pc01_state_name pc01_district_name pc01_block_name pc01_state_id ///
    pc01_district_id pc01_block_id dise_state district dise_block_name

/* drop missing data */
drop if mi(dise_block_name) | mi(pc01_block_name)

/* label key variables */
label var pc01_block_name "PC01 Block Name"
label var pc01_district_name "PC01 District Name"
label var pc01_state_name "PC01 State Name"
label var dise_state "DISE11 State Name"
label var district "DISE11 District Name"
label var dise_block_name "DISE11 Block Name"
label var pc01_state_id "PC01 State ID"
label var pc01_district_id "PC01 District ID"
label var pc01_block_id "PC01 Block ID"

/* save key */
save $ebb/pc01_dise_key, replace
