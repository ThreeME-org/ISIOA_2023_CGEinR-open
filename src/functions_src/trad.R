trad <- function(x,data = read.csv(file.path("src","translation_file.csv"),sep = ";", encoding = "UTF-8"),lang = language){
  if(exists("wd_racine")==TRUE){data = read.csv(file.path("results","report","markdown","src","translation_file.csv"),sep = ";", encoding = "UTF-8")}
  i = 1
  nb = length(x)
  for(i in 1:nb){
    x[i] <- data %>% filter(en == x[i]) %>% select(all_of(lang))
  }
  x <- unlist(x)
  x
}
