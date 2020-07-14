/* use dataset */
use /scratch/plindsay/dise_pc01_ebb_2.dta, clear

/* create numeric year var */
gen year1 = substr(year, 1, 4)
drop year
rename year1 year
destring year, replace

/* drop obs from 2001 */
drop if year == 2001

/* gen enrolment sum variables */
gen enr_all_g = enr_all_g1 + enr_all_g2 + enr_all_g3 + enr_all_g4 + enr_all_g5 + enr_all_g6 + enr_all_g7 + enr_all_g8
gen enr_all_b = enr_all_b1 + enr_all_b2 + enr_all_b3 + enr_all_b4 + enr_all_b5 + enr_all_b6 + enr_all_b7 + enr_all_b8

/* compare only using literacy rates */
drop if pc01_pca_lit_gender_gap < 0.2159

/* sort by state distirct block year */
sort pc01_state_id pc01_district_id pc01_block_id year

**** GIRLS ****

/* gen enrollment variables by year */
foreach var in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 {
 gen var`var' = enr_all_g if year == `var'
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace var`var' = var`var'[_n-1] if mi(var`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace var`var' = var`var'[_n+1] if mi(var`var')
 }
 
/* gen average enrollment variables */
gen avg0203 = (var2002 + var2003)/2 if year == 2012
gen avg0709 = (var2007 + var2008 + var2009)/3 if year == 2012
gen avg1012 = (var2010 + var2011 + var2012)/3 if year == 2012

/* gen log variables and replace missing values */
foreach var in avg0203 avg0709 avg1012 {
 gen ln_`var' = ln(`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace `var' = `var'[_n-1] if mi(`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace `var' = `var'[_n+1] if mi(`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace ln_`var' = ln_`var'[_n-1] if mi(ln_`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace ln_`var' = ln_`var'[_n+1] if mi(ln_`var')
 }

/* normalize running variable */
replace pc01_pca_f_lit_rate = pc01_pca_f_lit_rate - 0.4613

/* drop is missing values in avg numbers */
drop if mi(avg0203)
drop if mi(avg0709)
drop if mi(avg1012)

/* RD graphs */

/* 2002-03 graph */
rd ln_avg0203 pc01_pca_f_lit_rate if year==2012, degree(2) bins(50) start(-.05) end(.05) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Log Average Enrollment 2002-04") title ("Reduced Form - 2002-04")

gr save reduced1.gph, replace

/* 2007-09 graph */
rd ln_avg0709 pc01_pca_f_lit_rate if year == 2012, degree(2) bins(20) start(-.05) end(.05) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Log Average Enrollment 2004-07") title ("Reduced Form - 2004-07")

gr save reduced2.gph, replace

/* 2010-12 graph */
rd ln_avg1012 pc01_pca_f_lit_rate if year == 2012, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Log Average Enrollment 2008-10") title ("Reduced Form - 2008-10")

gr save reduced3.gph, replace

/* combine all graphs */
gr combine reduced1.gph reduced2.gph reduced3.gph, title(Reduced Form - Average Primary Enrollment for Girls)
graphout reducedg


**** BOYS *****

sort pc01_state_id pc01_district_id pc01_block_id year

/* gen rneollment var by year in long */
foreach var in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 {
 gen var`var'b = enr_all_b if year == `var'
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace var`var'b = var`var'b[_n-1] if mi(var`var'b)
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace var`var'b = var`var'b[_n+1] if mi(var`var'b)
 }
 
/* gen average variables */
gen avg0204b = (var2002b + var2003b + var2004b)/3 if year == 2012
gen avg0709b = (var2007b + var2008b + var2009b)/3 if year == 2012
gen avg1012b = (var2010b + var2011b + var2012b)/3 if year == 2012

/* gen log and replace missing values */
foreach var in avg0204b avg0709b avg1012b {
 gen ln_`var' = ln(`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace `var' = `var'[_n-1] if mi(`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace `var' = `var'[_n+1] if mi(`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace ln_`var' = ln_`var'[_n-1] if mi(ln_`var')
 by pc01_state_id pc01_district_id pc01_block_id, sort: replace ln_`var' = ln_`var'[_n+1] if mi(ln_`var')
 }


/* RD graphs */

/* 2002-03 */
rd ln_avg0204b pc01_pca_f_lit_rate if year == 2012, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Log Average Enrollment 2002-04") title ("Reduced Form - 2002-04")

gr save reduced1b.gph, replace

/* 2007-09 */
rd ln_avg0709b pc01_pca_f_lit_rate if year == 2012, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Log Average Enrollment 2004-07") title ("Reduced Form - 2004-07")

gr save reduced2b.gph, replace

/* 2010-12 */
rd ln_avg1012b pc01_pca_f_lit_rate if year == 2012, degree(2) bins(50) start(-.1) end(.1) ///
absorb(pc01_state_id) control(ln_pc01_pca_tot_p) xtitle ("Female Rural Literacy Rate") ///
ytitle ("Log Average Enrollment 2008-10") title ("Reduced Form - 2008-10")

gr save reduced3b.gph, replace

/* combine graphs */
gr combine reduced1b.gph reduced2b.gph reduced3b.gph, title(Reduced Form)
graphout reducedb
