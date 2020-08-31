/**************************************************/
/* CLEAN SECC DATA AND ESTIMATE SEX RATIOS BY AGE */
/**************************************************/

/* ASSIGN ALL MEMBERS TO 5-YEAR AGE BINS */
/* Note: age-binning code is adapted from Ali's code in
~/ddl/covid/b/gen_age_distributions.do*/


/* set globals for loops over SECC .dta files */
 global statelist andamannicobarislands andhrapradesh arunachalpradesh assam bihar chandigarh chhattisgarh dadranagarhaveli damananddiu goa gujarat haryana himachalpradesh jammukashmir jharkhand karnataka madhyapradesh maharashtra manipur meghalaya mizoram nagaland nctofdelhi odisha puducherry punjab rajasthan sikkim tamilnadu telangana tripura uttarakhand uttarpradesh westbengal

/* set global for 5-year age bins */
global agebins age_0 age_5 age_10 age_15 age_20 age_25 age_30 age_35 age_40 age_45 age_50 age_55 age_60 age_65 age_70 age_75 age_80 age_85

/************************************************/
/* Calculate Rural and Urban Age Bins from SECC */
/************************************************/

/* collapse this to both districts and subdistricts */
foreach level in district subdistrict {

  /* set location identifiers for this collapse level */
  if "`level'" == "district" local ids pc11_state_id pc11_district_id 
  if "`level'" == "subdistrict" local ids pc11_state_id pc11_district_id pc11_subdistrict_id 
  
  /* cycle through rural and urban */
  foreach sector in rural urban {
    
    /* set some urban and rural parameters: */
    /* - one letter suffix to distinguish urban and rural variables */
    /* - path: use parsed_draft for urban, final for rural */
    if "`sector'" == "urban" {
      local l = "u"
      local path $secc/parsed_draft/dta/urban
    }
    if "`sector'" == "rural" {
      local l = "r"
      local path $secc/final/dta
    }
    
    /* save an empty output file so we can append to it state by state */
    clear
    save $tmp/secc_age_bins_`level'_`l'_tmp, emptyok replace

    /* cycle through each state */
    foreach state in $statelist {
      disp_nice "`sector'-`level'-`state'"

      // /* use telangana from parsed_draft/ folder */
      // if "`state'" == "telangana" & "`sector'" == "rural" {
      //   use $secc/parsed_draft/dta/rural/`state'_members_clean, clear
      // }
      // else {
        
        /* open the members file */
        cap confirm file "`path'/`state'_members_clean.dta"
        
        /* skip loop if this file doesn't exist */
        if _rc != 0 continue
        
        /* open the file if it exists */
        use `path'/`state'_members_clean, clear
      // }
      
      /* drop if missing geographic identifiers */
      drop if mi(pc11_state_id) | mi(pc11_district_id)
      if "`level'" == "subdistrict" drop if mi(pc11_subdistrict_id)
  
      /* birthyear doesn't exist in the final/ data */
      cap gen birthyear = 2012 - age
      drop if age < 0

      /* only keep vars related to id, age, and sex */
keep `ids' age birthyear sex

        
      /****************/
      /* Age Cleaning */
      /****************/
      /* create a clean age variable */
      gen age_clean = age

      /* assume that birthyears below 100 are actually the age, if the age is missing  */
      replace age_clean = birthyear if mi(age) & birthyear < 100
      replace birthyear = . if mi(age) & birthyear < 100

      /* assume the birthyears under 100 and ages over 1000 have been swapped */
      replace age_clean = birthyear if age > 1000 & birthyear < 100
      replace birthyear = age if age > 1000 & birthyear < 100

      /* assume birthyear is off by 1000 if less than 1900 */
      replace birthyear = birthyear + 100 if birthyear < 1900 & birthyear > 1800
      replace age_clean = 2012 - birthyear if age > 100

      /* replace age_clean with missing if it is unreasonable */
      replace age_clean = . if age_clean > 200

      /* replace age with age_clean */
      drop age birthyear
      ren age_clean age

      /* drop if missing age */
      drop if mi(age)
      drop if age < 0

      qui count
      if `r(N)' == 0 {
        continue
      }

      /*******************/
      /* Gender Cleaning */
      /*******************/
/* create a simplified gender variable */
      gen female = sex

/* drop transgender persons and bad observations */
      replace female = . if sex == 3 | sex == -9998
      drop if female == .

      /* make sex_clean an indicator for female sex */
      recode female (1=0) (2=1)
      
      /* replace old sex var */
      drop sex

      
      /***************/
      /* Age Binning */
      /***************/
      /* create age bins */
      egen age_bin_`l' = cut(age), at(0(5)90)

      /* fill in the 85+ age bin */
      replace age_bin_`l' = 85 if age >= 85

      /* drop age */
      drop age

      /* create counter to collapse over */
      gen age_ = 1


      /* collapse to count people in the age bins by sex */
      collapse (sum) age_, by(`ids' female  age_bin_`l' )

      /* get total population by sex */
      bys `ids' female: egen secc_pop_`l' = total(age_)
  
      /* reshape rural data to wide so that each age bin is a variable */
      reshape wide age_, i(`ids' secc_pop_`l') j(age_bin_`l' )

      foreach i in $agebins {
        
        /* if the age bin doesn't exist, set it to 0 */
        cap gen `i' = 0
        
        /* rename the age bin variables to be rural/urban specific */
        ren `i' `i'_`l'

      }
/* reshape data wide again for gender specific variables */
reshape wide secc_pop_`l' age_* , i(`ids') j(female)

/* loop over age bins again */
      foreach i in $agebins {
        
      /* rename the age bin variable to also be gender-specific */
        ren `i'_`l'0 `i'_`l'_m 
        ren `i'_`l'1 `i'_`l'_f

/* close loop over agebins */
      }

      /* rename secc population total to be age-specific */
        ren secc_pop_`l'0 secc_pop_`l'm
        ren secc_pop_`l'1 secc_pop_`l'f



//      /* calculate age bin population share */
//      foreach i in $agebins {
//        gen `i'_`l'_share = `i'_`l' / secc_pop_`l'
//      }
  
      /********/
      /* Save */
      /********/
      /* append the data to the file */
      append using $tmp/secc_age_bins_`level'_`l'_tmp

      /* drop a weird broken rural district (almost no data)  */
      if "`sector'" == "rural" {
        drop if pc11_state_id == "12" & pc11_district_id == "246" & (secc_pop_rm == 198 | secc_pop_rf == 198)
      }
      bys `ids': assert _N == 1

      save $tmp/secc_age_bins_`level'_`l'_tmp, replace
    }
    
    /* save the appended file */
    save $tmp/secc_age_bins_`level'_`l', replace
  }
}
