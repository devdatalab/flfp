/**********************************************/
/* Runs All FLFP Build Files from Root Folder */
/**********************************************/

/* Create shrug-economic census with female work by industry */
do $flfp_code/b/create_ec_flfp.do

/* Create local level datasets (SHRID, State, and Region-level collapses) */
do $flfp_code/b/create_location_level_ec.do

/* Generate merged EC and PC for all years */
do $flfp_code/b/merge_ecpc_flfp_wide.do

/* Collapses raw EC to smaller industry levels and then to regional categorizations */
do $flfp_code/b/create_icat_ec.do

