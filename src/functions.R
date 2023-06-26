
# Define required packages
required_packages <- c("data.table", "lemon", "tidyverse", "extrafont", "scales", "readxl","quarto",
                       "colorspace", "ggpubr", "svglite", "magrittr", "png", "remotes","glue", "flextable",
                       "Deriv", "splitstackshape", "gsubfn", "cointReg","RcppArmadillo","Rcpp","zip",
                       "devtools","eurostat","RJSONIO","rdbnomics","rmarkdown","officer","shiny","ggh4x","openxlsx",
                       "stringr", "sys","ggpp","magick","qs","showtext","knitr","paletteer","countrycode","plotly",
                       "crayon","beepr","learnr", "DiagrammeR")

# Define required "house" packages in git
required_packages_local<- c("ofce","pegr","tresthor","ermeeth")

# required_packages_git<- c("ofce")


# Extract not installed packages
not_installed     <- required_packages[!(required_packages     %in% installed.packages()[ , "Package"])]
# not_installed_git <- required_packages_git[!(required_packages_git %in% installed.packages()[ , "Package"])]

# Install missing packages
if(length(not_installed)>0) {install.packages(not_installed)}

library(tidyverse)

# Loading all functions
purrr::map(list.files(file.path("src","functions_src","")),~source(file.path("src","functions_src",.x)))

required_packages_local %>%  purrr::map(~install_local(.x))

# Load packages
# NB: "require" is equivalent to "library" but is designed for use inside other functions.
purrr::map(c(required_packages,required_packages_local),~require(.x,character.only = TRUE))



# message.m()
# Load old function (for test only)
# purrr::map(list.files("src/functions_src_old/"),~source(file.path("src","functions_src_old",.x)))

# rm(list=ls())
rm( not_installed, required_packages, required_packages_local, install_local)