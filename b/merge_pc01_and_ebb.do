/* install packages necessary for masala merge */
ssc install reclink

/******************************/
/* Standardize EBB formatting */
/******************************/

/* open EBB dataset */
use $ebb/ebbs_list, clear

/* make state, district, block names lowercase */
replace state_name = lower(state_name)
replace district_name = lower(district_name)
replace cd_block_name = lower(cd_block_name)

/* standardize variable names */
ren state_code pc01_state_id
ren state_name pc01_state_name
ren district_code pc01_district_id
ren district_name pc01_district_name
ren cd_block_name pc01_block_name

/* drop unnamed forest villages (no match in PC01) */
drop if pc01_block_name == "forest villages"

/* manually change ebb districts to pc01 districts */
replace pc01_district_id = 10 if pc01_block_name == "uklana (p)"
replace pc01_district_id = 10 if pc01_block_name == "sikandrabad"
replace pc01_district_id = 46 if pc01_block_name == "puredalai"
replace pc01_district_id = 4 if pc01_block_name == "amroha"
replace pc01_district_id = 5 if pc01_block_name == "kulgam"
replace pc01_district_id = 5 if pc01_block_name == "shupiyan"
replace pc01_district_id = 12 if pc01_block_name == "shahpura" ///
    & pc01_state_name == "rajasthan"

/* generate unique identifiers for observations (necessary for masala merge) */
gen id = _n
tostring id, replace

/***********************/
/* Merge with PC01 key */
/***********************/

/* use masala merge to fuzzy merge datasets */
masala_merge pc01_state_id pc01_district_id using $ebb/pc01_village_block_key, ///
    s1(pc01_block_name) idmaster(id) idusing(id)

/* drop merge variable */
drop _merge

/* merge using and master block names into one variable */
gen pc01_block_name = pc01_block_name_master
replace pc01_block_name = pc01_block_name_using if mi(pc01_block_name_master)

/* manually drop duplicate uttar pradesh observations that are not
captured in the ddrop because they're in different districts */
drop if match_source == 6

/* generate unique identifiers for observations */
gen id = _n
tostring id, replace

/* drop variables which will be generates in future masala merges */
drop id_using id_master pc01_block_name_master pc01_block_name_using

/* save merged dataset */
save $ebb/ebbs_list_clean, replace
