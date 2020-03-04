** Calculate PCA FLFP divided by state **


*Calculate numbers for PC11 *

use $pca/shrug_pc11_pca.dta, clear /* Load PC11 */

merge 1:1 shrid using $pca/shrug_key2/shrug_pc11_state_key.dta /* Merge to state key */
drop _merge

collapse(sum) pc11_pca_mainwork_f pc11_pca_main_cl_f pc11_pca_main_al_f pc11_pca_tot_f, by (pc11_state_name) /* Collapse relevant statistics by state */

gen flfp_11 = (pc11_pca_mainwork_f - pc11_pca_main_cl_f - pc11_pca_main_al_f)/(pc11_pca_tot_f - pc11_pca_main_cl_f - pc11_pca_main_al_f) /* Generate flfp numbers by state */

ren pc11_state_name state_name /* Rename state so that we can merge later */

save $tmp/pc11_flfp_by_state.dta, replace /* Save to temporary file */

*Calculate numbers for PC01 *
 
use $pca/shrug_pc01_pca.dta, clear /* Load PC01 */

merge 1:1 shrid using $pca/shrug_key2/shrug_pc01_state_key.dta /* Merge to state key */
drop _merge

collapse(sum) pc01_pca_mainwork_f pc01_pca_main_cl_f pc01_pca_main_al_f pc01_pca_tot_f, by (pc01_state_name) /* Collapse relevant statistics by state */

gen flfp_01 = (pc01_pca_mainwork_f - pc01_pca_main_cl_f - pc01_pca_main_al_f)/(pc01_pca_tot_f - pc01_pca_main_cl_f - pc01_pca_main_al_f) /* Generate flfp numbers by state */

ren pc01_state_name state_name /* Rename state so that we can merge later */

save $tmp/pc01_flfp_by_state.dta, replace /* Save to temporary file */

* Calculate numbers for PC91 *

use $pca/shrug_pc91_pca.dta, clear /* Load PC91 */

merge 1:1 shrid using $pca/shrug_key2/shrug_pc91_state_key.dta /* Merge to state key */
drop _merge 

collapse(sum) pc91_pca_mainwork_f pc91_pca_main_cl_f pc91_pca_main_al_f pc91_pca_tot_f, by (pc91_state_name) /* Collapse relevant statistics by state */

gen flfp_91 = (pc91_pca_mainwork_f - pc91_pca_main_cl_f - pc91_pca_main_al_f)/(pc91_pca_tot_f - pc91_pca_main_cl_f - pc91_pca_main_al_f) /* Generate flfp numbers by state */

ren pc91_state_name state_name 

merge 1:1 state_name using $tmp/pc11_flfp_by_state.dta
drop _merge

merge 1:1 state_name using $tmp/pc01_flfp_by_state.dta
drop _merge

save $pca/pca_flfp_state_by_state, replace
