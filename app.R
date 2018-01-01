#' This package demonstrates the use of passwordInput to provide
#' a basic access control layer for your Shiny App
#' The feature idea is to render the app UI when the user enters
#' the correct access code, after which the app may be used. 
#' Note that it is only basic access control, probably suitable for 
#' internal applications only.
#' Author: Eric Do

library(shiny)
library(shinycssloaders)
library(shinythemes)
library(quantmod)
library(dygraphs)

# Begin date 
begin_date <- "2017-01-01"

# End date
end_date <- Sys.Date()

# String concat
`%.%` <- function(l,r){paste0(l,r)} 

# Access Code: You can secretly store this elsewhere in real life use
secret_access_code <- "TECHSTOCK"

# Color panels
tech_colors <- list(
  fb = "#3B5998",
  tsla = "#000000",
  goog = "#db3236",
  msft = "#7cbb00",
  amzn = "#ff9900",
  aapl = "#999999"
)

# Universal height 
universal_height <- "21.5vh"

# UI codes 

## >> UI for the app 
ui_app <- navbarPage(
  title = "Tech Stocks Watcher from " %.% 
    format.Date(begin_date, "%d %B %Y") %.% 
    " to " %.% format.Date(end_date, "%d %B %Y"),
  windowTitle = "Tech Stocks Watcher",
  theme = shinytheme('cosmo'),
  tags$head(tags$style(HTML(
    "
    .dygraph-legend {
      background: transparent !important;
    }
    "
  ))),
  fluidRow(
    column(
      6,
      h4("Facebook Stock", style = "color: " %.% tech_colors$fb),
      withSpinner(
        dygraphOutput('facebook_stock', height = universal_height),
        type = 4, color = tech_colors$fb
      )
    ),
    column(
      6,
      h4("Tesla Stock", style = "color: " %.% tech_colors$tsla),
      withSpinner(
        dygraphOutput('tesla_stock', height = universal_height),
        type = 1, color = tech_colors$tsla
      )
    )
  ),
  fluidRow(
    column(
      6,
      h4("Google Stock", style = "color: " %.% tech_colors$goog),
      withSpinner(
        dygraphOutput('google_stock', height = universal_height),
        type = 5, color = tech_colors$goog
      )
    ),
    column(
      6,
      h4("Microsoft Stock", style = "color: " %.% tech_colors$msft),
      withSpinner(
        dygraphOutput('microsoft_stock', height = universal_height),
        type = 6, color = tech_colors$msft
      )
    )
  ),
  fluidRow(
    column(
      6,
      h4("Amazon Stock", style = "color: " %.% tech_colors$amzn),
      withSpinner(
        dygraphOutput('amazon_stock', height = universal_height),
        type = 7, color = tech_colors$amzn
      )
    ),
    column(
      6,
      h4("Apple Stock", style = "color: " %.% tech_colors$aapl),
      withSpinner(
        dygraphOutput('apple_stock', height = universal_height),
        type = 8, color = tech_colors$aapl
      )
    )
  )
)

## >> UI for access portal 

ui_access_portal <- fluidPage(
  title = "Tech Stocks Watcher",
  theme = shinytheme('cosmo'),
  br(), br(), br(), br(), br(),
  wellPanel(
    br(),
    h2("Welcome to Tech Stocks Watcher!", style = "text-align: center; color: #000000"),
    br(),
    h3("Please Enter Your Access Code!"),
    br(),
    h4("This app is only accessible to those who have the secret access code administered by the app author."),
    br(),
    fluidRow(
      column(9, passwordInput('access_code', width = '100%', value = "", label = NULL)),
      column(3, actionButton('submit_access_code', width = "100%", 
                             label = "Go to App!", icon = icon("arrow-right"),
                             style = "background-color: #000000; border-color: #000000;"))
    ),
    br(),
    h4(textOutput('access_status')),
    br(),
    style = "background-color: white; border-style: solid;
    border-width: 2px; border-color: #000000;"
  )
)

## >> Main UI 
ui_main <- withSpinner(uiOutput('conditional_ui'), type = 1, color = "#000000")


# Server codes
server_main <- function(input, output, session) {
  
  # Sleep for 2s for suspense
  Sys.sleep(2)
  
  # Render the access portal first
  output$conditional_ui <- renderUI({
    ui_access_portal
  })
  
  # Tell people the access status
  output$access_status <- renderText({
    if (input$access_code == "") {return ("Please Provide Access Code!")}
    else if (input$access_code != secret_access_code) {return ("Access Denied! Incorrect Access Code!")}
    else if (input$access_code == secret_access_code) {return ("Correct Access Code! Click Go to App!")}
  })
  
  # Correct access code depends on the code entered and clicking the Go button
  correct_access_code <- eventReactive(input$submit_access_code, {
    status_return <- FALSE
    isolate({
      status_return <- input$access_code == secret_access_code
    })
    return (status_return)
  })
  
  # If access status is correct and people click go button, then take them to the UI
  observeEvent(input$submit_access_code, {
    access_granted <- correct_access_code()
    if (access_granted) {
      output$conditional_ui <- renderUI({
        ui_app
      })
    }
  })
  
  # Get stock price on condition that the access is granted 
  stock_prices <- reactive({
    validate(need(correct_access_code() == TRUE, message = "Access Denied")) 
    getSymbols(Symbols = c("FB", "TSLA", "GOOG", "MSFT", "AMZN", "AAPL"), 
               from = begin_date, to = end_date, auto.assign = TRUE)
    return(list(
      FB = FB,
      TSLA = TSLA,
      GOOG = GOOG,
      MSFT = MSFT,
      AMZN = AMZN,
      AAPL = AAPL
    ))
  })
  
  # Render Charts 
  output$facebook_stock <- renderDygraph({
    FB <- stock_prices()$FB[, 6]
    dygraph(FB, group = "stocks") %>% 
      dySeries("FB.Adjusted", label = "FB", color = tech_colors$fb)
  })
  output$tesla_stock <- renderDygraph({
    TSLA <- stock_prices()$TSLA[, 6]
    dygraph(TSLA, group = "stocks") %>% 
      dySeries("TSLA.Adjusted", label = "TSLA", color = tech_colors$tsla)
  })
  output$google_stock <- renderDygraph({
    GOOG <- stock_prices()$GOOG[, 6]
    dygraph(GOOG, group = "stocks") %>% 
      dySeries("GOOG.Adjusted", label = "GOOG", color = tech_colors$goog)
  })
  output$microsoft_stock <- renderDygraph({
    MSFT <- stock_prices()$MSFT[, 6]
    dygraph(MSFT, group = "stocks") %>% 
      dySeries("MSFT.Adjusted", label = "MSFT", color = tech_colors$msft)
  })
  output$amazon_stock <- renderDygraph({
    AMZN <- stock_prices()$AMZN[, 6]
    dygraph(AMZN, group = "stocks") %>% 
      dySeries("AMZN.Adjusted", label = "AMZN", color = tech_colors$amzn)
  })
  output$apple_stock <- renderDygraph({
    AAPL <- stock_prices()$AAPL[, 6]
    dygraph(AAPL, group = "stocks") %>% 
      dySeries("AAPL.Adjusted", label = "AAPL", color = tech_colors$aapl)
  })
}

# Run app
shinyApp(ui = ui_main, server = server_main)


