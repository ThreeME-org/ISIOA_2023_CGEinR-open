## 1 Parametres a modifer
paramaters_variables <- c(#"rho_rn_p", # Taylor function
                          #"rho_rn_U", # Taylor function
                          "g_shock", # Common shock
                           "rho_KL"#, # Substitution factors
                          # "rho_sigma_r", # Elasticity of the propensity to save to the interest rate
                          # "rho_sigma_p", # Elasticity of the propensity to save to the interest rate
                          # "rho_sigma_U", # Elasticity of the propensity to save to the interest rate
                          # "rho_sigma_DEBT", # Elasticity of the propensity to save to the interest rate
                          # "rho_wn_pe", # Wage equation parameters
                          # "rho_wn_PROGL", # Wage equation parameters
                          # "rho_wn_U", # Wage equation parameters
                          # "rho_wn_dU", # Wage equation parameters
                          # "ADJUST_I_rK", # Elasticity investment to interest rate
                          # "rho_M", # Armington elastiscity (open economy)
                          #"rho_X" # Armington elastiscity (open economy)
                          
                          )%>% tolower()

## Paramarange
parameters_range = list(
  
  ## Modifiable
  ##################
  # range_rho_rn_p =  c(0,1.5,10),
  # range_rho_rn_U = c(0,0.5,10),
  range_g = c(0, 0.01),
  range_rho_KL = c(0.1, 0.5, 10)#,
  # range_rho_sigma_r = c(0, 1, 10),
  # range_rho_sigma_p = c(0, 1, 10),
  # range_rho_sigma_U = c(0, 1.5, 10),
  # range_rho_sigma_DEBT = c(0, 1, 10),
  # range_rho_wn_pe = c(0, 1, 10),
  # range_rho_wn_PROGL = c(0, 1, 10),
  # range_rho_wn_U = c(0, 1, 10),
  # range_rho_wn_dU = c(0, 1, 10),
  # range_ADJUST_I_rK = c(0, 1, 10)#,
  # range_rho_M = c(0, 1, 10),
  # range_rho_X = c(0, 1, 10)
    
    
  ##################
  
  ) %>% 
  set_names(paramaters_variables) %>% expand.grid() %>% 
  ## Modifiable si envie
  mutate(name = ifelse(g_shock == 0, 
                       # str_c("baseline_",rho_rn_p,"_",rho_rn_u ),
                       # str_c("shock_g_",rho_rn_p,"_",rho_rn_u)
                       
                        str_c("baseline_",rho_kl),
                        str_c("shock_g_",rho_kl)
                       
                       # str_c("baseline_",rho_sigma_r,"_",rho_sigma_p,"_", rho_sigma_u, "_", rho_sigma_debt),
                       # str_c("shock_g_",rho_sigma_r,"_",rho_sigma_p,"_", rho_sigma_u, "_", rho_sigma_debt)
                       
                       # str_c("baseline_",rho_sigma_r,"_",adjust_i_rk),
                       # str_c("shock_g_",rho_sigma_r,"_",adjust_i_rk)

                       )  )
  
