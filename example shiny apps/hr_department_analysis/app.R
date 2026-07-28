# ==============================================================================
# HR Department Performance & Engagement Insights Dashboard
# File: app.R
# Author: Antigravity AI
# Purpose: Interactive exploration of staff satisfaction & monthly work hours
# ==============================================================================

# Ensure required packages are installed and loaded
required_packages <- c("shiny", "plotly", "dplyr")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
  library(pkg, character.only = TRUE)
}

# ------------------------------------------------------------------------------
# 1. DATA PREPARATION & LOADING
# ------------------------------------------------------------------------------

# Helper function to clean and format department names professionally
clean_dept_name <- function(x) {
  x_clean <- sapply(x, function(d) {
    switch(d,
      "product_mng" = "Product Management",
      "RandD"       = "R&D",
      "hr"          = "HR",
      "marketing"   = "Marketing",
      "technical"   = "Technical",
      "support"     = "Support",
      "management"  = "Management",
      "accounting"  = "Accounting",
      "IT"          = "IT",
      "sales"       = "Sales",
      # Fallback
      tools::toTitleCase(gsub("_", " ", d))
    )
  })
  return(as.character(x_clean))
}

load_data <- function() {
  paths_to_try <- c(
    "HR_comma_sep.csv",
    "../HR_comma_sep.csv",
    "C:/Users/IFEANYI/Documents/AntigravitySDK-R/HR_comma_sep.csv"
  )
  for (path in paths_to_try) {
    if (file.exists(path)) {
      data <- read.csv(path, stringsAsFactors = FALSE)
      # Keep track of formatted department names
      data$Dept_Clean <- clean_dept_name(data$Department)
      return(data)
    }
  }
  stop("Error: Could not locate 'HR_comma_sep.csv' in the common locations.")
}

hr_data <- load_data()

# ------------------------------------------------------------------------------
# 2. USER INTERFACE DESIGN
# ------------------------------------------------------------------------------
ui <- fluidPage(
  title = "HR Department Insights",
  
  # Custom modern styling
  tags$head(
    tags$style(HTML("
      body {
        background-color: #f4f6f9;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
        color: #2c3e50;
      }
      .dashboard-title {
        background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
        color: white;
        padding: 24px 30px;
        margin-bottom: 25px;
        border-radius: 8px;
        box-shadow: 0 4px 15px rgba(30, 60, 114, 0.2);
      }
      .dashboard-title h2 {
        margin: 0;
        font-weight: 700;
        font-size: 28px;
        letter-spacing: -0.5px;
      }
      .dashboard-title p {
        margin: 6px 0 0 0;
        font-size: 14px;
        opacity: 0.95;
      }
      .card {
        background-color: white;
        border-radius: 8px;
        padding: 22px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.04);
        margin-bottom: 22px;
        border: 1px solid #eef2f5;
      }
      .card-title {
        font-size: 17px;
        font-weight: 700;
        color: #1e3c72;
        margin-bottom: 15px;
        border-bottom: 2px solid #eef2f5;
        padding-bottom: 8px;
        letter-spacing: -0.3px;
      }
      .kpi-card {
        text-align: center;
        background-color: white;
        border-radius: 8px;
        padding: 16px;
        box-shadow: 0 3px 6px rgba(0, 0, 0, 0.03);
        border: 1px solid #e9ecef;
        border-top: 4px solid #1e3c72;
        height: 100%;
        transition: transform 0.2s, box-shadow 0.2s;
      }
      .kpi-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 6px 12px rgba(0, 0, 0, 0.06);
      }
      .kpi-val {
        font-size: 30px;
        font-weight: 700;
        margin-top: 6px;
        letter-spacing: -1px;
      }
      .kpi-val.blue { color: #1e3c72; }
      .kpi-val.green { color: #2ecc71; }
      .kpi-val.orange { color: #e67e22; }
      .kpi-lbl {
        font-size: 11px;
        color: #95a5a6;
        text-transform: uppercase;
        font-weight: 700;
        letter-spacing: 0.8px;
      }
      .control-panel {
        background-color: #ffffff;
        border-left: 4px solid #1e3c72;
      }
      .table-container {
        overflow-x: auto;
      }
      .table th {
        background-color: #f8f9fa;
        color: #1e3c72 !important;
        font-weight: 700;
      }
    "))
  ),
  
  # Dashboard Header
  div(class = "dashboard-title",
    h2("HR Department Engagement & Workload Explorer"),
    p("Interactive visual analytics of worker satisfaction levels and average monthly work duration grouped by department sectors.")
  ),
  
  # Sidebar + Main Panels Layout
  fluidRow(
    # Column 1: Controls Panel (3/12 width)
    column(3,
      div(class = "card control-panel",
        h4("Dashboard Filters", style = "font-weight: 700; color: #1e3c72; margin-top:0; margin-bottom:15px;"),
        
        # Salary Grade Grade Filter
        selectInput("salary_filter", "Filter by Salary Level:",
                    choices = c("All Salary Grades" = "All",
                                "Low Salary Only" = "low",
                                "Medium Salary Only" = "medium",
                                "High Salary Only" = "high"),
                    selected = "All"),
                    
        # Employee Left Status Filter
        selectInput("status_filter", "Employment Status Filter:",
                    choices = c("All Employees" = "All",
                                "Active Retained Staff" = "stayed",
                                "Resigned/Left Staff Only" = "left"),
                    selected = "All"),
                    
        # Statistic Type Filter
        selectInput("stat_filter", "Aggregation Function:",
                    choices = c("Average (Mean)" = "mean",
                                "Median (Middle Value)" = "median"),
                    selected = "mean"),
        
        hr(style = "margin-top: 15px; margin-bottom: 15px; border-color: #eee;"),
        
        # Dataset summary statistics
        tags$p(style = "font-size: 11.5px; color: #7f8c8d; line-height: 1.5;",
               "Use filters above to refine data subgroups. Satisfaction indices range from 0 (lowest) to 1 (highest). Average monthly hours capture typical employee workloads (high hours indicate potential burnout risks).")
      )
    ),
    
    # Column 2: Dashboard Content Panel (9/12 width)
    column(9,
      # Row 1: KPI Statistics Widgets
      fluidRow(
        column(4,
          div(class = "kpi-card", style = "border-top-color: #1e3c72;",
            div(class = "kpi-lbl", "Filtered Staff Headcount"),
            uiOutput("kpi_employees")
          )
        ),
        column(4,
          div(class = "kpi-card", style = "border-top-color: #2ecc71;",
            div(class = "kpi-lbl", "Overall satisfaction level"),
            uiOutput("kpi_satisfaction")
          )
        ),
        column(4,
          div(class = "kpi-card", style = "border-top-color: #e67e22;",
            div(class = "kpi-lbl", "average monthly work hours"),
            uiOutput("kpi_hours")
          )
        )
      ),
      br(),
      
      # Row 2: Charts Grid
      fluidRow(
        # Plot 1: Satisfaction levels bar plot
        column(6,
          div(class = "card",
            div(class = "card-title", "Satisfaction level per Department Sector"),
            plotlyOutput("satisfaction_plot", height = "400px")
          )
        ),
        
        # Plot 2: Average monthly hours pie chart
        column(6,
          div(class = "card",
            div(class = "card-title", "average monthly hours share"),
            plotlyOutput("hours_plot", height = "400px")
          )
        )
      ),
      
      # Row 3: Data Table Breakdown card
      fluidRow(
        column(12,
          div(class = "card",
            div(style = "display: flex; justify-content: space-between; align-items: center; border-bottom: 2px solid #eef2f5; padding-bottom: 8px; margin-bottom: 15px;",
                div(style = "font-size: 17px; font-weight: 700; color: #1e3c72;", "Tabular Department Breakdown Summary"),
                downloadButton("download_summary", "Download as CSV", style = "background-color: #1e3c72; color: white; border: none; padding: 4px 10px; font-size:12px; font-weight:600;")
            ),
            div(class = "table-container",
                tableOutput("summary_table")
            )
          )
        )
      )
    )
  )
)

# ------------------------------------------------------------------------------
# 3. SERVER-SIDES PROCESSING LOGIC
# ------------------------------------------------------------------------------
server <- function(input, output, session) {
  
  # Reactive subsetting based on filter choices
  filtered_df <- reactive({
    df <- hr_data
    
    # 1. Filter by salary 
    if (input$salary_filter != "All") {
      df <- df[df$salary == input$salary_filter, ]
    }
    
    # 2. Filter by status (left or stayed)
    if (input$status_filter == "stayed") {
      df <- df[df$left == 0, ]
    } else if (input$status_filter == "left") {
      df <- df[df$left == 1, ]
    }
    
    return(df)
  })
  
  # Reactive grouping and aggregation based on filters
  agg_df <- reactive({
    df <- filtered_df()
    if (nrow(df) == 0) {
      return(data.frame(
        Department = character(),
        Satisfaction = numeric(),
        Hours = numeric(),
        Count = integer()
      ))
    }
    
    # Select aggregation function
    agg_func <- if (input$stat_filter == "median") median else mean
    
    df %>%
      group_by(Dept_Clean) %>%
      summarise(
        Satisfaction = agg_func(satisfaction_level, na.rm = TRUE),
        Hours = agg_func(average_montly_hours, na.rm = TRUE),
        Count = n()
      ) %>%
      rename(Department = Dept_Clean) %>%
      arrange(desc(Satisfaction)) # Pre-sort descending by satisfaction for tidy visualizations
  })
  
  # --------------------
  # UI OUTPUT KPI OBJECTS
  # --------------------
  
  output$kpi_employees <- renderUI({
    df <- filtered_df()
    div(class = "kpi-val blue", format(nrow(df), big.mark = ","))
  })
  
  output$kpi_satisfaction <- renderUI({
    df <- filtered_df()
    if (nrow(df) == 0) return(div(class = "kpi-val green", "0.0%"))
    val <- mean(df$satisfaction_level, na.rm = TRUE)
    div(class = "kpi-val green", paste0(round(val * 100, 1), "%"))
  })
  
  output$kpi_hours <- renderUI({
    df <- filtered_df()
    if (nrow(df) == 0) return(div(class = "kpi-val orange", "0.0 hrs"))
    val <- mean(df$average_montly_hours, na.rm = TRUE)
    div(class = "kpi-val orange", paste0(round(val, 1), " hrs"))
  })
  
  # --------------------
  # CHALTS - PLOTLY OBJECTS
  # --------------------
  
  # Plot 1: Satisfaction Level Bar Plot
  output$satisfaction_plot <- renderPlotly({
    data <- agg_df()
    if (nrow(data) == 0) return(NULL)
    
    # Formulate interactive plotly bar plot
    p <- plot_ly(
      data,
      x = ~factor(Department, levels = Department), # Keep descending satisfaction order
      y = ~Satisfaction,
      type = "bar",
      text = ~paste0(round(Satisfaction * 100, 1), "%"),
      textposition = "auto",
      hoverinfo = "text",
      hovertext = ~paste(
        "<b>Department:</b>", Department,
        "<br><b>Satisfaction score:</b>", round(Satisfaction, 3), "(", round(Satisfaction * 100, 1), "%)",
        "<br><b>Total Employees:</b>", format(Count, big.mark = ","), "staff"
      ),
      marker = list(
        color = ~Satisfaction,
        colorscale = "Blues",
        reversescale = FALSE,
        line = list(color = "#1e3c72", width = 1)
      )
    ) %>%
    layout(
      xaxis = list(title = "", tickangle = -35),
      yaxis = list(title = "Satisfaction Level (0.0 to 1.0)", range = c(0, 1.1), gridcolor = "#e2e6e9"),
      margin = list(b = 85, l = 50, r = 20, t = 20),
      showlegend = FALSE,
      plot_bgcolor = "rgba(0,0,0,0)",
      paper_bgcolor = "rgba(0,0,0,0)"
    )
    p
  })
  
  # Plot 2: average monthly work hours pie chart
  output$hours_plot <- renderPlotly({
    data <- agg_df()
    if (nrow(data) == 0) return(NULL)
    
    # Formulate pie chart
    p <- plot_ly(
      data,
      labels = ~Department,
      values = ~Hours,
      type = "pie",
      textposition = "inside",
      textinfo = "label+percent",
      hoverinfo = "text",
      hovertext = ~paste(
        "<b>Department:</b>", Department,
        "<br><b>Average Monthly Hours:</b>", round(Hours, 1), "hrs/month",
        "<br><b>Total headcount:</b>", format(Count, big.mark = ","), "employees"
      ),
      marker = list(
        # Beautiful matching monochromatic cohesive blue scale
        colors = c("#1e3c72", "#244a8a", "#2a5298", "#3a60a3", "#4b70ae", "#5c80ba", "#6c90c5", "#7da0d1", "#8eb1dc", "#9fc1e8"),
        line = list(color = "#ffffff", width = 1.5)
      )
    ) %>%
    layout(
      showlegend = TRUE,
      legend = list(orientation = "h", x = 0.5, xanchor = "center", y = -0.15),
      margin = list(b = 50, l = 20, r = 20, t = 20),
      plot_bgcolor = "rgba(0,0,0,0)",
      paper_bgcolor = "rgba(0,0,0,0)"
    )
    p
  })
  
  # --------------------
  # TABULAR BREAKDOWN OUTPUT
  # --------------------
  
  output$summary_table <- renderTable({
    data <- agg_df()
    if (nrow(data) == 0) return(data.frame(Message = "No employee data matching current filter selections."))
    
    tbl_display <- data %>%
      select(
        `Department Sector` = Department,
        `Active Employee Headcount` = Count,
        `Satisfaction Level (Selected Metric)` = Satisfaction,
        `Average Monthly Work Hours` = Hours
      )
    
    # Beautiful formatting
    tbl_display$`Active Employee Headcount` <- format(tbl_display$`Active Employee Headcount`, big.mark = ",")
    tbl_display$`Satisfaction Level (Selected Metric)` <- paste0(round(tbl_display$`Satisfaction Level (Selected Metric)` * 100, 1), "%")
    tbl_display$`Average Monthly Work Hours` <- paste0(round(tbl_display$`Average Monthly Work Hours`, 1), " hrs")
    
    tbl_display
  }, striped = TRUE, bordered = TRUE, hover = TRUE, align = 'l')
  
  # CSV Downloader handler
  output$download_summary <- downloadHandler(
    filename = function() {
      paste0("HR_department_summary_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(agg_df(), file, row.names = FALSE)
    }
  )
}

# ------------------------------------------------------------------------------
# 4. EXECUTE APPLICATION
# ------------------------------------------------------------------------------
shinyApp(ui = ui, server = server)
