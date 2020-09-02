/**************************************************************/
/* Check completeness of age, sex, birth y,m,day vars in SECC */
/**************************************************************/

/* set globals for loops over SECC .dta files */
global statelist andamannicobarislands andhrapradesh arunachalpradesh assam bihar chandigarh chhattisgarh dadranagarhaveli damananddiu goa gujarat haryana himachalpradesh jammukashmir jharkhand karnataka madhyapradesh maharashtra manipur meghalaya mizoram nagaland nctofdelhi odisha puducherry punjab rajasthan sikkim tamilnadu telangana tripura uttarakhand uttarpradesh westbengal

/* save output in log */
log using $tmp/check_completeness.smcl, replace

qui{
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
    
    /* cycle through each state */
    foreach state in $statelist {
        
        /* open the members file */
        cap confirm file "`path'/`state'_members_clean.dta"
        
        /* skip loop if this file doesn't exist */
        if _rc != 0 continue
        
        /* open the file if it exists */
        use `path'/`state'_members_clean, clear
      
      /* drop if missing geographic identifiers */
      nois disp_nice "`state' - `sector'"
      nois mdesc sex age
      cap nois mdesc birthyear birthmonth birthday

    }
}
}
log close

