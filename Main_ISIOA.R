### Main Script 

rm(list = ls())
options(scipen = 14)


## 1. Load all Packages and Functions
source(file.path("src","functions.R"))

## 2. Load the configuration file 
source(file.path("configuration","config_training.R"))

## 3. Run the model 
source(file.path("src","00_Run_Model.R"))


# 4. Compile the documentation of the model from equations

teXdoc(sources   = c("01.1-eq.mdl"),
            exo       = c(NULL),
            base.path = file.path("src","model","training"),
            out       = "model-eq",
            out.path  = "results_side_files")


make_eq_qmd(preface = file.path("results_side_files",  "model-eq_preface.tex"),
            maintex = file.path("results_side_files", "model-eq.tex"),
            out.dir = "results_side_files" )

## 5. Rendering the markdowns 


output_file = paste0("Results_",project_name,".html")

quarto::quarto_render(input = file.path("results_one_equation_model.qmd"),
                      output_file = output_file,
                      output_format = "html",
                      execute_params = list(project_name = project_name ,
                                            startyear = 2020 ,
                                            endyear = 2035)
)
browseURL(file.path(paste0(output_file) ))
