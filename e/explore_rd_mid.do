use $iec/flfp/dise_ebb_analysis, clear

/* create middle school enr and log enrollment */

gen ln_enr_up_b = ln(enr_all_mid_b + 1)
gen ln_enr_up_g = ln(enr_all_mid_g + 1)

/*
/* loop over all years and generate graphs */

forval i = 2002/2015 {
  rd ln_enr_up_g pc01_pca_f_lit_rate if year == `i' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), ///
      bw degree(1) ylabel(6(.5)9) xtitle("Female Literacy Rate") ytitle("Log Enrollment") ///
      title(`i') bins(20) name(g`i') nodraw
  local graphs_g "`graphs_g' g`i'"
}

forval i = 2002/2015 {
  rd ln_enr_up_b pc01_pca_f_lit_rate if year == `i' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), ///
      bw degree(1) ylabel(6(.5)9) xtitle("Female Literacy Rate") ytitle("Log Enrollment") ///
      title(`i') bins(20) name(b`i') nodraw
  local graphs_b "`graphs_b' b`i'"
}

/* graph combine */

gr combine `graphs_g', cols(2)  title (RD - Middle School Enrollment for Girls) ///
    ysize(20) xsize(7) scheme(w538)
graphout g_combine_all

gr combine `graphs_b', cols(2)  title (RD - Middle School Enrollment for Boys) ///
    ysize(20) xsize(7) scheme(w538)
graphout b_combine_all
*/

tab year, gen(dyear)

/* create a treatment variable for the RD */
gen treatment = pc01_pca_f_lit_rate < 0

/* create a right side slope for the RD estimation */
gen lit_right = pc01_pca_f_lit_rate * treatment

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id 

/* GIRLS */
forval y = 2002/2015 {
  quireg ln_enr_up_g treatment pc01_pca_f_lit_rate lit_right if year == `y' ///
 & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), cluster(sdgroup) title(`y') absorb(sgroup)
}

/* BOYS */
forval y = 2002/2015 {
  quireg ln_enr_up_b treatment pc01_pca_f_lit_rate lit_right if year == `y' ///
 & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), cluster(sdgroup) title(`y') absorb(sgroup)
}


gen treat_year = treatment * year


areg ln_enr_up_g year treatment treat_year pc01_pca_tot_p  ///
    if inrange(pc01_pca_f_lit_rate, -0.1, 0.1) & inrange(year, 2003, 2008), ///
    absorb(sgroup) cluster(sdgroup)


