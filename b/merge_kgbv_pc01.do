/**********************/
/* Clean KGBV Dataset */
/**********************/

use $ebb/kgbvs, clear

gen id = pc01_state_name + "-" + pc01_district_name + "-" + pc01_block_name

masala_merge pc01_state_name pc01_district_name using $ebb/ebbs_list_clean, ///
    s1(pc01_block_name) idmaster(id) idusing(id)

process_manual_matches, outfile(/scratch/plindsay/kgbv_pc01_manual_matches.csv) ///
    infile(/scratch/plindsay/unmatched_observations_100920.csv) ///
    s1(pc01_block_name) idmaster(id_master) idusing(id_using)

insert_manual_matches, manual_file(/scratch/plindsay/kgbv_pc01_manual_matches.csv) ///
    idmaster(id_master) idusing(id_using)
