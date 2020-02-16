///***************************************************///
// CREATE A SHRIC DATABASE WITH NEW MERGED INDUSTRIES //
///***************************************************///

use $flfp/shric_descriptions.dta, clear

/*

///**** Old shric numbers for new industry classification ****///

1, 2, 9, 7, 8 Agriculture, forestry and fishing

4, 3 Mining and quarrying

86, 88, 89 Arts, entertainment, recreation

5, 6, 10, 11, 12 ,13 , 14, 15 ,16 ........ 31, 32, 72 Manufacturing

33, 34 Electricity, gas, steam and air conditioning supply

35 Water supply; sewerage, waste management and remediation activities

36, 37, 38  Construction

39, 40, 41, ....... 48, 49 Wholesale and retail trade; repair of motor vehicles and motorcycles

53, 54, 55, 56, 57, 58, 59, 61, 62, 63 Transportation and storage

51, 52 Accommodation and Food service activities

64 Information and communication

65, 66, 67, 68 Financial and insurance activities

69 Real estate activities

73, 74, 75, 76, 77, 78, 82, 87 Professional, scientific and technical activities

70, 71, 79, 60  Administrative and support service activities

80, 81, 83 Education, Human health and social work activities

50, 84 85 90 Other Services

Classification guide: http://mospi.nic.in/sites/default/files/main_menu/national_industrial_classification/nic_2008_17apr09.pdf

*/

// Generate new shric ids as per aforementioned groups in comments

gen new_shric = 1 if shric==1|shric==2|shric==9|shric==7|shric==8 // Agriculture, forestry and fishing

replace new_shric = 2 if shric==4 | shric==3 // Mining and quarrying

replace new_shric = 3 if shric==86|shric==88|shric==89 // Arts, entertainment, recreation

replace new_shric = 4 if shric==5|shric==6|shric==72 //Manufacturing

replace new_shric = 4 if shric>9&shric<33 // Manufacturing

replace new_shric = 5 if shric==33|shric==34 //Electricity, gas, steam and air conditioning supply

replace new_shric = 6 if shric==35 //Water supply; sewerage, waste management and remediation activities

replace new_shric = 7 if shric==36|shric==37|shric==38 //Construction

replace new_shric = 8 if shric>38&shric<50 //Wholesale and retail trade; repair of motor vehicles and motorcycles

replace new_shric = 9 if shric>52&shric<60 // Transportation and storage

replace new_shric = 9 if shric==61|shric==62|shric==63 //

replace new_shric = 10 if shric==51|shric==52 // Accommodation and Food service activities

replace new_shric = 11 if shric==64 //Information and communication

replace new_shric = 12 if shric>64&shric<69 //Financial and insurance activities

replace new_shric = 13 if shric==69 // Real estate activities

replace new_shric = 14 if shric>72&shric<79 // Professional, scientific and technical activities

replace new_shric = 14 if shric==82|shric==87 //Professional, scientific and technical activities

replace new_shric = 15 if shric==70|shric==71|shric==79|shric==60 // Administrative and support service activities

replace new_shric = 16 if shric==80|shric==81|shric==83 //Education, Human health and social work activities

replace new_shric =17 if shric==84|shric==85|shric==90|shric==50 // Other Services

sort new_shric


// Generate new shric descriptions as per aforementioned groups


gen new_shric_desc = "Agriculture, forestry and fishing" if new_shric==1

replace new_shric_desc = "Mining and quarrying" if new_shric==2

replace new_shric_desc = "Arts, entertainment and recreation" if new_shric==3

replace new_shric_desc = "Manufacturing" if new_shric==4

replace new_shric_desc = "Electricity, gas, steam and air conditioning supply" if new_shric==5

replace new_shric_desc = "Water supply; sewerage, waste management and remediation activities" if new_shric==6

replace new_shric_desc = "Construction" if new_shric==7

replace new_shric_desc = "Wholesale and retail trade; repair of motor vehicles and motorcycles" if new_shric==8

replace new_shric_desc = "Transportation and storage" if new_shric==9

replace new_shric_desc = "Accommodation and Food service activities" if new_shric==10

replace new_shric_desc = "Information and communication" if new_shric==11

replace new_shric_desc = "Financial and insurance activities" if new_shric==12

replace new_shric_desc = "Real estate activities" if new_shric==13

replace new_shric_desc = "Professional, scientific and technical activities" if new_shric==14

replace new_shric_desc = "Administrative and support service activities" if new_shric==15

replace new_shric_desc = "Education, Human health and social work activities" if new_shric==16

replace new_shric_desc = "Other Services" if new_shric==17

// save new dataset

save $tmp/new_shric_desc.dta, replace
