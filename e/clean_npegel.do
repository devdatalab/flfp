use $iec/ebb/NPEGEL_status.dta, clear

rename statnameFE pc01_state_name

rename distname pc01_district_name

rename blkname pc01_block_name

replace pc01_district_name = strlower(pc01_district_name)

replace pc01_block_name = strlower(pc01_block_name)

replace  pc01_state_name = strlower(pc01_state_name)

/*
expand 2 if pc01_state_name == "chhattisgarh/madhya pradesh"
expand 2 if pc01_state_name == "uttar pradesh/uttarakhand"
expand 2 if pc01_state_name == "bihar/jharkhand"
*/


/*
drop pc01_state_name



sort pc01_district_name pc01_block_name
quietly by pc01_district_name pc01_block_name: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

/*
gen id = pc01_district_name + "-" + pc01_block_name
tostring id, replace

masala_merge pc01_district_name using $tmp/102, s1(pc01_block_name) idmaster(id) idusing(id)

/*

process_manual_matches, outfile($tmp/npegel.csv) infile($ebb/unmatched_observations_70982.csv) s1(pc01_block_name) idmaster(id_master) idusing(id_using)

insert_manual_matches, manual_file($tmp/npegel.csv) idmaster(id_master) idusing(id_using)

/*
sort  pc01_district_name  pc01_block_name
quietly by pc01_district_name pc01_block_name: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop dup

