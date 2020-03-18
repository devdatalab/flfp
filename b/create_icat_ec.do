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
use $flfp/shric_descriptions.dta, clear

/* generate new SHRIC variable */
gen icat = .

/* replace with new SHRIC IDs for industry categories */

/* "agriculture, forestry and fishing" */
replace icat = 1 if shric==1|shric==2|shric==9|shric==7|shric==8

/* "mining and quarrying" */
replace icat = 2 if shric==4 | shric==3

/* "arts, entertainment and recreation" */
replace icat = 3 if shric==86|shric==88|shric==89

/* "manufacturing" */
replace icat = 4 if shric==5|shric==6|shric==72
replace icat = 4 if shric>9&shric<33

/* "electricity, gas, steam and air conditioning supply" */
replace icat = 5 if shric==33|shric==34

/* "water supply; sewerage, waste management and remediation activities" */
replace icat = 6 if shric==35

/* "construction" */
replace icat = 7 if shric==36|shric==37|shric==38

/* "wholesale and retail trade; repair of motor vehicles and motorcycles" */
replace icat = 8 if shric>38&shric<50

/* "transportation and storage" */
replace icat = 9 if shric>52&shric<60
replace icat = 9 if shric==61|shric==62|shric==63

/* "accommodation and food service activities" */
replace icat = 10 if shric==51|shric==52

/* "information and communication" */
replace icat = 11 if shric==64

/* "financial and insurance activities" */
replace icat = 12 if shric>64&shric<69

/* "real estate activities" */
replace icat = 13 if shric==69

/* "professional, scientific and technical activities" */
replace icat = 14 if shric>72&shric<79
replace icat = 14 if shric==82|shric==87

/* "administrative and support service activities" */
replace icat = 15 if shric==70|shric==71|shric==79|shric==60

/* "education, human health and social work activities" */
replace icat = 16 if shric==80|shric==81|shric==83

/* "other services" */
replace icat =17 if shric==84|shric==85|shric==90|shric==50

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
save $tmp/icat_descriptions.dta, replace

/******************************/
/* B) Collapse at SHRID Level */
/******************************/

/* open EC dataset for all years */
use $flfp/ec_flfp_all_years.dta, clear

/* merge with ICAT descriptions dataset */
merge m:1 shric using $tmp/icat_descriptions.dta

/* collapse by year, ICAT and shrid */
collapse (sum) count* emp*, by (year icat shrid)

/* save SHRID level dataset */
save $flfp/ec_flfp_icat.dta, replace


/************************************/
/* C) Collapse at Urban/Rural Level */
/************************************/

/* use SHRID level ICAT dataset */
use $flfp/ec_flfp_icat.dta, clear

/* merge all PCs */
foreach x in 91 01 11 {
    merge m:1 shrid using $flfp/shrug_pc`x'_pca.dta
	drop _merge
}

/* gen pop (total, male and female) long variable */

foreach x in m f p {
   gen pop`x' = pc01_pca_tot_`x' if inlist(year, 1998, 2005)
   replace pop`x' = pc11_pca_tot_`x'; if year == 2013
   replace pop`x' = pc91_pca_tot_`x' if year == 1990
}

/*

-- if the loop does not work --

gen popm = pc01_pca_tot_m if inlist(year, 1998, 2005)
replace popm = pc11_pca_tot_m if year == 2013
replace popm = pc91_pca_tot_m if year == 1990

gen popf = pc01_pca_tot_f if inlist(year, 1998, 2005)
replace popf = pc11_pca_tot_f if year == 2013
replace popf = pc91_pca_tot_f if year == 1990

*/

/* gen region long variable */
gen region = pc01_sector if inlist(year, 1998, 2005)
replace region = pc11_sector if year == 2013
replace region = pc91_sector if year == 1990

/* keep emp* count* */
keep shrid icat emp* count* region pop year

/* drop missing values */
drop if region=.

/* collapse dataset */
collapse (sum) emp* count*, by (year icat region)

/* save urban/rural level dataset */
save $flfp/ec_flfp_icat_ur.dta, replace


/*********************************/
/* D) Collapse at National Level */
/*********************************/

/* open EC dataset for all years */
use $flfp/ec_flfp_all_years.dta, clear

/* merge with ICAT descriptions dataset */
merge m:1 shric using $tmp/icat_descriptions.dta

/* collapse by year and ICAT */
collapse (sum) count* emp*, by (year icat)

/* save national level dataset */
save $flfp/ec_flfp_icat_india.dta, replace

/*********************************/
/* E) Collapse at Regional Level */
/*********************************/

/* open EC dataset for all years */
use $flfp/ec_flfp_all_years.dta, clear

/* merge with ICAT descriptions dataset */
merge m:1 shric using $tmp/icat_descriptions.dta

/* drop merge variable so we can merge again */
drop _merge

/* Merge with 2011 PC State Key */
merge m:1 shrid using $flfp/shrug_pc11_state_key.dta

/* create regional variable */
gen str13 region = "."

/* code North states */
replace region = "north" if inlist(pc11_state_name, "jammu kashmir", "himachal pradesh", "punjab", ///
"uttarakhand", "haryana")
 
/* code South states */
 replace region = "south" if inlist(pc11_state_name, "karnataka", "andhra pradesh", "kerala", "tamil nadu")
 
/* code North-East states */
replace region = "north-east" if inlist(pc11_state_name, "arunachal pradesh", "assam", "nagaland", "meghalya", ///
"manipur", "tripura", "mizoram")

/* code Central states */
replace region = "central" if inlist(pc11_state_name, "rajasthan", "uttar pradesh", "bihar", "madhya pradesh", ///
"gujarat", "jharkhand", "chattisgrah") | inlist(pc11_state_name, "odisha", "west bengal", "maharashtra")
 
/* collapse by region, year, and ICAT */
collapse (sum) count* emp*, by(region year icat)

/* Drop yearless observations */
drop if year == .

/* Drop regionless observations */
drop if region == "."

/* Generate relevant employment statistics */
gen emp_f_share = emp_f/(emp_f + emp_m)
gen count_f_share = count_f/(count_f + count_m)
gen emp_owner_f_share = emp_f_owner/(emp_m_owner + emp_f_owner)

/* Save to new state-level dataset */
save $flfp/ec_flfp_icat_regional.dta, replace
