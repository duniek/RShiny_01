#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Lantus Dosing Curve"),
   
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("units",
                     "Insulin units:",
                     min = 0,
                     max = 5,
                     value = 1)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
         plotOutput("Plot")
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$Plot <- renderPlot({
      # generate plot based on input$units from ui.R
     
     #activity of lantus
     act <- c(0,0.9,1.5,1.15,1,1,1,1,0.75,0.7,0.6,0.5,0.4)
     hours <- c(0,2,4,6,8,10,12, 14, 16, 18, 20, 22, 24)
     iso_date <- ISOdatetime(2018, 11, 23, 07, 00, 00)
     timeline <- iso_date + (hours * 3600)
     
      u <- input$units
      
      # draw the plot with the specified number of units
      plot(x=timeline, y=u*act, xlab="Time", ylab="Lantus activity", type="b")
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

