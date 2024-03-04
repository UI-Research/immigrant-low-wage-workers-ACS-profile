/*
Project:		Work Rise Immigrant Low Wage Workers (LWW)
Owners:			Hamutal Bernstein, Fernando Hernandez
Date modified:	3/1/2022
Task:			Build out of ACS and CPS files, to desired sample
Notes:

*/

*useful globals
clear all
global proc "C:\Users\fhernandez\Desktop\LWW\Processed files\" // needs to be fixed for each computer
global tab "C:\Users\fhernandez\Desktop\LWW\"
			

clear all
use "${proc}acs1y_2022_full.dta", clear
svyset [pw=perwt]

**BASIC SAMPLE CUTS**

*TAB 1 POPULATION TOTALS
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , replace sheet("Table 1")	

*labels (for guidance)
putexcel	A4 = "Total population" ///
			A5 = "Labor force" ///
			A6 = "Employed" ///
			A7 = "Low-wage workers" ///
			B3 = "US-born (%)" ///
			C3 = "Immigrant (%)" ///
			D3 = "Total" ///
			A9 = "Table 1. Low wage workers by nativity" ///
			A10 = "Source: ACS 2022 1-year estimates microdata" ///
			A11 = "Variables: citizen, empstat, wage" ///
			A12 = "Sample: all the population in all 50 states and DC excluding PR and territories"

*data for totpop numbers
svy: mean native , // total pop
	matrix tpop = e(b) , 1- e(b) , e(N_pop)
svy: mean native if labforce == 1, // labor force
	matrix lpop = e(b) , 1- e(b) , e(N_pop)
svy: mean native if insamp == 1 // employed workers
	matrix epop = e(b) , 1- e(b) , e(N_pop)
svy: mean native if lww == 1, // low-wage employed workers
	matrix lepop = e(b) , 1- e(b) , e(N_pop)
	
	matrix pops = tpop\lpop\epop\lepop
putexcel	B4 = matrix(pops),

*TAB 2 POP TOTALS BY GENDER for LWIW
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 2")	

*labels (for guidance)
putexcel	A4 = "Total immigrants" ///
			A5 = "Immigrants in the labor force" ///
			A6 = "Immigrant and employed" ///
			A7 = "Low-wage immigrant workers" ///
			B3 = "Male (%)" ///
			C3 = "Female (%)" ///
			D3 = "Total" ///
			A9 = "Table 2. Low wage workers by nativity and gender" ///
			A10 = "Source: ACS 2022 1-year estimates microdata" ///
			A11 = "Variables: citizen, labforce, empstat, wage" ///
			A12 = "Sample: population in all 50 states and DC, excluding PR and territories"

*data for totpop numbers
svy: mean sex if native == 0, // total pop
	matrix tipop = e(b) , 1- e(b) , e(N_pop)
svy: mean sex if native == 0 & labforce == 1, // labor force
	matrix lipop = e(b) , 1- e(b) , e(N_pop)
svy: mean sex if native == 0 & insamp==1 , // employed workers
	matrix eipop = e(b) , 1- e(b) , e(N_pop)
svy: mean sex if native == 0 & lww == 1, // low-wage employed workers
	matrix leipop = e(b) , 1- e(b) , e(N_pop)
	
matrix ipops = tipop\lipop\eipop\leipop

putexcel	B4 = matrix(ipops),
		
clear all
use "${proc}acs1y_2022_employed.dta", clear
svyset [pw=perwt]
					
*TAB 3 GEOGRAPHIC DISTRIBUTION OF IMMIGRANT LOW-WAGE WORKERS
svy: mean immigrant if lww==1 , over(statefip) 
	matrix statelwiw = (e(b)')\e(N_pop)
	matrix rownames statelwiw  = "Alabama" "Alaska" "Arizona" "Arkansas" ///
		"California" "Colorado" "Connecticut" "Delaware" "District of Columbia" ///
		"Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" ///
		"Kansas" "Kentucky" "Louisiana" "Maine" "Maryland" "Massachusetts" ///
		"Michigan" "Minnesota" "Mississippi" "Missouri" "Montana" "Nebraska" ///
		"Nevada" "New Hampshire" "New Jersey" "New Mexico" "New York" ///
		"North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" ///
		"Pennsylvania" "Rhode Island" "South Carolina" "South Dakota" ///
		"Tennessee" "Texas" "Utah" "Vermont" "Virginia" "Washington" ///
		"West Virginia" "Wisconsin" "Wyoming" "Total"
	
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 3")

putexcel	A4 = matrix(statelwiw) , names

putexcel	A4 = "State" ///
			B4 = "Share of low-wage workers who are immigrants, by state" ///
			A57 = "Table 3. Geographic distribution of immigrant low-wage workers" ///
			A58 = "Source: ACS 2022 1-year estimates microdata" ///
			A59 = "Variables: citizen, insamp, statefip, wage" ///
			A60 = "Sample: age 15-64 years old and is employed" ,
			

			
*TAB 4 REGIONS AND COUNTRIES OF ORIGIN OF LOW-WAGE IMMIGRANT WORKERS
tab origin if native==0 & lww==1  [fw=perwt], matcell(origN) matrow(origlabs)
	matrix origtot = r(N)
	scalar origt = r(N)
	matrix origsh = origlabs,(origN/origt)
	
forvalues i = 1(1)6 {
	scalar origNd`i' = origN[`i',1]
	
	tab bpld if native==0 & lww==1 & origin == `i'  [fw=perwt], sort matcell(origd`i')  matrow(origlabs`i')
	capture noisily matrix origshd`i' = (origd`i'/origNd`i')
	capture noisily matrix origd`i' = origlabs`i',(origd`i'/origNd`i')
}

matrix origlww =	origsh[1,1..2]\origd1[1..3,1..2]\ ///
					origsh[5,1..2]\origd5[1..3,1..2]\ ///
					origsh[2,1..2]\origd2[1..3,1..2]\ ///
					origsh[3,1..2]\origd3[1..3,1..2]\ ///
					origsh[4,1..2]\origd4[1..3,1..2]\ ///
					origsh[6,1..2]\origd6[1..3,1..2]
				
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 4")
	putexcel	A3 = "Region and top 3 countries within region" ///
				B3 = "Share of low-wage immigrant workers by region and top three major countries of origin within each region" ///
				A30 = "Table 4. Regions and countries of origin of low-wage immigrant workers" ///
				A31 = "Source: ACS 2022 1-year estimates microdata" ///
				A32 = "Variables: bpld, insamp, wage" ///
				A33 = "Sample: population age 16-64 years old and is employed"	
	putexcel	A4 = matrix(origlww)
	
*TAB 5 NATIVITY BREAKDOWN OF RACIAL/ETHNIC GROUPS
forvalues r = 1(1)7 {
	svy: mean immigrant if lww==1 & racem==`r'
		matrix natr`r' =  e(b) , 1 - e(b) 
}
	matrix natr = natr1 \ natr2 \ natr3 \ natr4 \ natr5 \ natr6 \ natr6 
	
	matrix rownames natr = "NL-White" "NL-Black" "NL-Asian" "Latinx" ///
		"NA-AN" "2+Race" "Other" 
	matrix colnames natr = "Immigrant" "US-born"
	
	matsort natr 2 // sorts the matrix according to col2
	
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 5")
	putexcel	A13 = "Table 5. Nativity breakdown of racial/ethnic groups" ///
				A14 = "Source: ACS 2022 1-year estimates microdata" ///
				A15 = "Variables: citizen, insamp, race, wage" ///
				A16 = "Sample: age 15-64 years old and is employed"
				
	putexcel	A4 = matrix(natr)	, names
		
*TAB 6 RACE/ETHNICITY OF IMMIGRANT AND US-BORN LOW-WAGE WORKERS
svy: tab racem if native == 1 // all US born workers
	matrix racelwwd1 = e(b), e(N_pop)
	
svy: tab racem if native == 1 & lww ==1 // USB LWW 
	matrix racelwwd2 = e(b), e(N_pop)
	
svy: tab racem if native == 0 // immigrant workers 
	matrix racelwwd3 = e(b), e(N_pop)
	
svy: tab racem if native == 0 & lww ==1 // ILWW
	matrix racelwwd4 = e(b), e(N_pop)
	
matrix racelwwd = racelwwd1\racelwwd2\racelwwd3\racelwwd4
	
matrix colnames racelwwd = "NL White" "NL Black" "NL Asian" "Latinx" ///
		"Native American or Alaska Native" "Two or more races" ///
		"Other undetermined" "Total"
matrix rownames racelwwd = "All US-born workers" "LW US-born workers" ///
		"All immigrant workers" "LW immigrant workers"
		
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 6")
	putexcel	A10 = "Table 6. Race/ethnicity of immigrant and US-born low-wage workers" ///
				A11 = "Source: ACS 2022 1-year estimates microdata" ///
				A12 = "Variables: citizen, insamp, race, wage" ///
				A13 = "Sample: age 15-64 years old and is employed"
				
	putexcel	A4 = matrix(racelwwd)	, names
	
*TAB 7 RACE/ETHNICITY OF IMMIGRANT AND US-BORN LOW-WAGE WORKERS, BY GENDER
svy: tab racem if native == 1 & lww ==1 // all USB LWW 
	matrix racelwwd1 = e(b), e(N_pop)

svy: tab racem if native == 1 & lww ==1 & sex == 1 // USB LWW FEM 
	matrix racelwwd2 = e(b), e(N_pop)

svy: tab racem if native == 1 & lww ==1 & sex == 0 // USB LWW MALE 
	matrix racelwwd3 = e(b), e(N_pop)

svy: tab racem if native == 0 & lww ==1 // ILWW
	matrix racelwwd4 = e(b), e(N_pop)

svy: tab racem if native == 0 & lww ==1 & sex == 1 // ILWW FEM 
	matrix racelwwd5 = e(b), e(N_pop)

svy: tab racem if native == 0 & lww ==1 & sex == 0 // ILWW MALE
	matrix racelwwd6 = e(b), e(N_pop)
	
matrix racelwwd = racelwwd1\racelwwd2\racelwwd3\racelwwd4\racelwwd5\racelwwd6
	
matrix colnames racelwwd = "NL White" "NL Black" "NL Asian" "Latinx" ///
		"Native American or Alaska Native" "Two or more races" ///
		"Other undetermined" "Total"
matrix rownames racelwwd = "All US-born LW workers" "Female US-born LW workers" ///
		"Male US-born LW workers" "All immigrant LW workers" ///
		"Female immigrant LW workers" "Male immigrant LW workers"
		
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 7")
	putexcel	A12 = "Table 7. Race/ethnicity of immigrant and US-born low-wage workers, by gender" ///
				A13 = "Source: ACS 2022 1-year estimates microdata" ///
				A14 = "Variables: citizen, insamp, race, wage, sex" ///
				A15 = "Sample: age 15-64 years old and is a low-wage worker"
				
	putexcel	A4 = matrix(racelwwd)	, names
	

*TAB 8 ENGLISH PROFICIENCY
svy: tab speak2  if native==0 // all immworkers
	matrix seng1 = e(b),e(N_pop)

svy: tab speak2  if native==0 & lww == 0 // immigrant non-lw workers 
	matrix seng2 = e(b), e(N_pop)	
	
svy: tab speak2  if native==0 & lww == 1 // immigrant LWW 
	matrix seng3 = e(b), e(N_pop)	
	
	matrix seng = seng1\seng2\seng3
	matrix rownames seng = "All immigrant workers" "Immigrant non-low-wage worker" ///
		"Immigrant low-wage worker" 
	matrix colnames seng = "Does't speak English" "Yes, speaks English but not well" ///
		"Yes, speaks English well" "Yes, speaks English very well" ///
		"Yes, speaks only English" "Total"

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 8")
	putexcel	A9 = "Table 8. English proficiency" ///
				A10 = "Source: ACS 2022 1-year estimates microdata" ///
				A11 = "Variables: citizen, insamp, speakeng, wage" ///
				A12 = "Sample: population age 16-64 years old and is an immigrant worker"	
				
	putexcel	A4 = matrix(seng) , names

*TAB 9 YEARS IN THE US	
svy: tab tenure if native==0 & insamp==1 // all IW
	matrix yrslvus1 = e(b), e(N_pop)
svy: tab tenure if native==0 & lww==0 // all nLWIW
	matrix yrslvus2 = e(b), e(N_pop)
svy: tab tenure if native==0 & lww==1 // all LWIW
	matrix yrslvus3 = e(b), e(N_pop)
	
	matrix yrslvus = yrslvus1\yrslvus2\yrslvus3
	matrix rownames yrslvus = "All immigrant workers" "Non-low-wage immigrant workers" ///
		"Low-wage immigrant workers" 
	matrix colnames yrslvus = "Less than 5 years" "5 to 9 years" "10 to 19" ///
		"20 or more years" "Total" 

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 9")
	putexcel	A9 = "Table 9. Tears in the US" ///
				A10 = "Source: ACS 2022 1-year estimates microdata" ///
				A11 = "Variables: citizen, insamp, yrimmig, yrusa1, yrnatur, wage" ///
				A12 = "Sample: age 15-64 years old and is an immigrant worker"

	putexcel	A4 = matrix(yrslvus) , names

*TAB 10 NATURALIZATION STATUS
svy: tab naturalized if native==0  // all IW
	matrix natstat1= e(b)[1,2],e(b)[1,1], e(N_pop)
svy: tab naturalized if native==0 & lww==0 // all nILWW
	matrix natstat2= e(b)[1,2],e(b)[1,1], e(N_pop)
svy: tab naturalized if native==0 & lww==1 // all LWIW
	matrix natstat3= e(b)[1,2],e(b)[1,1], e(N_pop)

	matrix natstat = natstat1\natstat2\natstat3
	matrix rownames natstat = "All immigrant workers" "Non-low-wage immigrant workers" ///
		"Low-wage immigrant workers" 
	matrix colnames natstat = "Naturalized citizen" "Non-citizen" "Total" 

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 10")
	putexcel	A9 = "Table 10. Naturalization status of immigrant workers" ///
				A10 = "Source: ACS 2022 1-year estimates microdata" ///
				A11 = "Variables: citizen, insamp, yrimmig, yrusa1, yrnatur, wage" ///
				A12 = "Sample: age 15-64 years old and is an immigrant worker"

	putexcel	A4 = matrix(natstat), names


*TAB 11 EDUCATIONAL ATTAINMENT
svy: tab educm if native == 1 // US workers
	matrix educ1 = e(b),e(N_pop)
svy: tab educm if lww == 1 & native == 1  // US lww
	matrix educ2 = e(b), e(N_pop)
svy: tab educm if native==0 // IW
	matrix educ3 = e(b),  e(N_pop)
svy: tab educm if native==0 & lww==1 // LWIW
	matrix educ4 = e(b), e(N_pop)
	
	matrix educ = educ1\educ2\educ3\educ4
	matrix rownames educ = "US-born workers" "US-born low-wage workers" ///
		"Immigrant workers" "Immigrant low-wage worker"
	matrix colnames educ = "Less than high school" "High school or equivalent" ///
		"Some college education" "Bachelor degree" "Graduate degree" "Total"

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 11")

putexcel	A10 = "Table 11. Educational attainment of low wage workers" ///
			A11 = "Source: ACS 2022 `y'-year estimates microdata" ///
			A12 = "Variables: citizen, insamp, educ (detailed coding), wage" ///
			A13 = "Sample: population age 16-64 years old and employed"	
		
putexcel	A4 = matrix(educ) , names

*TAB 12 EDUCATIONAL ATTAINMENT, BY GENDER
svy: tab educm if lww == 1 & native == 1  // US lww
	matrix educs1 = e(b), e(N_pop)
svy: tab educm if lww == 1 & native == 1 & sex == 1 // US lww female
	matrix educs2 = e(b), e(N_pop)
svy: tab educm if lww == 1 & native == 1 & sex == 0 // US lww male
	matrix educs3 = e(b), e(N_pop)
svy: tab educm if native==0 & lww==1 // LWIW
	matrix educs4 = e(b), e(N_pop)
svy: tab educm if native==0 & lww==1 & sex == 1 // LWIW female 
	matrix educs5 = e(b), e(N_pop)
svy: tab educm if native==0 & lww==1 & sex == 0 // LWIW male
	matrix educs6 = e(b), e(N_pop)
	
	matrix educs = educs1\educs2\educs3\educs4\educs5\educs6

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 12")

putexcel	B4 = matrix(educs)

putexcel	A4 = "All US-born LW workers" ///
			A5 = "Female US-born LW workers" ///
			A6 = "Male US-born LW workers" ///
			A7 = "All immigrant LW workers" ///
			A8 = "Female immigrant LW workers" ///
			A9 = "Male immigrant LW workers" ///
			B3 = "Less than high school" ///
			C3 = "High school or equivalent" ///
			D3 = "Some college education" ///
			E3 = "Bachelor degree" ///
			F3 = "Graduate degree" ///
			G3 = "Total" ///
			A11 = "Table 12. Educational attainment of low wage workers, by gender" ///
			A12 = "Source: ACS 2022 `y'-year estimates microdata" ///
			A13 = "Variables: citizen, insamp, educ (detailed coding), wage" ///
			A14 = "Sample: population age 16-64 years old and employed"	

*TAB 13 Field of study for college and graduate degree holders in low-wage immigrant workforce
tab degfield if educm>3 & native==0 & lww==1 [fw=perwt], sort matcell(deg) matrow(deglab)
	scalar define degt = r(N)
	matrix degc = (deg/degt)
	matrix degs = degc[1..10,1]
	matrix deglabc = deglab[1..10,1]
	matrix degs = deglabc,degs
	

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 13")
	putexcel	A4 = matrix(degs) ///
				B14 = matrix(degt)
	putexcel	A3 = "Degree codes" ///
				B3 = "Fields of degrees obtained by low-wage immigrant workers who completed a college or graduate degree" ///
				A14 = "Total" ///
				A16 = "Table 13. Fields of degrees obtained by low-wage immigrant workers who completed a college or graduate degree" ///
				A17 = "Source: ACS 2022 1-year estimates microdata" ///
				A18 = "Variables: citizen, insamp, educ (detailed coding), degfield, wage" ///
				A19 = "Sample: population age 16-64 years old, employed low-wage workers who completed a college or graduate degree"	
			

*TAB 14 Field of study for college and graduate degree holders in low-wage immigrant workforce by gender
tab degfield if educm>3 & native==0 & lww==1 & sex == 0 [fw=perwt], sort matcell(mdeg) matrow(mdeglab) // immigrant LWW male
	scalar define mdegt = r(N)
	matrix mdegc = (mdeg/mdegt)
	matrix mdegs = mdegc[1..10,1]
	matrix mdeglabc = mdeglab[1..10,1] 
	matrix mdegs = mdeglabc,mdegs
	
tab degfield if educm>3 & native==0 & lww==1 & sex == 1 [fw=perwt], sort matcell(fdeg) matrow(fdeglab) // immigrant LWW female
	scalar define fdegt = r(N)
	matrix fdegc = (fdeg/fdegt)
	matrix fdegs = fdegc[1..10,1]
	matrix fdeglabc = fdeglab[1..10,1] 
	matrix fdegs = fdeglabc,fdegs
	
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 14")
	putexcel	A4 = matrix(mdegs) ///
				B14 = matrix(mdegt) ///
				E4 = matrix(fdegs) ///
				F14 = matrix(fdegt) 
				
	putexcel	A3 = "Degree codes for male immigrant LWW" ///
				B3 = "Fields of degrees obtained by male low-wage immigrant workers who completed a college or graduate degree" ///
				A14 = "Total" ///
				E3 = "Degree codes for female LWIW" ///
				F3 = "Fields of degrees obtained by male low-wage immigrant workers who completed a college or graduate degree" ///
				E14 = "Total" ///
				A16 = "Tables 14.1 and 14.2 Fields of degrees obtained by low-wage immigrant workers who completed a college or graduate degree, by gender" ///
				A17 = "Source: ACS 2022 1-year estimates microdata" ///
				A18 = "Variables: citizen, insamp, educ (detailed coding), degfield, wage" ///
				A19 = "Sample: population age 16-64 years old, employed low-wage workers who completed a college or graduate degree"

*TAB 15 TOP OCCUPATIONS OF LOW-WAGE WORKERS, BY NATIVITY
tab occ if native == 1 & lww == 1 [fw = perwt] , label sort matcell(occlww1) matrow(olwwlab1) // US-born 
	scalar occlwwt1 = r(N)
	matrix occlww1 = occlww1[1..10,1]/occlwwt1 \ r(N)
	matrix occlwwlab1 = olwwlab1[1..10,1]
tab occ if native == 0 & lww == 1 [fw = perwt] , label sort matcell(occlww2) matrow(olwwlab2) // immigrant
	scalar occlwwt2 = r(N)
	matrix occlww2 = occlww2[1..10,1]/occlwwt2 \ r(N)
	matrix occlwwlab2 = olwwlab2[1..10,1]
	
	
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 15")
	putexcel	A4 = matrix(occlwwlab1) ///
				D4 = matrix(occlwwlab2) ///
				B4 = matrix(occlww1) ///
				E4 = matrix(occlww2)
	
	putexcel	B3 = "Top 10 occupations of US-born low-wage workers" ///
				E3 = "Top 10 occupations of immigrant low-wage workers" ///
				A14 = "Total" ///
				D14 = "Total" ///
				A16 = "Table 15. Top 10 occupations of US-born low-wage workers (left) and immigrant low-wage workers (right)" ///
				A17 = "Source: ACS 2022 1-year estimates microdata" ///
				A18 = "Variables: citizen, insamp, educ (detailed coding), degfield, wage" ///
				A19 = "Sample: population age 16-64 years old, employed low-wage workers"	

*TAB 16 FULLTIME PARTTIME BY SEX AND NATIVITY
	svy: mean fulltime if native == 1 & lww==1 & sex ==0 , // US born male lww 
		matrix ft1 = e(b), 1 - e(b), e(N_pop)
	svy: mean fulltime if native == 1 & lww==1 & sex ==1 // US born female lww
		matrix ft2 = e(b), 1 - e(b), e(N_pop)
	svy: mean fulltime if native == 0 & lww==1 & sex ==0 , // immigrant born male lww 
		matrix ft3 = e(b), 1 - e(b), e(N_pop)
	svy: mean fulltime if native == 0 & lww==1 & sex ==1 // immigrant born female lww
		matrix ft4 = e(b), 1 - e(b), e(N_pop)
		
	matrix fullpart = ft1\ft2\ft3\ft4
	matrix rownames fullpart = "US-born: Male LWW" "Female LWW" "Immigrant: Male LWW" "Female LWW"
	matrix colnames fullpart = "Full-time (%)" "Part-time (%)"

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 16")	
	putexcel	A4 = matrix(fullpart), names
	
	putexcel	A10 = "Table 16. Full-time and part-time US-born and immigrant low-wage workers, by gender" ///
				A11 = "Source: ACS 2022 1-year estimates microdata" ///
				A12 = "Variables: citizen, insamp, educ (detailed coding), degfield, wage" ///
				A13 = "Sample: population age 16-64 years old, employed low-wage workers"	


*TAB 17 OCCUPATION ANALYSIS: IMMIGRANT DENSE OCCUPATIONS
*identifying top 25 occupations with the most immigrant 
tab occ if lww == 1 & native == 0 [fw = perwt] , label sort matcell(occ) matrow(occlabf) // all immigrant lw workers
	scalar occt = r(N)
	matrix occ = (occ[1..25,1]/occt)
	matrix occlab = occlabf[1..25,1]
	
	svy: total n if native == 0  & lww == 1 
		matrix occn = e(N_pop)

	svy: mean immigrant if lww == 1 
		matrix occsh = e(b)
	
	sum hwage if native == 0  & lww == 1  [fw = perwt], d
		matrix mwage = r(p50)

	svy: mean educm1 if native == 0  & lww == 1 
		matrix educm1 = e(b)

	svy: mean nlep if native == 0  & lww == 1 
		matrix nlep = e(b)

	svy: mean tenure2 if native == 0  & lww == 1 
		matrix ten2 = e(b)
	
	svy: mean naturalized if native == 0  & lww == 1 
		matrix nat = e(b)
	
	forvalues r = 1(1)4 {
		svy: mean racem`r' if native == 0  & lww == 1 
			matrix racem`r' = e(b)		
		}

	svy: mean sex if native == 0  & lww == 1 
		matrix sexs = e(b)		

	svy: mean parttime if native == 0  & lww == 1 
		matrix pts = e(b)		
		
	matrix ilww = (occsh\occn\mwage\pts\educm1\nlep\ten2\nat\racem1\racem2\racem3\racem4\sexs)'

	
	forvalues o = 1(1)25 {
		
		svy: total n if native == 0  & lww == 1 & occ == occlab[`o',1]
			matrix occn`o' = e(N_pop)

		svy: mean immigrant if lww == 1 &  occ == occlab[`o',1]
			matrix occsh`o' = e(b)
			
		sum hwage if native == 0  & lww == 1 &  occ == occlab[`o',1] [fw = perwt], d
			matrix mwage`o' = r(p50)
		
		svy: mean educm1 if native == 0  & lww == 1 &  occ == occlab[`o',1]
			matrix educm`o' = e(b)
		
		svy: mean nlep if native == 0  & lww == 1 & occ == occlab[`o',1]
			matrix nlep`o' = e(b)
		
		svy: mean tenure2 if native == 0  & lww == 1 & occ == occlab[`o',1]
			matrix ten2`o' = e(b)
			
		svy: mean naturalized if native == 0  & lww == 1 & occ == occlab[`o',1]
			matrix nat`o' = e(b)
			
		forvalues r = 1(1)4 {
			svy: mean racem`r' if native == 0  & lww == 1 & occ == occlab[`o',1]
				matrix racem`r'_`o' = e(b)			
				}
			
		svy: mean sex if native == 0  & lww == 1 & occ == occlab[`o',1]
			matrix sex`o' = e(b)		
			
		svy: mean parttime if native == 0  & lww == 1 & occ == occlab[`o',1]
			matrix pts`o' = e(b)
		
		}

putexcel set "${tab}Tables and Graphs acs1y 2022 OCC table_$S_DATE.xlsx" , replace sheet("Table 17 OCCS_all")

	putexcel	A3 = "Occupational code" ///
				B3 = "Occupation" ///
				B4 = "All immigrant low-wage workers" ///
				C3 = "Immigrant share" ///
				D3 = "N low-wage immigrant workers (weighted)" ///
				E3 = "Median hourly wages" ///
				F3 = "Part-time" ///
				G3 = "Less than HS degree" ///
				H3 = "English proficient" ///
				I3 = "10+ years in the US" ///
				J3 = "Naturalized" ///
				K3 = "NL-white, only" ///
				L3 = "NL-Black, only" ///
				M3 = "NL-Asian, only" /// 
				N3 = "Latinx" ///
				O3 = "Female" 
 
	putexcel	A5 = matrix(occlab) ///
				C4 = matrix(ilww)

forvalues i = 1(1)25 {
	
	local j = 4+`i'
	foreach l of local j {
		putexcel	C`l' = matrix(occsh`i') ///
					D`l' = matrix(occn`i') ///
					E`l' = matrix(mwage`i') ///
					F`l' = matrix(educm`i') ///
					G`l' = matrix(pts`i') ///
					H`l' = matrix(nlep`i') ///
					I`l' = matrix(ten2`i') ///
					J`l' = matrix(nat`i') ///
					K`l' = matrix(racem1_`i') ///
					L`l' = matrix(racem2_`i') ///
					M`l' = matrix(racem3_`i') ///
					N`l' = matrix(racem4_`i') ///
					O`l' = matrix(sex`i')
			}
	}

clear all
use "${proc}acs1y_2022_employed.dta", clear
*identifying top occupations with most immigrant sorted by share of female workers
	*step 1: total immigrants
	preserve 
		collapse	(sum) n ///
					(p50) hwage ///
					(mean) educm1 nlep tenure2 naturalized racem1 racem2 racem3 ///
						racem4 sex parttime ///
					[fw = perwt] if native == 0 & lww == 1, by(occ)
		
		save "${proc}collapse occ femtable.dta", replace 
	restore 
	
	collapse (mean) naturalized [fw = perwt] if lww == 1, by(occ)
	merge 1:1 occ using "${proc}collapse occ femtable.dta"
	keep if _merge == 3
	drop _merge 
	order occ n naturalized sex
	gsort -n -sex
	
	export excel using "${tab}Female dense occupations of ILWW_$S_DATE.xlsx" ///
		in 1/25, sheet("FEM OCC TAB") sheetmodify firstrow(variables) 

