##### CHECK FILE 1 : Configuration Checks

#######################################################
## A. Supplementary parameters
#######################################################
scenario_name <- paste(scenario, iso3, sep = "_") %>% tolower()
shocks_nb <- length(scenario)
max_tresthor_capability <- 300 # Max size in kb for a model that tresthor can handle
options(scipen = 15)


path_main <- NULL
#######################################################
## B. Basic Configuration checks
#######################################################

## Set minimun period of simulation for standard shock

# @LUCIA: To be reactivated  
if( (project_name=="standard_shocks") & ((lastyear - shockyear + 1) < 40) ){
  lastyear <- shockyear + 40 - 1

  paste0("Standard shock simulation:\nThe difference between lastyear and shockyear must be greater or equal than 39.\nLastyear has been modified and is now ",lastyear,".") %>%
    message_warning()
}

if( length(calib_baseline) > 1 ){

  paste0("Only one baseline scenario possible, the first one specified will be retained: \n", calib_baseline[1]) %>% 
    message_warning()

  calib_baseline <- calib_baseline[1]
}

if( length(calib_scenario) != length(scenario) & automated_shocks == FALSE ){
  
  "The number of shock scenario provided does not match the number of calibration scripts for the shock scenarii" %>% message_not_ok()
  ("Stopping now") %>% message_stopbomb()
  stop(error = "Problem in configuration of shock scenarios calibration.")
  
}


#######################################################
## C. Save config 
#######################################################
##### ## ls() %>% cat(file ="plop", sep = "','") 

config_og <- mget(c('annexes',"automated_shocks",'baseyear','calib_baseline','calib_files','calib_scenario','classification','color_theme','eviews_timeout','firstyear','iso3','language','lastyear','lists_files','max_lags','max_tresthor_capability','model_files','model_folder','project_name','path_eviews_exe','rcpp_option','recompile_model','Rsolver','save_files_res','scenario','scenario_name','shocks_nb','shockyear','skip_compiler','time','tolerance_calib_check','use.superlu','variables_to_keep','warning'))
saveRDS(config_og,
     file = file.path("configuration","saved_configurations",str_c("config_",Sys.Date() %>% format("%yl%ml%d"),"_",Sys.info()[["user"]],".rds" ) ) )
