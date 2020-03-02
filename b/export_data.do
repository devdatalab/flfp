/* exports the data for offline analysis of FLFP */
global flfp $tmp/flfp
cap mkdir $flfp
cap mkdir $flfp/nss
cap mkdir $flfp/shrug

/* export economic censuses */
foreach y in 90 98 05 13 {
  shell rsync $tmp/ec_flfp_`y'.dta $flfp
}
shell rsync $tmp/ec_flfp_all_years.dta $flfp

/* export shric descriptions */
shell rsync $shrug/keys/shric_descriptions.dta $flfp/shrug

/* export shrug data */
foreach v in ec90 ec98 ec05 ec13 nl_wide pc01_pca pc01_td pc01_vd pc11_pca pc11_vd pc11_td pc91_pca pc91_td pc91_vd {
  shell rsync $shrug/data/shrug_`v'.dta $flfp/shrug
}

/* shrug names */
shell rsync $shrug/keys/shrug_names.dta $flfp/shrug

/* shrug keys */
shell rsync $shrug/keys/shrug_*pc11*.dta $flfp/shrug


/* export nss */
cap mkdir $flfp/nss
shell rsync $nss/nss-68/10/block*.dta $flfp/nss

/* zip everything */
cd $flfp
shell zip -R flfp.zip '*.dta'

