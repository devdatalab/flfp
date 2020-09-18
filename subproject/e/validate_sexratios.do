foreach level in district subdistrict {

  if "`level'" == "district" local ids pc11_state_id pc11_district_id
  if "`level'" == "subdistrict" local ids pc11_state_id pc11_district_id pc11_subdistrict_id 

  /* bring in pc01 sex ratio dataset */
  use $tmp/pc_sexratios, clear

  /* keep necessary vars */
  keep pc11*id pc11*name pc11*td*2011

  /* collapse to subdistrict level */
  collapse_save_labels
  collapse (mean) pc11*td*2011, by(`ids')
  collapse_apply_labels

  /* merge with secc urban sex ratio data */
  merge 1:1 `ids' using /scratch/bcai/secc_age_bins_`level'_u, keep(match) nogen
  /* almost all of the using data merged except 9 obs */

  /* gen secc sex ratio */
  gen secc_sex_2012 = secc_pop_uf/secc_pop_um
  replace secc_sex_2012 = secc_sex_2012 * 1000

  /* drop unnecessary vars */
  drop age_*

  /* one insane outlier */
  replace pc11_td_sex_2011 = . if pc11_td_sex_2011 > 2000

  /* scatter plot */
  set scheme pn
  graph twoway (scatter secc_sex_2012 pc11_td_sex_2011, msymbol(circle_hollow)) || function y = x, ra(pc11_td_sex_2011) clpat(dash) xtitle("females/1000 males - PC 11") ytitle("females/1000 males - SECC (2012)") note("Scope: `level' - urban")
  graphout secc_pc11_`level'

  }

