/*
Project:		Work Rise Immigrant Low Wage Workers (LWW)
Owners:			Hamutal Bernstein, Fernando Hernandez
Date modified:	3/1/2021
Task:			Build out of ACS and CPS files, to desired sample
Notes:

*1. ACS DATA: 5-year estimates 

Variable list:
P = Person level
H = Household level

Type	Variable	Label
H	YEAR		Census year
H	MULTYEAR	Actual year of survey, multi-year ACS/PRCS
H	SAMPLE		IPUMS sample identifier
H	SERIAL		Household serial number
H	CBSERIAL	Original Census Bureau household serial number
H	HHWT		Household weight
H	HHTYPE		Household Type
H	CLUSTER		Household cluster for variance estimation
H	ADJUST		Adjustment factor, ACS/PRCS
H	CPI99		CPI-U adjustment factor to 1999 dollars
H	REGION		Census region and division
H	STATEFIP	State (FIPS code)
H	COUNTYFIP	County (FIPS code)
H	DENSITY		Population-weighted density of PUMA
H	METRO		Metropolitan status
H	CITY		City
H	PUMA		Public Use Microdata Area
H	STRATA		Household strata for variance estimation
H	HOMELAND	American Indian, Alaska Native, or Native Hawaiian homeland area
H	GQ			Group quarters status
H	FARM		Farm status
H	HHINCOME	Total household income
H	LINGISOL	Linguistic isolation
P	PERNUM		Person number in sample unit
P	PERWT		Person weight
P	RELATE 		(general)	Relationship to household head [general version]
P	RELATED 	(detailed)	Relationship to household head [detailed version]
P	SEX			Sex
P	AGE			Age
P	MARST		Marital status
P	RACE 		(general)	Race [general version]
P	RACED 		(detailed)	Race [detailed version]
P	HISPAN 		(general)	Hispanic origin [general version]
P	HISPAND 	(detailed)	Hispanic origin [detailed version]
P	BPL 		(general)	Birthplace [general version]
P	BPLD 		(detailed)	Birthplace [detailed version]
P	ANCESTR1 	(general)	Ancestry, first response [general version]
P	ANCESTR1D 	(detailed)	Ancestry, first response [detailed version]
P	ANCESTR2 	(general)	Ancestry, second response [general version]
P	ANCESTR2D 	(detailed)	Ancestry, second response [detailed version]
P	CITIZEN		Citizenship status
P	YRNATUR		Year naturalized
P	YRIMMIG		Year of immigration
P	YRSUSA1		Years in the United States
P	YRSUSA2		Years in the United States, intervalled
P	LANGUAGE 	(general)	Language spoken [general version]
P	LANGUAGED 	(detailed)	Language spoken [detailed version]
P	SPEAKENG	Speaks English
P	EDUC		(general)	Educational attainment [general version]
P	EDUCD 		(detailed)	Educational attainment [detailed version]
P	DEGFIELD 	(general)	Field of degree [general version]
P	DEGFIELDD	(detailed)	Field of degree [detailed version]
P	DEGFIELD2 	(general)	Field of degree (2) [general version]
P	DEGFIELD2D 	(detailed)	Field of degree (2) [detailed version]
P	EMPSTAT 	(general)	Employment status [general version]
P	EMPSTATD 	(detailed)	Employment status [detailed version]
P	LABFORCE	Labor force status
P	CLASSWKR 	(general)	Class of worker [general version]
P	CLASSWKRD 	(detailed)	Class of worker [detailed version]
P	OCC			Occupation
P	IND			Industry
P	WKSWORK1	Weeks worked last year
P	UHRSWORK	Usual hours worked per week
P	WRKLSTWK	Worked last week
P	WORKEDYR	Worked last year
P	INCTOT		Total personal 
P	INCWAGE		Wage and salary income
P	INCEARN		Total personal earned income
P	POVERTY		Poverty status

*/

*setting up useful globals:

*global rawf "C:\Users\fhernandez\Desktop\LWW\Data\" // needs to be fixed for each computer
global proc "C:\Users\MCasas\Box\Immigrants in low wage workforce\Analysis using 2021-22 data\Data\" // needs to be fixed for each computer

clear all
/*
import delimited "C:\Users\fhernandez\Desktop\LWW\Data\usa_00008.csv"
save "${proc}acs1y_2021_source.dta", replace // sample for population estimates within age range
clear all

import delimited "C:\Users\fhernandez\Desktop\LWW\Data\usa_00011.csv"
save "${proc}acs1y_2022_source.dta", replace // sample for population estimates within age range
clear all

*/

*forvalues k = 1(1)2 {

use "${proc}2022_acs_data.dta", clear 

*basics
count		// 1-y: 3,252,599; 5-y: 15,537,785
gen n = 1		// use for later in counts

*STATE FIP INDICATOR
label define statefip	1 "Alabama" ///
						2 "Alaska" ///
						4 "Arizona" ///
						5 "Arkansas" ///
						6 "California" ///	
						8 "Colorado" ///
						9 "Connecticut" ///
						10 "Delaware" ///
						11 "District of Columbia" ///
						12 "Florida" ///
						13 "Georgia" ///
						15 "Hawaii" ///
						16 "Idaho" ///
						17 "Illinois" ///
						18 "Indiana" ///
						19 "Iowa" ///
						20 "Kansas" ///
						21 "Kentucky" ///
						22 "Louisiana" ///
						23 "Maine" ///
						24 "Maryland" ///
						25 "Massachusetts" ///
						26 "Michigan" ///
						27 "Minnesota" ///
						28 "Mississippi" ///
						29 "Missouri" ///
						30 "Montana" ///
						31 "Nebraska" ///
						32 "Nevada" ///
						33 "New Hampshire" ///
						34 "New Jersey" ///
						35 "New Mexico" ///
						36 "New York" ///
						37 "North Carolina" ///
						38 "North Dakota" ///
						39 "Ohio" ///
						40 "Oklahoma" ///
						41 "Oregon" ///
						42 "Pennsylvania" ///
						44 "Rhode Island" ///
						45 "South Carolina" ///
						46 "South Dakota" ///
						47 "Tennessee" ///
						48 "Texas" ///
						49 "Utah" ///
						50 "Vermont" ///
						51 "Virginia" ///
						53 "Washington" ///
						54 "West Virginia" ///
						55 "Wisconsin" ///
						56 "Wyoming" 
						
label val statefip statefip
label var statefip "State FIPS code"

decode statefip, gen(state_name)

*CITIZENSHIP AND NATIVITY
gen native = citizen==0 | citizen == 1 // IDs citizens
gen naturalized = citizen==2 // IDs nat citizens
	replace naturalized = .n if native == 1

label define citizen	1 "US-born" ///
						2 "Born abroad of US parents" ///
						3 "Naturalized citizen" ///
						4 "Not a naturalized citizen" 
label val citizen citizen
label var citizen "Citizenship status"

label define native	1 "US-born (or born abroad to US parents)" ///
					0 "Immigrant"
label val native native
label var native "US-born or immigrant"

label define naturalized	1 "Naturalized US-citizen (immigrant)" ///
							0 "Not a naturalized US-citizen" ///
							.n "US-born (not in sample)"
label val naturalized naturalized
label var naturalized "Naturalization status of immigrant"

gen immigrant = native == 0

gen origin = .									// codes origin according to MPI, please edit if you know a better way!
	replace origin = 	1	if bpl ==	200
	replace origin = 	1	if bpl ==	210
	replace origin = 	1	if bpl ==	299

	replace origin = 	2	if bpl ==	250
	replace origin = 	2	if bpl ==	260

	replace origin = 	3	if bpl ==	300

	replace origin = 	4	if bpl ==	150
	replace origin = 	4	if bpl ==	160
	replace origin = 	4	if bpl ==	400
	replace origin = 	4	if bpl ==	401
	replace origin = 	4	if bpl ==	402
	replace origin = 	4	if bpl ==	404
	replace origin = 	4	if bpl ==	405
	replace origin = 	4	if bpl ==	410
	replace origin = 	4	if bpl ==	411
	replace origin = 	4	if bpl ==	413
	replace origin = 	4	if bpl ==	414
	replace origin = 	4	if bpl ==	420
	replace origin = 	4	if bpl ==	421
	replace origin = 	4	if bpl ==	425
	replace origin = 	4	if bpl ==	426
	replace origin = 	4	if bpl ==	430
	replace origin = 	4	if bpl ==	433
	replace origin = 	4	if bpl ==	434
	replace origin = 	4	if bpl ==	436
	replace origin = 	4	if bpl ==	438
	replace origin = 	4	if bpl ==	450
	replace origin = 	4	if bpl ==	451
	replace origin = 	4	if bpl ==	452
	replace origin = 	4	if bpl ==	453
	replace origin = 	4	if bpl ==	454
	replace origin = 	4	if bpl ==	455
	replace origin = 	4	if bpl ==	456
	replace origin = 	4	if bpl ==	457
	replace origin = 	4	if bpl ==	461
	replace origin = 	4	if bpl ==	462
	replace origin = 	4	if bpl ==	465
	replace origin = 	4	if bpl ==	499
	replace origin = 	4	if bpl ==	700
	replace origin = 	4	if bpl ==	710

	replace origin = 	5	if bpl ==	500
	replace origin = 	5	if bpl ==	501
	replace origin = 	5	if bpl ==	502
	replace origin = 	5	if bpl ==	511
	replace origin = 	5	if bpl ==	512
	replace origin = 	5	if bpl ==	513
	replace origin = 	5	if bpl ==	514
	replace origin = 	5	if bpl ==	515
	replace origin = 	5	if bpl ==	516
	replace origin = 	5	if bpl ==	517
	replace origin = 	5	if bpl ==	518
	replace origin = 	5	if bpl ==	520
	replace origin = 	5	if bpl ==	521
	replace origin = 	5	if bpl ==	522
	replace origin = 	5	if bpl ==	524
	replace origin = 	5	if bpl ==	531
	replace origin = 	5	if bpl ==	532
	replace origin = 	5	if bpl ==	534
	replace origin = 	5	if bpl ==	535
	replace origin = 	5	if bpl ==	536
	replace origin = 	5	if bpl ==	537
	replace origin = 	5	if bpl ==	540
	replace origin = 	5	if bpl ==	541
	replace origin = 	5	if bpl ==	542
	replace origin = 	5	if bpl ==	543
	replace origin = 	5	if bpl ==	544
	replace origin = 	5	if bpl ==	599

	replace origin = 	6	if bpl ==	600

	replace origin = 	7	if bpl ==	950
	
	replace origin = .n if native == 1
	
label define origin	1 "Mexico and Central America" ///
					2 "Caribbean" ///
					3 "South America" ///
					4 "Canada, Europe, or Oceana" ///
					5 "Asia" ///
					6 "Africa" ///
					7 "Other" ///
					.n "US-born"
label val origin origin
label var origin "Country of origin of immigrant" 
label var bpl "Place of birth"
label var bpld "Place of birth (detailed)"


*ENGLISH PROFICIENCY
gen lep = 0
	replace lep = 1 if speak==1 | speak==5 | speak==6 // LimEngProf according to MPI

label define speak	0 "N/A or blank" ///
					1 "Does not speak English" /// 
					2 "Yes, speaks English" ///
					3 "Yes, speaks only English" ///
					4 "Yes, speaks English very well" /// 
					5 "Yes, speaks English well" /// 
					6 "Yes, speaks English but not well" 
label val speak speak 
label var speak "Speaks English"

clonevar speak2 = speak
	recode speak2 (1=1) (6=2) (5=3) (4=4) (3=5) (2=.n) (0=.m) 
	
	label define speak2	1 "Does't speak English" ///
						2 "Yes, speaks English but not well" ///
						3 "Yes, speaks English well" ///
						4 "Yes, speaks English very well" ///
						5 "Yes, speaks only English" ///
						.n "Not in the sample (val == 2)" ///
						.m "N/A or blank"
	label val speak2 speak2
	label var speak2 "Speaks English (recategorized)"

label define lep	1 "Has limited English proficiency" ///
					0 "Doesn't have limited English proficiency" 
label val lep lep
label var lep "Limited English proficiency status"

*EDUCATIONAL ATTAINMENT
gen educm = .
	replace educm = 1 if educd<62
	replace educm = 2 if educd==63 | educd==64
	replace educm = 3 if educd==65 | educd==71 | educd==81
	replace educm = 4 if educd==101
	replace educm = 5 if educd>113 // reduced education cats

label define educm	1 "Less than HS or equivalent" ///
					2 "High school or equivalent degree" ///
					3 "Some college or associate degree" ///
					4 "Bachelor's degree" ///
					5 "Graduate degree"
label val educm educm
label var educm "Educational attainment (5-category variable)"
label var educd "Educational attainment (detailed)"

*YEARS IN THE USA
gen tenure = .
	replace tenure = 1 if yrsusa1<5
	replace tenure = 2 if yrsusa1>4 & yrsusa1<10
	replace tenure = 3 if yrsusa1>9 & yrsusa1<20
	replace tenure = 4 if yrsusa1>19		// # of years in the US
 
label define tenure	1 ">5 years" ///
					2 "5 to 9 years" ///
					3 "10 to 19" ///
					4 "20 or more years"
label val tenure tenure
label var tenure "Year of immigration"
label var yrsusa1 "Years in the US"

*RACE AND ETHNICITY
gen racem = .
	replace racem = 1 if race==1 & hispan==0 | hispan==9
	replace racem = 2 if race==2 & hispan==0 | hispan==9
	replace racem = 3 if (race==4 | race==5 | race==6) & hispan==0 | hispan==9
	replace racem = 5 if race==3
	replace racem = 6 if inlist(race, 8,9)
	replace racem = 7 if race==7
	
	replace racem = 4 if inlist(hispan,1,2,3,4) // Race, overrides hispan

label define racem	1 "NL White" ///
					2 "NL Black" ///
					3 "NL Asian" ///
					4 "Latinx" ///
					5 "Native American or Alaska Native"	///
					6 "Two or more races" ///
					7 "Other undetermined race/ethnicity"
label val racem racem
label var racem "Race/ethnicity reduced cateogories"
label var race "Race"

*GENDER
recode sex (1=0) (2=1)
label define sex	1 "Female" ///
					0 "Male"
label val sex sex
label var sex "Respondent is female"

drop if inlist(bpl, 100,105,110,115,120) // dropping PR and other US territories

gen agef = age <= 25 | age<=54
	label define agef	0 "Not a prime-age worker" ///
						1 "Prime-age worker" 
	label val agef agef 
	label var agef "Prime-age worker indicator"

*defining labforce/employed sample
recode labforce (0=.m) (1=0) (2=1) 
label define labforce	0 "Not in the labor force" ///
						1 "In the labor force" ///
						.m "N/A"
label val labforce labforce
label var labforce "Labor force indicator"

recode farm (0=.m) (1=0) (2=1) 
label define farm	0 "Non-farm" ///
					1 "Farm" ///
					.m "N/A"
label val farm farm
label var farm "Farm indicator"

* using definition from workrise: age 25-54 and employed in the last year 
gen insamp = 1 if empstat == 1 & agef == 1 
	replace insamp = 0 if insamp == .
	
	label define insamp	1 "In sample (employed, aged 25-54)" ///
						0 "Not in sample" 
	label val insamp insamp
	label var insamp "In-sample indicator"
	
*fixing wages
replace incwage = .n if incwage == 999999 
replace incwage = .s if incwage == 999998

gen hwage = incwage/(uhrswork*wkswork1) /* Note that this hwage measure is 
										based on 3 variables:
										1. the annual income from wages/salaries
										2. the usual amount of hours worked per week
										3. the number of weeks worked over the year
										
										Note that ACS collects wage/salaries
										over the past year - so if surveyed in
										August 2019, the wages cover Aug 2018-
										Aug 2019.
										*/			
label var hwage "Pre-tax hourly wage estimated"
label var incwage "Total pre-tax wage and salary income"

*full time part time indicator
gen fulltime = uhrswork >34
label var fulltime "Works full time (35 or more hours usually per week)"
label define fulltime	1 "Works fulltime" ///
						0 "Works part time or less"
label val fulltime fulltime

gen parttime = fulltime == 0	
	label define parttime	1 "Works part-time" ///
							0 "Works full-time" 
	label val parttime parttime 
	label var parttime "Part-time indicator"
	
*final fixes
tab educm, gen(educm)
gen nlep = lep == 0
gen tenure2 = inlist(tenure,3,4)
tab racem, gen(racem)


**KEY VARIABLES**
/*
forvalues i = 1(1)56 {
	capture noisily xtile  q_wage_`i' = hwage if incwage>0 & insamp==1 & statefip==`i' [fw = perwt], n(10)
	}
gen q_wage = .
forvalues i = 1(1)56 {
	capture noisily replace q_wage = q_wage_`i' if q_wage==. & q_wage_`i' !=.
	}
*/ 


*** Updating definition of low wage workers based on https://www.workrisenetwork.org/sites/default/files/2023-10/technical-appendix-who-low-wage-workforce.pdf 

summ hwage if insamp == 1, d

gen mednatwage_lww = r(p50)*(2/3)

gen lww = (hwage < mednatwage_lww)
	replace lww = 0 if insamp == 0 

label define lww	1 "Low-wage worker" ///
					0 "Not a low-wage worker" ///
					.m "Missing information"
label var lww "Low-wage worker indicator"

*drop q_wage_*

*label var q_wage "Wage quintile by state" 
*label var n "Person indicator"

/*note, incwage has 2 non-relevant responses, incwage=999999 & incwage==999998
that stem from non-response and not applicable, respectively. I checked that 
the labor force sample doesn't have any of these values included. All incwages
reported none of these values.
*/

save "${proc}acs1y_2022_full_clean.dta", replace // sample for population estimates
 
 *dropping ages -15 and +64, eyeball, seems to drop evenly across sample years
keep if insamp == 1 

save "${proc}acs1y_2022_employed_clean.dta", replace 
	
*}