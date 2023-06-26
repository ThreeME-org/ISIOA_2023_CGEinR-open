##### CHECK FILE 2 : Post-compiler checks


# Define style function for ThreeME message alert # TO BE NORMALISED LATER
alert_red <- make_style("brown", bg = TRUE)
alert_green <- make_style("green", bg = FALSE)


######################

## 1.  Checking that the calib.csv file has all the endogenous variables declared in the model.prg file

### Get all equations from the equation list 
mod_from_dynamo <- readLines(file.path("src","compiler","model.prg")) %>%   str_remove_all("^a_3ME\\.append\\s") 
list_endo <- mod_from_dynamo %>%
  
  ### Remove basic common things and keep LHS of equations
  str_remove_all("\\s+") %>%
  str_remove_all("=.*$") %>%
  
  ### remove funcions
  str_remove_all("\\w+\\(") %>%
  str_replace_all("^|$","@") %>%
  str_replace_all("(\\+|-|\\*|/|\\(|\\)|\\^)","@") %>%
  
  ### remove numbers
  str_replace_all("@\\d+(\\.\\d+)?@","@") %>%
  
  ### clean up
  str_replace_all("@+","@") %>%
  
  ### remove extra variables
  str_replace_all("^(@\\w+\\@).*$","\\1") %>%
  str_remove_all("@")

equation_table <- data.frame(endogenous = list_endo, equation = mod_from_dynamo)

calib_vars <- data.table::fread("src/compiler/calib.csv",data.table = FALSE ) %>% names()

missing_calibs <- setdiff(list_endo,calib_vars)

if(length(missing_calibs) > 0){
  
  cat("\n \U274C The following endogenous variables have not been calibrated in the calib.csv file: \n")
  equation_table %>% filter( endogenous %in% missing_calibs)
  
}else{
  
  cat("\n \U2705 All endogenous variables are present in the calib.csv file. \n")
  
}


## 2.  Definite check if EViews will be used
if(file.size(file.path("src","compiler","model.prg")) > max_tresthor_capability *1000  ){
  Rsolver <- FALSE
  if (grepl("win", tolower(osVersion))){
  cat("\n \U2757  The model appears to be too large for current R solver capabilities, EViews should be used instead.\n")
  }else{
      cat(alert_red("\n \U274C The model appears to be too large for current R solver capabilities. EViews should be used instead, however running EViews will require a windows OS installation.
          \n\U1F4A3 Stopping now. \U1F4A3"))
        stop(error ="Cannot run the specified configuration of ThreeME on this computer.")
    }
}

if( file.size(file.path("src","compiler","model.prg")) <= max_tresthor_capability *1000 &
    grepl("win", tolower(osVersion)) == FALSE &
    Rsolver == FALSE
    ){
  cat("\n \U2757  \U1F914 It looks like you are not using Windows, EViews cannot be used on other OSs than Windows. \nHowever, since the model specified is not too large, the model will be solved through R.\n" %>% 
        bgBlue() %>% black())
  Rsolver <- TRUE
  rcpp_option = TRUE 
  use.superlu = FALSE
}


## 3. Checking and detecting automatically location of EViews.exe 

### Detect location of EViews.exe  
if (grepl("win", tolower(osVersion)) & Rsolver == FALSE){
  
  if (file.exists(path_eviews_exe)) {
    message <- paste0("Default EViews path (for Windows OS only): \nThe EViews path provided (",path_eviews_exe,") is correct. \n")
    cat(alert_green(message))
  } else {
    message <- paste0("Default EViews path (for Windows OS only): \nThe EViews path provided (",path_eviews_exe,") is incorrect. \n")
    cat(alert_red(message))
    
    nb_eviews.exe <- 0
    for (progfolder in c("C:/Program Files","C:/Program Files (x86)")){  
      for (i in c(8:14)){
        # assign(paste0("eviews.exe.ver",i), paste0("C:/Program Files/EViews ",i,"/EViews",i,".exe"))
        path_eviews_exe_tested <- paste0(progfolder,"/EViews ",i,"/EViews",i,".exe")
        
        if (file.exists(path_eviews_exe_tested)) {
          path_eviews_exe <- path_eviews_exe_tested
          nb_eviews.exe <- nb_eviews.exe + 1
          message <- paste0("Possible path: ", path_eviews_exe, ". \n")
          cat(alert_green(message))
          
        }  
        
        path_eviews_exe_tested <- paste0(progfolder,"/EViews ",i,"/EViews",i,"_x64.exe")
        if (file.exists(path_eviews_exe_tested)) {
          path_eviews_exe <- path_eviews_exe_tested
          nb_eviews.exe <- nb_eviews.exe + 1
          message <- paste0("Possible path: ", path_eviews_exe, ". \n")
          cat(alert_green(message))
          
        } 
      }
    }
    if (nb_eviews.exe == 0) {
      message <- "Warning: No Eviews.exe found! \nCheck if Eviews is installed if you wish to use the EViews solver. \n"
      cat(alert_red(message))
      
    } else {
      message <- paste0(nb_eviews.exe, " path(s) found. \nWe will use: ",  path_eviews_exe, 
                        ". \nChange manually in config (path_eviews_exe <- DESIRED PATH) if you wish otherwise. \n")
      cat(alert_green(message))
    }
  }
  
  ### Define the path of Eviews default directory
  path_eviews_default <- paste0(getwd(), "/src/EViews/")
  
  ### (if issue) Define the absolute path of Eviews default directory
  # path_eviews_default <- "C:/Users/reynesfgd/GitHub/ThreeME_V3/src/EViews/"
}
