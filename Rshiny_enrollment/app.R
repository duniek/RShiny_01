#-----------------------------------------------------------------------
# Shiny App for Subject recruitment
# Kamila Duniec
# Nov-Dec 2018
#-----------------------------------------------------------------------

#runApp("~/Rshinyapp01")
#\\idorsia.com\org\Clinical Development\Biometry\08_USER_FOLDERS\dunieka1\Rshinyapp01

#-----------------------------------------------------------------------
#USER INTERFACE
#-----------------------------------------------------------------------
ui <- pageWithSidebar(

  # App title ----
  headerPanel("Recruitment"),

  # Sidebar panel for inputs ----
  sidebarPanel(
    # Input: Selector for variable to plot against mpg ----
    selectInput("country", "Select country:",
                choices = c("All", unique(overall0[order(overall0$Country), 12] )), selected = "0", selectize = F )
   ,selectInput("site", "Select site ID:",
                choices = unique(overall0$Site.ID), selected = "1" )
   
   ,dateRangeInput("dates", 
                         "Screening date range",
                         start = "2019-12-16", end = "2021-12-16")

  ),

  # Main panel for displaying outputs ----
  mainPanel("Predicted subject enrollment rate",
    plotOutput("Plot")
  )
)


#-----------------------------------------------------------------------
# Define the ENGINE
#-----------------------------------------------------------------------
server <- function(input, output) {

  #overall <- reactive({ overall[(overall$Country) == (input$country), ] })
  
  overall <- reactive({ subset(overall0, Country == input$country 
                             & Formatted.Enrollment.Date >= input$dates[1]
                             & Formatted.Enrollment.Date <= input$dates[2]
  #  & Site.ID == input$site 
            ) })
  
  #overall <- reactive({ overall[grep(input$country, overall$Country, ignore.case=T),]  })
  
  
  
  output$Plot <- renderPlot({
    
      ggplot(overall() ) +
    
        geom_line(data=overall(), aes(y=N.enrollment, x = Formatted.Enrollment.Date, color="Enrollment Date"),size=0.6)+
        geom_point(aes(y=N.enrollment,x = Formatted.Enrollment.Date,color="Enrollment Date"),size=1) +
    
        geom_line(data=overall(), aes(y=N.randomization, x = Randomization.Dates, color="Randomization Date" ),size=0.6)+
        geom_point(aes(y=N.randomization,x =Randomization.Dates,color="Randomization Date"),size=1) +
    
        scale_x_date(breaks = seq(min(final_data[,3]),max(final_data[,3]),by="2 months"),labels = date_format("%d%b%Y"))+
        theme(axis.text.x = element_text(angle = 90, hjust = 1))+
        xlab("Date")+
        ylab("N")+
        labs(color="Legend text")
  })
}

shinyApp(ui, server)