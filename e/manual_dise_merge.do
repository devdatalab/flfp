/* match manual matches */

/* install required packages */
net install vlookup, from(http://www.stata.com/users/kcrow)

/* import old manual matches */
import delimited /scratch/pgupta/unmatched_observations_1606.csv, varnames(1) clear

/* rename variables with prefix */
rename id_master id_master_a
rename id_using id_using_a
rename id_match id_match_a

/* drop duplicates */
sort _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using
quietly by _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using: gen dup = cond(_N==1,0,_n)
drop if dup > 1

/* save temp dataset */
save $tmp/match1, replace

/* import new unmatched merge file */
import delimited /scratch/pgupta/unmatched_observations_71452.csv, varnames(1) clear

/* rename variables with prefix */
rename id_match id_match_b
rename id_master id_master_b
rename id_using id_using_b

/* drop duplicates */
sort _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using
quietly by _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using: gen dup = cond(_N==1,0,_n)
drop if dup > 1

/* save temp dataset */
save $tmp/match2, replace

/* merge old and new datasets */
merge m:1 _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using  using $tmp/match1

/* drop dup */
drop dup

sort _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using
quietly by _pc01_stat~e  _pc01_stat~d  _pc01_dist~d  _pc01_dist~e  _pc01_bloc~r _pc01_block_name_using: gen dup = cond(_N==1,0,_n)
drop if dup > 1
drop if dup == 1

/* drop extra variables */
drop _merge dup

/* recreate obs to drop unmatched manual obs */
vlookup id_using_a, gen(match_look) key(id_match_a) value(id_master_a)
drop if mi(id_match_a) & mi(id_using_a)
drop if mi(match_look) & mi(id_master_a)

/* match using old data with id_match and id_using */
vlookup id_match_a, gen(match_look1) key(id_using_a) value(id_using_b)

/* process manual matches */
vlookup id_match_a, gen(match_look2) key(id_using_a) value(_pc01_block_name_using)

/* keep necessarys vars */
keep  _pc01_block_name_master id_master_b match_look1 match_look2

/* rename relevant variables */
rename match_look2 _pc01_block_name_using
rename id_master_b id_master
rename match_look1 id_using

/* order vars */
order id_master id_using _pc01_block_name_master _pc01_block_name_using

/* drop master only obs */
drop if mi(id_master)

/* drop comma delimiters */
destring id_master, replace ignore(-)
drop if mi(id_master)

/* string id variables */
tostring id*, replace

/* export as csv and dataset */
export delimited $tmp/manual_dise, replace
save $tmp/md, replace
