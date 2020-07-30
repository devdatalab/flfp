/* use dataset */

use $iec/flfp/dise_ebb_analysis, clear

/* create middle school enr and log enrollment */
egen enr_up_b = rowtotal(enr_all_b6 enr_all_b7 enr_all_b8 )
egen enr_up_g = rowtotal(enr_all_g6 enr_all_g7 enr_all_g8 )
gen ln_enr_up_b = ln(enr_up_b + 1)
gen ln_enr_up_g = ln(enr_up_g + 1)

/* loop over all years */
forval y = 2002/2008 {
  rd ln_enr_up_g pc01_pca_f_lit_rate if year == `y' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), bw degree(1) ylabel(6(.5)9)
  graphout ln_enr_g_`y'

  rd ln_enr_up_b pc01_pca_f_lit_rate if year == `y' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), bw degree(1) ylabel(6(.5)9)
  graphout ln_enr_b_`y'
}

/* create a treatment variable for the RD */
gen treatment = pc01_pca_f_lit_rate < 0

/* create a right side slope for the RD estimation */
gen lit_right = pc01_pca_f_lit_rate * treatment

/* create state and district fixed effects */
group pc01_state_id
group pc01_state_id pc01_district_id 

/* GIRLS */
forval y = 2002/2008 {
  quireg ln_enr_up_g treatment pc01_pca_f_lit_rate lit_right if year == `y' & inrange(pc01_pca_f_lit_rate, -0.1, 0.1), absorb(sgroup) cluster(sdgroup) title(`y')
}

/* BOYS */
forval y = 2002/2008 {
  quireg ln_enr_up_b treatment pc01_pca_f_lit_rate lit_right if year == `y', cluster(sdgroup) absorb(sgroup)
}

