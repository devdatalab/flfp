/* use dataset */
use $iec/dise/dise_basic_clean, clear

/* keep single state */
keep if dise_state == "Uttar-Pradesh"

/* keep 2005-06 data */
keep if year == "2005-2006"

/* edit school names */
replace school_name = strlower(school_name)
replace school_name = strtrim(school_name)
replace school_name = stritrim(school_name)

/* sort */
sort school_name

/* gen identifying vars */
gen schname1 = substr(school_name, 1, 1)
gen schname2 = substr(school_name, 1, 2)
gen schname3 = substr(school_name, 1, 3)
gen schname4 = substr(school_name, 1, 4)
gen identify = 1 if strpos(school_name, "gandhi")
replace identify  = 1 if strpos(school_name, "kasturba")
replace identify  = 1 if strpos(school_name, "kastoorba")

/* list possible kgbv school names */
list school_name if schname2 == "kg"
list school_name if schname3 == "kas"
list school_name if schname3 == "k.g"
list school_name if schname3 == "k. "
list school_name if schname3 == "k g"
list school_name if schname4 == "k. g."
list school_name if schname4 == "kgbv"
list school_name if identify == 1

/* instructions:

Start with one state’s DISE data - say Gujurat. Keep years 2005 to 2015 or whatever other range is available. You may even just do it for the latest year of data (say 2015) and then check in other years for the blocks that we think should have a KGBV but you didn’t find it in 2015.
Replace fullstops (.) with space - subinstr. Remove additional blank spaces in the school name - strtrim & stritrim. Remove even single spaces if needed - subinstr. Convert everything to lowercase - strlower.
Drop schools whose management is private or private unaided. Drop all the variables that are not needed to make the process quicker.
Sort by school name and manually glance through schools that start with alphabet “k”. Here are a couple of variations of the name KGBV in the DISE for Gujurat: “K G B V LAVANA”, “K G B V”, “K G B V SCHOOL”, “K G B V ANJAR”
Use regexr to search through string type school names to either rename all KGBV schools to be exactly the same (“KGBV”) or use regexm to search through school names for key words and identity school type as KGBV. Here are a couple of examples expanding Paul’s last suggestion:
replace school_name=regexr(school_name,"^K G B V","KGBV") - you can do this for all possible variations of KGBV name and use the below line to change the status just once.
replace kgbv = 1 if regexm(school_name, "KGBV")

*/
