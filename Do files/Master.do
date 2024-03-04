/*
Project:		Work Rise Immigrant Low Wage Workers (LWW)
Owners:			Hamutal Bernstein, Fernando Hernandez
Date modified:	4/5/2021
Task:			Master do file
Notes:


*/

global do "/Users/fernando/Box/Immigrants in low wage workforce/Data Analysis/Do files/" // needs to be fixed for each computer
set more off

*Build
do "${do}Cleaning and sample selection ACS.do"

*Basic tables and graphs
do "${do}Analysis.do"

*Industry choice
*do "${do}ind_occ analysis.do"

