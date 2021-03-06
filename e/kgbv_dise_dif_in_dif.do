/*****************************************/
/* EXPLORING KGBV IDENTIFICATION IN DISE */
/*****************************************/

/************************/
/* Merge and Clean DISE */
/************************/

/* use seed dise dataset */
use $iec/dise/dise_basic_clean, clear

/* merge with other DISE datasets */
foreach dataset in dise_enr_clean dise_facility_clean.dta dise_general_clean {
  merge m:1 dise_state year vilcd schcd using $iec/dise/`dataset'
  drop _merge
}

/* destring */
capture destring, replace

/* clean relevant string variables */
local vars district dise_block_name school_name

foreach i of local vars{
replace `i' = subinstr(`i', ".", "",.)
replace `i' = subinstr(`i', ",", "",.)
replace `i' = subinstr(`i', "-", "",.)
replace `i'=strtrim(`i')
replace `i'=stritrim(`i')
replace `i'=upper(`i')
}

/* save as temporary dataset */
save $tmp/findkgbvs, replace

/******************************************/
/* Explore Methods of KGBV Identification */
/******************************************/

/* open dataset */
use $tmp/findkgbvs, clear

/* generate variable that indicates where in school names the KGBV indicator appears */
gen kgbv_pos = strpos(school_name, "KGBV")

/* add additional KGBV indicators */
replace kgbv_pos=strpos(school_name, "KGB ") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURAB GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA BALIKA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA MADHYAMIK") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURABA KANYA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA UTTAB") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTRURBA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA KANYA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTRUBAI GHANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURABA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURIBA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTHURABA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTHURABA GANDI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTRUBAI GANDI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURA BA ") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURI BA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASUTHURI BA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTHURI BA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTHRI BA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KATURA BA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURIBAI MCHS") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURIBAI MPL HS") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTRUBA GIRL") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "PSGANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA BANIPATHAR(SSA)") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURI (SSA)") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GIRL") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURWA GHANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURWA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "GIRLS KASTURBA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTUBA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTRUBA GANDHI BALIKA VIDYALAYA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTUTBA GANDI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURVA GANDHI BALIKA VIDYALAYA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GOVT GIRLS") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTHURIBAI GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTOORBA GHANDHI BALIKA VIDYALAI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTOORBA GANDHI VALIKA VIDYAL") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTOORBA GANDHI BALIKA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GABALIKA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "UPS KASTOORBA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GANDI B") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTOORABA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GADHI ABASEE") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBHA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GHANDHI B") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA AVASIYA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTOORBA GANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTGANDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GAWASIYA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GBV") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GABDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "GANDHI BALIKA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA GHNDHI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "VINDWALIYA (KASTURVA)") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA A BALIKA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURABA GANDI B") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "GHANDHI BALIKA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURBA HINDI") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "KASTURIBA VIDYA") if kgbv_pos==0
replace kgbv_pos=strpos(school_name, "GOVT GIRL") if kgbv_pos==0 & dise_state == "Orissa"
replace kgbv_pos=strpos(school_name, "PROJECT") if kgbv_pos==0 & dise_state == "Bihar"

/* replace misidentifications of private schools */
replace kgbv_pos = 0 if schmgt == 5

/* create identified dataset */
save $tmp/kgbv_ids, replace

/* Prepare dise SC data for merge */
use ~/iec/dise/dise_enr_sc.dta, clear
duplicates drop schcd year, force

save $tmp/dise_sc, replace

/* Merge DISE SC data */
use $tmp/kgbv_ids, replace

duplicates drop schcd year, force
merge 1:1 schcd year using $tmp/dise_sc
drop _merge

/* generate enrollment counts for  KGBVs */
gen kgbv_enr_g_up = 0 if kgbv_pos == 0
replace kgbv_enr_g_up = enr_all_up_g if kgbv_pos > 0

gen kgbv_enr_g_up_sc = 0 if kgbv_pos == 0
replace kgbv_enr_g_up_sc = enr_sc_up_g if kgbv_pos > 0

/* Generate non-KGBV enrollment */
gen non_kgbv_enr_g_up = enr_all_up_g if kgbv_pos == 0
gen non_kgbv_enr_g_up_sc = enr_sc_up_g if kgbv_pos == 0 

/* clean year variable */
replace year = substr(year, 1, 4)
destring year, replace

/* Generate KGBV introduced variable. Using 10000 as a placeholder for never having a KGBV */
gen kgbv_introduced = year_established if kgbv_pos > 0
replace kgbv_introduced = 10000 if kgbv_pos == 0

/* Drop KGBVs created before KGBV program started */
drop if kgbv_introduced < 2004

/* save as temporary file */
save $tmp/kgbv_enr_with_year, replace

/* Open School-level dataset */
use $tmp/kgbv_enr_with_year, clear

/* Collapse to the village level creating kgbv introduced into village variable */
collapse (min) kgbv_introduced, by(dise_village_name)

/* Gen kgbv dummy */
gen kgbv_village = 0
replace kgbv_village = 1 if kgbv_introduced != 10000

/* Save dataset for merge */
save $tmp/kgbv_village_dummy, replace

/* open school-level dataset */
use $tmp/kgbv_enr_with_year, clear

/* Collapse to village-year level */
collapse (sum) kgbv_enr_g_up non_kgbv_enr_g_up kgbv_enr_g_up_sc non_kgbv_enr_g_up_sc, by(year dise_village_name)

/* Merge in village dummy and kgbv introduction year */
merge m:1 dise_village_name using $tmp/kgbv_village_dummy

/* Take village-level average by year and kgbv introduction year */
collapse (mean) kgbv_enr_g_up non_kgbv_enr_g_up kgbv_enr_g_up_sc non_kgbv_enr_g_up_sc, by(year kgbv_introduced)

/* Graph non-kgbv enrollment for kgbv introduced in given year vs. enrollment in villages with no kgbvs */
forval i = 2009/2012 {
  graph twoway (line non_kgbv_enr_g_up year if kgbv_introduced == `i') (line non_kgbv_enr_g_up year if kgbv_introduced == 10000), xline(`i') title(`i') xtitle(Year) ytitle(Mean Village-Level Enrollment) legend(label(1 "KGBV introduced in year") label(2 "Non-KGBV Villages")) name(non_kgbv_`i', replace)
}

graph combine non_kgbv_2009 non_kgbv_2010 non_kgbv_2011 non_kgbv_2012, xcommon ycommon title(Non-KGBV enrollment in KGBV vs Non-KGBV villages)
graphout combined
