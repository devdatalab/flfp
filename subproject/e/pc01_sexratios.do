/****************************************************************************************************/
/* This do file creates district level maps using town-level sex ratios from Population census data */
/****************************************************************************************************/

/* impor pc01 town directory */
use $pc01/pc01_td_clean, clear

/* keep necessary vars */
keep pc01*id *sex*

/* merge pc01 and pc11 */
merge 1:m pc01_state_id pc01_district_id pc01_subdistrict_id pc01_town_id using $keys/pc0111_town_key, nogen keepusing(pc11*id)
merge m:1 pc11_state_id pc11_district_id pc11_subdistrict_id pc11_town_id using $pc11/pc11_td_clean,  nogen keepusing(*sex* pc11_town_name)

/* keep only ids and sex ratios */
keep pc*id *sex* pc*name
drop pc01*91 pc01*01
order pc*id pc*sex*

/* save as temp dataset for use later */
save $tmp/sexratio_townnames

/* get coordinates */
merge m:1 pc11_state_id pc11_district_id pc11_subdistrict_id pc11_town_id using $iec1/pc11/geo/town_coords_clean, nogen keep(match)

/* collapse to district level to create maps */
collapse_save_labels
collapse (mean) *sex*, by(pc11_state_id pc11_district_id)
collapse_apply_labels

/* categorize data to standardize legend */
foreach x of var pc*sex* {
  replace `x' = . if `x' > 1500
  gen c_`x' = .
  replace c_`x' = 500 if inrange(`x', 1, 500)
  replace c_`x' = 800 if inrange(`x', 501, 800)
  replace c_`x' = 900 if inrange(`x', 801, 1000)
  replace c_`x' = 1000 if `x' > 1000 & !mi(`x')
  replace c_`x' = . if `x' == .
  }

/* define scale */
label define sr 500 "0-500" 800 "501-800" 900 "801-1000"  1000 ">1000" 
label values c_* sr

/* save data */
save $tmp/sr_dataset, replace

/* create maps */

/* convert shape file to dta format */
shp2dta using "~/iec1/gis/pc11/pc11-district.shp", database("$tmp/base_db") coordinates("$tmp/dist_coord") genid(geoid) replace

/* merge coordinates with dataset with sex ratios */
use $tmp/base_db, clear

/* rename variables for merge */
ren pc11_s_id pc11_state_id
ren pc11_d_id pc11_district_id
//ren pc11_sd_id pc11_subdistrict_id
//ren pc11_v_id pc11_town_id 

/* bring in sex ratios */
merge 1:1 pc11_state_id pc11_district_id using $tmp/sr_dataset, nogen keep(match)

spmap c_pc01_td_sex_1981 using $tmp/dist_coord, id(geoid) fcolor(RdYlGn) ndfcolor(white) title("District-level sex ratio - 1981") name(first, replace) clmethod(unique)
graphout first

spmap c_pc11_td_sex_1991 using $tmp/dist_coord, id(geoid) fcolor(RdYlGn) title("District-level sex ratio - 1991") name(second, replace) clmethod(unique)
graphout second

grc1leg first second
graphout sexratio_1

spmap c_pc11_td_sex_2001 using $tmp/dist_coord, id(geoid) fcolor(RdYlGn) title("District-level sex ratio - 2001") clmethod(unique) name(third, replace)
graphout third

spmap c_pc11_td_sex_2011 using $tmp/dist_coord, id(geoid) fcolor(RdYlGn) title("District-level sex ratio - 2011") clmethod(unique) name(fourth, replace)
graphout fourth

grc1leg third fourth
graphout sexratio_2

//spmap pc11_td_sex_2011  using  $tmp/trial_coord, id(geoid) ///
//	legenda(on) clmethod(quantile) fcolor(RdYlGn) ocolor(white ..) osize(vvthin ..)  ///
//	title("Figure title here", size(*0.8)) 	subtitle("(Subtitle here) ", size(*0.6)) ///
//	legtitle("Legend title here")   legcount  ///
//    legend(size(medium)) legend(pos(6) row(7) ring(1) size(*.75) forcesize /* symx(*.75) symy(*.75) */ )
//
//graphout trial
//

/* create time series plots for cities */
use $tmp/sexratio_townnames, clear

/* drop towns with missing names */
drop if mi(pc11_town_name)

/* rename some towns for ease */
replace pc11_town_name = "bangalore" if pc11_town_name == "bruhat bengaluru mahanagara palike"
replace pc11_town_name = "mumbai" if pc11_town_name == "navi mumbai"
replace pc11_town_name = "delhi" if pc11_town_name == "delhi municipal corporation"

/* keep towns you're interesting in plotting */
local cities delhi kolkata chennai mumbai bangalore amritsar bhopal jaipur ahmadabad tiruchirappalli cuttack guwahati imphal srinagar patna

/* rename trichy for shorter label on plot */
replace pc11_town_name = "trichy" if pc11_town_name == "tiruchirappalli"

/* keep towns you've decided on */
gen keep = .
foreach c in `cities'{
 replace keep = 1 if pc11_town_name == "`c'"
  }
  
keep if keep == 1

/* keep only vars you need */
keep pc11_town_name *sex*

/* rename vars */
ren pc01_* pc11_*
ren pc11_td_sex_* sexratio*

/* drop duplicates - one row for each town */
duplicates tag pc11_town_name, gen(tag)
keep if tag == 0

/* reshape to long */
reshape long sexratio, i(pc11_town_name) j(year)

/* set scheme */
set scheme s1color

/* convert town name into numeric variable */
encode pc11_town_name, gen(id)

/* create plot */
xtset id year
replace sexratio = . if sexratio == 0
xtline sexratio, overlay ytitle("No. of females per 1000 males", margin(medium)) name(sr1, replace) legend(size(small) col(1) pos(4) lstyle(none)) ylabel(, nogrid) xlabel(, nogrid)
graphout sex_timeseries

