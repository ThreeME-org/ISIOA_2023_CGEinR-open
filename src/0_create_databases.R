### Prepare and store the databases in long format from EViews
if(!exists("scenario_name")){scenario_name <- "oilprice_fra"}
if(!exists("classification")){classification <- "c28_s32"}

if(file.exists(paste0("src/bridges/bridge_",classification,".R")) & file.exists(paste0("src/bridges/codenames_",classification,".R"))){

  # source("src/functions_src/0_loadResults.R")
  source(paste0("src/bridges/bridge_",classification,".R"))
  source(paste0("src/bridges/codenames_",classification,".R"))
  bridge_check = TRUE
  }else{
  bridge_check = FALSE
  bridge_sectors = NULL
  bridge_commodities = NULL
  
  
  ### Commodities: c4
  names_commodities <- rbind(
    c('Industry','cind'),
    c('Transport','ctrp'),
    c('Services','cser'),
    c('Energy','cenj'),
    c('Industry','C001'),
    c('Transport','C002'),
    c('Services','C003'),
    c('Energy','C004')
  ) %>%
    as.data.frame() %>% rename(name = V1,code = V2)
  
  ### Sectors: s4
  names_sectors <- rbind(
    c('Industry','sind'),
    c('Transport','strp'),
    c('Services','sser'),
    c('Energy','senj'),
    c('Industry','s001'),
    c('Transport','s002'),
    c('Services','s003'),
    c('Energy','s004')
  ) %>%
    as.data.frame() %>% rename(name = V1,code = V2)
 
  } 





cat("Creating database 1. Please wait.:) \n")

data_full <- loadResults(scenario_name,
                         by_sector = FALSE, by_commodity = FALSE, 
                         bridge_s = bridge_sectors, bridge_c = bridge_commodities,
                         names_s = names_sectors, names_c = names_commodities,
                         csv_folder = file.path("data","temp","csv"))

if(bridge_check){

cat("Creating database 2 / 4. Please wait.:) \n")

data_ag_sector <- loadResults(scenario_name,
                              by_sector = TRUE, by_commodity = FALSE,
                              bridge_s = bridge_sectors, bridge_c = bridge_commodities,
                              names_s = names_sectors, names_c = names_commodities,
                              csv_folder = file.path("data","temp","csv"),
                              aggregation_rules_path = file.path("src","bridges", 
                                                                 "aggregation_rules.xlsx"))

cat("Creating database 3 / 4. Please wait.:) \n")

data_ag_commodity <- loadResults(scenario_name,
                                 by_sector = FALSE, by_commodity = TRUE,
                                 bridge_s = bridge_sectors, bridge_c = bridge_commodities,
                                 names_s = names_sectors, names_c = names_commodities,
                                 csv_folder = file.path("data","temp","csv"),
                                 aggregation_rules_path = file.path("src","bridges", 
                                                                    "aggregation_rules.xlsx"))

cat("Creating database 4 / 4. Please wait.:) \n")

data_ag_commodity_sector <- loadResults(scenario_name,
                                        by_sector = TRUE, by_commodity = TRUE,
                                        bridge_s = bridge_sectors, bridge_c = bridge_commodities,
                                        names_s = names_sectors, names_c = names_commodities,
                                        csv_folder = file.path("data","temp","csv"),
                                        aggregation_rules_path = file.path("src","bridges", 
                                                                           "aggregation_rules.xlsx"))

cat("Saving the databases. Almost there! \n")

saveRDS(data_ag_sector,
        file = paste0("data/output/",scenario_name,"_",classification,"_sectors",".rds"))


saveRDS(data_ag_commodity,
        file = paste0("data/output/",scenario_name,"_",classification,"_commodities",".rds"))


saveRDS(data_ag_commodity_sector,
        file = paste0("data/output/",scenario_name,"_",classification,"_commodities_sectors",".rds"))


}

saveRDS(data_full,
     file = paste0("data/output/",scenario_name,"_",classification,".rds"))



cat("Done! \n")