# flfp
Studying female labor force participation in India

# Repository structure

a/ | Analysis files (produce results only, do not save new datasets)
b/ | Build files (no analysis, only build working datasets)
e/ | Exploration files-- anything goes

# Dataset descriptions

## Economic Censuses (1990, 1998, 2005, 2013)

Files: ec_flfp_90.dta, ec_flfp_98.dta, ec_flfp_05.dta, ec_flfp_13.dta

Economic Censuses are complete enumerations of non-farm establishments
in India. These don't include agricultural work. These are aggregated
as sums to the shrid (town/village) level -- `emp_all` describes total
employment, `emp_m` and `emp_f` describe male and female employment,
and the `*_owner` variables describe total employment in male and
female-owned firms. The `o` in owner is described as "other",
i.e. (male/female/other). The numbers in some years are way too high
for this to be possible, so we need to investigate whether this means
female or missing.

`shrid` is a location, which is a town or village. `shric` is an
industry code. The dataset `shric_descriptions.dta` provides
descriptions of each industry.

## SHRUG (1991-2013)


`shrug_pc91_pca`,`shrug_pc01_pca`,`shrug_pc11_pca`: Population Census Abstracts -- demographic data
covering years 1991, 2001, 2011

`shrug_pc*_vd`: Village directories: list of village public goods (1991-2011)
`shrug_pc*_td`: Town directories: list of urban public goods (1991-2011)
`shrug_ec13`: 2013 Economic Census: more info on non-farm
employment but the same underlying data as the ec_flfp files above.

## NSS (2012)

National Sample Surveys (esp. round 68 in 2012) are sample surveys of
individuals, from which we can get information on where people
work. This is a survey of individuals, from which we can get
self-reported characteristics of work. This is the data most commonly
used to estimate FLFP, but it is only representative at the district
level, so we can't match it to local labor markets or to narrow
industries.

