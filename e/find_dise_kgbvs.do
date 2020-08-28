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

drop if kgbv_pos == 0
collapse (sum) enr_all_b enr_all, by(year)
gen boys_share = enr_all_b / enr_all
replace year = substr(year, 1, 4)
destring year, replace
graph twoway scatter boys_share year
graphout boys_share_revised

/* generate enrollment counts for  KGBVs */
gen kgbv_enr_g_up = 0 if kgbv_pos == 0
replace kgbv_enr_g_up = enr_all_up_g if kgbv_pos > 0

/* collapse to block level */
collapse (sum) kgbv_enr_g_up enr_all_up_g, by(dise_state district dise_block_name year)

/* generate KGBV enrollment share */
keep if kgbv_enr_g_up > 0
gen kgbv_enr_share = kgbv_enr_g_up / enr_all_up_g

/* clean year variable */
replace year = substr(year, 1, 4)
destring year, replace

/* collapse */
collapse (mean) kgbv_enr_share, by(year)

/* save as temporary file */
save $tmp/kgbv_enr, replace

/*******************************/
/* Further Explore Some States */
/*******************************/

/* merge with DISE x PC01 key */
merge m:1 dise_state district dise_block_name using $ebb/pc01_dise_key
drop if _merge == 2
drop _merge

/* merge with KGBVs list */
merge m:1 pc01_state_id pc01_district_id pc01_block_id using $ebb/kgbvs_list_clean
drop if _merge == 2
drop _merge

/* exclude blocks with previously identified KGBV identifiers */
sort dise_block_name
by dise_block_name: egen max_kgbv = max(kgbv_pos)

/* list schools in blocks which should have a KGBV */
list school_name if max_kgbv == 0 & kgbvs_operational > 0 & schtype == 2

/*******************************/
/* Generate Summary Statistics */
/*******************************/

/* generate KGBV dummy */
gen kgbv_dummy = .
replace kgbv_dummy = 1 if kgbv_pos > 0
replace kgbv_dummy = 0 if kgbv_pos == 0

/* generate summary stats */
tab schmgt if kgbv_dummy == 1
tab schtype if kgbv_dummy == 1
tab schcat if kgbv_dummy == 1
summ enr_all_b if kgbv_dummy == 1, detail
summ enr_all_g if kgbv_dummy == 1, detail


/****************************************/
/* Explore Accuracy of Year Established */
/****************************************/

/* use post-algorithm dataset */
use $tmp/kgbv_ids, clear

/* drop non-KGBVs */
drop if kgbv_pos == 0

replace year = substr(year, 1, 4)
destring year, replace

sort schcd year

by schcd: gen is_estdyear_changing = year_established - year_established[_n-1]

replace is_estdyear_changing = 0 if mi(is_estdyear_changing)

drop if is_estdyear_changing != 0

/***********************************/
/* Generate KGBV Enrollment Shares */
/***********************************/

/* open SC/ST DISE dataset */
use /scratch/pgupta/dise_enr_sc_school.dta, clear

/* clean year variable to allow merge */
forvalues year = 1/4 {
  drop if year == "`year'"
}

replace year = "2005-2006" if year == "5"
replace year = "2006-2007" if year == "6"
replace year = "2007-2008" if year == "7"
replace year = "2008-2009" if year == "8"
replace year = "2009-2010" if year == "9"
replace year = "2010-2011" if year == "10"
replace year = "2011-2012" if year == "11"
replace year = "2012-2013" if year == "12"

/* merge with SC/ST enrollment dataset */
merge 1:m dise_state year vilcd schcd using $tmp/kgbv_ids

/* save as temporary dataset */
save $tmp/kgbv_sc_ids, replace

/* generate KGBV enrollment variable */
gen kgbv_enr_sc = 0
replace kgbv_enr_sc = enr_sigc if kgbv_pos > 0
gen kgbv_enr_st = 0
replace kgbv_enr_st = enr_sigt if kgbv_pos > 0

/* collapse to the block level */
collapse (sum) kgbv_enr_sc kgbv_enr_st enr_sigc enr_sigt kgbv_pos, ///
    by(dise_block_name district dise_state year)

/* keep only blocks with a KGBV */
keep if kgbv_pos > 0

/* generate KGBV enrollment share variables */
gen kgbv_sc_share = kgbv_enr_sc / enr_sigc
gen kgbv_st_share = kgbv_enr_st / enr_sigt

/* collapse to year level */
collapse (mean) kgbv_sc_share kgbv_st_share, by(year)

/* clean year variable, and restrict sample to only years with SC/ST data */
replace year = substr(year, 1, 4)
destring year, replace
keep if year < 2013

/* graph KGBV enrollment shares */
graph twoway scatter kgbv_sc_share year, title(KGBV Share of SC Enrollment)
graphout kgbv_sc

graph twoway scatter kgbv_st_share year, title(KGBV Share of ST Enrollment)
graphout kgbv_st
