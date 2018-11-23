#INTERFACE

library(shiny)

shinyUI(fluidPage(
  titlePanel(title=h4("Taxes in Switzerland", align="center")),
  sidebarLayout(
	  sidebarPanel(
	    selectInput(inputId = "canton", label = "Select Canton", choices = unique(taxes$Canton), selectize = F, multiple = T)
	  , selectInput(inputId = "xvar", label = "Select X axis", choices = c("Taxable.Income"=4, "Canton"=2, "ï..Year"=1), selected = "Taxable.Income")
	  , selectInput(inputId = "yvar", label = "Select Y axis", choices = c("Tax.perc."=8, "Total.Tax" = 7, "Federal.Tax" = 5, "Cantonal.Tax" = 6), selected="Tax.perc.", multiple = F)
	    ),
	  mainPanel(
	    #textOutput("canton"),
	    plotOutput("myplot")
	)
	)
))


