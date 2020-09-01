/******************************************************************************/
/* This do file creates urban/rural files with birth order, and space between */
/* births variables for each state                                            */
/******************************************************************************/

/* set globals for loops over SECC .dta files */
global statelist andamannicobarislands andhrapradesh arunachalpradesh assam bihar chandigarh chhattisgarh dadranagarhaveli damananddiu goa gujarat haryana himachalpradesh jammukashmir jharkhand karnataka madhyapradesh maharashtra manipur meghalaya mizoram nagaland nctofdelhi odisha puducherry punjab rajasthan sikkim tamilnadu telangana tripura uttarakhand uttarpradesh westbengal

  /* cycle through rural and urban */
  foreach sector in urban{

  /* save empty dataset */
  clear
  save $tmp/`sector'_birthorder, replace emptyok
  
    /* set some urban and rural parameters: */
    /* - one letter suffix to distinguish urban and rural variables */
    /* - path: use parsed_draft for urban, final for rural */
    if "`sector'" == "urban" {
      local l = "u"
      local path $secc/parsed_draft/dta/urban
      local hhid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_block_id  pc11_ward_id pc11_town_id house_no 
      local memberid pc11_state_id pc11_district_id pc11_subdistrict_id pc11_block_id  pc11_ward_id pc11_town_id house_no sn
  }
    if "`sector'" == "rural" {
      local l = "r"
      local path $secc/final/dta
    }
    
    /* cycle through each state */
    foreach state in $statelist {
        
        /* open the members file */
        cap confirm file "`path'/`state'_members_clean.dta"
        
        /* skip loop if this file doesn't exist */
        if _rc != 0 continue
        
        /* open the file if it exists */
        use `path'/`state'_members_clean, clear

    /* drop obs with missing ids */
    foreach x of var `hhid' {
      drop if mi(`x')
      }

    /* ensure dataset is unique at hh - member level */
    duplicates drop `memberid', force
    
    /* identify children in the data */
    gen child = 1 if age <= 18 & !mi(age)

    /* sort members by age within households*/
    sort `hhid' age
    bys `hhid': gen ageorder = _n

    /* create birth order for children */
    gen birthorder = ageorder if child == 1

    /* age difference between successive children in the household */
    sort `hhid' birthorder
    bys `hhid': gen diff = age[_n+1] - age[_n]
    replace diff = . if child != 1    
    bys `hhid': replace diff = . if diff[_n+1] == .

    /* keep necessary vars */
    keep `memberid' age sex diff birthorder

    /* label vars */
    la var birthorder "Order of birth of child"
    la var diff "Age difference between two subsquent siblings"

    /* cap birth order variable */
    replace birthorder = . if birthorder > 20
    
    /* save dataset */
    append using $tmp/`sector'_birthorder
    save $tmp/`sector'_birthorder, replace
    }
    
}
