/******************************/
/* Standardize EBB formatting */
/******************************/

/* open EBB dataset */
use $ebb/ebbs_list, clear

/* make state, district, block names lowercase */
replace state_name = lower(state_name)
ren state_code pc01_state_id
replace district_name = lower(district_name)
ren district_code pc01_district_id
replace cd_block_name = lower(cd_block_name)
ren cd_block_name pc01_block_name

/* generate unique identifiers for observations (necessary for masala merge) */
gen id = _n

/***********************/
/* Merge with PC01 key */
/***********************/

/* use masala merge to fuzzy merge datasets */
masala_merge pc01_state_id pc01_district_id using $ebb/pc01_village_block_key, ///
    s1(pc01_block_name) idmaster(id) idusing(id)
