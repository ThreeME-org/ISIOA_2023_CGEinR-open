## 1% GDP point increase of public expenditure

# Load calibration for range baseyear:lastyear

# Define the series necessary to calibrate the scenario  
series <- c("G", "Y") %>% tolower
 
# Load the selected series for the range baseyear:lastyear
selection <- calib_new_base %>% select(year,all_of(series))

## Change in exogenous variables
#(1) Using formulas

shock_ch <- mutate(selection,
                   # g =   ifelse(year >= 2021, g + 1, g)
                   g =   ifelse(year >= 2021, g * (1 + i_multi/100)^(year-2021), g)
                   )

