** PCA numbers year by year without agricultural workers and cultivators **

use $pca/shrug_pc91_pca, clear /* PCA 1991 */

/* Generate Variables for non-ag main workers and ag main workers */
gen non_ag_f_main = pc91_pca_mainwork_f - pc91_pca_main_cl_f - pc91_pca_main_al_f /* Generate total number of non-agricultural main workers */

gen ag_f_main = pc91_pca_main_cl_f + pc91_pca_main_al_f /* Generate total number of agricultural workers */

/* Calculate labor statistics for entire nation */
sum non_ag_f_main /* Summarize nonagricultural workers */

display r(sum) /* Total number of Non-agricultural main female worker = 13,360,756 */

sum pc91_pca_tot_f /* Summarize total female population */

display r(sum)*0.666 /* Find working age women using pop. pyramid. Total number of working age women = 264,600,000 */

sum ag_f_main  /* Summarize main female agricultural workers */

display r(sum) /* Total number of women occupied in agricultural work = 49,957,200 */

display 13360756/(264600000-49957200) /* Labor force participation in Non-agricultural work is therefore 6.2% */

* Calculate labor statistics for Rural Areas *

gen rural = (pc91_sector == 2) /* Generate rural/urban dummy */

sum non_ag_f_main if rural ==1 /* Summarize nonagricultural workers in rural areas */

display r(sum) /* Total number of rural non-agricultural main female workers = 6,732,552 */

sum pc91_pca_tot_f if rural ==1 /* Summarize total female rural population */

display r(sum)*0.666 /* Find total working age women based on pop. pyramid. Total number of rural working age women = 195,200,000 */

sum ag_f_main if rural ==1 /* Summarize main agricultural workers */

display r(sum) /* Total number of agricultural working rural women = 47,174,432 */

display 6732552/(195200000-47174432) /* Rural FLFP =  4.5%*/

/* Calculate labor statistics for Urban Areas */

sum non_ag_f_main if rural ==0 /* Summarize nonagricultural urban workers */

display r(sum) /* Total number of urban non-agricultural main workers female = 6,628,204 */

sum pc91_pca_tot_f if rural == 0 /* Summarize female total population */

display r(sum)*0.666 /* Total number of urban working-age women = 69,402,507 */

sum ag_f_main if rural ==0 /* Summarize total agricultural urban workers */

display r(sum) /* Total number of urban agricultural main workers female = 2,782,768 */

display 6628204/(69402507-2782768) /* Urban FLFP =  9.9% */









use $pca/shrug_pc01_pca, clear /* PCA 2001 */

/* Generate Variables for non-ag main workers and ag main workers */
gen non_ag_f_main = pc01_pca_mainwork_f - pc01_pca_main_cl_f - pc01_pca_main_al_f
gen ag_f_main = pc01_pca_main_cl_f + pc01_pca_main_al_f

/* Calculate labor statistics for entire nation */
sum non_ag_f_main
display r(sum) /* Total number of Non-agricultural main female worker = 25,095,352 */

sum pc01_pca_tot_f
display r(sum)*0.666 /* Total number of working age women = 330,500,000 */

sum ag_f_main  
display r(sum) /* Total number of women occupied in agricultural work = 47,728,981 */

display 25095352/(330500000-47728981) /* Labor force participation in Non-agricultural work is therefore 8.8% */

/* Calculate labor statistics for Rural Areas */

gen rural = (pc01_sector == 2) /* Generate rural/urban dummy */

sum non_ag_f_main if rural ==1 
display r(sum) /* Total number of rural non-agricultural main female workers = 13,314,655 */

sum pc01_pca_tot_f if rural ==1 
display r(sum)*0.666 /* Total number of rural working age women = 236,100,000 */

sum ag_f_main if rural ==1 
display r(sum) /* Total number of agricultural working rural women = 45,335,846 */

display 13314655/(236100000-45335846) /* Rural FLFP = 6.97% */

/* Calculate labor statistics for Urban Areas */

sum non_ag_f_main if rural ==0
display r(sum) /* Total number of urban non-agricultural main workers female = 11,780,697 */

sum pc01_pca_tot_f if rural == 0 
display r(sum)*0.666 /* Total number of urban working-age women = 94,427,395 */

sum ag_f_main if rural ==0
display r(sum) /* Total number of urban agricultural main workers female = 2,393,135 */

display 11780697/(94427395-2393135) /* Urban FLFP = 12.8% */







use $pca/shrug_pc11_pca, clear /* PCA 2011 */

/* Generate Variables for non-ag main workers and ag main workers */
gen non_ag_f_main = pc11_pca_mainwork_f - pc11_pca_main_cl_f - pc11_pca_main_al_f
gen ag_f_main = pc11_pca_main_cl_f + pc11_pca_main_al_f

/* Calculate labor statistics for entire nation */
sum non_ag_f_main
display r(sum) /* Total number of Non-agricultural main female worker = 35,530,492 */

sum pc11_pca_tot_f
display r(sum)*0.666 /* Total number of working age women = 391,000,000 */

sum ag_f_main  
display r(sum) /* Total number of women occupied in agricultural work = 53,768,649 */

display 35530492/(391000000-53768649) /* Labor force participation in Non-agricultural work is therefore 10.5% */

/* Calculate labor statistics for Rural Areas */

gen rural = (pc11_sector == 2) /* Generate rural/urban dummy */

sum non_ag_f_main if rural ==1 
display r(sum) /* Total number of rural non-agricultural main female workers = 15,755,972 */

sum pc11_pca_tot_f if rural ==1 
display r(sum)*0.666 /* Total number of rural working age women = 266,800,000 */

sum ag_f_main if rural ==1 
display r(sum) /* Total number of agricultural working rural women = 50,674,432 */

display 15755972/(266800000-50674432) /* Rural FLFP = 7.2% */

/* Calculate labor statistics for Urban Areas */

sum non_ag_f_main if rural ==0
display r(sum) /* Total number of urban non-agricultural main workers female = 19,774,520 */

sum pc11_pca_tot_f if rural == 0 
display r(sum)*0.666 /* Total number of urban working-age women = 124,300,000 */

sum ag_f_main if rural ==0
display r(sum) /* Total number of urban agricultural main workers female = 3,094,217 */

display 19774520/(124300000-3094217) /* Urban FLFP = 16.3% */

