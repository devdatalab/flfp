/***********************************************/
/* Generate Histogram of EBB Share by District */
/***********************************************/

/* import EBB and PC01 merged dataset */
use $ebb/ebbs_list_clean, clear

/* generate variable for number of blocks per district */
by pc01_state_id pc01_district_id pc01_block_name, sort: gen blocks = _n == 1
by pc01_state_id pc01_district_id: replace blocks = sum(blocks)
by pc01_state_id pc01_district_id: replace blocks = blocks[_N]
label variable blocks "Number of blocks by district"

/* collapse to dsitrict level, maintaining number of EBBs and total blocks */
collapse (sum) ebb_dummy (mean) blocks, by(pc01_state_id pc01_state_name pc01_district_id pc01_district_name)

/* generate share of blocks that are EBBs */
gen ebb_share = (ebb_dummy / blocks)
label variable ebb_share "EBBs / Total blocks (by district)"

/* graph frequency of each EBB share */
histogram ebb_share, frequency ///
    title(Fraction of EBB-Qualified Blocks by District) ///
    fcolor(blue) lcolor(bluishgray) ///
    name(ebb_district_hist, replace)

/* export graph */
graphout ebb_district_hist
