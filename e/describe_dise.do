use /scratch/plindsay/dise_pc01_ebb_2.dta, clear

gen year1 = substr(year, 1, 4)

drop year

rename year1 year

drop if year == "2001"

destring year, replace

gen enr_all_g = enr_all_g1 + enr_all_g2 + enr_all_g3 + enr_all_g4 + enr_all_g5 + enr_all_g6 + enr_all_g7 + enr_all_g8

gen enr_all_b = enr_all_b1 + enr_all_b2 + enr_all_b3 + enr_all_b4 + enr_all_b5 + enr_all_b6 + enr_all_b7 + enr_all_b8

/* compare only using literacy rates */

drop if pc01_pca_lit_gender_gap < 0.2159

// drop if ebb_dummy ==0 & pc01_pca_f_lit_rate < .4613


// So rd ln_enr_2002_2004 f_lit_rate — where the Y var is log of average block-level
// enrollment from 2002-2004.  THen do 2007-2009 and 2010-2012. According to Meller-Litschig, 
// we should find no jump in 02-04, and soem kind of jump in 07-09 and 10-12.

sort pc01_state_id pc01_district_id pc01_block_id year

foreach var in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 {
 gen var`var' = enr_all_g if year == `var'
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace var`var' = var`var'[_n-1] if mi(var`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace var`var' = var`var'[_n+1] if mi(var`var')
 }
 
gen avg0204 = (var2002 + var2003 + var2004)/3 if year == 2012
gen avg0407 = (var2004 + var2005 + var2006 + var2007)/4 if year == 2012
gen avg0810 = (var2008 + var2009 + var2010)/3 if year == 2012

foreach var in avg0204 avg0407 avg0810 {
 gen ln_`var' = ln(`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace `var' = `var'[_n-1] if mi(`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace `var' = `var'[_n+1] if mi(`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace ln_`var' = ln_`var'[_n-1] if mi(ln_`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace ln_`var' = ln_`var'[_n+1] if mi(ln_`var')
 }
 
replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - 0.4613


/* RD graphs */

/* RD graphs */

rd ln_avg0204 pc01_pca_f_lit_rate if year == 2012, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Log Average Enrollment 2002-04") title ("Reduced Form - 2002-04")

graphout reduced1

rd ln_avg0407 pc01_pca_f_lit_rate if year == 2012, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Log Average Enrollment 2004-07") title ("Reduced Form - 2004-07")

graphout reduced2

rd ln_avg0810 pc01_pca_f_lit_rate if year == 2012, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Log Average Enrollment 2008-10") title ("Reduced Form - 2008-10")

graphout reduced3

// pc01_pca_f_lit_rate < .4613
// by pc01_state_id pc01_district_id pc01_block_id, sort: replace var = var[_n-1] if mi(var)
 
