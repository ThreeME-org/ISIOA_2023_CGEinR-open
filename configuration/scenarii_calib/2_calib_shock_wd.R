## 1% GDP point increase of world demand

# Define the series necessary to calibrate the scenario  
series <- c("WD", "Y") %>% tolower
 
# Load the selected series for the range baseyear:lastyear
selection <- calib_new_base %>% select(year,all_of(series))


## Change in exogenous variables
#(1) Using formulas
shock_ch <- mutate(selection,
                   # wd =   ifelse(year >= 2021, wd + 1, wd)
                   # wd =   ifelse(year >= 2021, wd + 0.01*y[which(year == 2021)], wd)
                   # wd =   ifelse(year == 2021, wd + 0.01*y[which(year == 2021)], wd) # Transitory shock
                   wd =   ifelse(year >= 2021, wd + 0.01*y, wd) # Equivalent shock with economic growth
                   ) %>% select(-y)
