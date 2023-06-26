# Building Model objects or loading them up

## A. With R solver
if(Rsolver){
  if (recompile_model){
####### If model must be recompiled
    
  ### A.1 Transform model.prg file into tresthor syntax
  ("Translating model.prg file for tresthor format") %>% message_sub_step()
  model_to_build <- translate_modelprg()
  
  ### A.2 Build model and save
  ("Creating the model for simulations") %>% message_sub_step()
  tresthor::create_model(model_name = "my_model" ,
                         endogenous = model_to_build$endo,
                         exogenous = model_to_build$exo ,
                         coefficients = model_to_build$coef,
                         equations = model_to_build$equations, 
                         rcpp = rcpp_option ,rcpp_path = "src/R_solver_files/" ,
                         no_var_map = TRUE )
  
  ("Saving the model and dependencies for future usage") %>% message_sub_step()
  tresthor::export_model(my_model,filename = file.path("src","R_solver_files","model_thor.txt"))
  tresthor::save_model(my_model,folder_path  = file.path("src","R_solver_files/") )
 
  data_3me <- model_to_build$data %>%filter( year %in% c(firstyear:lastyear))
   saveRDS(data_3me,"src/R_solver_files/data_thor.rds")
   
  }else{
  ### A.3 Load model and calib
  tresthor::load_model(file = file.path("src","R_solver_files","my_model.rds"))
  data_3me <- readRDS(file.path("src","R_solver_files","data_thor.rds"))
  }
  
  ### A.4 Consolidating databases : adding the newly created variables elem variables to calib_new_base
  
  #### if new variables created for the Rsolver must be added to calib_new_base
  newly_created_variables <- setdiff(names(data_3me), names(calib_new_base) )
  if(length(newly_created_variables) > 0){
    calib_new_base <- calib_new_base %>% 
      full_join(data_3me %>% 
                  select(all_of(c("year",newly_created_variables))), by = "year" )
  }
  
  
  
  
  ### A.5 Check calibration at baseyear for calib.csv
  parts <- c("prologue", "heart", "epilogue")
  parts_list <- map(parts, 
                  function(part = .x){
                    list( 
                      part = part ,
                      bool = eval(parse(text = paste0("my_model@",part) )),
                      fun_check = eval(parse(text = paste0("my_model@",part,"_equations_f") )) )
                  }) %>% 
  purrr::set_names(parts)

  ("Calibration check at the base year with the calibration data") %>% message_sub_step()
  
  baseyear_index <- which(data_3me$year== baseyear)
  
  equations <- map(parts, 
                   function(section = .x){
                     if(parts_list[[section]]$bool == TRUE){
                       
                       equations <- my_model@equation_list %>% 
                         filter(part == section) %>% 
                         select(equation =name, formula = equation) %>% 
                         mutate(calib_test = parts_list[[section]]$fun_check(t = baseyear_index, t_data = data_3me)  )
                       
                     }else{equations<-NULL}
                   }) %>% compact() %>% reduce(rbind)
  
  equations_check <- equations %>% filter(abs(calib_test) >= tolerance_calib_check)
  
  
  if(nrow(equations_check) == 0 ){
    ("All equations appear to well calibrated at the baseyear with the calib.csv file.") %>% message_ok()
  }else{ 
    ("The following equations are not well calibrated for the baseline scenario:") %>% message_warning()
    print(equations_check)
    Sys.sleep(2)
    
    #### TODO : ADD OPTION / PROMPT to stop here
  }

}

## B. Preparing the databases to be used with the solver (common to both EViews and R solver)

data_for_solver <- all_scenarii %>% 
  map(~update_data_merge(calib_new_base , .x)) ##data_for solver contains the full databases needed to run the solver for each scenario


## C. Preparing model With EViews
if(Rsolver == FALSE){

  ## Run ThreeMe
  ## 1 Edit eviews run file
  # Define the path of Eviews default directory
  eviews_default_path <- str_c(getwd(), "/src/EViews/")
  
    
  # Rewrite run_main_from_R.prg
  readLines("src/EViews/run_main_from_R.prg") %>%
    str_replace_all("(^%iso3\\s*=\\s*).*$", str_c("\\1\\\"", iso3, "\\\"")) %>%
    str_replace_all("(^%path_eviews_default\\s*=\\s*).*$", str_c("\\1\\\"", eviews_default_path,"\\\"")) %>%
    
    str_replace_all("(^%warning\\s*=\\s*).*$", str_c("\\1\\\"", warning, "\\\"")) %>%
    str_replace_all("(^%compil\\s*=\\s*).*$",replacement =paste0("\\1\\\"", compil,"\\\"")) %>%
    
    str_replace_all("(^%firstyear\\s*=\\s*).*$", str_c("\\1\\\"", firstyear, "\\\"")) %>%
    str_replace_all("(^%baseyear\\s*=\\s*).*$", str_c("\\1\\\"", baseyear, "\\\"")) %>%
    str_replace_all("(^%tolerance_calib_check\\s*=\\s*).*$", str_c("\\1\\\"", tolerance_calib_check, "\\\"")) %>%
    
    str_replace_all("(^%lastyear\\s*=\\s*).*$", str_c("\\1\\\"", lastyear, "\\\"")) %>%
    str_replace_all("(^%recompile_model\\s*=\\s*).*$", str_c("\\1\\\"", recompile_model, "\\\"")) %>%
    
    str_replace_all("(^%save_files_res\\s*=\\s*).*$", str_c("\\1\\\"", save_files_res, "\\\"")) %>%
  
    writeLines("src/EViews/run_main_from_R.prg")
  
  if (recompile_model){

    
    # Splits calib.csv in 2 files: to get around Eviews limitation regarding loading big csv files
    cat(str_c("Loading calib.csv file. Size: ", round(file.size("src/compiler/calib.csv")/1000000,3), " MB\n"))
    
    calib <- fread("src/compiler/calib.csv", data.table = FALSE) %>% 
      select(-baseyear) %>% 
      mutate(year = year + baseyear) 
    
    limit.size.calib.cvs <- 12 
    nb_calib.files <- ceiling(file.size("src/compiler/calib.csv")/1000000/limit.size.calib.cvs)
    
    if (file.size("src/compiler/calib.csv")/1000000 > limit.size.calib.cvs) {    
      
      (paste("calib.csv is larger than", limit.size.calib.cvs, "MB (EViews limit when importing cvs files). Splitting csv into", nb_calib.files,"files:")) %>% message_warning()
      calib1 <- calib %>% select(.,1                     :round(ncol(.)/2,0))
      calib2 <- calib %>% select(.,(round(ncol(.)/2,0)+1):ncol(.)           )

      ("Saving calib1.csv") %>% message_save()
      write.csv(calib1,file.path("src","compiler","calib1.csv"))
      
      ("Saving calib2.csv")%>% message_save()
      write.csv(calib2,file.path("src","compiler","calib2.csv"))
    }
    
     

  }
  
  
    
}


















#### Relevant Checks
# source(file.path("src","03b_ParametersandChecks.R"))
####

