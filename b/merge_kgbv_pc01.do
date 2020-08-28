/*********************************************/
/* MERGE KGBV LIST WITH PC01 AND EBB DATASET */
/*********************************************/

/**********************/
/* Clean KGBV Dataset */
/**********************/

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
drop if mi(pc01_state_name) | mi(pc01_district_name) | mi(pc01_block_name)

/* replace state names */
replace pc01_state_name = "dadar nagar haveli" if pc01_state_name == "dadar & nagar haveli"
replace pc01_state_name = "jammu kashmir" if pc01_state_name == "j&k"

/* drop duplicates */
sort pc01_state_name pc01_district_name pc01_block_name
quietly by pc01_state_name pc01_district_name pc01_block_name: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

/* remove extraneous characters from district names */
replace pc01_district_name = regexr(pc01_district_name, "\((.)+\)", "")
replace pc01_district_name = regexr(pc01_district_name, "Â", "")
replace pc01_district_name = strtrim(pc01_district_name)

/* generate unique identifiers (for masala merge) */
gen id = pc01_state_name + "-" + pc01_district_name + "-" + pc01_block_name

/* save dataset */
save $ebb/kgbvs, replace

/************************/
/* Match District Names */
/************************/

/* use clean EBB x PC01 dataset */
use $ebb/ebbs_list_clean, clear

/* collapse so dataset is unique on district level (masala merge is m:1) */
collapse (firstnm) pc01_block_id, by(pc01_state_name pc01_state_id ///
    pc01_district_name pc01_district_id)

/* drop block ID, since we only need state and district data */
drop pc01_block_id

/* generate new unique ID */
gen id = pc01_state_name + "-" + pc01_district_name

/* save collapsed dataset for masala merge */
save $tmp/collapsed_ebbs_list_clean, replace

/* use KGBV dataset */
use $ebb/kgbvs, clear

/* manually alter district names */
replace pc01_district_name = "cuddapah" if pc01_district_name == "kadapa" ///
    & pc01_state_name == "andhra pradesh"
replace pc01_district_name = "pashchim champaran" if pc01_district_name == "west champaran" ///
    & pc01_state_name == "bihar"
replace pc01_district_name = "purba champaran" if pc01_district_name == "e.champaran" ///
    & pc01_state_name == "bihar"
replace pc01_district_name = "kaimur bhabua" if pc01_district_name == "kaimur" ///
    & pc01_state_name == "bihar"
replace pc01_district_name = "faridabad" if pc01_district_name == "faridabad/ mewat" ///
    & pc01_state_name == "haryana"
replace pc01_district_name = "gurgaon" if pc01_district_name == "gurgaon/ mewat" ///
    & pc01_state_name == "haryana"
replace pc01_district_name = "leh ladakh" if pc01_district_name == "leh" ///
    & pc01_state_name == "jammu kashmir"
replace pc01_district_name = "pashchimi singhbhum" if pc01_district_name == "w. singhbhum" ///
    & pc01_state_name == "jharkhand"
replace pc01_district_name = "purbi singhbhum" if pc01_district_name == "e. singhbhum" ///
    & pc01_state_name == "jharkhand"
replace pc01_district_name = "lunglei" if pc01_district_name == "lungsen" ///
    & pc01_state_name == "mizoram"
replace pc01_district_name = "kendujhar" if pc01_district_name == "keonjhar" ///
    & pc01_state_name == "orissa"
replace pc01_district_name = "kendujhar" if (pc01_block_name == "ghatagaon" ///
    | pc01_block_name == "anandapur") & pc01_state_name == "orissa"
replace pc01_district_name = "namakkal" if pc01_district_name == "namakool" ///
    & pc01_state_name == "tamil nadu"
replace pc01_district_name = "sant ravidas nagar bhadohi" if pc01_district_name == "bhadohi" ///
    & pc01_state_name == "uttar pradesh"
replace pc01_district_name = "rae bareli" if pc01_district_name == "raibarielly" ///
    & pc01_state_name == "uttar pradesh"
replace pc01_district_name = "medinipur" if pc01_district_name == "paschim medinipur" ///
    & pc01_state_name == "west bengal"

/* merge with collapsed PC01 dataset */
masala_merge pc01_state_name using $tmp/collapsed_ebbs_list_clean, ///
    s1(pc01_district_name) idmaster(id) idusing(id)

/* rename PC01 district name variable as core name variable */
ren pc01_district_name_using pc01_district_name

/* replace unmatched KGBV districts with KGBV dataset district names */
replace pc01_district_name = pc01_district_name_master if mi(pc01_district_name)

/* drop unmatched observations from the PC01 dataset */
drop if match_source == 7

/* generate unique IDs for each observation (for masala merge) */
tostring pc01_state_id pc01_district_id, replace
gen id = pc01_state_id + "-" + pc01_district_id + "-" + pc01_block_name
destring pc01_state_id pc01_district_id, replace

/* drop extraneous variables */
drop _merge pc01_district_name_master masala_dist id_using id_master match_source

/* save new KGBV dataset with PC01 IDs */
save $ebb/kgbvs, replace

/*********************/
/* Match Block Names */
/*********************/

/* use master list of EBBs (master names are selected by masala merge) */
use $ebb/ebbs_list_clean, clear

/* merge with the clean merge between PC01 and EBBs */
masala_merge pc01_state_name pc01_district_name using $ebb/kgbvs, ///
    s1(pc01_block_name) idmaster(id) idusing(id) ///
    manual_file(~/ddl/flfp/b/manual_matches/manual_kgbv_pc01.csv)

/* make master block names the key block name variable */
ren pc01_block_name_master pc01_block_name

/* drop if unmatched from KGBV data (cannot merge on block ID later) */
drop if mi(pc01_block_id)

/* drop extraneous variables */
drop match_source pc01_block_name_using _merge masala_dist _new_match_flg ///
    _pc01_block_name_master _pc01_block_name_using id_master id_using

/* label KGBV variables */
label var model "KGBV Type"
label var sc "Scheduled Caste Enrollment in KGBVs"
label var st "Scheduled Tribe Enrollment in KGBVs"
label var obc "Other Backward Caste Enrollment in KGBVs"
label var bpl "Below Poverty Line Enrollment in KGBVs"
label var min "Minority Enrollment in KGBVs"
label var total "Total Enrollment in KGBVs"

/* replace missing data with zeroes */
foreach var in kgbvs_approved kgbvs_operational model sc st obc bpl min total {
  replace `var' = 0 if mi(`var')
}

/* save final dataset */
save $ebb/kgbvs_list_clean, replace
