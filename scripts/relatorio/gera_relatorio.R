library('RPostgreSQL')
library('RPostgreSQL')
library(ggplot2)
library(dplyr)

con <- dbConnect(PostgreSQL(), dbname ="r_workflow",user="r_workflow",password="curso",host='143.107.205.218',port='5432')
df <- dbGetQuery(con,paste0("select * from s3672792.cidade_sintese where pop_alfabetizada is not null"))
iCodIbge <- 110034

for (iCodIbge in df$codmun) {
  print(paste0('Gerando para:',iCodIbge))
  rmarkdown::render('relatorio_geral.Rmd', output_file = paste0('arquivos/',iCodIbge,'.pdf'),envir = new.env(parent = globalenv()))
  
}
dbDisconnect(con)

