# An ACS profile of the Immigrant Low Wage Workforce (WorkRise)
Welcome! This ReadMe file is a great beginning point to understanding what is what! Please contact the admins with any questions!

## Overview
This repo contains the code to estimate key statistics from the ACS that help describe the composition of the immigrant low wage workforce. It produces a spreadsheet with multiple sheets which form the tables that are used later to make the graphs according to the publication requirements. Below are the details on the data requirments and output.

**The data:** for any given year T, we pull the ACS 1-year estimates manually from IPUMS. _We are working to make integrate the IPUMS API into this, but we haven't gotten that far yet._ The most recent year of data available is for 2022.

**Code and software:** we work on Stata. This may change if we ever get the API running. Could switch to R if that works better. There are 2 dofiles that comprise the data build and analysis:
* **Cleaning and sample selection ACS:** starting from a _renamed_ IPUMS data pull (note because IPUMS downloads the data like... usa_000N, we rename before uploading as raw data), this file creates all the key variables needed for the analysis. In particular, this is where the definition of low wage worker comes. In essence, we define a low wage worker as someone **receiving two-thirds the national median wage** of **prime-age workers**, defined as workers 25 to 54.
*  **Analysis:** based on the file produced in the previous dofile, we create each sheet of the _spreadsheet_, but leave out programming each individual graph. That is later done by hand. **Here is a point where someone with better coding skills can pick up to automate the graph making piece on like R.**

## Note on labeling before describing the details of the data
Once you successfully run this code, you will notice that the labels for things like occupations are not coded in, rather we use the OCC codes available on IPUMS. Detailed occupational codes since 2018 can be found here [here](https://usa.ipums.org/usa/volii/occ2018.shtml).  **Would appreciate any thoughts on how to automate this.**


## IPUMS data pulls 
For now, we only dump the files we download from IPUMS. We are working on automating this piece so everything is more streamlined. Note that the variables which are repeated except for an added "D" just mean the variable is the same but more granular, that is with greater level of detail. Right now, make sure you download at minimum the following:

Variable type:
* P = Person level
* H = Household level

Type	Variable	Label
* H	YEAR		Census year
* H	MULTYEAR	Actual year of survey, multi-year ACS/PRCS
* H	SAMPLE		IPUMS sample identifier
* H	SERIAL		Household serial number
* H	CBSERIAL	Original Census Bureau household serial number
* H	HHWT		Household weight
* H	HHTYPE		Household Type
* H	CLUSTER		Household cluster for variance estimation
* H	ADJUST		Adjustment factor, ACS/PRCS
* H	CPI99		CPI-U adjustment factor to 1999 dollars
* H	REGION		Census region and division
* H	STATEFIP	State (FIPS code)
* H	COUNTYFIP	County (FIPS code)
* H	DENSITY		Population-weighted density of PUMA
* H	METRO		Metropolitan status
* H	CITY		City
* H	PUMA		Public Use Microdata Area
* H	STRATA		Household strata for variance estimation
* H	HOMELAND	American Indian, Alaska Native, or Native Hawaiian homeland area
* H	GQ			Group quarters status
* H	FARM		Farm status
* H	HHINCOME	Total household income
* H	LINGISOL	Linguistic isolation
* P	PERNUM		Person number in sample unit
* P	PERWT		Person weight
* P	RELATE 		(general)	Relationship to household head [general version]
* P	RELATED 	(detailed)	Relationship to household head [detailed version]
* P	SEX			Sex
* P	AGE			Age
* P	MARST		Marital status
* P	RACE 		(general)	Race [general version]
* P	RACED 		(detailed)	Race [detailed version]
* P	HISPAN 		(general)	Hispanic origin [general version]
* P	HISPAND 	(detailed)	Hispanic origin [detailed version]
* P	BPL 		(general)	Birthplace [general version]
* P	BPLD 		(detailed)	Birthplace [detailed version]
* P	ANCESTR1 	(general)	Ancestry, first response [general version]
* P	ANCESTR1D 	(detailed)	Ancestry, first response [detailed version]
* P	ANCESTR2 	(general)	Ancestry, second response [general version]
* P	ANCESTR2D 	(detailed)	Ancestry, second response [detailed version]
* P	CITIZEN		Citizenship status
* P	YRNATUR		Year naturalized
* P	YRIMMIG		Year of immigration
* P	YRSUSA1		Years in the United States
* P	YRSUSA2		Years in the United States, intervalled
* P	LANGUAGE 	(general)	Language spoken [general version]
* P	LANGUAGED 	(detailed)	Language spoken [detailed version]
* P	SPEAKENG	Speaks English
* P	EDUC		(general)	Educational attainment [general version]
* P	EDUCD 		(detailed)	Educational attainment [detailed version]
* P	DEGFIELD 	(general)	Field of degree [general version]
* P	DEGFIELDD	(detailed)	Field of degree [detailed version]
* P	DEGFIELD2 	(general)	Field of degree (2) [general version]
* P	DEGFIELD2D 	(detailed)	Field of degree (2) [detailed version]
* P	EMPSTAT 	(general)	Employment status [general version]
* P	EMPSTATD 	(detailed)	Employment status [detailed version]
* P	LABFORCE	Labor force status
* P	CLASSWKR 	(general)	Class of worker [general version]
* P	CLASSWKRD 	(detailed)	Class of worker [detailed version]
* P	OCC			Occupation
* P	IND			Industry
* P	WKSWORK1	Weeks worked last year
* P	UHRSWORK	Usual hours worked per week
* P	WRKLSTWK	Worked last week
* P	WORKEDYR	Worked last year
* P	INCTOT		Total personal
* P	INCWAGE		Wage and salary income
* P	INCEARN		Total personal earned income
* P	POVERTY		Poverty status

