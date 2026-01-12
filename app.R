# Cloning Data UI - Main Application
# This is a sample Shiny app structure for displaying cloning data from BigQuery

library(shiny)
library(shinydashboard)
library(DT)
library(bigrquery)
library(DBI)
library(dplyr)
library(plotly)
library(config)

# Load configuration
cfg <- config::get()

# Authenticate with GCP
if (file.exists(Sys.getenv("GCP_AUTH_FILE"))) {
  bq_auth(path = Sys.getenv("GCP_AUTH_FILE"))
}

# Create BigQuery connection
get_bq_connection <- function() {
  tryCatch({
    con <- dbConnect(
      bigrquery::bigquery(),
      project = cfg$bigquery$project_id,
      dataset = cfg$bigquery$dataset,
      billing = cfg$bigquery$billing_project
    )
    return(con)
  }, error = function(e) {
    showNotification(
      paste("Failed to connect to BigQuery:", e$message),
      type = "error",
      duration = NULL
    )
    return(NULL)
  })
}

# UI
ui <- dashboardPage(
  dashboardHeader(title = cfg$app$title),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Data Table", tabName = "datatable", icon = icon("table")),
      menuItem("About", tabName = "about", icon = icon("info-circle"))
    )
  ),
  
  dashboardBody(
    tabItems(
      # Dashboard tab
      tabItem(
        tabName = "dashboard",
        fluidRow(
          box(
            title = "Cloning Data Overview",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            p("Welcome to the Cloning Data UI application."),
            p("This application connects to Google Cloud BigQuery to display cloning nomination data."),
            hr(),
            actionButton("test_connection", "Test Connection", icon = icon("plug"))
          )
        ),
        fluidRow(
          valueBoxOutput("total_records"),
          valueBoxOutput("connection_status"),
          valueBoxOutput("last_updated")
        )
      ),
      
      # Data Table tab
      tabItem(
        tabName = "datatable",
        fluidRow(
          box(
            title = "Cloning Data",
            width = 12,
            status = "primary",
            solidHeader = TRUE,
            DTOutput("data_table")
          )
        )
      ),
      
      # About tab
      tabItem(
        tabName = "about",
        fluidRow(
          box(
            title = "About",
            width = 12,
            h3("Cloning Data UI"),
            p("Version: 1.0.0"),
            p("This R Shiny application displays nominated cloning data from Google Cloud BigQuery."),
            hr(),
            h4("Setup Instructions:"),
            tags$ol(
              tags$li("Install required R packages using renv::restore()"),
              tags$li("Configure GCP credentials in .Renviron file"),
              tags$li("Update config.yml with your BigQuery project details"),
              tags$li("Run test_bigquery_connection.R to verify connection"),
              tags$li("Launch the app with: shiny::runApp()")
            ),
            hr(),
            h4("Environment Configuration:"),
            verbatimTextOutput("env_info")
          )
        )
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Reactive connection
  bq_con <- reactiveVal(NULL)
  
  # Test connection button
  observeEvent(input$test_connection, {
    showNotification("Testing BigQuery connection...", type = "message")
    con <- get_bq_connection()
    if (!is.null(con)) {
      bq_con(con)
      showNotification("Connection successful!", type = "success")
    }
  })
  
  # Value boxes
  output$total_records <- renderValueBox({
    valueBox(
      "N/A",
      "Total Records",
      icon = icon("database"),
      color = "blue"
    )
  })
  
  output$connection_status <- renderValueBox({
    status <- if (!is.null(bq_con())) "Connected" else "Not Connected"
    color <- if (!is.null(bq_con())) "green" else "red"
    
    valueBox(
      status,
      "BigQuery Status",
      icon = icon("plug"),
      color = color
    )
  })
  
  output$last_updated <- renderValueBox({
    valueBox(
      format(Sys.time(), "%Y-%m-%d %H:%M"),
      "Last Checked",
      icon = icon("clock"),
      color = "yellow"
    )
  })
  
  # Data table (placeholder)
  output$data_table <- renderDT({
    if (is.null(bq_con())) {
      datatable(
        data.frame(Message = "Please connect to BigQuery first"),
        options = list(dom = 't')
      )
    } else {
      # Example query - replace with actual table name
      # df <- dbGetQuery(bq_con(), "SELECT * FROM your_table_name LIMIT 100")
      # datatable(df, options = list(pageLength = 25, scrollX = TRUE))
      
      datatable(
        data.frame(Message = "Update the query in app.R with your actual table name"),
        options = list(dom = 't')
      )
    }
  })
  
  # Environment info
  output$env_info <- renderText({
    paste0(
      "R Version: ", R.version.string, "\n",
      "Platform: ", R.version$platform, "\n",
      "Project: ", cfg$bigquery$project_id, "\n",
      "Dataset: ", cfg$bigquery$dataset, "\n",
      "Debug Mode: ", cfg$app$debug
    )
  })
  
  # Cleanup on session end
  session$onSessionEnded(function() {
    if (!is.null(bq_con())) {
      dbDisconnect(bq_con())
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
