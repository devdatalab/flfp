*****************************
*** SHIFT SHARE ANALYSIS ****
*****************************

/*

* Nationally: For each change in years (e.g. 1990->1998, 1998->2005, etc.), we want to know: 

(i) how much did female employment change (you already have this in your graphs); 
(ii) how much would female employment have changed if it remained the same in each sector, but the sector sizes were the only thing that changed. 
In other words, for the 1990->98 period: you should do the following:

1. Create a `predicted_female_emp` for each `icat` in 1998. 
This is the total (M+F) employment in each `icat` multiplied by the female share in *1990*. 
Then add these up across icats. This tells us what female employment would have been if there was no within-sector growth. 
Then, create the complementary variable which describes what female employment would have been if there was *no* cross-sector growth. 
In other words, take the `icat` female shares in 1998, and multiply them by the total (M+F) employment in each sector in *1990*. 
This tells us what FLFP would have been if there had been *no* sectoral change in the economy, and only increased numbers of women in each sector. 
(Note we could also do this at the `shric` level and may eventually modify the code to do so.)

2. Let's do the same thing using place. 
In other words, did the *places* with growing female-intensive sectors end up hiring more women overall? 
e.g. suppose a tobacco-rolling plant appears in a village. These plants typically hire a lot of women. 
How much do we see the female share rise? (If your view was that cultural factors were the only thing driving FLFP, 
then you wouldn't expect these economic changes to have an effect at all.)

To do this, we do a step similar to that in #1. 
First, we calculate the female share for each `icat` nationally in 1998. 
Then in each *district*, we calculate the female share that we would expect to see in that district just based on its industry composition. 
e.g. A district that produces a lot of tobacco would have higher female employment, following the same logic above. 
We are then interested in seeing the slope of the relationship between predicted female share and actual female share. 
It's also interesting to map the places that have abnormally high and abnormally low female shares.


*/

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
