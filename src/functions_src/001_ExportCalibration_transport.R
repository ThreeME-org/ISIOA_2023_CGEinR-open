
ExportCalibration_TRANSPORT   <- function(iso3) {
  
  
  ### 1. IMPORT DATA
  
  col_names <- c("CA", "CB", "CC", "CD", "CE", "CF", "CG", "TOTAL")
  
  calib <- readxl::read_xlsx(str_c("data/input/France/DATA_TRANSPORT.xlsx"),
                             sheet = "TRANSPORT", col_names = TRUE, range = "B2:J35") %>% 
    `colnames<-`(c("code", col_names)) %>% select(code, all_of(col_names))  %>% 
    pivot_longer(cols = col_names, names_to = "class",values_to = "value") %>%
    mutate(variable = str_c(code,"_",class)) 
  
  ### 2. LISTS OF VARIABLES AND steady-state growth rate
  # List all variables that must be exported to the model
  # and associate each variable with its steady-state growth rate
  
  export.vars   <- c("AUTO_cele_class" = "0",
                     "AUTO_th_cfut_class" = "0",
                     "AUTO_th_cgas_class" = "0",
                     
                     "kmPerAuto_class"    = "0",
                     "KM_Auto_class"      = "0",
                     "km_auto_LD_class" = "0",
                     "km_auto_SD_class" = "0",
                     "KM_Auto_cele_class" = "0",
                     "KM_Auto_cfut_class" = "0",
                     "KM_Auto_cgas_class" = "0",
                     "km_trav_auto_LD_class" = "0",
                     "km_trav_auto_SD_class" = "0",
                     "km_traveler_crai_class" = "0",
                     "km_traveler_croa_class" = "0",
                     "km_traveler_cair_class" = "0",
                     "ENER_BUIL_bis_cele_class" = "0",
                     "ENER_BUIL_bis_cgas_class" = "0",
                     "NewAUTO_cele_class" = "0",
                     "NewAUTO_cfut_class" = "0",
                     "NewAUTO_cgas_class" = "0",
                     "delta_AUTO_cele_DES_class" = "0",
                     "delta_AUTO_cfut_DES_class" = "0",
                     "delta_AUTO_cgas_DES_class" = "0",
                     "CH_AUTO_toe_cele_class" = "0",
                     "CH_AUTO_toe_cfut_class" = "0",
                     "CH_AUTO_toe_cgas_class" = "0",
                     "overcost_elec_euro_class" = "GR_PRICES",
                     "Pbattery_euro_class" = "GR_PRICES",
                     "PNewAUTO_cfut_class" = "GR_PRICES",
                     "PNewAUTO_cgas_class" = "GR_PRICES",
                     "Mcperkm_cele_class" = "0",
                     "Mcperkm_cfut_class" = "0",
                     "Mcperkm_cgas_class" = "0"
  )
  
  if (length(unique(calib$code)) != length(export.vars)){
    cat("WARNING: The number of variables provided in the excel table and the list does not match")
  } 
  ### 3. DATA MANIPULATION
  # Extract the variables that are defined by the class index
  export.vars_sub <- export.vars[grepl("_class", names(export.vars))] 
  
  
  export.vars_2 <-   map(col_names, ~ str_replace(export.vars_sub, "class", .x)) |> reduce(c)|>
    `names<-`(map(col_names, ~ str_replace(names(export.vars_sub), "class", .x)) |> reduce(c)) 
  
  ### 4. EXPORT DATA
  df_calib <- calib  %>% na.omit
  
  
  v   <- df_calib$value 
  vars   <- df_calib$variable
  
  # Matching of variables in export.vars_2 with vars
  
  export.vars_3 <- export.vars_2[names(export.vars_2) %in% vars]
  # Ordering of variables in export.vars_3 with variables
  export.vars_3 <- export.vars_3[order(match(names(export.vars_3),df_calib$variable))]
  
  
  exported   <-    str_c(vars, " := ", 
                         v |> format(digits = 10, scientific = FALSE), 
                         " * (1 + ", export.vars_3, ") ^ (@year - %baseyear)", collapse = "\n")
  
  writeTextFile <- function(s, filename) {
    fileConn <- file(filename)
    writeLines(s, fileConn)
    close(fileConn)
  }
  
  writeTextFile(exported, str_c("src/model/threeme/data/R_ExtraCalibration_TRANSPORT_", toupper(iso3), "_c28_s32.mdl"))
}
