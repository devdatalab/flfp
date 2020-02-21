** Describe Female Share by Population for Each EC year**


**EC 90**
use $flfp/ec_flfp_90.dta, clear
merge m:1 shrid using $flfp/shrug_pc91_pca.dta 
drop _merge

drop if shrid =="" 
drop if shric ==.

collapse (sum) count* emp*  pc91_pca_tot*, by (shrid)

gen emp_f_share_90 = emp_f/(emp_f + emp_m)
gen ln_population_91 = ln(pc91_pca_tot_p + 1)
gen pop_m_share_91 = pc91_pca_tot_m/pc91_pca_tot_p

drop if emp_f_share_90 == 0 & pc91_pca_tot_f > 50 | emp_f_share_90 == 1 | ln_population_91 == 0 | pc91_pca_tot_p < 100

egen pop_bin = cut(pc91_pca_tot_p), group(50)
binscatter emp_f_share_90 pop_bin, linetype(connect)
graph save emp_f_share_90, replace

binscatter pop_m_share_91 pop_bin, linetype(connect)
graph save male_share_91, replace


**EC 98**

use $flfp/ec_flfp_98.dta, clear
merge m:1 shrid using $flfp/shrug_pc01_pca.dta
drop _merge

drop if shrid == ""
drop if shric ==. 

collapse (sum) count* emp* pc01_pca_tot*, by(shrid)

gen emp_f_share_98 = emp_f/(emp_f + emp_m)
gen ln_population_01 = ln(pc01_pca_tot_p + 1)

drop if emp_f_share_98 == 0 | emp_f_share_98 == 1 | ln_population_01 == 0 | pc01_pca_tot_p < 100 

egen pop_bin = cut(pc01_pca_tot_p), group(50)

binscatter emp_f_share_98 pop_bin, linetype(connect)
graph save emp_f_share_98, replace

gen pop_m_share_01 = pc01_pca_tot_m/pc01_pca_tot_p
binscatter pop_m_share_01 pop_bin, linetype(connect)
graph save male_share_01, replace

**EC 05**

use $flfp/ec_flfp_05.dta, clear
merge m:1 shrid using $flfp/shrug_pc01_pca.dta
drop _merge

drop if shrid == ""
drop if shric ==. 

collapse (sum) count* emp* pc01_pca_tot*, by(shrid)

gen emp_f_share_05 = emp_f/(emp_f + emp_m)
gen ln_population_01 = ln(pc01_pca_tot_p + 1)

drop if emp_f_share_05 == 0 | emp_f_share_05 == 1 | ln_population_01 == 0 | pc01_pca_tot_p < 100 

egen pop_bin = cut(pc01_pca_tot_p), group(50)

binscatter emp_f_share_05 pop_bin, linetype(connect)
graph save emp_f_share_05, replace

**EC 13**

use $flfp/ec_flfp_13.dta, clear
merge m:1 shrid using $flfp/shrug_pc11_pca.dta
drop _merge

drop if shrid == ""
drop if shric ==. 

collapse (sum) count* emp* pc11_pca_tot*, by(shrid)

gen emp_f_share_13 = emp_f/(emp_f + emp_m)
gen ln_population_11 = ln(pc11_pca_tot_p + 1)

drop if emp_f_share_13 == 0 | emp_f_share_13 == 1 | ln_population_11 == 0 | pc11_pca_tot_p < 100 

egen pop_bin = cut(pc11_pca_tot_p), group(50)

binscatter emp_f_share_13 pop_bin, linetype(connect)
graph save emp_f_share_13, replace

gen pop_m_share_11 = pc11_pca_tot_m/pc11_pca_tot_p
binscatter pop_m_share_11 pop_bin, linetype(connect)
graph save male_share_11, replace

graph combine emp_f_share_90.gph emp_f_share_98.gph emp_f_share_05.gph emp_f_share_13.gph	

graph combine male_share_91.gph male_share_01.gph male_share_11.gph
