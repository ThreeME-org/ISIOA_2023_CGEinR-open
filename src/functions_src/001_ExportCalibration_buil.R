ExportCalibration_BUIL   <- function(iso3) {
  
  
  ### 1. PREPARE LISTS OF VARIABLES AND PRODUCT/SECTOR CODES
  # List all variables that must be exported to the model
  # and associate each variable with its steady-state growth rate
  col_names <- c("CA", "CB", "CC", "CD", "CE", "CF", "CG", "DES", "TOTAL")
  
  export.vars   <- c("tau_REHAB_class" = "0.0", 
                     "tau_REHAB_MIN_class" = "0", 
                     "tau_REHAB_MAX_class" = "0",
                     "sigma_class" = "0", 
                     "phi_NEWBUIL_class"   = "0",
                     "phi_REHAB_CA_class"  = "0", 
                     "phi_REHAB_CB_class"  = "0", 
                     "phi_REHAB_CC_class"  = "0", 
                     "phi_REHAB_CD_class"  = "0",
                     "phi_REHAB_CE_class"  = "0",
                     "phi_REHAB_CF_class"  = "0", 
                     "phi_REHAB_CG_class"  = "0",
                     "phi_REHAB_is0_CA_class"  = "0", 
                     "phi_REHAB_is0_CB_class"  = "0", 
                     "phi_REHAB_is0_CC_class"  = "0", 
                     "phi_REHAB_is0_CD_class"  = "0",
                     "phi_REHAB_is0_CE_class"  = "0",
                     "phi_REHAB_is0_CF_class"  = "0", 
                     "phi_REHAB_is0_CG_class"  = "0",
                     "delta_BUIL_CA_class"  = "0", 
                     "delta_BUIL_CB_class"  = "0", 
                     "delta_BUIL_CC_class"  = "0", 
                     "delta_BUIL_CD_class"  = "0",
                     "delta_BUIL_CE_class"  = "0",
                     "delta_BUIL_CF_class"  = "0", 
                     "delta_BUIL_CG_class"  = "0",
                     "PREHAB_HOUSING_CA_class"      = "GR_PRICES", 
                     "PREHAB_HOUSING_CB_class"      = "GR_PRICES", 
                     "PREHAB_HOUSING_CC_class"      = "GR_PRICES", 
                     "PREHAB_HOUSING_CD_class"      = "GR_PRICES",
                     "PREHAB_HOUSING_CE_class"      = "GR_PRICES",
                     "PREHAB_HOUSING_CF_class"      = "GR_PRICES", 
                     "PREHAB_HOUSING_CG_class"      = "GR_PRICES",
                     "PNEWBUIL_class"       = "GR_PRICES",
                     "BUIL_class"           = "0",
                     "ENER_BUIL_ccoa_class" = "0",
                     "ENER_BUIL_cfuh_class" = "0",
                     "ENER_BUIL_cele_class" = "0",
                     "ENER_BUIL_cgas_class" = "0",
                     "ENER_BUIL_chea_class" = "0",
                     "ENER_BUIL_cbio_class" = "0",
                     "CH_AUTO_toe_bis_cele_class" = "0", 
                     "CH_AUTO_toe_bis_cgas_class" = "0"
                     )
  
  
  ### 2. IMPORT DATA
  calib <- readxl::read_excel(str_c("data/input/France/DATA_BUILDING.xlsx"),
                              sheet = "BUILDING", col_names = TRUE, range = "B2:K45")  |>  
    `colnames<-`(c("code", col_names)) |> select(code, all_of(col_names))   |>  
    pivot_longer(cols = col_names, names_to = "class",values_to = "value") |> 
    mutate(variable = str_c(code,"_",class)) 
  
  
  
  if (length(unique(calib$code)) != length(export.vars)){
    cat("WARNING: The number of variables provided in the excel table and the list does not match")
  } 
  ### 3. DATA MANIPULATION
  # Extract the variables that are defined by the class index
  export.vars_sub <- export.vars[grepl("_class", names(export.vars))] 
  
  # Vector extended with 0 values
  # TO CHANGE in order to assign values from the original vector

  export.vars_2 <-   map(col_names, ~ str_replace(export.vars_sub, "class", .x)) |> reduce(c)|>
    `names<-`(map(col_names, ~ str_replace(names(export.vars_sub), "class", .x)) |> reduce(c)) 

  ### 4. EXPORT DATA
  df_calib <- calib  |>  na.omit()

  v       <- df_calib$value 
  vars    <- df_calib$variable
  # Matching of variables in export.vars_2 with vars
  export.vars_3 <- export.vars_2[names(export.vars_2) %in% vars]
  # Ordering of variables in export.vars_3 with variables
  export.vars_3 <- export.vars_3[order(match(names(export.vars_3),df_calib$variable))]
  #data.frame(names(export.vars_3), df_calib$variable) %>% View
  exported   <-    str_c(vars, " := ", 
                         v |> format(digits = 10, scientific = FALSE), 
                         " * (1 + ", export.vars_3, ") ^ (@year - %baseyear)", collapse = "\n")
  
  
  writeTextFile <- function(s, filename) {
    fileConn <- file(filename)
    writeLines(s, fileConn)
    close(fileConn)
  }
  
  writeTextFile(exported, str_c("src/model/threeme/data/R_ExtraCalibration_BUIL_", toupper(iso3), "_c28_s32.mdl"))
}


