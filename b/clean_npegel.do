/*************************/
/* MATCHES NPEGEL & PC01 */
/*************************/

/* use dataset */
use $iec/ebb/NPEGEL_status.dta, clear

/* rename variables */
rename statnameFE pc01_state_name
rename distname pc01_district_name
rename blkname pc01_block_name

/* edit names */
foreach var in state district block {
   replace pc01_`var'_name = strlower(pc01_`var'_name)
}

/* manually fix district names */
replace pc01_district_name = "chikmagalur" if pc01_district_name == "chikkamangalore"
replace pc01_district_name = "east nimar" if pc01_district_name == "khandwa"
replace pc01_district_name = "west nimar" if pc01_district_name == "khargone"
replace pc01_district_name = "baleshwar" if pc01_district_name == "balasore"
replace pc01_district_name = "kendujhar" if pc01_district_name == "keonjhar"
replace pc01_district_name = "sundargarh" if pc01_district_name == "sundergarh"
replace pc01_district_name = "bastar" if pc01_district_name == "baster"
replace pc01_district_name = "janjgir champa" if pc01_district_name == "janjgir - champa"
replace pc01_district_name = "chamarajanagar" if pc01_district_name == "chamarajanagara"
replace pc01_district_name = "sonapur" if pc01_district_name == "sonepur"
replace pc01_district_name = "balangir" if pc01_district_name == "bolangir"
replace pc01_district_name = "nabarangapur" if pc01_district_name == "nabarangpur"
replace pc01_district_name = "debagarh" if pc01_district_name == "deogarh"
replace pc01_district_name = "north twenty four parganas" if pc01_district_name == "north twenty four pargana"
replace pc01_district_name = "bulandshahar" if pc01_district_name == "bulandshahr"
replace pc01_district_name = "hamirpur" if pc01_district_name == "hamirpur (u.p.)"
replace pc01_district_name = "medinipur" if pc01_district_name == "purba medinipur"
replace pc01_district_name = "mahrajganj" if pc01_district_name == "maharajganj"
replace pc01_district_name = "south twenty four parganas" if pc01_district_name == "south  twenty four pargan"
replace pc01_district_name = "jagatsinghapur" if pc01_district_name == "jagatsinghpur"
replace pc01_district_name = "jajapur" if pc01_district_name == "jajpur"
replace pc01_district_name = "anugul" if pc01_district_name == "angul"

/* drop state name */
ren pc01_state_name state

/* drop duplicates if any */
sort pc01_district_name pc01_block_name
quietly by pc01_district_name pc01_block_name: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

/* gen id for masala merge */
gen id = pc01_district_name + "-" + pc01_block_name
tostring id, replace

/* masala merge witth ebb dataset */
masala_merge pc01_district_name using $tmp/102, s1(pc01_block_name) idmaster(id) idusing(id) ///
    manual_file(~/ddl/flfp/b/manual_matches/manual_npegel_pc01.csv)

/* make using block names the key block name */
ren pc01_block_name_using pc01_block_name

/* replace block names for missing */
replace pc01_block_name = pc01_block_name_master if mi(pc01_block_name)

/* drop extraneous variables */
drop match_source pc01_block_name_master _merge masala_dist _new_match_flg ///
    _pc01_block_name_master _pc01_block_name_using id_master id_using

/* drop unmatches obs */
drop if mi(pc01_block_id) | mi(distcd)

/* save dataset */
save $ebb/npegel_list_clean, replace

