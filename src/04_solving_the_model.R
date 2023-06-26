# Solving the model

solved_data <- data_for_solver

if(Rsolver){
  ## 1. Solving using R : loop needed while we work on parallelisation
"Solving each scenario, please wait... \U23F1" %>%   message_main_step()
scenar_order <- c("baseline", setdiff(names(data_for_solver), "baseline")) 
tot_scen <- length(scenar_order)


for (item_scen in 1:tot_scen){

    if(length(variables_to_keep)==0){
      variables_to_keep <- setdiff(names(data_for_solver[["baseline"]]), "year") %>% tolower
    }
  
  scenar_solved <- scenar_order[item_scen]
  str_c("Solving scenario ",scenar_solved ) %>% message_any(str_c(item_scen," / ", tot_scen))
  
  solved_data[[scenar_solved]] <- thor_solver(my_model,
                                              first_period = baseyear,last_period = lastyear,
                                              database = data_for_solver[[scenar_solved]],
                                              index_time = "year", rcpp = rcpp_option,skip_tests = TRUE) %>% 
    select(year, any_of(tolower(variables_to_keep)) )
  
}
  
### Generate long format datafull

  data_full <- solved_data %>% imap(~pivot_longer(.x,cols = !year,names_to = "variable",values_to = .y) %>% 
                                      mutate(variable = toupper(variable))) %>% 
                                      reduce(full_join, by = c("year","variable")) %>% 
    mutate(sector = NA,commodity = NA) %>% as.data.frame()
  
}

if(Rsolver == FALSE){
  ##EViews
  
  ## stock the results in solved_data
  shock_nb = 1
  for (scen in scenario){
    
    readLines("src/EViews/run_main_from_R.prg") %>%
      str_replace_all("(^%scenario\\s*=\\s*).*$", str_c("\\1\\\"",scen,"\\\"")) %>%
      
      writeLines("src/EViews/run_main_from_R.prg")
    
    if(shock_nb>1){
      readLines("src/EViews/run_main_from_R.prg") %>%
        str_replace_all("(^%warning\\s*=\\s*).*$", str_c("\\1\\\"", "FALSE", "\\\"")) %>%
        str_replace_all("(^%recompile_model\\s*=\\s*).*$", str_c("\\1\\\"", "FALSE", "\\\"")) %>%
        
        writeLines("src/EViews/run_main_from_R.prg")
      
    }  
    
    
    # Run ThreeME in Eviews
    cat("Run ThreeME in Eviews\n")
    sys::exec_wait(path_eviews_exe, c(str_c(eviews_default_path, "run_main_from_R.prg")), timeout = eviews_timeout)
    
    shock_nb = shock_nb + 1
  }  
  
  
  # Removing calib1 and calib 2 files
  for (i in 1:2) {
    file <- str_c("src/compiler/calib",i,".csv")
    if (file.exists(file)) {
      cat(str_c("Removing file calib",i,".csv\n"))
      file.remove(file)
    }
  }
  
  
  
  
}
