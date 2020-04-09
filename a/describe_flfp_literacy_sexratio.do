**Literacy and Sex Ratio Analysis**

/* Load EC-PC merged dataser*/
use $flfp/flfp_ecpc.dta, clear

/* Generate Total Literacy, Female Literacy and Sex Ratio statistics for each PC year */
foreach year in 91 01 11 {
	gen total_literacy_`year' = pc`year'_pca_p_lit / pc`year'_pca_tot_p
	gen female_literacy_`year' = pc`year'_pca_f_lit / pc`year'_pca_tot_f
	gen sex_ratio_`year' = pc`year'_pca_tot_m / pc`year'_pca_tot_f
	}
	
/* Generate Female Employment Share, Female Ownership Share, and Share of Employment in Female owned Firms numbers */	
foreach year in 1990 1998 2005 2013 {
	gen emp_f_share_`year' = emp_f / (emp_m + emp_f) if year == `year'
	gen count_f_share_`year' = count_f / (count_m + count_f) if year == `year'
	gen emp_f_owner_share_`year' = emp_f_owner / (emp_m_owner + emp_f_owner) if year == `year'
}

/* Binscatter all employment statistics against closest PC year Total Literacy and then export combined graphs */

binscatter emp_f_share_1990 total_literacy_91, linetype(connect) title(1990) xtitle(Total Literacy Rate) ytitle(Female Employment Share) name(emp_f_share_1990, replace)
binscatter emp_f_share_1998 total_literacy_01, linetype(connect) title(1998) xtitle(Total Literacy Rate) ytitle(Female Employment Share) name(emp_f_share_1998, replace)
binscatter emp_f_share_2005 total_literacy_01, linetype(connect) title(2005) xtitle(Total Literacy Rate) ytitle(Female Employment Share) name(emp_f_share_2005, replace)
binscatter emp_f_share_2013 total_literacy_11, linetype(connect) title(2013) xtitle(Total Literacy Rate) ytitle(Female Employment Share) name(emp_f_share_2013, replace)

graph combine emp_f_share_1990 emp_f_share_1998 emp_f_share_2005 emp_f_share_2013, xcommon ycommon title(Female Employment Share vs. Total Literacy Rate)
graphout emp_f_share_t_literacy

binscatter count_f_share_1998 total_literacy_01, linetype(connect) title(1998) xtitle(Total Literacy Rate) ytitle(Female Ownership Share) name(count_f_share_1998, replace)
binscatter count_f_share_2005 total_literacy_01, linetype(connect) title(2005) xtitle(Total Literacy Rate) ytitle(Female Ownership Share) name(count_f_share_2005, replace)
binscatter count_f_share_2013 total_literacy_11, linetype(connect) title(2013) xtitle(Total Literacy Rate) ytitle(Female Ownership Share) name(count_f_share_2013, replace)

graph combine count_f_share_1998 count_f_share_2005 count_f_share_2013, xcommon ycommon title(Female Ownership Share vs. Total Literacy Rate)
graphout count_f_share_t_literacy

binscatter emp_f_owner_share_1998 total_literacy_01, linetype(connect) title(1998) xtitle(Total Literacy Rate) ytitle(Employment in Female Owned Firm Share) name(emp_f_owner_share_1998, replace)
binscatter emp_f_owner_share_2005 total_literacy_01, linetype(connect) title(2005) xtitle(Total Literacy Rate) ytitle(Employment in Female Owned Firm Share) name(emp_f_owner_share_2005, replace)
binscatter emp_f_owner_share_2013 total_literacy_11, linetype(connect) title(2013) xtitle(Total Literacy Rate) ytitle(Employment in Female Owned Firm Share) name(emp_f_owner_share_2013, replace)

graph combine emp_f_owner_share_1998 emp_f_owner_share_2005 emp_f_owner_share_2013, xcommon ycommon title(Employment in Female Owned Firm Share vs. Total Literacy Rate)
graphout emp_f_owner_share_t_literacy

/* Binscatter all employment statistics against closest PC year Female Literacy and then export combined graphs */

binscatter emp_f_share_1990 female_literacy_91, linetype(connect) title(1990) xtitle(Female Literacy Rate) ytitle(Female Employment Share) name(emp_f_share_1990, replace)
binscatter emp_f_share_1998 female_literacy_01, linetype(connect) title(1998) xtitle(Female Literacy Rate) ytitle(Female Employment Share) name(emp_f_share_1998, replace)
binscatter emp_f_share_2005 female_literacy_01, linetype(connect) title(2005) xtitle(Female Literacy Rate) ytitle(Female Employment Share) name(emp_f_share_2005, replace)
binscatter emp_f_share_2013 female_literacy_11, linetype(connect) title(2013) xtitle(Female Literacy Rate) ytitle(Female Employment Share) name(emp_f_share_2013, replace)

graph combine emp_f_share_1990 emp_f_share_1998 emp_f_share_2005 emp_f_share_2013, xcommon ycommon title(Female Employment Share vs. Female Literacy Rate)
graphout emp_f_share_f_literacy

binscatter count_f_share_1998 female_literacy_01, linetype(connect) title(1998) xtitle(Female Literacy Rate) ytitle(Female Ownership Share) name(count_f_share_1998, replace)
binscatter count_f_share_2005 female_literacy_01, linetype(connect) title(2005) xtitle(Female Literacy Rate) ytitle(Female Ownership Share) name(count_f_share_2005, replace)
binscatter count_f_share_2013 female_literacy_11, linetype(connect) title(2013) xtitle(Female Literacy Rate) ytitle(Female Ownership Share) name(count_f_share_2013, replace)

graph combine count_f_share_1998 count_f_share_2005 count_f_share_2013, xcommon ycommon title(Female Ownership Share vs. Female Literacy Rate)
graphout count_f_share_f_literacy

binscatter emp_f_owner_share_1998 female_literacy_01, linetype(connect) title(1998) xtitle(Female Literacy Rate) ytitle(Employment in Female Owned Firm Share) name(emp_f_owner_share_1998, replace)
binscatter emp_f_owner_share_2005 female_literacy_01, linetype(connect) title(2005) xtitle(Female Literacy Rate) ytitle(Employment in Female Owned Firm Share) name(emp_f_owner_share_2005, replace)
binscatter emp_f_owner_share_2013 female_literacy_11, linetype(connect) title(2013) xtitle(Female Literacy Rate) ytitle(Employment in Female Owned Firm Share) name(emp_f_owner_share_2013, replace)

graph combine emp_f_owner_share_1998 emp_f_owner_share_2005 emp_f_owner_share_2013, xcommon ycommon title(Employment in Female Owned Firm Share vs. Female Literacy Rate)
graphout emp_f_owner_share_f_literacy

/* Binscatter all employment statistics against closest PC year Sex Ratio and then export combined graphs */

binscatter emp_f_share_1990 sex_ratio_91, linetype(connect) title(1990) xtitle(Sex Ratio) ytitle(Female Employment Share) name(emp_f_share_1990, replace)
binscatter emp_f_share_1998 sex_ratio_01, linetype(connect) title(1998) xtitle(Sex Ratio) ytitle(Female Employment Share) name(emp_f_share_1998, replace)
binscatter emp_f_share_2005 sex_ratio_01, linetype(connect) title(2005) xtitle(Sex Ratio) ytitle(Female Employment Share) name(emp_f_share_2005, replace)
binscatter emp_f_share_2013 sex_ratio_11, linetype(connect) title(2013) xtitle(Sex Ratio) ytitle(Female Employment Share) name(emp_f_share_2013, replace)

graph combine emp_f_share_1990 emp_f_share_1998 emp_f_share_2005 emp_f_share_2013, xcommon ycommon title(Female Employment Share vs. Total Sex Ratio)
graphout emp_f_share_ratio

binscatter count_f_share_1998 sex_ratio_01, linetype(connect) title(1998) xtitle(Sex Ratio) ytitle(Female Ownership Share) name(count_f_share_1998, replace)
binscatter count_f_share_2005 sex_ratio_01, linetype(connect) title(2005) xtitle(Sex Ratio) ytitle(Female Ownership Share) name(count_f_share_2005, replace)
binscatter count_f_share_2013 sex_ratio_11, linetype(connect) title(2013) xtitle(Sex Ratio) ytitle(Female Ownership Share) name(count_f_share_2013, replace)

graph combine  count_f_share_1998 count_f_share_2005 count_f_share_2013, xcommon ycommon title(Female Ownership Share vs. Sex Ratio)
graphout count_f_share_ratio

binscatter emp_f_owner_share_1998 sex_ratio_01, linetype(connect) title(1998) xtitle(Sex Ratio) ytitle(Employment in Female Owned Firm Share) name(emp_f_owner_share_1998, replace)
binscatter emp_f_owner_share_2005 sex_ratio_01, linetype(connect) title(2005) xtitle(Sex Ratio) ytitle(Employment in Female Owned Firm Share) name(emp_f_owner_share_2005, replace)
binscatter emp_f_owner_share_2013 sex_ratio_11, linetype(connect) title(2013) xtitle(Sex Ratio) ytitle(Employment in Female Owned Firm Share) name(emp_f_owner_share_2013, replace)

graph combine emp_f_owner_share_1998 emp_f_owner_share_2005 emp_f_owner_share_2013, xcommon ycommon title(Employment in Female Owned Firm Share vs. Sex Ratio)
graphout emp_f_owner_share_ratio
