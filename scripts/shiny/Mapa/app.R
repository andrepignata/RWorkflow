rm(list=ls())
library(shiny)
library(leaflet)
library(RColorBrewer)
library(htmltools)
if(!require(devtools)) install.packages("devtools")
if(!require(leaflet)) install_github("rstudio/leaflet")
library(RPostgreSQL)


conCurso <<- dbConnect(PostgreSQL(), user= "r_workflow", password="curso", dbname="r_workflow",host="143.107.205.218",port='5432')
sSql <- "select * from s3672792.shoppings"
res <- dbSendQuery(conCurso, sSql)
dShoppings <- fetch(res,n=-1) 


dShoppings$lat <- as.numeric(dShoppings$lat)
dShoppings$lng <- as.numeric(dShoppings$lng)
dShoppings$popup <- paste0(dShoppings$administradora,'. Fone: ',dShoppings$contato)

leafIcons <- icons(
  iconUrl = "images/pin.png",
  iconWidth = 39, iconHeight = 55,
  iconAnchorX = 20, iconAnchorY = -2
  #shadowUrl = "images/coopSep.png",
  #shadowWidth = 20, shadowHeight = 20,
  #shadowAnchorX = 4, shadowAnchorY = 62
)

ui <- bootstrapPage(
  tags$style(type = "text/css", "html, body {width:100%;height:100%}"),theme = "custom.css",
  leafletOutput("map", width = "100%", height = "100%"),
  absolutePanel(top = 10, right = 10, width=300, draggable = T, id = "pMain", class = "panel panel-default"
                ,textInput("nome","Nome da administradora")
                
  )
)

server <- function(input, output, session) {
  
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    #quakes[quakes$mag >= input$range[1] & quakes$mag <= input$range[2],]
    dTemp <- dShoppings

    if (input$nome != '')
      dTemp <- dTemp[grep( toupper(input$nome),dTemp$administradora),]
    #dTemp <- dTemp[grep(pattern=toupper('BrM'),dTemp$administradora),]
    dTemp
  })
  
  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    #leaflet(quakes) %>% addTiles() %>%
    #  fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
    m <- leaflet(dShoppings) %>% addTiles()
    m %>% setView(lng = -48.021152, lat = -15.797552, zoom = 5) %>%  addProviderTiles("Esri.WorldStreetMap")

  })
  
  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    #pal <- colorpal()
    
    leafletProxy("map", data = filteredData()) %>%
      clearControls() %>% 
      clearMarkerClusters() %>% 
      addMarkers(clusterOptions = markerClusterOptions(),popup = ~htmlEscape(popup),icon = leafIcons) # add a marker
  })
  
 
}

shinyApp(ui, server)