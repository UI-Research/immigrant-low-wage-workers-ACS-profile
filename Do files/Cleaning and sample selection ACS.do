/*
Project:		Work Rise Immigrant Low Wage Workers (LWW)
Owners:			Hamutal Bernstein, Fernando Hernandez
Date modified:	8/6/2024
Task:			Build out of ACS sample
Notes:
*/

*1. ACS DATA: 1-year estimates 
*setting up useful globals:
clear all
global proc "C:\Users\fhernandez\Desktop\LWW\Processed files\" // needs to be fixed for each computer
global save "C:\Users\fhernandez\Desktop\LWW\Processed files\Stata output\" // needs to be fixed for each computer

**ANALYST RUNS THIS THE FIRST TIME TO PULL THE EXTRACT**

*import delimited "${proc}ACS 2023 1-year estimates IPUMS_Aug 6 2024.csv"
*save "${save}ACS 2023 1-year estimates IPUMS_${S_DATE}", replace // sample for population estimates within age range
clear all


*forvalues k = 1(1)2 {

use "${save}ACS 2023 1-year estimates IPUMS_ 7 Aug 2024.dta", clear // latest data

*basics
count		
gen n = 1

**STATE FIP INDICATOR
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

	*generating a variable with state names to use for labeling later
	decode statefip, gen(state_name)

**CITIZENSHIP AND NATIVITY

gen usborn = citizen==0 | citizen == 1 // IDs citizens
	replace usborn = 1 if bpl == 100 | bpl == 105 | bpl == 110 | bpl == 115 | bpl == 120
		// IDs citizens (the ACS considers people from PR and UST as citizens in the data)

gen naturalized = citizen==2 // IDs nat citizens (sample of non-US born only)
	replace naturalized = .n if usborn == 1 // removing US-born from universe of question

	label define citizen	0 "US-born" ///
							1 "Born abroad of US parents" ///
							2 "Naturalized citizen" ///
							3 "Not a naturalized citizen" 
		label val citizen citizen
		label var citizen "Citizenship status"

	label define usborn	1 "US-born (or born abroad to US parents)" ///
						0 "Immigrant"
		label val usborn usborn
		label var usborn "US-born or immigrant"

	label define naturalized	1 "Naturalized US-citizen (immigrant)" ///
								0 "Not a naturalized US-citizen" ///
								.n "US-born (not in sample)"
	label val naturalized naturalized
	label var naturalized "Naturalization status of immigrant"

gen immigrant = usborn == 0 // immigrant person (non-US born)
	label var immigrant "Person is immigrant (not US-born)"
	label define immigrant	1 "Yes, immigrant" ///
							0 "No, US-born" 
	label val immigrant immigrant
	
gen origin = .									// codes origin according to MPI, please edit if you know a better way!
	replace origin = 	1	if bpl ==	200 // Mexico and central america
	replace origin = 	1	if bpl ==	210 
	replace origin = 	1	if bpl ==	299

	replace origin = 	2	if bpl ==	250 // 
	replace origin = 	2	if bpl ==	260

	replace origin = 	3	if bpl ==	300

	replace origin = 	4	if bpl ==	150 // Canada, Europe, and Oceania
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

	replace origin = 	5	if bpl ==	500 // Asia 
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

	replace origin = 	6	if bpl ==	600 // Africa 

	replace origin = 	7	if bpl ==	950 // Other NEC
	
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

**ENGLISH PROFICIENCY
gen lep = 0
	replace lep = 1 if speakeng==1 | speakeng==5 | speakeng==6 // LEP from MPI
	replace lep = .m if speakeng == 0

clonevar speakeng2 = speakeng
	recode speakeng2	(1=1) (6=2) (5=3) (4=4) (3=5) (0=.m)
	
label define speakeng	0 "N/A or blank" ///
						1 "Does not speak English" /// 
						3 "Yes, speaks only English" ///
						4 "Yes, speaks English very well" /// 
						5 "Yes, speaks English well" ///
						6 "Yes, speaks English but not well" ///
						
label define speakeng2	1 "Does not speak English" /// 
						2 "Yes, speaks English but not well" ///
						3 "Yes, speaks English well" ///
						4 "Yes, speaks English very well" /// 
						5 "Yes, speaks only English" ///
						.m "N/A or blank"
						
	label val speakeng speakeng 
	label val speakeng2 speakeng2 
	label var speakeng "English proficiency"
	label var speakeng2 "English proficiency (recode)"

label define lep	1 "Has limited English proficiency" ///
					0 "Has English proficiency" 
	label val lep lep
	label var lep "Has limited English proficiency"

**EDUCATIONAL ATTAINMENT
gen educm = .m
	replace educm = 1 if educd<62
	replace educm = 2 if educd==63 | educd==64
	replace educm = 3 if educd==65 | educd==71 | educd==81
	replace educm = 4 if educd==101
	replace educm = 5 if educd>113 // reduced education cats

label define educm	1 "Less than HS or equivalent" ///
					2 "High school or equivalent degree" ///
					3 "Some college or associate degree" ///
					4 "Bachelor's degree" ///
					5 "Graduate degree" ///
					.m "Missing information"
	label val educm educm
	label var educm "Educational attainment (5-category variable)"
	label var educd "Educational attainment (detailed)"

tab educm educd,m 

**YEARS IN THE USA
gen yearsusa = .m
	replace yearsusa = 1 if yrsusa1<5
	replace yearsusa = 2 if yrsusa1>4 & yrsusa1<10
	replace yearsusa = 3 if yrsusa1>9 & yrsusa1<20
	replace yearsusa = 4 if yrsusa1>19		// # of years in the US
	replace yearsusa = .n if native == 1
label define yearsusa	1 ">5 years" ///
						2 "5 to 9 years" ///
						3 "10 to 19" ///
						4 "20 or more years" ///
						.n "NIS: US-born"
	label val yearsusa yearsusa
	label var yearsusa "Number of years in the US (category)"
	label var yrsusa1 "Number of years in the US"

**RACE AND ETHNICITY
gen racem = .m
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

**GENDER
recode sex (1=0) (2=1) (9=.m)
label define sex	1 "Female" ///
					0 "Male"
	label val sex sex
	label var sex "Respondent is female"

drop if inlist(bpl, 100,105,110,115,120) // dropping PR and other US territories


**LABORFORCE VARIABLES
*defining labforce/employed sample
recode labforce (0=.m) (1=0) (2=1) 
	label define labforce	0 "Not in the labor force" ///
							1 "In the labor force" ///
							.m "N/A"
	label val labforce labforce
	label var labforce "Labor force indicator"

recode farm (0=.m) (1=0) (2=1) 
	label define farm	0 "Non-farm household" ///
						1 "Farm household" ///
						.m "N/A"
	label val farm farm
	label var farm "Farm household indicator"

**SAMPLE MARKERS 

/* from workrise 

Our sample of low-wage workers is made up of individuals ages 25–54, what 
economists refer to as prime-age workers, in the labor force who were employed 
at some point during the prior year. The sample includes both full- and 
part-time workers.

*/

**WAGE CONSTRUCTION
*fixing wages
replace incwage = .n if incwage == 999999 // coded as not in sample 
replace incwage = .s if incwage == 999998
replace incwage = .m if incwage == 0 // data quality issue, there were about 150 zeros in incwage

gen hwage = incwage/(uhrswork*wkswork1) 
	replace hwage = .c if classwkr == 1	

	label var hwage "Pre-tax hourly wage estimated"
	label var incwage "Total pre-tax wage and salary income"
	label var uhrswork "Usual number of hours worked in the past 12 months" 
	label var wkswork1 "Weeks worked in the last 12 months"		
	
**LABORFORCE PRIME AGE
gen primeagelf = age >= 25 & age<=54
	label define primeagelf	0 "Not a prime-age worker" ///
							1 "Prime-age worker" 
	label val primeagelf primeagelf 
	label var primeagelf "Prime-age worker indicator"

*worked at some point during the prior year 
gen worked = .m 
	replace worked = 1 if wkswork1 >0 
	replace worked = 0 if wkswork1 ==0
	
	label define worked	1 "Worked at least 1 week" ///
						0 "Didn't work any weeks" ///
						.m "N/A"
	label val worked worked 
	label var worked "Worked at least 1 week in the past 12 months" // calendar year

gen insamp = .m 
	replace insamp = 1 if worked == 1 & primeagelf == 1 
	replace insamp = 0 if worked == 0 | primeagelf == 0
	replace insamp = 0 if classwkr == 1
	
	label define insamp	1 "In sample" ///
						0 "Not in sample" ///
						.m "N/A"
	label val insamp insamp
	label var insamp "In-sample indicator (worked, aged 25-54)"
	
	
*full time part time indicator
gen fulltime = uhrswork >34
	label var fulltime "Works full time (35 or more hours usually per week)"
	label define fulltime	1 "Works fulltime" ///
							0 "Works part time or less"
	label val fulltime fulltime

gen parttime = fulltime == 0
	label var parttime "Works part time (usually less than 35 per week)"
	label define parttime	1 "Works part time" ///
							0 "Works full time"
	label val parttime parttime

*final fixes
tab educm, gen(educm)
gen nlep = lep == 0
gen yearsusa2 = inlist(yearsusa,3,4)
tab racem, gen(racem)


*** Definition of low wage workers based on https://www.workrisenetwork.org/sites/default/files/2023-10/technical-appendix-who-low-wage-workforce.pdf 
summ hwage if insamp == 1 , d

gen mednatwage_lww = r(p50)*(2/3)

gen lww = (hwage <= mednatwage_lww)
	replace lww = 0 if insamp == 0 

label define lww	1 "Low-wage worker" ///
					0 "Not a low-wage worker" ///
					.m "Missing information"
label var lww "Low-wage worker indicator"

save "${proc}acs1y_2023_full_clean_${S_DATE}.dta", replace // sample for population estimates
 
 *dropping ages -15 and +64, eyeball, seems to drop evenly across sample years
keep if insamp == 1 

save "${proc}acs1y_2023_employed_clean_${S_DATE}.dta", replace 
