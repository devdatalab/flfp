/* match manual matches */

import delimited /scratch/pgupta/unmatched_observations_1606.csv, varnames(1) clear

drop id_master _pc01_block_name_using id_using

drop if mi(_pc01_block_name_master)

rename id_match id_match_a

save $tmp/match1, replace

import delimited /scratch/pgupta/unmatched_observations_8035.csv, varnames(1) clear

drop id_master _pc01_block_name_using id_using

drop if mi(_pc01_block_name_master)

rename id_match id_match_b

save $tmp/match2, replace

merge 1:1 _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r  using $tmp/match1
