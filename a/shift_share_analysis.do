*****************************
*** SHIFT SHARE ANALYSIS ****
*****************************

/* use national-level icat dataset */
use $flfp/ec_flfp_icat_india.dta, clear

sort icat year

/* Gen emp_f share variable */
gen emp_f_share = emp_f/(emp_m+emp_f)
gen count_f_share = count_f/(count_f+count_m)
gen emp_f_owner_share = emp_f_owner/(emp_f_owner+emp_m_owner)

/* Gen total emp_f variable */
gen emp_tot = emp_f + emp_m

/* Gen emp_f share growth variable */
gen fshare_growth = .

forval i = 1/17 {
  display `i'
  reg emp_f_share year if icat == `i'
  replace fshare_growth = _b["year"] if icat == `i'
}

********************
****** ALL ECS *****
********************

/* gen emp_f growth variable from n-1 period */
by icat (year), sort: gen empfgrowth = emp_f - emp_f[_n-1]

/* gen empfpredicted variable from n-1 period */
by icat (year): gen empfpredicted = emp_tot * emp_f_share[_n-1]

/* gen complementary empfpredicted: (female share in n)*(emp_tot in n-1) */
by icat (year): gen empfpredictedcomp = emp_f_share * emp_tot[_n-1]

/* gen residual emp_f: predicted emp_f - actual emp_f in year n */
by icat (year): gen empfresidual = emp_f - empfpredicted

/* output a table with all new variables */
outsheet icat year emp_f emp_m  empfgrowth emp_f_share fshare_growth empfpredicted empfpredictedcomp empfresidual using $tmp/shiftshare_flfp.csv, comma replace


********************
*** 1990 to 2013 ***
********************


/* gen emp_f growth variable from n-3 period */
by icat (year), sort: gen empfgrowth_13 = emp_f - emp_f[_n-3]

/* gen empfpredicted variable from n-3 period */
by icat (year): gen empfpredicted_13 = emp_tot * emp_f_share[_n-3]

/* gen complementary empfpredicted: (female share in 2013)*(emp_tot in 1990) */
by icat (year): gen empfpredictedcomp_13 = emp_f_share * emp_tot[_n-3]

/* gen residual emp_f: predicted emp_f - actual emp_f in year n */
by icat (year): gen empfresidual_13 = emp_f - empfpredicted_13

/* output a table with all new variables */
outsheet icat year emp_f emp_m  empfgrowth_13 emp_f_share fshare_growth empfpredicted_13 empfpredictedcomp_13 empfresidual_13 using $tmp/shiftshare_flfp_13.csv, comma replace

********************
**** Graphing  *****
********************

/* graph shift share variables for all periods */

forval i= 1(1)17 {
      local v : label (icat) `i'
	  graph twoway line emp_f empfpredicted empfpredictedcomp year if icat==`i' & year~=1990, title("`v'") ytitle(Female Employment) xtitle(Year) ysc(off) ///
	  legend(label(1 "Actual Female Employment") label(2 "Predicted Female Employment") label(3 "Complementary Predicted Female Employment") cols(1)) name(g`i', replace) nodraw
      local graphs "`graphs' g`i'"
}

grc1leg2 `graphs', title (Shift Share Female Employment by Industry) legendfrom(g1) xtob1title ytol1title ///
note("empfpredicted = (female share in n-1)*(total employment in n)" "complementary empfpredicted: (female share in n)*(total employment in n-1)")
graphout $tmp/shiftshare1

/* graph shift share variables for 2013 period */

forval i= 1(1)17 {
      local v : label (icat) `i'
	  graph dot emp_f empfpredicted_13 empfpredictedcomp_13 if year==2013 & icat==`i', title("`v'") ytitle(Female Employment) ///
	  legend(label(1 "Actual Female Employment") label(2 "Predicted Female Employment") label(3 "Complementary Predicted Female Employment") cols(1)) ///
	  title("`v'") ytitle(Female Employment) name(h`i', replace) nodraw
      local graphs "`graphs' h`i'"
}

grc1leg2 `graphs', title (Shift Share Female Employment by Industry) legendfrom(h1) ///
note("empfpredicted = (female share in n-1)*(total employment in n)" "complementary empfpredicted: (female share in n)*(total employment in n-1)")
graphout $tmp/shiftshare2
