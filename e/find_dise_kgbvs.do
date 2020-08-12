/*****************************************/
/* EXPLORING KGBV IDENTIFICATION IN DISE */
/*****************************************/

/************************/
/* Merge and Clean DISE */
/************************/

/* use seed dise dataset */
use $iec/dise/dise_basic_clean, clear

/* merge with other DISE datasets */
foreach dataset in dise_enr_clean dise_facility_clean.dta dise_general_clean {
  merge m:1 dise_state year vilcd schcd using $iec/dise/`dataset'
  drop _merge
}

/* focus on single year, after enaction of scheme */
keep if year == "2006-2007"

/* edit school names */
replace school_name = strlower(school_name)
replace school_name = strtrim(school_name)
replace school_name = stritrim(school_name)

/* save pre-merge dataset */
save $tmp/premerge, replace

/******************************/
/* Merge DISE with KGBVs List */
/******************************/

/* use cleaned DISE dataset */
use $tmp/premerge, clear

/* merge with key to get PC01 block names */
merge m:1 dise_state district dise_block_name using $ebb/pc01_dise_key

/* drop merge variable to faciliate second merge */
drop _merge

/* add missing state and district IDs */
bysort pc01_state_name (pc01_state_id): ///
    replace pc01_state_id = pc01_state_id[_n-1] if missing(pc01_state_id)
bysort pc01_district_name (pc01_district_id): ///
    replace pc01_district_id = pc01_district_id[_n-1] if missing(pc01_district_id)

/* merge with KGBV list */
merge m:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/kgbvs_list_clean

/* save as temporary dataset */
save $tmp/findkgbvs, replace

/******************************************/
/* Explore Methods of KGBV Identification */
/******************************************/

/* open dataset */
use $tmp/findkgbvs, clear

/* replace missings KGBV data with 0's */
replace kgbvs_operational = 0 if mi(kgbvs_operational)
replace total = 0 if mi(total)

/* add dummy for potential KGBV status */
gen potential = 0
replace potential = 1 if kgbvs_operational > 0 & enr_all_b < 10 ///
    & schmgt != "4" & schmgt != "5" & inrange(enr_all_g, total - 10, total + 10)
