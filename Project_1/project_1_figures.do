cd "C:\Users\darsh\OneDrive\Documents\PBHLT 7101\Project 1"
use project_data_final

ssc install asdoc

* Get quick summary statistics on everything for the first table
sum
* Then get the suspicious and missing values for each variable of interest
foreach var in chestcircumference waistcircumference hipbreadth hipbreadthsitting bicristalbreadth {
	tab `var'  if `var' >100000, missing
}

** Figure creation
* Create variable for height attributable to height to hip
gen perc_height_attr_to_hip = 100 * trochanterionheight / stature

set scheme s1mono
* Create a split violin plot for the percent of height attributable to height to hip by gender 
violinplot perc_height_attr, vertical fill split(gender) key(fill) legend(subtitle("Gender") position(3) cols(1)) ytitle("% Height Attributable to Height of Hip", margin(medium)) title({bf:Figure 3.1},position(11)) xlabel(,nogrid) ylabel(,nogrid)

*******************************************************
* Relationships between anthropometric measures

* Assess the level of correlation between the measures of stature
correlate kneeheightmidpatella cervicaleheight trochanterionheight waistheightomphalion functionalleglength footlength thumbtipreach span weightkg
************* OUTPUT *********************
/*

             | kneehe~a cervic~t trocha~t waisth~n functi~h footle~h thumbt~h     span weightkg
-------------+---------------------------------------------------------------------------------
kneeheight~a |   1.0000
cervicaleh~t |   0.9030   1.0000
trochanter~t |   0.9255   0.8880   1.0000
waistheigh~n |   0.9134   0.9414   0.9118   1.0000
functional~h |   0.8759   0.9022   0.8655   0.8787   1.0000
  footlength |   0.8077   0.8503   0.7695   0.8068   0.8003   1.0000
thumbtipre~h |   0.7945   0.8250   0.7771   0.7815   0.8320   0.7873   1.0000
        span |   0.8732   0.9079   0.8594   0.8835   0.8720   0.8627   0.8811   1.0000
    weightkg |   0.5833   0.6794   0.5361   0.5320   0.6902   0.6682   0.6478   0.6414   1.0000


*/

*** We can see that waistheightomphalion and cervicaleheight have the highest correlation coefficient using the correlate command. We can then make a figure to show this too:

heatplot waistheightomphalion cervicaleheight, xtitle("Neck Cervical Height (cm)") ytitle("Waist Height (cm)") title({bf:Figure 4.1}, position(11)) xlabel(,nogrid) ylabel(,nogrid) legend(size(small) bmargin(medium) region(margin(medium))) keylabels(, format(%4.0g))

********************
* Now let's check WITH stature and see if there are any differences by gender
correlate stature kneeheightmidpatella cervicaleheight trochanterionheight waistheightomphalion functionalleglength footlength thumbtipreach span weightkg if gender == "Male"
/*
             |  stature kneehe~a cervic~t trocha~t waisth~n functi~h footle~h thumbt~h     span weightkg
-------------+------------------------------------------------------------------------------------------
     stature |   1.0000
kneeheight~a |   0.8334   1.0000
cervicaleh~t |   0.9841   0.8572   1.0000
trochanter~t |   0.8501   0.8981   0.8698   1.0000
waistheigh~n |   0.9085   0.8701   0.9157   0.8843   1.0000
functional~h |   0.8179   0.8084   0.8458   0.8114   0.8125   1.0000
  footlength |   0.7181   0.6925   0.7253   0.6758   0.6931   0.6608   1.0000
thumbtipre~h |   0.6912   0.6981   0.7263   0.6997   0.6759   0.7462   0.6524   1.0000
        span |   0.8230   0.8000   0.8386   0.8135   0.8178   0.7894   0.7492   0.8119   1.0000
    weightkg |   0.4689   0.3866   0.5067   0.3480   0.3088   0.5363   0.4835   0.4833   0.4468   1.0000

*/
correlate stature kneeheightmidpatella cervicaleheight trochanterionheight waistheightomphalion functionalleglength footlength thumbtipreach span weightkg if gender == "Female"
/*

             |  stature kneehe~a cervic~t trocha~t waisth~n functi~h footle~h thumbt~h     span weightkg
-------------+------------------------------------------------------------------------------------------
     stature |   1.0000
kneeheight~a |   0.8432   1.0000
cervicaleh~t |   0.9843   0.8664   1.0000
trochanter~t |   0.8578   0.9168   0.8786   1.0000
waistheigh~n |   0.9088   0.8802   0.9234   0.8897   1.0000
functional~h |   0.8323   0.8341   0.8497   0.8484   0.8289   1.0000
  footlength |   0.7219   0.7315   0.7262   0.7184   0.7016   0.7124   1.0000
thumbtipre~h |   0.6710   0.6853   0.6904   0.6935   0.6573   0.7338   0.6535   1.0000
        span |   0.8190   0.8319   0.8309   0.8423   0.8284   0.8132   0.7726   0.8064   1.0000
    weightkg |   0.5334   0.4719   0.5344   0.4697   0.3866   0.6011   0.5364   0.5090   0.5002   1.0000
*/

* This is hard to look at BUT we only care about the stature correlations so we'll put only those into our table in a separate program to make it easier to compare the male and female results. 