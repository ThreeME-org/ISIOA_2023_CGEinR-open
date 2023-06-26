
ExportCalibration_elas_nrj   <- function(iso3, names_sectors) {
  
  
  ### 1. PREPARE LISTS OF VARIABLES AND PRODUCT/SECTOR CODES
  
  
  
  # List all variables that must be exported to the model
  # and associate each variable with its steady-state growth rate
  
  # Correct list: %list_com_E := ccoa ccoi cfut cfuh cgas cele chea cbio cote
 
  col_names <-  c("ccoa_ccoi",	"ccoa_cfut",	"ccoa_cfuh",	"ccoa_cgas",	"ccoa_cele",	"ccoa_chea",	"ccoa_cbio",	"ccoa_cote",
                  "ccoi_cfut",	"ccoi_cfuh",	"ccoi_cgas",	"ccoi_cele",	"ccoi_chea",	"ccoi_cbio",	"ccoi_cote",
                  "cfut_cfuh",	"cfut_cgas",	"cfut_cele",	"cfut_chea",	"cfut_cbio",
                  "cfuh_cgas",	"cfuh_cele",	"cfuh_chea",	"cfuh_cbio",	"cfuh_cote",
                  "cgas_cele",	"cgas_chea",	"cgas_cbio",	"cgas_cote",
                  "cele_chea",	"cele_cbio",	"cele_cote",
                  "chea_cbio","chea_cote",
                  "cbio_cote")

  export.vars   <- c("ES_NRJ" = "0")
  
  ### 2. IMPORT DATA
  
  calib <- readxl::read_xlsx(str_c("data/input/France/DATA_ELAS_NRJ.xlsx"), sheet = "ELAS_NRJ", col_names = TRUE, range = "A2:AJ34") %>% 
    `colnames<-`(c("name",all_of(col_names))) %>% merge(names_sectors, by = "name" ) %>% select(code, all_of(col_names))  %>% 
    pivot_longer(cols = col_names, names_to = "ES",values_to = "value") %>%
    mutate(variable = str_c("ES_NRJ_",ES,"_",code)) %>% 
    select(code, variable, value)
  # Symmetric variable for elasticities
  calib_2 <- calib %>% mutate(variable = str_c("ES_NRJ_", str_sub(variable,13,16),"_",str_sub(variable,8,11),"_",str_sub(variable,18,22))) %>%
    select(code, variable, value) 
  
  
  calib <- rbind(calib, calib_2) 
  ### 4. EXPORT DATA
  df_calib <- calib  
  
  v   <- df_calib$value 
  vars   <- df_calib$variable
  
  exported   <-    str_c("@over ", vars, " := ", 
                         v %>% format(digits = 10, scientific = FALSE), 
                         " * (1 + ", export.vars, ") ^ (@year - %baseyear)", collapse = "\n")
  
  
  # exported   <- str_c(c(exported, 
  #                       # "@over ES_NRJ[CCOI, CCOA, s]   := ES_NRJ[CCOA, CCOI, s]",
  #                       # "@over ES_NRJ[CELE, CCOA, s]   := ES_NRJ[CCOA, CELE, s]",
  #                       # "@over ES_NRJ[CCOA, CGAS, s]   := ES_NRJ[CGAS, CCOA, s]"
  #                       ),
  #                     collapse = "\n")
  
  
  
  writeTextFile <- function(s, filename) {
    fileConn <- file(filename)
    writeLines(s, fileConn)
    close(fileConn)
  }
  
  writeTextFile(exported, str_c("src/model/threeme/data/R_ExtraCalibration_elas_nrj_", toupper(iso3), "_c28_s32.mdl"))
}
