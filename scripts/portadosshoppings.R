#install.packages('xml2')
#install.packages('rvest')
rm(list=ls())
sNroUSP = 's3672792'
library('rvest')
library('RPostgreSQL')
sShopping <- read_html('http://www.portaldoshopping.com.br/guia-de-shoppings/todos/')
aLinks <- sShopping %>% html_nodes("a") %>% html_attr("href")
aLinks <- aLinks[grep('^/shopping/[0-9]*',aLinks)]

iLink <- 1
dDadosTotal <- data.frame()
for (iLink in 1:length(aLinks)) {
  sShopping <- read_html(paste0('http://www.portaldoshopping.com.br',aLinks[iLink]))  
  #info-shopping-block
  aDados <- sShopping %>% html_nodes(".info-shopping-block")

  dDados <- data.frame( cbind(
                    as.character(aDados[[1]] %>% html_text())
                   ,as.character(aDados[[2]] %>% html_text())
                   ,as.character(aDados[[3]] %>% html_text())
                   ,gsub('[^0-9.]',"", aDados[[4]] %>% html_text())
                   ,gsub('[^0-9.]',"",aDados[[5]] %>% html_text())
                   ,gsub('[^0-9.]',"",aDados[[6]] %>% html_text())
                   ,NULL,NULL
                   ))
  dDadosTotal <- rbind(dDadosTotal,dDados)
  
  
  
}
dDadosTotal$lat <- ''
dDadosTotal$lng <- ''
names(dDadosTotal) <- c('contato','endereco','administradora','area_total_do_terreno','area_construida','area_bruta_locavel','lat','lng')
con2 <<- dbConnect(PostgreSQL(), user= "r_workflow",password="curso",  dbname="r_workflow",host="143.107.205.218",port='5432')
dbWriteTable(con2,c(sNroUSP,'shoppings'),dDadosTotal)
