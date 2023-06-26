## 10% increase of fossil fuel prices

# Load the selected series for the range baseyear:lastyear
if(calib_baseline=="configuration/scenarii_calib/1_calib_baseline_statec.R"){
  selection <- calib_new_base %>% select(year,starts_with("PWD"))
  
}else{
  selection <- calib_new_base %>% select(year,starts_with("PWD_"))
}
## Change in exogenous variables
#(1) Using formulas
shock_ch <- if(classification == "c8_s8"){mutate(selection, 
                                                pwd_cend =   ifelse(year >= shockyear, pwd_cend * (1 + 0.1*0.2), pwd_cend) #replace 0.2 by oil and gas part in "cend" (energy dirty commodity) - search
)
}else{if(classification == "c4_s4"){mutate(selection, 
                                           pwd_cenj =   ifelse(year >= shockyear, pwd_cenj * (1 + 0.1*0.15), pwd_cenj) #replace 0.15 by oil and gas part in "cenj" (energy commodity) - search
)
}else{mutate(selection, 
             pwd_cfut =   ifelse(year >= shockyear, pwd_cfut * 1.1, pwd_cfut),
             pwd_cgas =   ifelse(year >= shockyear, pwd_cgas * 1.1, pwd_cgas)
)
}
}
