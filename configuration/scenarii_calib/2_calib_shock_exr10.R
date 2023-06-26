##  5% decrease of the exchange rate
## For France, this corresponds to 10% because of the Euro 

# Define the series necessary to calibrate the scenario  
series <- c("EXR") %>% tolower
 
# Load the selected series for the range baseyear:lastyear
selection <- calib_new_base %>% select(year,all_of(series))


## Change in exogenous variables
#(1) Using formulas
shock_ch <- mutate(selection,
                      exr = ifelse(year >= shockyear, exr*1.05, exr)
                          ) 
