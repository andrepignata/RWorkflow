conCurso <<- dbConnect(PostgreSQL(), user= "r_workflow", password="curso",  dbname="r_workflow",host="143.107.205.218",port='5432')
sSql <- "select * from s3672792.cidade_sintese"
res <- dbSendQuery(conCurso, sSql)
dCidade <- fetch(res,n=-1)   
========================================================================================================
  

summary(dCidade[,1:4])

========================================================================================================
library(psych)
describe(dCidade)


========================================================================================================
dTemp <- subset(dCidade[dCidade$estado %in% c('SP','RJ'),])
describeBy(dTemp[,c('estado','pop_alfabetizada')],group=dTemp$estado)

========================================================================================================
library(reshape2)
sSql <- "select * from s3672792.sintese_informacao"
res <- dbSendQuery(conCurso, sSql)
dSintese <- fetch(res,n=-1)  

dLargo <- reshape(dSintese[c('codmun','ano','descricao','valor')]
                  , timevar='descricao',idvar=c('codmun','ano')
                  ,direction = 'wide'
                  )
warnings()

========================================================================================================
r1 <- lm(dCidade$nro_estab_sus ~ dCidade$pop_alfabetizada)
r1

summary(r1)

plot(nro_estab_sus ~ pop_alfabetizada,data=dCidade) 
abline(r1)

dTemp <- dCidade[dCidade$pop_alfabetizada<500000,]
plot(nro_estab_sus ~ pop_alfabetizada,data=dTemp) 
abline(lm(dTemp$nro_estab_sus ~dTemp$pop_alfabetizada))


r2 <- lm(dTemp$nro_estab_sus ~dTemp$pop_alfabetizada+dTemp$pop_homens+dTemp$pop_mulheres)
summary(r2)


par(mfrow = c(2, 2))
plot(r2)


dCidade$mais_de_80perc <- 0
dCidade$mais_de_80perc[dCidade$pop_alfabetizada/(dCidade$pop_homens+dCidade$pop_mulheres) > 0.8] <- 1


g1 <- glm(mais_de_80perc ~ nro_estab_sus, data=dCidade, family = "binomial")
summary(g1)

par(mfrow = c(2, 2))
plot(g1)

confint(g1)
confint(r2)

coefficients(r2)
head(residuals(r2))

t.test(dCidade$nro_estab_sus,dCidade$pop_alfabetizada)

r1 <- lm(nro_estab_sus ~ pop_alfabetizada, data=dCidade)
dPopAlfabetizada <- data.frame(pop_alfabetizada=100000)

predict(r1,dPopAlfabetizada, interval="predict")

anova(r2, test="Chisq")


dTemp <- na.omit(dCidade)
dTemp <- dTemp[dTemp$nro_estab_sus < 60,]
fit <- kmeans(dTemp[,c('nro_estab_sus','pop_alfabetizada')], 5)
fit$cluster <- as.factor(fit$cluster)
ggplot(dTemp,aes(x=nro_estab_sus,y=pop_alfabetizada,color=fit$cluster))+
      geom_point()


hist(dCidade[dCidade$nro_estab_sus < 60,c('nro_estab_sus')],
       main = 'Distribuição de cidades com menos de 60 estabelecimentos do SUS'
       ,xlab = 'Nro de estabelecimentos', ylab='Frequência'
       )      

library(ggplot2)
ggplot(data=subset(dCidade,nro_estab_sus<60), aes(x = nro_estab_sus)) +
  geom_histogram(binwidth=1)



sSql <- "select c.estado, s.descricao, 
        sum(case when valor = '-' then 0 else replace(valor,'.','')::numeric end) as valor
        from s3672792.cidades c
inner join s3672792.sintese_informacao  s on (c.codmun = s.codmun)
where
s.descricao = 'População residente - Mulheres' 
or
s.descricao = 'População residente - Homens'
group by estado,descricao"
  res <- dbSendQuery(conCurso, sSql)
  dBarra <- fetch(res,n=-1)   


options(scipen=999)  
ggplot(data=dBarra) +
  geom_bar(aes(x = estado,y=valor, fill=descricao),stat = "identity")  

ggplot(data=dBarra) +
  geom_bar(aes(x = estado,y=valor, fill=descricao),stat = "identity",position = 'dodge')  

ggplot(data=subset(dCidade,nro_estab_sus<60), aes(x = nro_estab_sus, y = pop_homens)) +
  geom_point()  


plot <- ggplot(data=subset(dCidade,nro_estab_sus<60)) +
  geom_point(aes(x = nro_estab_sus, y = log(pop_homens),color='homem'),shape=3)+
  geom_point(aes(x = nro_estab_sus, y = log(pop_mulheres),color='mulher'),shape=1)+
  geom_smooth(aes(x = nro_estab_sus, y = log(pop_homens))
              ,method = 'lm',col='darkblue')+
  geom_smooth( aes(x = nro_estab_sus, y = log(pop_mulheres))
              ,method='loess',col='magenta'
              )+
  labs(title='Estabelecimentos SUS x População',x='Nro estabelecimentos SUS',y='log(População)')+
  scale_colour_manual(name = 'Gênero', 
         values =c('homem'='blue','mulher'='tomato1'), labels = c('Homem','Mulher'))  

plot  


ggplot(data=dCidade) +
    geom_line(aes(x = nro_estab_sus, y = pop_homens+pop_mulheres,color='Homem'))+
    geom_smooth(aes(x = nro_estab_sus, y = pop_homens+pop_mulheres)
              ,method = 'loess',col='darkblue')

              
df <- data.frame(
  variable = c("não se parece", "parece"),
  value = c(20, 80)
)
pac <- ggplot(df, aes(x = "", y = value, fill = variable)) +
  geom_bar(width = 1, stat = "identity") +
  scale_fill_manual(values = c("red", "yellow")) +
  coord_polar("y", start = pi / 2) +
  labs(title = "Pac man")
              
pac


library(corrgram)
corrgram(dCidade)



library(leaflet)
  sSql <- "select * from s3672792.shoppings where lat != ''"
  res <- dbSendQuery(conCurso, sSql)
  dShoppings <- fetch(res,n=-1)    
  m <- leaflet(dShoppings) %>% addTiles()
  m <- m %>% setView(lng = -48.021152, lat = -15.797552, zoom = 4) %>%  addProviderTiles("Esri.WorldStreetMap")

  m

leaflet(dShoppings) %>% addTiles() %>% 
  setView(lng = -48.021152, lat = -15.797552, zoom = 4) %>% addProviderTiles("Esri.NatGeoWorldMap")  


dShoppings$lat <- as.numeric(dShoppings$lat)
dShoppings$lng <- as.numeric(dShoppings$lng)
m <- leaflet(dShoppings) %>% addTiles() %>% 
  setView(lng = -48.021152, lat = -15.797552, zoom = 4) %>%  
  addProviderTiles("Esri.WorldStreetMap") %>%  
  addMarkers(lng = dShoppings$lng,lat=dShoppings$lat)
m  

 library(htmltools)
  m <- m %>% clearControls() %>% 
      clearMarkerClusters() %>%
    addMarkers(lng = dShoppings$lng,lat=dShoppings$lat,popup = ~htmlEscape(dShoppings$administradora))  
  m

m %>% clearMarkers() %>%
    addMarkers(lng = dShoppings$lng,lat=dShoppings$lat
               ,popup = ~htmlEscape(dShoppings$administradora)
               ,clusterOptions = markerClusterOptions()) 