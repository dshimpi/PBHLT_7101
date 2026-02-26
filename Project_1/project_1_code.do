** Name: Darshan Shimpi
** Title: Project 1 Code
** Date Last Modified: 2/26/2026
*
*
*
*
*
**************************************************
* Clear out existing data
clear 
* Navigate to our folder and load the dataset
cd "C:\Users\darsh\OneDrive\Documents\PBHLT 7101\Project 1"
use "ansur2allV2.dta"

* Save the dataset as v0
save project_data_v0, replace

** Change missing values and add Unique ID

* Grab all numeric variables and it'll store them into `r(varlist)'
ds, has(type numeric)

* Go through and replace missing values appropriately
foreach var of varlist `r(varlist)'{
	replace `var' = .a if `var' == -77
	replace `var' = .b if `var' == -88
	replace `var' = .c if `var' == -99
}

* Create Unique ID (grabbed from online at "https://www.reddit.com/r/stata/comments/yrauxz/create_unique_id/")
set seed 27
gen u_id = sum(runiformint(1,5))

* Save dataset as v1
save project_data_v1, replace 

*********************************************************
** Inspect and correct data

* a.)	Go through each variable and find invalid/suspicious values

** First our numerics
ds, has(type numeric)

foreach var of varlist `r(varlist)'{
	summ `var', detail
}

* Example:
//                             age
// -------------------------------------------------------------
//       Percentiles      Smallest
//  1%           18             17
//  5%           19             17
// 10%           20             18       Obs               7,031
// 25%           23             18       Sum of wgt.       7,031
//
// 50%           28                      Mean           30.06756
//                         Largest       Std. dev.      8.805637
// 75%           37             58
// 90%           43             58       Variance       77.53925
// 95%           47             58       Skewness       .7301577
// 99%           53             58       Kurtosis       2.635243


* b.)	For each value, make a reasonable correction to the special missing values we've noted (or come up with a new one) and document the changes

gen is_suspicious = 0

* We'll note our changes/suspicions here per variable:
*** Numeric variables
**	Age
* Two less than 18 which isn't allowed (Change in part D.)

* Replace the age with our suspicious value indicator (.d) and change is suspicious
gen is_adult = 1
replace is_adult = 0 if age < 18
replace age = .d if age < 18 
replace is_suspicious = 1 if age == .d


** Subject Numeric Race
*  No suspicious values

** DOD Race
* 7 is not a legal value
replace dodrace = .d if dodrace == 7
replace is_suspicious = 1 if dodrace == .d

** Weight lbs
* Two individuals with a weight of 0 seem a bit too skinny
replace weightlbs = .d if weightlbs == 0 
replace is_suspicious = 1 if weightlbs == .d

** heightin
* No suspicious values 

** Thumbtipreach
* There are a about 10 or so values above 5000 for thumb tip reach which seems like quite the long reach
replace thumbtipreach = .d if thumbtipreach > 5000
replace is_suspicious = 1 if thumbtipreach > 5000


** span, footlength, kneeheightmidpatella, waistheightomphalion, functionalleglength, cervicaleheight, trochanterionheight, stature, waistcircumference, chestcircumference, bicristalbreadth, hipbreadth, and hipbreadthsitting all have no suspicious values

* weightkg
* About 39 individuals have a weightkg above 500 kg which seems a bit too heavy

replace weightkg = .d if weightkg > 500 
replace is_suspicious = 1 if weightkg == .d

* date 
* Nothing suspicious here

** Then our string variables
ds, has(type string)

foreach var of varlist `r(varlist)'{
	tab `var', missing
}

* We'll note our changes/suspicions here per variable:
*** String variables


* Ethnicity, Gender, Component, Branch
** No suspicious values

* Writing Preference
** 25 records with value "Either han" which should most likely be "Either hand (No preference)"
replace is_suspicious = 1 if writingpreference == "Either han"
replace writingpreference = "Either hand (No preference)" if writingpreference == "Either han"

* Installation, Test Date, Strdate
** No suspicious values


* c.) Changed the is_suspicious = 1 if a value was changed above!

* d.)	Note that any records where the legal age is below 18 should not be allowed

** ii.)	Drop any that have that is_adult == 0
drop if is_adult == 0

* e.)	Save dataset as project_data_v2
save project_data_v2, replace
*********************************************************
** Identify and Remove Duplicates

** To identify duplicates we'll use the duplicate command and base it off of the gender, span, waistcircumference, chestcircumference, weightkg, stature, and subjectnumericrace

** First, we know that there should be 6,068 records according to the documentation. We started with 7,031.

duplicates report gender span waistcircumference chestcircumference weightkg stature subjectnumericrace

** This gives us 
/* 

--------------------------------------
   Copies | Observations       Surplus
----------+---------------------------
        1 |         5187             0
        2 |         1842           921
--------------------------------------

*/ 
* If we add up 5,187 + 921 = 6,068 so we can hopefully assume that we've found the correct duplicates based on these fields. So let's go ahead and tag the ones we believe to be duplicates using the same criteria

duplicates tag gender span waistcircumference chestcircumference weightkg stature subjectnumericrace, gen(is_duplicate)

* Drop them using the same duplicates command 
duplicates drop gender span waistcircumference chestcircumference weightkg stature subjectnumericrace , force

* Convert all mm measurements to cm measurements 
foreach var of varlist thumbtipreach - hipbreadthsitting {
	replace `var' = `var' / 10
}

* Save as project_data_v3
save project_data_v3, replace

*********************************************************
** Label Variables and Values
label data "This dataset consists of survey data from the ANSUR-II dataset which consists of responses to a 2012 survey by the U.S. Army to measure demographic and anthropometric measures of personnel representing the US army."

label variable subjectnumericrace "A single or multi-digit code indicating a subject's self-reported race or races. Where 1 = White, 2 = Black, 3 = Hispanic, 4 = Asian, 5 = Native American, 6 = Pacific Islander, 8 = Other"

label variable dodrace "A single digit indicating a subject's self-reported preferred single race where selecting multiple races is not an option. Where 1 = White, 2 = Black, 3 = Hispanic, 4 = Asian, 5 = Native American, 6 = Pacific Islander, 8 = Other"

label variable ethnicity "Self-reported ethinicty of the individual"

label variable gender "Male or Female gender for the individual"

label variable age "Age of the respondent (years)"

label variable component "Which portion of the army the respondent came from:  Army National Guard, Army Reserve, or Regular Army"

label variable branch "Which branch of the army the respondent came from: Combat Arms, Combat Support, or Combat Service Support"

label variable writingpreference "Which hand the respondent prefers to write with."

label variable installation "U.S. army installation/camp where the measurements occurred."

label variable test_date "Date the measurements took place"

label variable weightlbs "Weight in pounds of the respondent (self-reported)"

label variable heightin "Height in inches of the respondent (self-reported)"

label variable thumbtipreach "Forward arm reach of the respondent in cm"

label variable span "Arm span length of the respondent in cm"

label variable footlength "Length of foot of the respondent in cm"

label variable kneeheightmidpatella "Height of the knee of the respondent in cm"

label variable waistheightomphalion "Height of the waist of the respondent in cm"

label variable functionalleglength "Functional leg length of the respondent in cm"

label variable cervicaleheight "Height of the neck cervical of the respondent in cm"

label variable trochanterionheight "Height to hip of the respondent in cm"

label variable stature "Measured height of the respondent in cm"

label variable waistcircumference "Waist circumfrence of the respondent in cm"

label variable chestcircumference "Chest circumfrence of the respondent in cm"

label variable bicristalbreadth "Pelvic breadth of the respondent in cm"

label variable hipbreadth "Hip breadth of the respondent in cm"

label variable hipbreadthsitting "Hip breadth while sitting of the respondent in cm"

label variable weightkg "Measured weight of the respondent in kg"

label variable date "Date of the testing of the respondent in date format"

label variable strdate "Date of the testing of the respondent in string format"

label variable u_id "Unique id for the respondent"

label variable is_suspicious "Indicator variable representing whether or not measurements from the respondent are suspicious. 1 = Yes 0 = No"

label variable is_adult "Indicator variable representing whether or not the respondent is an adult (>= 18 years of age). 1 = Yes 0 = No"

label variable is_duplicate "Indicator variable representing whether or not the response may be a duplicate of another response in the dataset based off the gender, span, waistcircumference, chestcircumference, weightkg, stature, and subjectnumericrace for the response. 1 = Potential Duplicate 0 = Unique"

** Label our categorical variable values
* Grab all numeric variables and it'll store them into `r(varlist)'
ds, has(type numeric)

* Go through and replace missing values appropriately
label define missing_value_labels .a "Not Recorded" .b "Refused Measurement" .c "Unknown Missing" .d "Suspicious Value"

foreach var of varlist `r(varlist)'{
	label values `var' missing_value_labels
}

* Now go through the categorical variables and label them accordingly 

* Label DOD Race Values

label define dodrace_labels 1 "White" 2 "Black" 3 "Hispanic" 4 "Asian" 5 "Native American" 6 "Pacific Islander" 8 "Other" .d "Suspicious Value"
label values dodrace dodrace_labels

* Label Is Suspicious Values
label define is_suspicious_labels 0 "Not Suspicious" 1 "Suspicious"
label values is_suspicious is_suspicious_labels

* Label Is Adult Values
label define is_adult_labels 0 "Minor" 1 "Adult"
label values is_adult is_adult_labels

* Label Is Duplicate Values
label define is_duplicate_labels 0 "Unique Record" 1 "Potential Duplicate"
label values is_duplicate is_duplicate_labels

* Save as project_data_v4
save project_data_v4, replace

***************************************************************
* Create New Variables

* Continuous BMI Variable from weight in kg divided by the height in meters squared
gen bmi = weightkg / ((stature/100)^2)
* We have some missing values from weightkg that are all suspicious values so let's appropriately replace them and label them
replace bmi = .d if bmi == .
label define bmi_sus_labels .d "Suspicious Value"
label values bmi bmi_sus_labels
label variable bmi "Body Mass Index (BMI) of the individual calculated from their weight in KG dvided by the square of their height in meters"

* Categorical BMI Variable from BMI with labels
* Use splits from https://www.nhlbi.nih.gov/calculate-your-bmi
recode bmi (0/18.499999999 = 0) (18.5/24.9999999 = 1) (25/29.999999999 = 2) (30/max = 3) (missing = .d), gen(bmi_cat)
label define bmi_cat_labels 0 "Underweight" 1 "Healthy" 2 "Overweight" 3 "Obese" .d "Suspicious Value"
label values bmi_cat bmi_cat_labels
label variable bmi_cat "BMI Categories for the individual based on the splits from the NIH."

* Season variable
* We will use months to determine the season consider the following definitions for our seasons:
* December, January, February - Winter
* March, April, May - Spring
* June, July, August - Summer
* September, October, November - Autumn

gen month_of_testing = month(date)
label variable month_of_testing "Month in which the testing occurred for the collected response"

recode month_of_testing (1 2 12 = 1) (3/5 = 2) (6/8 = 3) (9/11 = 4), gen(season_of_testing)
label define season_labels 1 "Winter" 2 "Spring" 3 "Summer" 4 "Autumn"

label values season_of_testing season_labels
label variable season_of_testing "Season in which the testing occurred for the collected response based on month of the year."

* Numerical Categorical Variable of Gender
encode gender, generate(gender_num)
label variable gender_num "Numerical representation of the gender of the respondent."

* Numerical Categorical Variable of Preferred Hand
encode writingpreference, generate(writingpreference_num)
label variable writingpreference_num "Numerical representation of the writing preference of the respondent."


* Categorical body type based on height, weight, gender, and other measurements
* Let's split the body types into Stout (1), Regular (0), and Lanky (2)
* Percentiles were taken from https://dqydj.com/height-percentile-calculator-for-men-and-women/
* Stout will be for individuals that have a BMI of overweight or obese and are below the 30th percentile for height by gender (171 cm for Men, 158cm for Women) and their legs (trochanterionheight) make up less than 51% of their stature
* Small will be for individuals that have a BMI of regular or underweight and are below the 30th percentile for height by gender (171 cm for Men, 158cm for Women) and their legs
* Lanky will be for individuals that have a BMI of regular or underweight and are above the 70th percentile (179 cm for Men, 166cm for Women) and their legs make up more than 51% of their stature
* Big will be for individuals that have a BMI of overweight or obese and are above the 70th percentile (179 cm for Men, 166cm for Women) AND their legs make up more than 51% of their stature. 
* Average will be for any other individual who doesn't meet these criteria 


* Set everyone to average
gen body_category = 0

* Set small for the individuals meeting the criteria
replace body_category = 1 if gender == "Male" & (bmi_cat == 0 | bmi_cat == 1) & stature < 171 & (trochanterionheight / stature < 0.51)
replace body_category = 1 if gender == "Female" & (bmi_cat == 0 | bmi_cat == 1) & stature < 158  & (trochanterionheight / stature < 0.51)

* Set stout for the individuals meeting the criteria
replace body_category = 2 if gender == "Male" & (bmi_cat == 2 | bmi_cat == 3) & stature < 171 & (trochanterionheight / stature < 0.51)
replace body_category = 2 if gender == "Female" & (bmi_cat == 2 | bmi_cat == 3) & stature < 158  & (trochanterionheight / stature < 0.51)

* Set lanky for the individuals meeting the criteria
replace body_category = 3 if gender == "Male" & (bmi_cat == 0 | bmi_cat == 1) & stature > 179 & (trochanterionheight / stature > 0.51)
replace body_category = 3 if gender == "Female" & (bmi_cat == 0 | bmi_cat == 1) & stature < 166  & (trochanterionheight / stature > 0.51)

* Set big for the individuals meeting the criteria 
replace body_category = 4 if gender == "Male" & (bmi_cat == 2 | bmi_cat == 3) & stature > 179 & (trochanterionheight / stature > 0.51)
replace body_category = 3 if gender == "Female" & (bmi_cat == 2 | bmi_cat == 3) & stature < 166  & (trochanterionheight / stature > 0.51)

label define body_category_labels 0 "Average" 1 "Small" 2 "Stout" 3 "Lanky" 4 "Big"
label values body_category body_category_labels
label variable body_category "Simple category for the body type of an individual based on BMI, Gender, Height Percentiles, and Hip to Height Ratio"

* Save as project_data_final
save project_data_final, replace
