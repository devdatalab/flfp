** Calculate Top 10 industries for EC13 in rural and urban sectors as well as total numbers **


** PART A- Rural **

use $ec/ec13_gender/ec13_rural_mf_emp.dta, clear /* Load EC13 rural microdata */

rename emp_m emp_m_r	/* Rename male employment variable to mark rural */

rename emp_f emp_f_r 	/* Rename female employment variable to mark rural */

collapse (sum) emp_m_r emp_f_r, by (shric) /* Collapse by shric in order to obtain total female and male employment by industry */

merge 1:1 shric using $ec/shric_descriptions.dta /* Merge with shric key for descriptions */
drop _merge 

drop if shric ==. /* Drop shric that has no value */

**Find Top 10 industries based on overall female employment **

gsort - emp_f_r /*Sort by emp_f in descending order */

list shric_desc emp_f_r in 1/10, string(40) /* List top 10 rural industries by total female employment */

**Find Top 10 industries by percent of workers that are female **

gen percent_female_r = (emp_f_r)/(emp_m_r + emp_f_r)  /* Generate percent female variable */

gsort -percent_female_r		/* Sort by percent female */

list shric_desc percent_female_r in 1/10, compress /* List top 10 rural industries by percent female */

save $tmp/ec13_shric_by_gender_rural.dta, replace /* Save to temporary data */

** PART B- Urban **

use $ec/ec13_gender/ec13_urban_mf_emp.dta, clear /* Load EC13 urban microdata */

rename emp_m emp_m_u	/* Rename male employment variable to mark rural */

rename emp_f emp_f_u	/* Rename female employment variable to mark rural */

collapse(sum) emp_m_u emp_f_u, by (shric)	/* Collapse by shric in order to obtain total female and male employment by industry */

merge 1:1 shric using $ec/shric_descriptions.dta /* Merge with shric key and drop merge variable */
drop _merge

drop if shric ==. /* Drop shric that has no value */

**Find Top 10 industries based on overall female employment **

gsort -emp_f_u	 /*Sort by emp_f */

list shric_desc emp_f_u in 1/10, string(40) /* List top 10 urban industries by total female employment */

**Find Top 10 industries by percent of workers that are female **

gen percent_female_u = (emp_f_u)/(emp_m_u + emp_f_u)  /* Generate percent female variable */

gsort -percent_female_u		/* Sort by percent female */

list shric_desc percent_female_u in 1/10, compress /* List top 10 urban industries by percent female */

save $tmp/ec13_shric_by_gender_urban.dta, replace /* Save urban data to temporary file */

** PART C- Total **

merge 1:1 shric using $tmp/ec13_shric_by_gender_rural.dta /* Merge shric urban and rural data */
drop _merge


gen emp_m_t = emp_m_u + emp_m_r /* Generate total rural male and female employment variables */

gen emp_f_t = emp_f_u + emp_f_r  /* Generate total urban male and female employment variables */

gsort -emp_f_t	/* Sort descending by total female employment */

list shric_desc emp_f_t in 1/10, string(40) /* Top 10 total industries by total female employment */

gen percent_female_t = (emp_f_t)/(emp_f_t + emp_m_t) /* Generate percent female variable */

gsort -percent_female_t /* Sort by percent female */

list shric_desc percent_female_t in 1/10 /* Top 10 total industries by percent female */

label var emp_m_u "Total Male Urban Employment" /* Add labels to all variables in new dataset */
label var emp_f_u "Total Female Urban Employment"
label var emp_m_r "Total Male Rural Employment"
label var emp_f_r "Total Female Rural Employment" 
label var emp_m_t "Total Male Employment"
label var emp_f_t "Total Female Employment" 
label var percent_female_r "Percent of workers female(Rural)"
label var percent_female_u "Percent of workers female(Urban)"
label var percent_female_t "Percent of workers female(Total)"

save $ec/ec13_total_shric_by_gender.dta, replace /* Save to new dataset */


