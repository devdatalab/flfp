# flfp
Studying female labor force participation in India

# Repository structure / rules

`a/`:  Analysis files (produce results only, do not save new datasets)

`b/`:  Build files (no analysis, only build working datasets)

`e/`:  Exploration files-- anything goes

Please do not check data files into the repository. Code files only.

# Build structure

`export_data.do`: This file generates all the raw datasets that you
will be working with. This can only be run on the research
server. This copies the SHRUG, the NSS, and the EC-FLFP
(`ec_flfp_all_years.dta`) into the `$flfp` folder.

EC-FLFP has the key Economic Census FLFP variables from all four
economic censuses, with a `year` variable to indicator the source
year. (NOTE: This is a different starting point from what you had
previously, but I think we agreed everything should start from here.)

`b/create_location_level_ec.do`: This dofile should collapse
`ec_flfp_shric_all_years.dta` across SHRICs, so that there is one
observation for location. We may want different location-level
datasets. e.g. We want a shrid-level dataset, a district-level
dataset, and a state-level dataset. You can get district and state
identifiers from `$flfp/shrug/shrug_pc11_district_key.dta` and
`$flfp_shrug/shrug_pc11_state_key.dta`. A district is identified by
`pc11_state_id pc11_district_id`, and a state by just `pc11_state_id`.
This should save `ec_flfp_shrid.dta`, `ec_flfp_district.dta`, etc..
The collapsed dataset should have all the employment data from the
uncollapsed data, but I think it is easier / less confusing to drop
the shares, collapse the employment levels, and then recalculate the
shares.

`b/create_icat_ec.do`: This collapses the raw EC to a smaller set of
industries defined by Pranit, and then further collapses those to the
national level and to the urban/rural level. Let's call these `icat`s
for "industry categories." This should save `ec_flfp_icat.dta` (an
icat-shrid level dataset), and then collapse across locations to
create `ec_flfp_icat_india.dta`, `ec_flfp_icat_ur.dta` (for
urban/rural split), and any other regional categorizations that we
need.

`make_flfp.do`: this should be a file in the root folder that runs all
the build files in the correct order. A user should be able to run
`make_flfp.do`, and then run any of the analysis files without
additional work.

# Dataset descriptions

All raw data can be downloaded from this dropbox folder:
https://www.dropbox.com/sh/ax2vurnlqguucd6/AAANxzv8Ai_QhETLewPa_eCHa?dl=0

Any datasets used for analysis should be constructed from the raw data
using do files in the `b/` folder that should run successfully on
anyone's machine.

## Economic Censuses (1990, 1998, 2005, 2013)

(new) Data file with combined years: `ec_flfp_all_years.dta`

(old) Data file with one year at a time: `ec_flfp_05.dta`,
`ec_flfp_13.dta`, etc.

Economic Censuses are complete enumerations of non-farm establishments
in India. These don't include agricultural work. These are aggregated
as sums to the shrid (town/village) level -- `emp_all` describes total
employment, `emp_m` and `emp_f` describe male and female employment,
and the `*_owner` variables describe total employment in male and
female-owned firms. The `o` in owner is described as "other"; we
should drop these firms when studying ownership--- they seem to be
public firms and we don't have ownership information on them.

`shrid` is a location, which is a town or village. `shric` is an
industry code. The dataset `shric_descriptions.dta` provides
descriptions of each industry.

This dataset is collapsed to the industry/year/village
level. Industry is given by `shric`, village/town by `shrid` and year
by `year`.

To get village level aggregated, you need to `collapse (sum) [emp*],
by(shrid year)`. For national industry aggregates, `collapse (sum)
[emp*], by(shric year)`.

If the combined file is too bulky to work with, I've left the
year-separated files up as well. But the collapsed aggregated
described above will be much smaller, and we can always run
exploratory analysis on smaller samples (e.g. `keep if uniform() <
0.1`).

## SHRUG (1991-2013)

`shrug_pc91_pca`,`shrug_pc01_pca`,`shrug_pc11_pca`: Population Census Abstracts -- demographic data
covering years 1991, 2001, 2011

`shrug_pc*_vd`: Village directories: list of village public goods (1991-2011)

`shrug_pc*_td`: Town directories: list of urban public goods (1991-2011)

`shrug_ec13`: 2013 Economic Census: more info on non-farm
employment but the same underlying data as the ec_flfp files above.

`shrug_names`: State, district, subdistrict and villagetown name for
each shrid

## NSS (2012)

National Sample Surveys (esp. round 68 in 2012) are sample surveys of
individuals, from which we can get information on where people
work. This is a survey of individuals, from which we can get
self-reported characteristics of work. This is the data most commonly
used to estimate FLFP, but it is only representative at the district
level, so we can't match it to local labor markets or to narrow
industries.

# Coding Style

Please adhere to a common coding style following that used in the
`nss-clean` repo in the prior work. This include, among other things:

1. All variables and strings are always lowercase, even
   abbrevations. Use `rename *, lower` when importing external data
   with any upper case.

2. Every line of code is preceded by a blank line and a comment
   line. It should be possible to read an entire code file and
   understand it by looking only at the comments.
   
3. Put spaces around all operators, i.e. `5 * emp_all`, not
   `5*emp_all`.
   
4. Every path in the code should begin either with `$flfp` or
   `$tmp`. Do not use absolute or relative path names and do not use
   `cd`. This ensures the code will run the same on all machines. Set
   `$flfp` and `$tmp` in `profile.do`. You can create `profile.do` in
   the PERSONAL folder given by the Stata command
   `sysdir`. `profile.do` will be run every time you open Stata.
   
