rm(list=ls())
sNroUSP = 's3672792'
library(RPostgreSQL)
#install.packages("RCurl")
library(RCurl)

dCidades <- read.csv('bases/cidades.csv',header = T,sep = ',', quote = '"',stringsAsFactors = F)

aTema <- rbind(c(2016,16))
names(aTema) <- c('ano','tema')
dTemas <- as.data.frame(aTema)
names(dTemas) <- c('ano','tema')
#http://cidades.ibge.gov.br/xtras/csv.php?lang=&idtema=16&codmun=150080

dSinteseInformacaoTotal <- data.frame()
dSinteseInformacaoTotal <- readRDS('scripts/sintese.Rds')
tail(unique(dSinteseInformacaoTotal$codmun))
length(unique(dSinteseInformacaoTotal$codmun))
#dCidades[4001,'nome']

iCidade <- 10
iTema <- 1

for (iCidade in 1:10) {
  print(paste('Buscando cidade:',dCidades[iCidade,'nome']))
  for (iTema in 1:nrow(dTemas)) {
    print(paste(' --> tema:',dTemas[iTema,'tema']))
    sArquivo <- getURL(paste0('https://cidades.ibge.gov.br/xtras/csv.php?lang=&idtema=',dTemas[iTema,'tema'],'&codmun=',dCidades[iCidade,'codmun']))
    dSinteseInformacao <- read.csv(textConnection(sArquivo),sep = ';',header = F)
    #limpando linhas em branco
    dSinteseInformacao <- dSinteseInformacao[dSinteseInformacao$V3 != '',]
    #criando colunas
    dSinteseInformacao$ano <- dTemas[iTema,'ano']
    dSinteseInformacao$codmun <- dCidades[iCidade,'codmun']
    names(dSinteseInformacao) <- c('descricao','valor','unidade','ano','codmun')
    dSinteseInformacaoTotal <- rbind(dSinteseInformacaoTotal,dSinteseInformacao)
    saveRDS(dSinteseInformacaoTotal,file = 'scripts/sintese.Rds')
  }
}

con2 <<- dbConnect(PostgreSQL(), 
                   host="143.107.205.218"
                   ,port='5432'
                   ,user= "r_workflow", 
                   password="curso",  
                   dbname="r_workflow",host="143.107.205.218",port='5432')
dbSendQuery(con2,paste0('CREATE SCHEMA if not exists "',sNroUSP,'" AUTHORIZATION r_workflow;'))

dbWriteTable(con2, c(sNroUSP,'sintese_informacao'),dSinteseInformacaoTotal,append=T)
dbWriteTable(con2,c(sNroUSP,'cidades'),dCidades)

