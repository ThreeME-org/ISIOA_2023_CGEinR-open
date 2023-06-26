## 1% GDP point increase of public expenditure
## For France, this corresponds to 10% because of the Euro 

# Define the series necessary to calibrate the scenario  
series <- c("I") %>% tolower

# Load the selected series for the range baseyear:lastyear
selection <- calib_new_base %>% select(year,all_of(series))

## Change in exogenous variables
#(1) Using formulas
shock_ch <- mutate(selection,
                   i =   ifelse(year >= 2021, i + 0.5, i)
                        )

