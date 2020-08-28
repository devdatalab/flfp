/*******************************************************/
/* Runs All DISE-EBB-FLFP Build Files from Root Folder */
/*******************************************************/

/*********/
/* BUILD */
/*********/

/* PC01 */

/* merge EBBs list with PC01 */
do $flfp_code/b/merge_ebbs_list_pc01.do

/* merge clean EBBs list with KGBVs list */
do $flfp_code/b/merge_kgbv_pc01.do

/* merge and clean NPEGEL data */
do $flfp_code/b/clean_npegel.do

/* merge all treatment data into a master list */
do $flfp_code/b/gen_treated_list_clean.do

/* DISE */

/* creates DISE-pc01 key */
do $flfp_code/b/create_dise_pc01_key.do

/* merges old and new DISE data */
do $flfp_code/b/merge_dise_old_new.do

/* adds PC01 key and EBB data */
do $flfp_code/b/merge_dise_ebb.do

/* create RD DISE analysis-ready dataset */
do $flfp_code/b/create_dise_analysis.do

/* create EBB-EC dataset */
do $flfp_code/b/create_ec_pc01_ebb.do

/* SECC11 */

/* generate clean SECC list with education outcomes */
do $flfp_code/b/gen_secc_block_ed_age.do

/* generate clean SECC list with marriage outcomes */
do $flfp_code/b/secc11_marriage.do

/************/
/* ANALYSIS */
/************/

/* replicate all M&L results */
do $flfp_code/e/replicate_meller_figures.do

/* runs all dise enrollment analyses */
do $flfp_code/e/describe_dise_new.do

/* runs all FLFP related analyses */
do $flfp_code/e/explore_flfp_ebb.do

/* EXPLORE SECC */

/* explores marriage rates */
do $flfp_code/e/explore_secc_marriage.do

/* explores education attainment */
do $flfp_code/e/explore_secc_block_ed_age.do
