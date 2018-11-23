#SERVER:

library(shiny)
library(ggplot2)
#library(dplyr)

shinyServer(function(input,output){
  #output$canton <- renderText(input$canton)
  

  #data <- reactive({ taxes[taxes$Canton == input$canton, c(input$xvar, input$yvar)] }) #consider only the cantons selected by the user 
  #data <- reactive({taxes.query('Canton == input$canton') })
    
  x <- reactive({ taxes[taxes$Canton == input$canton , as.numeric(input$xvar)] })
  y <- reactive({ taxes[taxes$Canton == input$canton , as.numeric(input$yvar)] })
  
  output$myplot <- renderPlot({
    plot(x(), y() )
    #qplot(x(), y(), data = data(), colour=Canton )
  })
}) 
 
