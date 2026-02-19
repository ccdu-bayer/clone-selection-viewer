# ui.R for UI 
ui <- dashboardPage(
  dashboardHeader(title = "Set Rearray Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "overview", icon = icon("dashboard")),
      menuItem("Detailed Analysis", tabName = "detailed", icon = icon("chart-bar")),
      menuItem("Data Explorer", tabName = "explorer", icon = icon("table"))
    ),
    
    # Dynamic Filters
    hr(),
    h4("Filters", style = "padding-left: 15px;"),
    
    # Set Rearray Filter with Select All/Clear
    selectInput(
      "set_rearray",
      "Set Rearray:",
      choices = NULL,
      multiple = TRUE,
      selectize = TRUE
    ),
    fluidRow(
      column(6, actionButton("select_all_sets", "Select All", 
                             class = "btn-xs", 
                             style = "margin-left: 15px; width: 90%;")),
      column(6, actionButton("clear_sets", "Clear", 
                             class = "btn-xs", 
                             style = "width: 90%;"))
    ),
    
    br(),
    
    # Source ID Filter
    selectInput(
      "source_id",
      "Source ID:",
      choices = NULL,
      multiple = TRUE,
      selectize = TRUE
    ),
    fluidRow(
      column(6, actionButton("select_all_sources", "Select All", 
                             class = "btn-xs", 
                             style = "margin-left: 15px; width: 90%;")),
      column(6, actionButton("clear_sources", "Clear", 
                             class = "btn-xs", 
                             style = "width: 90%;"))
    ),
    
    br(),
    
    # Clone ID Filter
    selectInput(
      "clone_id",
      "Clone ID:",
      choices = NULL,
      multiple = TRUE,
      selectize = TRUE
    ),
    fluidRow(
      column(6, actionButton("select_all_clones", "Select All", 
                             class = "btn-xs", 
                             style = "margin-left: 15px; width: 90%;")),
      column(6, actionButton("clear_clones", "Clear", 
                             class = "btn-xs", 
                             style = "width: 90%;"))
    ),
    
    br(),
    
    actionButton("apply_filters", "Apply Filters", 
                 class = "btn-primary",
                 icon = icon("filter"),
                 style = "margin-left: 15px; margin-right: 15px; width: calc(100% - 30px);"),
    
    br(), br(),
    actionButton("reset_filters", "Reset Filters", 
                 icon = icon("undo"),
                 style = "margin-left: 15px; margin-right: 15px; width: calc(100% - 30px);"),
    
    br(), br(),
    actionButton("refresh_data", "Refresh Data", 
                 icon = icon("refresh"),
                 style = "margin-left: 15px; margin-right: 15px; width: calc(100% - 30px);"),
    hr(),
    
    box(
      width = 12,
      background = "light-blue",
      tags$h5(tags$b("How to Use:")),
      tags$ol(
        tags$li("Select one or more sets"),
        tags$li("Wait for filters to load"),
        tags$li("Optionally filter by source/clone"),
        tags$li("Click 'Apply Filters'"),
        tags$li("View charts and tables")
      )
    )
  ),
  
  dashboardBody(
    # manually added:
    # Filter Summary Box
    fluidRow(
      column(12,
             h3("Welcome to the Home Page"),
             span(textOutput("username", inline = TRUE), style = "font-size: 16px; color: #2c3e50;"),
             h2("Rearray Viewer.")
      ),
      box(
        width = 12,
        status = "info",
        solidHeader = FALSE,
        collapsible = TRUE,
        collapsed = FALSE,
        title = "Current Filters",
        uiOutput("filter_summary")
      )
    ), # end of manually added
    
    tabItems(
      # Overview Tab
      tabItem(
        tabName = "overview",
        fluidRow(
          valueBoxOutput("total_sets", width = 3),
          valueBoxOutput("total_sources", width = 3),
          valueBoxOutput("total_clones", width = 3),
          valueBoxOutput("total_records", width = 3)
        ),
        fluidRow(
          box(
            title = "Clone Distribution by Set Rearray",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("clones_by_set_chart", height = "400px")
          )
        ),
        fluidRow(
          box(
            title = "Top 20 Sources by Clone Count",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("source_clone_chart", height = "400px")
          ),
          box(
            title = "Set Rearray Summary",
            status = "success",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("set_summary_chart", height = "400px")
          )
        )
      ),
      
      # Detailed Analysis Tab
      tabItem(
        tabName = "detailed",
        fluidRow(
          box(
            title = "Clone vs Source Analysis",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            plotlyOutput("scatter_analysis", height = "450px")
          )
        ),
        fluidRow(
          box(
            title = "Source Distribution",
            status = "warning",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("source_distribution", height = "400px")
          ),
          box(
            title = "Clone Distribution",
            status = "info",
            solidHeader = TRUE,
            width = 6,
            plotlyOutput("clone_distribution", height = "400px")
          )
        )
      ),
      
      # Data Explorer Tab : manually updated
      tabItem(
        tabName = "explorer",
        fluidRow(
          box(
            title = "Parent Table: tbl_set_rearray",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            collapsible = TRUE,
            DTOutput("parent_table")
          )
        ),
        fluidRow(
          box(
            title = "Child Table: tbl_set_rearray_clones (Joined View)",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            collapsible = TRUE,
            DTOutput("child_table")
          )
        ),
        fluidRow(
          box(
            title = "Export Options",
            status = "success",
            solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(4,
                     downloadButton("download_full_data", "Download Filtered Data (CSV)", 
                                    class = "btn-success btn-block")
              ),
              column(4,
                     downloadButton("download_summary", "Download Summary Stats (CSV)", 
                                    class = "btn-info btn-block")
              ),
              column(4,
                     downloadButton("download_parent", "Download Parent Table (CSV)", 
                                    class = "btn-primary btn-block")
              )
            )
          )
        )
      )
    )
  )
)