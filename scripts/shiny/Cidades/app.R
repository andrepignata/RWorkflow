#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(RPostgreSQL)
library(sqldf)
library(DT)
conCurso <<- dbConnect(PostgreSQL(), user= "r_workflow", password="curso", dbname="r_workflow",host="143.107.205.218",port='5432')
sSql <- "select * from s3672792.cidade_sintese"
res <- dbSendQuery(conCurso, sSql)
dCidade <- fetch(res,n=-1) 
names(dCidade) <- c('Cód IBGE','Nome','Estado','Pop Alfabetizada','Matriculas 2015','Homens','Mulheres','Nro Estab. SUS')

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Dados de cidades"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         textInput("edCidade",
                     "Nome da cidade:"
                  )
         ,sliderInput("slPopAlfabetizada","População alfabetizada",min=0,max=100,step=1,value=20)
         ,selectInput("seEstado", "Estado:", 
                      choices = levels(as.factor(dCidade$Estado)))
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        h4("Dados da cidade"),
        DT::dataTableOutput("tbCidade")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  datasetInput <- reactive({
    sqldf(paste0("select * from dCidade where nome like '",input$edCidade,"%'
                 and \"Pop Alfabetizada\"/(\"Homens\"+\"Mulheres\")*100 >= ",input$slPopAlfabetizada,"
                 and \"Estado\" = '",input$seEstado,"'
                 "),drv="SQLite")
  })
  
  output$tbCidade <- DT::renderDataTable(
    DT::datatable(datasetInput(), options = list(paging = FALSE))
  )
  
  

  dbDisconnect(conCurso)
}

# Run the application 
shinyApp(ui = ui, server = server)

