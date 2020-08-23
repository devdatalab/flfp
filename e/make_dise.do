/*******************************************************/
/* Runs All DISE-EBB-FLFP Build Files from Root Folder */
/*******************************************************/

/*********/
/* BUILD */
/*********/

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


/************/
/* ANALYSIS */
/************/

/* replicate all M&L results */
do $flfp_code/e/replicate_meller_figures.do

/* runs all dise enrollment analyses */
do $flfp_code/e/describe_dise_new.do

/* runs all FLFP related analyses */
do $flfp_code/e/explore_flfp_ebb.do
