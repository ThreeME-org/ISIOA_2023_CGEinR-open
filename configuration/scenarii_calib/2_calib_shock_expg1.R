## 1% GDP point increase of public expenditure
## For France, this corresponds to 10% because of the Euro

# Define the series necessary to calibrate the scenario  
series <- c("DEXPG", "DSOC_BENF_VAL", "GDP") %>% tolower
 
# Load the selected series for the range baseyear:lastyear
selection <- calib_new_base %>% select(year,all_of(series))


## Change in exogenous variables
#(1) Using formulas
shock_ch <- mutate(selection,
                   dexpg =   ifelse(year >= shockyear, dexpg + 1 * 0.01*gdp[which(year == shockyear)], dexpg)
                   #dsoc_benf_val = ifelse(year >= 2021, 0.5 * 0.01*gdp[which(year == baseyear)], dsoc_benf_val)
                        ) %>% 
            select(-gdp) 

