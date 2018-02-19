rm(list=ls())
sNroUSP = 's3672792'
library(utils)
library(jsonlite)
library(RPostgreSQL)

con2 <<- dbConnect(PostgreSQL(), user= "r_workflow", password='curso',  dbname="r_workflow",host="143.107.205.218",port='5432')
sSql <- paste0("select * from ",sNroUSP,".shoppings where lat = ''  ");
res <- dbSendQuery(con2, sSql)
dDados <- fetch(res,n=-1)
i <- 7
for (i in 1:nrow(dDados)) {
  aDado <- dDados[i,]
  paste('Pegando dados da ',aDado$nome,' - ',aDado$id)
  #sURL <- paste0("https://maps.google.com/maps/api/geocode/json?sensor=false&address=",URLencode(aDado$endereco),"&key=AIzaSyA-WNVTfPo6OykllXVePFgE90wj044MHg4")
  sURL <- paste0("https://maps.google.com/maps/api/geocode/json?sensor=false&address=",URLencode(aDado$endereco))
  paste(sURL)
  jEndereco <- fromJSON(sURL)
  if (is.null(jEndereco$results$geometry$location$lat) == F) {
    sSql <- paste0("update ",sNroUSP,".shoppings set lat = ",jEndereco$results$geometry$location$lat
                   ,",lng=",jEndereco$results$geometry$location$lng," where \"row.names\" = '",aDado$row.names,"'")
    dbSendQuery(con2,sSql)
  } 
  Sys.sleep(2)
}

