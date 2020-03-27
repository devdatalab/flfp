/***********************************************/
/* Create Industry Category Collapsed Datasets */
/***********************************************/

/* A) Classify and label ICATs */
/* B) Collapse at SHRID Level */
/* C) Collapse at Urban/Rural Level */
/* D) Collapse at National Level */
/* E) Collapse at Regional Level */

/***********************************/
/* A) Classify and label new ICATs */
/***********************************/

/* Classification guide: http://mospi.nic.in/sites/default/files/main_menu/national_industrial_classification/nic_2008_17apr09.pdf */

/* open SHRIC descriptions dataset */
use $flfp/shric_descriptions, clear

/* generate new SHRIC variable */
gen icat = .

/* replace with new SHRIC IDs for industry categories */

/* "agriculture, forestry and fishing" */
replace icat = 1 if shric == 1 | shric == 2 | shric == 9 | shric == 7 | shric == 8

/* "mining and quarrying" */
replace icat = 2 if shric == 4 | shric == 3

/* "arts, entertainment and recreation" */
replace icat = 3 if shric == 86 | shric == 88 | shric == 89

/* "manufacturing" */
replace icat = 4 if shric == 5 | shric == 6 | shric == 72
replace icat = 4 if shric > 9 & shric < 33

/* "electricity, gas, steam and air conditioning supply" */
replace icat = 5 if shric == 33 | shric == 34

/* "water supply; sewerage, waste management and remediation activities" */
replace icat = 6 if shric == 35

/* "construction" */
replace icat = 7 if shric == 36 | shric == 37 | shric == 38

/* "wholesale and retail trade; repair of motor vehicles and motorcycles" */
replace icat = 8 if shric > 38 & shric < 50

/* "transportation and storage" */
replace icat = 9 if shric > 52 & shric < 60
replace icat = 9 if shric == 61 | shric == 62 | shric == 63

/* "accommodation and food service activities" */
replace icat = 10 if shric == 51 | shric == 52

/* "information and communication" */
replace icat = 11 if shric == 64

/* "financial and insurance activities" */
replace icat = 12 if shric > 64 & shric < 69

/* "real estate activities" */
replace icat = 13 if shric == 69

/* "professional, scientific and technical activities" */
replace icat = 14 if shric > 72 & shric < 79
replace icat = 14 if shric == 82 | shric == 87

/* "administrative and support service activities" */
replace icat = 15 if shric == 70 | shric == 71 | shric == 79 | shric == 60

/* "education, human health and social work activities" */
replace icat = 16 if shric == 80 | shric == 81 | shric == 83

/* "other services" */
replace icat = 17 if shric == 84 | shric == 85 | shric == 90 | shric == 50

/* identify labels for new SHRIC numeric values */
label define icat_label 1 "agriculture, forestry and fishing" ///
2 "mining and quarrying" ///
3 "arts, entertainment and recreation" ///
4 "manufacturing" ///
5 "electricity, gas, steam and air conditioning supply" ///
6 "water supply; sewerage, waste management and remediation activities" ///
7 "construction" ///
8 "wholesale and retail trade; repair of motor vehicles and motorcycles" ///
9 "transportation and storage" ///
10 "accommodation and food service activities" ///
11 "information and communication" ///
12 "financial and insurance activities" ///
13 "real estate activities" ///
14 "professional, scientific and technical activities" ///
15 "administrative and support service activities" ///
16 "education, human health and social work activities" ///
17 "other services"

/* apply labels to each value */
label values icat icat_label

/* save new dataset */
save $tmp/icat_descriptions, replace

/******************************/
/* B) Collapse at SHRID Level */
/******************************/

/* open EC dataset for all years */
use $flfp/ec_flfp_all_years, clear

/* merge with ICAT descriptions dataset */
merge m:1 shric using $tmp/icat_descriptions

/* collapse by year, ICAT and shrid */
collapse (sum) count* emp*, by (year icat shrid)

/* save SHRID level dataset */
save $flfp/ec_flfp_icat, replace

/************************************/
/* C) Collapse at Urban/Rural Level */
/************************************/

/* use SHRID level ICAT dataset */
use $flfp/ec_flfp_icat, clear

/* merge all PCAs */
foreach x in 91 01 11 {
  merge m:1 shrid using $flfp/shrug_pc`x'_pca, keepusing(pc*sector pc*pca*tot_*)
  drop if _merge == 2
  drop _merge
}

/* generate pop (total, male and female) long variable */
foreach x in m f p {

  /* interpolate 1998 population based on 91 and 01 */
  gen     pop`x' = pc91_pca_tot_`x' * (pc01_pca_tot_`x' / pc91_pca_tot_`x') ^ (7/10) if year == 1998
  
  /* interpolate 2005 population based on 01 and 11 */
  replace pop`x' = pc01_pca_tot_`x' * (pc11_pca_tot_`x' / pc01_pca_tot_`x') ^ (4/10) if year == 2005

  replace pop`x' = pc11_pca_tot_`x' if year == 2013
  replace pop`x' = pc91_pca_tot_`x' if year == 1990
}

/* generate sector that works across all years */
gen     sector = pc01_sector if inlist(year, 1998, 2005)
replace sector = pc11_sector if year == 2013
replace sector = pc91_sector if year == 1990

/* apply sector labels */
label values sector shrug_sector

/* keep emp* count* */
keep shrid icat emp* count* sector pop* year

/* drop missing values */
drop if sector == .

/* collapse dataset */
collapse (sum) emp* count*, by (year icat sector)

/* save urban/rural level dataset */
save $flfp/ec_flfp_icat_ur, replace

/*********************************/
/* D) Collapse at National Level */
/*********************************/

/* open EC dataset for all years */
use $flfp/ec_flfp_all_years, clear

/* merge with ICAT descriptions dataset */
merge m:1 shric using $tmp/icat_descriptions
keep if _merge == 3
drop _merge

/* collapse by year and ICAT */
collapse (sum) count* emp*, by(year icat)

/* save national level dataset */
save $flfp/ec_flfp_icat_india, replace

/***************************************/
/* E) Collapse at Region Level by icat */
/***************************************/

/* open EC dataset for all years */
use $flfp/ec_flfp_all_years, clear

/* merge with ICAT descriptions dataset */
merge m:1 shric using $tmp/icat_descriptions
keep if _merge == 3
drop _merge

/* Merge with 2011 PC State Key */
merge m:1 shrid using $flfp/shrug_pc11_region_key
keep if _merge == 3
drop _merge
 
/* collapse by region, year, and icat */
drop if mi(region) | mi(year) | mi(icat)
collapse (sum) count* emp*, by(region year icat)

/* Save to new state-level dataset */
save $flfp/ec_flfp_icat_regional, replace
