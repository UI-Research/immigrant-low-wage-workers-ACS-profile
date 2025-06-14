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
*use "${proc}acs1y_2022_full_clean_${S_DATE}.dta", clear
use "${proc}acs1y_2022_full_clean_13 Aug 2024.dta", clear
svyset [pw=perwt]

**LW CUTOFF
sum hwage if lww==1 [w=perwt]

**BASIC SAMPLE CUTS**
*TAB 1 POPULATION TOTALS
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , replace sheet("Table 1")	

*labels (for guidance)
putexcel	A4 = "Total population" ///
			A5 = "Workforce (prime age, worked in the past 12 months)" ///
			A6 = "Low-wage prime-age workers" ///
			B3 = "US-born (%)" ///
			C3 = "Immigrant (%)" ///
			D3 = "Total" ///
			A9 = "Table 1. Low wage workers by nativity" 

*data for totpop numbers
svy: mean usborn , // total pop
	matrix tpop = e(b) , 1- e(b) , e(N_pop)
svy: mean usborn if insamp == 1, // the the prime-age workforce
	matrix wforce = e(b) , 1- e(b) , e(N_pop)
svy: mean usborn if lww == 1 & insamp==1, // low-wage employed workers
	matrix lwwoop = e(b) , 1- e(b) , e(N_pop)
	
	matrix pops = tpop\wforce\lwwoop
	putexcel	B4 = matrix(pops),

	*CALC 1 POP TOTALS BY GENDER for LWIW
	putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("CALC 1")	

	*labels (for guidance)
	putexcel	A4 = "Total immigrants" ///
				A5 = "Immigrants in the workforce" ///
				A6 = "Low-wage immigrant workers" ///
				B3 = "Male (%)" ///
				C3 = "Female (%)" ///
				D3 = "Total" ///
				A8 = "Calc 1.1 Low wage workers by nativity and gender" ///
				A11 = "Total immigrant worker" ///
				A12 = "Total immigrant low-wage workers" ///
				A13 = "Share of LWIWs of all immigrant workers" ///
				A15 = "Total US-born worker" ///
				A16 = "Total US-born low-wage workers" ///
				A17 = "Share of US-born LWWs of all US-born workers"


	*data for totpop numbers
	svy: mean sex if usborn == 0, // share female and total immigrant pop
		matrix tipop = e(b) , 1- e(b) , e(N_pop)
	svy: mean sex if usborn == 0 & insamp == 1, // share female and total im wforce
		matrix lipop = e(b) , 1- e(b) , e(N_pop)
	svy: mean sex if usborn == 0 & lww == 1 & insamp == 1, // share female and lww
		matrix leipop = e(b) , 1- e(b) , e(N_pop)
		
	matrix ipops = tipop\lipop\leipop

	svy: total n if insamp == 1 & usborn == 0
		scalar timw = e(N_pop)
	svy: total n if insamp == 1 & usborn == 0 & lww==1
		scalar timlww = e(N_pop)
		matrix simlww = timlww/timw
		
	svy: total n if insamp == 1 & usborn == 1
		scalar tusw = e(N_pop)
	svy: total n if insamp == 1 & usborn == 1 & lww==1
		scalar tuslww = e(N_pop)
		matrix suslww = tuslww/tusw
		
	putexcel	B4 = matrix(ipops) ///
				B11 = matrix(timw) ///
				B12 = matrix(timlww) ///
				B13 = matrix(simlww) ///
				B15 = matrix(tusw) ///
				B16 = matrix(tuslww) ///
				B17 = matrix(suslww),
		
clear all
*use "${proc}acs1y_2022_employed_clean_${S_DATE}.dta", clear // INSAMP == 1 FOR EVERYONE
use "${proc}acs1y_2022_employed_clean_13 Aug 2024.dta", clear // INSAMP == 1 FOR EVERYONE
svyset [pw=perwt]
					
*TAB 2 GEOGRAPHIC DISTRIBUTION OF IMMIGRANT LOW-WAGE WORKERS
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
	
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 2")

putexcel	A4 = matrix(statelwiw) , names

putexcel	A4 = "State" ///
			B4 = "Share of low-wage workers who are immigrants, by state" ///
			A57 = "Table 2. Geographic distribution of immigrant low-wage workers" 
			
	*CALC XX share of immigrants in the top states in text
	svy: total n if usborn == 0
		scalar tim = e(N_pop)
	svy: total n if usborn==0 & (state_name == "New Jersey" | ///
								state_name == "California" | ///
								state_name == "District of Columbia" | ///
								state_name == "New York" | ///
								state_name == "Massachusetts" | ///
								state_name == "Florida")			
		scalar timts = e(N_pop)
		matrix shstate = timts/tim
								
*TAB 3 EDUCATIONAL ATTAINMENT, BY GENDER
svy: tab educm if lww == 1 & usborn == 1  // US lww
	matrix educs1 = e(b), e(N_pop)
svy: tab educm if lww == 1 & usborn == 1 & sex == 1 // US lww female
	matrix educs2 = e(b), e(N_pop)
svy: tab educm if lww == 1 & usborn == 1 & sex == 0 // US lww male
	matrix educs3 = e(b), e(N_pop)
svy: tab educm if usborn==0 & lww==1 // LWIW
	matrix educs4 = e(b), e(N_pop)
svy: tab educm if usborn==0 & lww==1 & sex == 1 // LWIW female 
	matrix educs5 = e(b), e(N_pop)
svy: tab educm if usborn==0 & lww==1 & sex == 0 // LWIW male
	matrix educs6 = e(b), e(N_pop)
	
	matrix educs = educs1\educs2\educs3\educs4\educs5\educs6	

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 3")

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
			A11 = "CALC 2. Educational attainment of low wage workers, by gender"

	*CALC 2 Field of study for college and graduate degree holders in low-wage immigrant workforce
	tab degfield if educm>3 & usborn==0 & lww==1 [fw=perwt], sort matcell(deg) matrow(deglab)
		scalar define degt = r(N)
		matrix degc = (deg/degt)
		matrix degs = degc[1..10,1]
		matrix deglabc = deglab[1..10,1]
		matrix degs = deglabc,degs
		

	putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("CALC 2")
		putexcel	A4 = matrix(degs) ///
					B14 = matrix(degt)
		putexcel	A3 = "Degree codes" ///
					B3 = "Fields of degrees obtained by low-wage immigrant workers who completed a college or graduate degree" ///
					A14 = "Total" ///
					A16 = "CALC 3. Fields of degrees obtained by low-wage immigrant workers who completed a college or graduate degree" 
					

*TAB 4 YEARS IN THE US	
svy: tab yearsusa if usborn==0 & insamp==1 // all IW
	matrix yrslvus1 = e(b), e(N_pop)
svy: tab yearsusa if usborn==0 & lww==0 // all nLWIW
	matrix yrslvus2 = e(b), e(N_pop)
svy: tab yearsusa if usborn==0 & lww==1 // all LWIW
	matrix yrslvus3 = e(b), e(N_pop)
	
	matrix yrslvus = yrslvus1\yrslvus2\yrslvus3
	matrix rownames yrslvus = "All immigrant workers" "Non-low-wage immigrant workers" ///
		"Low-wage immigrant workers" 
	matrix colnames yrslvus = "Less than 5 years" "5 to 9 years" "10 to 19" ///
		"20 or more years" "Total" 

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 4")
	putexcel	A9 = "Table 4. Years in the US" 
	putexcel	A4 = matrix(yrslvus) , names
	

	*CALC 3 NATURALIZATION STATUS
	svy: tab naturalized if usborn==0  // all IW
		matrix natstat1= e(b)[1,2],e(b)[1,1], e(N_pop)
	svy: tab naturalized if usborn==0 & lww==0 // all nILWW
		matrix natstat2= e(b)[1,2],e(b)[1,1], e(N_pop)
	svy: tab naturalized if usborn==0 & lww==1 // all LWIW
		matrix natstat3= e(b)[1,2],e(b)[1,1], e(N_pop)

		matrix natstat = natstat1\natstat2\natstat3
		matrix rownames natstat = "All immigrant workers" "Non-low-wage immigrant workers" ///
			"Low-wage immigrant workers" 
		matrix colnames natstat = "Naturalized citizen" "Non-citizen" "Total" 

	putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("CALC 3")
		putexcel	A9 = "Table 4.1 Naturalization status of immigrant workers" 
		putexcel	A4 = matrix(natstat), names
		
*TAB 5.1 RACE/ETHNICITY OF IMMIGRANT AND US-BORN LOW-WAGE WORKERS
svy: tab racem if usborn == 1 // all US born workers
	matrix racelwwd1 = e(b), e(N_pop)
	
svy: tab racem if usborn == 1 & lww ==1 // USB LWW 
	matrix racelwwd2 = e(b), e(N_pop)
	
svy: tab racem if usborn == 0 // immigrant workers 
	matrix racelwwd3 = e(b), e(N_pop)
	
svy: tab racem if usborn == 0 & lww ==1 // ILWW
	matrix racelwwd4 = e(b), e(N_pop)
	
matrix racelwwd = racelwwd1\racelwwd2\racelwwd3\racelwwd4
	
matrix colnames racelwwd = "NL White" "NL Black" "NL Asian" "Latinx" ///
		"usborn American or Alaska usborn" "Two or more races" ///
		"Other undetermined" "Total"
matrix rownames racelwwd = "All US-born workers" "LW US-born workers" ///
		"All immigrant workers" "LW immigrant workers"
		
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 5.1")
	putexcel	A10 = "Table 5.1. Race/ethnicity of immigrant and US-born low-wage workers" 				
	putexcel	A4 = matrix(racelwwd)	, names
	
*TAB 5.2 NATIVITY BREAKDOWN OF RACIAL/ETHNIC GROUPS
forvalues r = 1(1)7 {
	svy: mean immigrant if lww==1 & racem==`r' // share immigrants who are lww by race
		matrix natr`r' =  e(b) , 1 - e(b) 
}
	matrix natr = natr1 \ natr2 \ natr3 \ natr4 \ natr5 \ natr6 \ natr6 
	
	matrix rownames natr = "NL-White" "NL-Black" "NL-Asian" "Latinx" ///
		"NA-AN" "2+Race" "Other" 
	matrix colnames natr = "Immigrant" "US-born"
	
	matsort natr 2 // sorts the matrix according to col2
	
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 5.2")
	putexcel	A13 = "Table 5.2. Nativity breakdown of racial/ethnic groups" 				
	putexcel	A4 = matrix(natr)	, names
		
	*CALC 4 REGIONS AND COUNTRIES OF ORIGIN OF LOW-WAGE IMMIGRANT WORKERS
	tab origin if usborn==0 & lww==1  [fw=perwt], matcell(origN) matrow(origlabs) // immigrant and lww by bpl region
		matrix origtot = r(N)
		scalar origt = r(N)
		matrix origsh = origlabs,(origN/origt)
		
	forvalues i = 1(1)6 {
		scalar origNd`i' = origN[`i',1]
		
		tab bpld if usborn==0 & lww==1 & origin == `i'  [fw=perwt], sort matcell(origd`i')  matrow(origlabs`i') // same + bpl country
		capture noisily matrix origshd`i' = (origd`i'/origNd`i')
		capture noisily matrix origd`i' = origlabs`i',(origd`i'/origNd`i')
	}

	matrix origlww =	origsh[1,1..2]\origd1[1..3,1..2]\ ///
						origsh[5,1..2]\origd5[1..3,1..2]\ ///
						origsh[2,1..2]\origd2[1..3,1..2]\ ///
						origsh[3,1..2]\origd3[1..3,1..2]\ ///
						origsh[4,1..2]\origd4[1..3,1..2]\ ///
						origsh[6,1..2]\origd6[1..3,1..2]
					
	putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("CALC 4")
		putexcel	A3 = "Region and top 3 countries within region" ///
					B3 = "Share of low-wage immigrant workers by region and top three major countries of origin within each region" ///
					A30 = "Table 5.3. Regions and countries of origin of low-wage immigrant workers" 
		putexcel	A4 = matrix(origlww)
			
*TAB 8 LANGUAGE PROFICIENCY
svy: tab speakeng2  if usborn==0 // all immworkers
	matrix seng1 = e(b),e(N_pop)

svy: tab speakeng2  if usborn==0 & lww == 0 // immigrant non-lw workers 
	matrix seng2 = e(b), e(N_pop)	
	
svy: tab speakeng2  if usborn==0 & lww == 1 // immigrant LWW 
	matrix seng3 = e(b), e(N_pop)	
	
	matrix seng = seng1\seng2\seng3
	matrix rownames seng = "All immigrant workers" "Immigrant non-low-wage worker" ///
		"Immigrant low-wage worker" 
	matrix colnames seng = "Does't speak English" "Yes, speaks English but not well" ///
		"Yes, speaks English well" "Yes, speaks English very well" ///
		"Yes, speaks only English" "Total"

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 6")
	putexcel	A9 = "Table 8. English proficiency" 				
	putexcel	A4 = matrix(seng) , names

	
	

*TAB 17 OCCUPATION ANALYSIS: IMMIGRANT DENSE OCCUPATIONS
*identifying top 25 occupations with the most immigrant 
tab occ if lww == 1 & usborn == 0 [fw = perwt] , label sort matcell(occ) matrow(occlabf) // all immigrant lw workers
	scalar occt = r(N)
	matrix occ = (occ[1..25,1]/occt)
	matrix occlab = occlabf[1..25,1]
	
	svy: total n if usborn == 0  & lww == 1 
		matrix occn = e(N_pop)

	svy: mean immigrant if lww == 1 
		matrix occsh = e(b)
	
	sum hwage if usborn == 0  & lww == 1  [fw = perwt], d
		matrix mwage = r(p50)

	svy: mean educm1 if usborn == 0  & lww == 1 
		matrix educm1 = e(b)

	svy: mean nlep if usborn == 0  & lww == 1 
		matrix nlep = e(b)

	svy: mean yearsusa2 if usborn == 0  & lww == 1 
		matrix ten2 = e(b)
	
	svy: mean naturalized if usborn == 0  & lww == 1 
		matrix nat = e(b)
	
	forvalues r = 1(1)4 {
		svy: mean racem`r' if usborn == 0  & lww == 1 
			matrix racem`r' = e(b)		
		}

	svy: mean sex if usborn == 0  & lww == 1 
		matrix sexs = e(b)		

	svy: mean parttime if usborn == 0  & lww == 1 
		matrix pts = e(b)		
		
	matrix ilww = (occsh\occn\mwage\pts\educm1\nlep\ten2\nat\racem1\racem2\racem3\racem4\sexs)'

	
	forvalues o = 1(1)25 {
		
		svy: total n if usborn == 0  & lww == 1 & occ == occlab[`o',1]
			matrix occn`o' = e(N_pop)

		svy: mean immigrant if lww == 1 &  occ == occlab[`o',1]
			matrix occsh`o' = e(b)
			
		sum hwage if usborn == 0  & lww == 1 &  occ == occlab[`o',1] [fw = perwt], d
			matrix mwage`o' = r(p50)
		
		svy: mean educm1 if usborn == 0  & lww == 1 &  occ == occlab[`o',1]
			matrix educm`o' = e(b)
		
		svy: mean nlep if usborn == 0  & lww == 1 & occ == occlab[`o',1]
			matrix nlep`o' = e(b)
		
		svy: mean yearsusa2 if usborn == 0  & lww == 1 & occ == occlab[`o',1]
			matrix ten2`o' = e(b)
			
		svy: mean naturalized if usborn == 0  & lww == 1 & occ == occlab[`o',1]
			matrix nat`o' = e(b)
			
		forvalues r = 1(1)4 {
			svy: mean racem`r' if usborn == 0  & lww == 1 & occ == occlab[`o',1]
				matrix racem`r'_`o' = e(b)			
				}
			
		svy: mean sex if usborn == 0  & lww == 1 & occ == occlab[`o',1]
			matrix sex`o' = e(b)		
			
		svy: mean parttime if usborn == 0  & lww == 1 & occ == occlab[`o',1]
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

	
	
	/*
	NOT NEEDED ANYMORE
	
	
*TAB 7 RACE/ETHNICITY OF IMMIGRANT AND US-BORN LOW-WAGE WORKERS, BY GENDER
svy: tab racem if usborn == 1 & lww ==1 // all USB LWW 
	matrix racelwwd1 = e(b), e(N_pop)

svy: tab racem if usborn == 1 & lww ==1 & sex == 1 // USB LWW FEM 
	matrix racelwwd2 = e(b), e(N_pop)

svy: tab racem if usborn == 1 & lww ==1 & sex == 0 // USB LWW MALE 
	matrix racelwwd3 = e(b), e(N_pop)

svy: tab racem if usborn == 0 & lww ==1 // ILWW
	matrix racelwwd4 = e(b), e(N_pop)

svy: tab racem if usborn == 0 & lww ==1 & sex == 1 // ILWW FEM 
	matrix racelwwd5 = e(b), e(N_pop)

svy: tab racem if usborn == 0 & lww ==1 & sex == 0 // ILWW MALE
	matrix racelwwd6 = e(b), e(N_pop)
	
matrix racelwwd = racelwwd1\racelwwd2\racelwwd3\racelwwd4\racelwwd5\racelwwd6
	
matrix colnames racelwwd = "NL White" "NL Black" "NL Asian" "Latinx" ///
		"usborn American or Alaska usborn" "Two or more races" ///
		"Other undetermined" "Total"
matrix rownames racelwwd = "All US-born LW workers" "Female US-born LW workers" ///
		"Male US-born LW workers" "All immigrant LW workers" ///
		"Female immigrant LW workers" "Male immigrant LW workers"
		
putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 7")
	putexcel	A12 = "Table 7. Race/ethnicity of immigrant and US-born low-wage workers, by gender" 				
	putexcel	A4 = matrix(racelwwd)	, names

	
*TAB 14 Field of study for college and graduate degree holders in low-wage immigrant workforce by gender
tab degfield if educm>3 & usborn==0 & lww==1 & sex == 0 [fw=perwt], sort matcell(mdeg) matrow(mdeglab) // immigrant LWW male
	scalar define mdegt = r(N)
	matrix mdegc = (mdeg/mdegt)
	matrix mdegs = mdegc[1..10,1]
	matrix mdeglabc = mdeglab[1..10,1] 
	matrix mdegs = mdeglabc,mdegs
	
tab degfield if educm>3 & usborn==0 & lww==1 & sex == 1 [fw=perwt], sort matcell(fdeg) matrow(fdeglab) // immigrant LWW female
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
				A16 = "Tables 14.1 and 14.2 Fields of degrees obtained by low-wage immigrant workers who completed a college or graduate degree, by gender" 



*TAB 15 TOP OCCUPATIONS OF LOW-WAGE WORKERS, BY NATIVITY
tab occ if usborn == 1 & lww == 1 [fw = perwt] , label sort matcell(occlww1) matrow(olwwlab1) // US-born 
	scalar occlwwt1 = r(N)
	matrix occlww1 = occlww1[1..10,1]/occlwwt1 \ r(N)
	matrix occlwwlab1 = olwwlab1[1..10,1]
tab occ if usborn == 0 & lww == 1 [fw = perwt] , label sort matcell(occlww2) matrow(olwwlab2) // immigrant
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
				A16 = "Table 15. Top 10 occupations of US-born low-wage workers (left) and immigrant low-wage workers (right)" 

*TAB 16 FULLTIME PARTTIME BY SEX AND NATIVITY
	svy: mean fulltime if usborn == 1 & lww==1 & sex ==0 , // US born male lww 
		matrix ft1 = e(b), 1 - e(b), e(N_pop)
	svy: mean fulltime if usborn == 1 & lww==1 & sex ==1 // US born female lww
		matrix ft2 = e(b), 1 - e(b), e(N_pop)
	svy: mean fulltime if usborn == 0 & lww==1 & sex ==0 , // immigrant born male lww 
		matrix ft3 = e(b), 1 - e(b), e(N_pop)
	svy: mean fulltime if usborn == 0 & lww==1 & sex ==1 // immigrant born female lww
		matrix ft4 = e(b), 1 - e(b), e(N_pop)
		
	matrix fullpart = ft1\ft2\ft3\ft4
	matrix rownames fullpart = "US-born: Male LWW" "Female LWW" "Immigrant: Male LWW" "Female LWW"
	matrix colnames fullpart = "Full-time (%)" "Part-time (%)"

putexcel set "${tab}Tables and Graphs acs1y 2022 data_$S_DATE.xlsx" , modify sheet("Table 16")	
	putexcel	A4 = matrix(fullpart), names
	
	putexcel	A10 = "Table 16. Full-time and part-time US-born and immigrant low-wage workers, by gender" 

*/
