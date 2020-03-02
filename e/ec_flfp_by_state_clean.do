** FLFP stats for states in 2013 using EC13 and PC11(population estimates) **

/* In order to get the EC state-by-state data I've collapsed the total female employment by state after merging with the state keys. Then I used 
population estimates for each state using the closest PC year and then exported these numbers to an excel file where I calculated the final flfp stat. */


use $ec/shrug_ec13.dta, clear

merge 1:1 shrid using $ec/shrug_key/shrug_ec13_state_key.dta /* Merge with state key */

collapse (sum) ec13_emp_f, by (ec13_state_name) /* Collapse by state and display total female employment */

list

export excel using ec13, replace	/* Export to excel file */

use $pca/shrug_pc11_pca.dta, clear /* Use Pc11 to get total female population estimate */

merge 1:1 shrid using $pca/shrug_key2/shrug_pc11_state_key.dta /* Merge with state key */

collapse (sum) pc11_pca_tot_f, by (pc11_state_name) /* Collapse by state */
list

export excel using ec13, sheet(pc11) /* Export to excel */

** FLFP stats for states in 2005 and 98 using ec05,ec98 and pc01(closest population estimates **

use $ec/shrug_ec05.dta, clear 

merge 1:1 shrid using $ec/shrug_key/shrug_ec05_state_key.dta /*Merge with state key */

collapse (sum) ec05_emp_f, by (ec05_state_name)			/* Collapse by state */
list

export excel using ec13, sheet(ec05)  /* Export to Excel */

use $ec/shrug_ec98.dta, clear

merge 1:1 shrid using $ec/shrug_key/shrug_ec98_state_key.dta /* Merge with state key */

collapse (sum) ec98_emp_f, by (ec98_state_name) /* Collapse by state */

list

export excel using ec13, sheet(ec98) /* Export excel */

use $pca/shrug_pc01_pca.dta, clear

merge 1:1 shrid using $pca/shrug_key2/shrug_pc01_state_key.dta /* Merge with state key */

collapse (sum) pc01_pca_tot_f, by (pc01_state_name) /* Collapse by state */

export excel using ec13, sheet(pc01) /* Export to excel */

** FLFP stats for states in 1990 using ec90 and pc91(population estimates) **

use $ec/shrug_ec90.dta, clear

merge 1:1 shrid using $ec/shrug_key/shrug_ec90_state_key.dta /* Merge with state key */

collapse (sum) ec90_emp_f, by (ec90_state_name) /* Collapse by state */
list 

export excel using ec13, sheet(ec90) /* Export to excel */

use $pca/shrug_pc91_pca.dta, clear 

merge 1:1 shrid using $pca/shrug_key2/shrug_pc91_state_key.dta /* Merge with State key */

collapse (sum) pc91_pca_tot_f, by (pc91_state_name) /* Collapse by state */

list 
export excel using ec13, sheet(pc91) /* Export to excel */
