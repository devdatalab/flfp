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

/* drop state name */
drop pc01_state_name

/* drop duplicates if any */
sort pc01_district_name pc01_block_name
quietly by pc01_district_name pc01_block_name: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

/* gen id for masala merge */
gen id = pc01_district_name + "-" + pc01_block_name
tostring id, replace

/* masala merge witth ebb dataset */
masala_merge pc01_district_name using $tmp/102, s1(pc01_block_name) idmaster(id) idusing(id)

/* process manual matches */
// process_manual_matches, outfile($tmp/npegel.csv) infile($ebb/unmatched_observations_70982.csv) s1(pc01_block_name) idmaster(id_master) idusing(id_using)

/* insert manual matches */
insert_manual_matches, manual_file($tmp/npegel.csv) idmaster(id_master) idusing(id_using)

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
save $ebb/npegel_clean, replace

