** Calculate FLFP in EC13 and PC11**

/* For EC13, I merged onto the PC11 for the total population numbers and then used the population pyramid to find working age women.
For PC11, I simply used the PC11 employment and population estimates along with the population pyramid to calculate the FLFP */


use ~/Desktop/Novosad/WorkingDirectory/iec1/ec/shrug_ec13.dta, clear

/*Generate Urban Variable for Towns */
merge 1:1 shrid using ~/Desktop/Novosad/WorkingDirectory/iec1/pca/shrug_pc11_pca.dta /* Merge onto PC11  for population numbers */

gen urban = (ec13_sector == 1 | pc11_sector == 1)  /* Generate urban variable for Towns that are marked on either PC or EC */


**Find total number of female workers in urban areas using EC **

sum ec13_emp_f if urban == 1  /* Summarize urban female employment */

display r(sum) /* 9,188,971 total female workers in Urban Areas */

sum pc11_pca_tot_f_u /* Summarize urban female population using PC */

display r(sum) /* Total female urban population is 181,400,000. 66.7% of woman are working age
based on population pyramid therefore working age population is 120,993,800 */

/* Based on this the labor force participation(before removing other factors) is 
only 7.5% in Urban areas. */

**Find total number of female workers in rural areas using EC */

sum ec13_emp_f if urban == 0 /* Summarize rural female employment */

display r(sum)	/* 15,034,309 working women in rural areas. */

sum pc11_pca_tot_f_r /* Summarize rural female population using PC */

display r(sum)
/* 405,700,000 total women in rural areas, 66.7% of whom will be likely working age
thus leading to 270,601,900 potential workers. */
/* Female labor force participation in rural areas therefore is 3.7% */


/* Find same statistics using only PC employment data */

sum pc11_pca_tot_work_f if urban ==1 /* Summarize total female urban employment */

display r(sum)	/* 23,103,182 urban female workers. In this case using the PC data the participation
rate is 19.1 %*/ 

sum pc11_pca_tot_work_f if urban == 0 /* Summarize total female rural employment */

display r(sum) /* 126,700,000 rural female workers. In this case the participation rate would be 46.8% */
