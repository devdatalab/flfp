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

/***************************************************/
/* Generate Histogram of Blocks by Female Literacy */
/***************************************************/

/* import EBB and PC01 merged dataset */
use $ebb/ebbs_list_clean, clear

/* graph frequency of literacy rate in the blocks */
histogram pc01_pca_f_lit_rate if kgbv_treatment_dummy == 1 & ///
    pc01_pca_f_lit_rate >= 0.3813 & pc01_pca_f_lit_rate <= 0.5413, ///
    freq bin(16) gap(20) ///
    title(Female Literacy Rate Prevalence by Block) ///
    ytitle("Number of Blocks in Bin") ///
    xtitle("Female Rural Literacy Rate") ///
    xlabel(0.3813(0.02)0.5413) ///
    xtick(0.3813(0.01)0.5413) ///
    xline(.4613, lcolor(black) lwidth(medthick)) ///
    fcolor(maroon) lcolor(black) ///
    name(female_lit_hist, replace)

/* export graph */
graphout female_lit_hist
