
ExportCalibration_elas   <- function(iso3, names_sectors) {
  

  ### 1. PREPARE LISTS OF VARIABLES AND PRODUCT/SECTOR CODES
  
  
  
  # List all variables that must be exported to the model
  # and associate each variable with its steady-state growth rate
  
  
  col_names <- c("K_L", "K_E", "K_MAT", "L_E", "L_MAT", "E_MAT")
  
  
  export.vars   <- c("ES" = "0")
  
  ### 2. IMPORT DATA
 
  calib <-readxl::read_xlsx(str_c("data/input/France/DATA_ELAS.xlsx"), sheet = "ELAS", col_names = TRUE, range = "A2:G34") %>% 
    merge(names_sectors, by.x = "sectors", by.y = "name" ) %>% select(code, all_of(col_names))  %>% 
    pivot_longer(cols = col_names, names_to = "ES",values_to = "value") %>%
    mutate(variable = str_c("ES_",ES,"_",code)) 
  

  ### 4. EXPORT DATA
  df_calib <- calib  
  
  v   <- df_calib$value 
  vars   <- df_calib$variable
  
  exported   <-    str_c("@over ", vars, " := ", 
                         v %>% format(digits = 10, scientific = FALSE), 
                         " * (1 + ", export.vars, ") ^ (@year - %baseyear)", collapse = "\n") 
                
  exported   <- str_c(c(exported, 
                         "@over ES[L, K, s]   := ES[K, L, s]",
                         "@over ES[E, K, s]   := ES[K, E, s]",
                         "@over ES[MAT, K, s] := ES[K, MAT, s]",
                         "@over ES[E, L, s]   := ES[L, E, s]",
                         "@over ES[MAT, L, s] := ES[L, MAT, s]",
                         "@over ES[MAT, E, s] := ES[E, MAT, s]"),
                       collapse = "\n")
  
  writeTextFile <- function(s, filename) {
    fileConn <- file(filename)
    writeLines(s, fileConn)
    close(fileConn)
  }
  
  writeTextFile(exported, str_c("src/model/threeme/data/R_ExtraCalibration_elas_KLEM_", toupper(iso3), "_c28_s32.mdl"))
}
