/* match manual matches */

/* install required packages */
net install vlookup, from(http://www.stata.com/users/kcrow)

import delimited /scratch/pgupta/unmatched_observations_1606.csv, varnames(1) clear

rename id_master id_master_a

rename id_using id_using_a

rename id_match id_match_a

sort _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using

quietly by _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using: gen dup = cond(_N==1,0,_n)

drop if dup > 1

save $tmp/match1, replace

import delimited /scratch/pgupta/unmatched_observations_25818.csv, varnames(1) clear

rename id_match id_match_b
rename id_master id_master_b
rename id_using id_using_b

sort _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using

quietly by _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using: gen dup = cond(_N==1,0,_n)

drop if dup > 1

save $tmp/match2, replace

merge 1:1 _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using  using $tmp/match1

drop if dup == 1

drop _merge dup

vlookup id_using_a, gen(match_look) key(id_match_a) value(id_master_a)

drop if mi(id_match_a) & mi(id_using_a)

drop if mi(match_look) & mi(id_master_a)

vlookup id_match_a, gen(match_look1) key(id_using_a) value(id_using_b)

vlookup id_match_a, gen(match_look2) key(id_using_a) value(_pc01_block_name_using)

keep _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r ///
_pc01_block_name_using id_using_b id_master_b match_look1 match_look2

drop _pc01_block_name_using

rename match_look2 _pc01_block_name_using

rename id_using_b id_using
rename id_master_b id_master
rename match_look1 id_match

drop id_using _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e
rename id_match id_using
order id_master id_using _pc01_block_name_master _pc01_block_name_using

drop if mi(id_master)

tostring id*, replace

export delimited $tmp/manual_dise, replace

save $tmp/md, replace
