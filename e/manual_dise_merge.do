/* match manual matches */

import delimited /scratch/pgupta/unmatched_observations_1606.csv, varnames(1) clear

drop id_master id_using

 //  drop if mi(_pc01_block_name_master)

// rename id_match id_match_a

sort _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using

quietly by _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using: gen dup = cond(_N==1,0,_n)

drop if dup > 1

save $tmp/match1, replace

import delimited /scratch/pgupta/unmatched_observations_8035.csv, varnames(1) clear

// drop id_master _pc01_block_name_using id_using

// drop if mi(_pc01_block_name_master)

// rename id_match id_match_b

drop id_match

// replace id_match_b = "1" if mi(id_match_b)

sort _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using

quietly by _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using: gen dup = cond(_N==1,0,_n)

drop if dup > 1

save $tmp/match2, replace

merge 1:1 _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using  using $tmp/match1

drop dup _merge

export delimited $tmp/manual_dise, replace
