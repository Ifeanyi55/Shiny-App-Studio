library(shiny)

# Define UI for Old Faithful Geyser App
ui <- fluidPage(
  # Include Custom CSS for a beautiful, modern design
  tags$head(
    tags$style(HTML("
      body {
        background-color: #f8f9fa;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        color: #333333;
      }
      .navbar {
        background-color: #2c3e50;
        border-radius: 0;
      }
      .title-container {
        background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
        color: white;
        padding: 30px;
        margin-bottom: 30px;
        border-radius: 10px;
        box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        text-align: center;
      }
      .title-container h1 {
        margin-top: 0;
        font-weight: 700;
        letter-spacing: 1px;
      }
      .title-container p {
        font-size: 1.1em;
        opacity: 0.9;
        margin-bottom: 0;
      }
      .sidebar-panel {
        background-color: white;
        border: 1px solid #e3e6f0;
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.05);
        margin-bottom: 20px;
      }
      .well {
        background-color: white !important;
        border: 1px solid #e3e6f0 !important;
        box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important;
        border-radius: 8px !important;
      }
      .nav-tabs {
        border-bottom: 2px solid #ddd;
        margin-bottom: 15px;
      }
      .nav-tabs > li > a {
        font-weight: 600;
        color: #555;
        border: none;
        border-radius: 0;
        transition: all 0.3s ease;
      }
      .nav-tabs > li.active > a, .nav-tabs > li.active > a:focus, .nav-tabs > li.active > a:hover {
        border: none;
        border-bottom: 3px solid #1e3c72;
        color: #1e3c72;
        background-color: transparent;
      }
      .nav-tabs > li > a:hover {
        background-color: #f1f3f5;
        border-bottom: 3px solid #cbd5e0;
      }
      .card {
        background-color: white;
        border: 1px solid #e3e6f0;
        border-radius: 8px;
        padding: 20px;
        margin-bottom: 20px;
        box-shadow: 0 4px 6px rgba(0,0,0,0.05);
      }
      .card-header {
        font-size: 1.15em;
        font-weight: 600;
        border-bottom: 1px solid #f1f3f5;
        padding-bottom: 10px;
        margin-bottom: 15px;
        color: #1e3c72;
        display: flex;
        justify-content: space-between;
        align-items: center;
      }
      .tooltip-box {
        position: absolute;
        background-color: rgba(44, 62, 80, 0.9);
        color: white;
        padding: 8px 12px;
        border-radius: 4px;
        font-size: 12px;
        pointer-events: none;
        z-index: 100;
        box-shadow: 0 2px 5px rgba(0,0,0,0.2);
      }
      .metric-box {
        text-align: center;
        padding: 15px;
        border-radius: 8px;
        background-color: #f8f9fa;
        border: 1px solid #e3e6f0;
        box-shadow: inset 0 1px 3px rgba(0,0,0,0.02);
      }
      .metric-value {
        font-size: 1.8em;
        font-weight: bold;
        color: #2e59d9;
      }
      .metric-label {
        font-size: 0.85em;
        text-transform: uppercase;
        color: #858796;
        font-weight: 600;
        margin-top: 5px;
      }
      .stat-highlight {
        color: #1e3c72;
        font-weight: bold;
      }
    "))
  ),

  # Header Jumbotron Banner
  div(class = "title-container",
      h1("🌋 Old Faithful Geyser Explorer"),
      p("Interactive analysis, regression models, and spatial clustering of Yellowstone's famous thermal feature.")
  ),

  sidebarLayout(
    sidebarPanel(
      class = "sidebar-panel",
      width = 4,
      h4(strong("Control Panel")),
      hr(),
      
      # Variable selection for distribution
      selectInput("var", "1. Select Variable Analysis:",
                  choices = c("Eruption Duration" = "eruptions", 
                              "Waiting Time" = "waiting")),
      
      # Slider for number of bins
      sliderInput("bins", "2. Number of Bins (Histogram):",
                  min = 5, max = 50, value = 20, step = 1),
      
      # Color Palette Choice
      selectInput("color_theme", "3. Color Theme Palette:",
                  choices = c("Deep Ocean (Blue)" = "#2196F3",
                              "Volcanic Ash (Teal)" = "#009688",
                              "Thermal Geyser (Orange/Coral)" = "#FF5722",
                              "Yellowstone Forest (Green)" = "#4CAF50")),
      
      # Checkbox options
      checkboxInput("show_density", "Overlay Density Curve", value = TRUE),
      checkboxInput("show_rug", "Show Data Points (Rug plot)", value = TRUE),
      
      tags$div(style = "margin-top: 25px; margin-bottom: 10px; font-weight: bold;", "4. Clustering Parameters:"),
      sliderInput("clusters", "Number of Clusters (K-Means):",
                  min = 1, max = 5, value = 2, step = 1),
      
      # Help text info
      hr(),
      tags$div(
        style = "background-color: #f8f9fa; padding: 12px; border-radius: 6px; border-left: 4px solid #1e3c72; font-size: 0.9em;",
        tags$p(style = "margin: 0;", tags$b("Interaction Tips:")),
        tags$ul(
          style = "padding-left: 15px; margin-top: 5px; margin-bottom: 0;",
          tags$li("Hover over the scatter plot to read values."),
          tags$li("Click and drag (brush) on the scatter plot to slice/filter data points dynamically.")
        )
      )
    ),

    mainPanel(
      width = 8,
      tabsetPanel(
        id = "tab_selected",
        
        # TAB 1: Distribution Plot
        tabPanel(
          title = tagList(icon("chart-bar"), "Distribution Analysis"),
          value = "distribution",
          
          tags$div(class = "card", style = "margin-top: 15px;",
            div(class = "card-header", "Histogram of Selected Variable"),
            plotOutput("distPlot", height = "400px", 
                       click = "dist_click",
                       brush = "dist_brush"),
            uiOutput("dist_info")
          ),
          
          # Summary stats cards row
          fluidRow(
            column(4, 
                   div(class = "metric-box",
                       div(class = "metric-value", textOutput("stat_mean")),
                       div(class = "metric-label", "Mean Value")
                   )
            ),
            column(4, 
                   div(class = "metric-box",
                       div(class = "metric-value", textOutput("stat_median")),
                       div(class = "metric-label", "Median Value")
                   )
            ),
            column(4, 
                   div(class = "metric-box",
                       div(class = "metric-value", textOutput("stat_sd")),
                       div(class = "metric-label", "Std. Deviation")
                   )
            )
          )
        ),
        
        # TAB 2: Interactive Scatter Plot & Regression
        tabPanel(
          title = tagList(icon("cubes"), "Bivariate Scatter & Clusters"),
          value = "scatter",
          
          tags$div(class = "card", style = "margin-top: 15px;",
            div(class = "card-header", "Eruption Duration vs Waiting Time"),
            
            # Interactive Scatter Plot
            div(style = "position: relative;",
                plotOutput("scatterPlot", height = "420px",
                           hover = hoverOpts("scatter_hover", delay = 100, delayType = "debounce"),
                           brush = brushOpts("scatter_brush", resetOnNew = TRUE),
                           click = "scatter_click"),
                uiOutput("scatter_tooltip")
            ),
            
            hr(),
            fluidRow(
              column(6,
                     h4("Selected Points Summary"),
                     verbatimTextOutput("brush_summary")
              ),
              column(6,
                     h4("Correlation & Clustering"),
                     verbatimTextOutput("cluster_details")
              )
            )
          ),
          
          tags$div(class = "card",
            div(class = "card-header", "Dynamic Brushed Data Points Table"),
            p(style = "font-size: 0.9em; color: #666;", "Drag a box over the scatter plot above to display selected records below:"),
            tableOutput("brushed_table")
          )
        ),
        
        # TAB 3: Data Table Explorer
        tabPanel(
          title = tagList(icon("table"), "Dataset Explorer"),
          value = "table",
          
          tags$div(class = "card", style = "margin-top: 15px;",
            div(class = "card-header", 
                span("Searchable Geyser Observations"),
                downloadButton("download_data", "Export to CSV", class = "btn-primary btn-sm")
            ),
            
            # Interactive search and pagination
            fluidRow(
              column(6,
                     sliderInput("search_waiting", "Filter by Waiting Time (mins):", 
                                 min = 40, max = 100, value = c(43, 96))
              ),
              column(6,
                     sliderInput("search_eruptions", "Filter by Eruption Duration (mins):", 
                                 min = 1.5, max = 5.2, value = c(1.6, 5.1), step = 0.1)
              )
            ),
            hr(),
            # Table visualization
            tableOutput("geyser_data_table"),
            
            # Table paging buttons
            fluidRow(
              column(12, align = "center",
                     actionButton("prev_page", "Previous Page", class = "btn-secondary btn-xs"),
                     span(style = "margin: 0 15px; font-weight: bold;", textOutput("page_indicator")),
                     actionButton("next_page", "Next Page", class = "btn-secondary btn-xs")
              )
            )
          )
        ),
        
        # TAB 4: Geyser Info / Documentation
        tabPanel(
          title = tagList(icon("info-circle"), "About Geyser"),
          value = "about",
          
          tags$div(class = "card", style = "margin-top: 15px;",
            div(class = "card-header", "Yellowstone Old Faithful Geyser"),
            tags$h5(strong("Project Overview")),
            p("This interactive R Shiny application explores the landmark Old Faithful Geyser dataset (or 'faithful' in R packages). Old Faithful is a cone geyser located in Yellowstone National Park in Wyoming, United States. It was named in 1870, and was the first geyser in the park to receive a name."),
            tags$hr(),
            tags$h5(strong("Understanding the Variables")),
            tags$ul(
              tags$li(tags$strong("Eruption Duration (eruptions):"), " Duration of the eruption in minutes. The distribution exhibits a clear bimodal shape, indicating two distinct states: short-duration eruptions (around 2 minutes) and long-duration eruptions (around 4.5 minutes)."),
              tags$li(tags$strong("Waiting Time (waiting):"), " Waiting time to the next eruption in minutes. This also shows a strong bimodal pattern, with peaks around 54 minutes and 80 minutes.")
            ),
            tags$hr(),
            tags$h5(strong("Key Geological Insight")),
            p("There is a strong positive correlation between eruption duration and the waiting time to the next eruption. If an eruption is particularly long, the geyser has depleted more storage water and volcanic heat, requiring a longer recharge cycle (hence longer waiting time) before its next eruption."),
            p("The spatial clustering tab uses ", tags$strong("K-Means Clustering"), " under-the-hood to cluster these two bimodal behaviors dynamically! Adjust K from K=1 to K=5 to see how clustering partitions the bimodal geyser behavior.")
          )
        )
      )
    )
  )
)

# Define server logic for building outputs
server <- function(input, output, session) {
  
  # Reactive subsetting of dataset
  geyser_data <- reactive({
    faithful
  })
  
  # --- TAB 1: DISTRIBUTION PLOT LIBRARIES & CALCULATIONS ---
  
  # Selected variable data reactive
  selected_var_data <- reactive({
    col_name <- input$var
    geyser_data()[[col_name]]
  })
  
  # Format column name for labels
  label_name <- reactive({
    if (input$var == "eruptions") "Eruption Duration (minutes)" else "Waiting Time (minutes)"
  })
  
  # Summary stats outputs
  output$stat_mean <- renderText({
    round(mean(selected_var_data()), 2)
  })
  
  output$stat_median <- renderText({
    round(median(selected_var_data()), 2)
  })
  
  output$stat_sd <- renderText({
    round(sd(selected_var_data()), 2)
  })
  
  # Render the distribution histogram
  output$distPlot <- renderPlot({
    x <- selected_var_data()
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    # Set plot parameters with transparent backgrounds and clean margins
    par(mar = c(5, 4, 3, 2) + 0.1, bg = "transparent")
    
    # Draw standard base histogram
    h <- hist(x, breaks = bins, col = input$color_theme, border = "white",
         xlab = label_name(),
         main = paste("Histogram of", label_name()),
         col.main = "#1e3c72", font.main = 2,
         cex.lab = 1.1, cex.axis = 1.0, freq = !input$show_density)
    
    # Overlay Density Plot if requested
    if (input$show_density) {
      d <- density(x)
      lines(d, col = "#2c3e50", lwd = 3)
      polygon(d, col = adjustcolor("#2c3e50", alpha.f = 0.15), border = NA)
    }
    
    # Draw Rug Plot if requested
    if (input$show_rug) {
      rug(x, col = "#e74c3c", lwd = 1.2)
    }
  })
  
  # Display details of clicked / brushed points on the distribution plot
  output$dist_info <- renderUI({
    click <- input$dist_click
    brush <- input$dist_brush
    
    result_html <- NULL
    
    if (!is.null(click)) {
      result_html <- p(
        tags$b("Mouse Click Position:"), 
        round(click$x, 2), 
        style = "margin-top: 10px; font-size: 0.95em;"
      )
    } else if (!is.null(brush)) {
      # Count points inside brush x-range
      x <- selected_var_data()
      count <- sum(x >= brush$xmin & x <= brush$xmax)
      pct <- round(100 * count / length(x), 1)
      result_html <- p(
        tags$b("Selected Range:"), round(brush$xmin, 2), "to", round(brush$xmax, 2),
        br(),
        tags$b("Observations in selection:"), count, sprintf("(%s%% of dataset)", pct),
        style = "margin-top: 10px; font-size: 0.95em;"
      )
    }
    
    if (is.null(result_html)) {
      p("Click or drag a selection box on the histogram to display exact ranges and proportions.", 
        style = "color: #888; font-style: italic; margin-top: 10px; font-size: 0.95em;")
    } else {
      result_html
    }
  })
  
  # --- TAB 2: SCATTER PLOT & K-MEANS CLUSTERING ---
  
  # Reactive clustering
  clustered_faithful <- reactive({
    k <- input$clusters
    # Scale variables for clustering
    scaled_data <- scale(faithful)
    fit <- kmeans(scaled_data, centers = k, nstart = 25)
    
    # Store cluster assignments
    df <- faithful
    df$cluster <- as.factor(fit$cluster)
    
    # Capture additional details for output summary
    list(df = df, size = fit$size, centers = fit$centers, totss = fit$totss, tot.withinss = fit$tot.withinss)
  })
  
  # Render the scatter plot
  output$scatterPlot <- renderPlot({
    cluster_res <- clustered_faithful()
    df <- cluster_res$df
    
    par(mar = c(5, 4.5, 3, 2), bg = "transparent")
    
    # Visual cues for different number of clusters
    # Distinct palettes
    cluster_colors <- c("#2e59d9", "#1cc88a", "#f6c23e", "#e74a3b", "#4e73df")
    
    plot(df$eruptions, df$waiting,
         col = cluster_colors[as.integer(df$cluster)],
         pch = 19, cex = 1.4,
         xlab = "Eruption Duration (minutes)",
         ylab = "Waiting Time (minutes)",
         main = paste("K-Means Clustering: ", input$clusters, "Distinct Behaviors"),
         col.main = "#1e3c72", font.main = 2,
         cex.lab = 1.1)
         
    # Add grid lines
    grid(col = "lightgray", lty = "dotted")
    
    # Add fitting regression line
    abline(lm(waiting ~ eruptions, data = faithful), col = "#858796", lwd = 2, lty = 2)
    legend("bottomright", legend = paste("Cluster", 1:input$clusters),
           col = cluster_colors[1:input$clusters], pch = 19, bty = "n")
  })
  
  # Mouse tooltip logic for scatter plot
  output$scatter_tooltip <- renderUI({
    hover <- input$scatter_hover
    if (is.null(hover)) return(NULL)
    
    # Search nearest point
    point <- nearPoints(faithful, hover, xvar = "eruptions", yvar = "waiting", threshold = 10, maxpoints = 1)
    if (nrow(point) == 0) return(NULL)
    
    # Calculate position
    left_px <- hover$coords_css$x + 10
    top_px <- hover$coords_css$y + 10
    
    # Tooltip HTML box
    style <- sprintf("left: %dpx; top: %dpx;", left_px, top_px)
    
    div(class = "tooltip-box", style = style,
        tags$b("Geyser Active Point"), br(),
        sprintf("Eruption: %s min", round(point$eruptions, 2)), br(),
        sprintf("Wait Time: %s min", round(point$waiting, 2))
    )
  })
  
  # Print correlation and clustering summary
  output$cluster_details <- renderPrint({
    cluster_res <- clustered_faithful()
    fit_lm <- lm(waiting ~ eruptions, data = faithful)
    r_sq <- summary(fit_lm)$r.squared
    
    cat("1. Bivariate Connection Summary:\n")
    cat("----------------------------------\n")
    cat("Pearson Correlation: ", round(cor(faithful$eruptions, faithful$waiting), 3), "\n")
    cat("Linear R-squared:    ", round(r_sq, 4), "\n")
    cat("\n2. K-Means (K =", input$clusters, ") Summary:\n")
    cat("----------------------------------\n")
    for (i in 1:input$clusters) {
      cat(sprintf("   - Active cluster %d contains: %d observations\n", i, cluster_res$size[i]))
    }
    pct_explained <- round(100 * (1 - (cluster_res$tot.withinss / cluster_res$totss)), 1)
    cat(sprintf("Variance Explained (BSS/TSS Ratio): %s%%\n", pct_explained))
  })
  
  # Dynamic brushed points box
  output$brush_summary <- renderPrint({
    brush <- input$scatter_brush
    if (is.null(brush)) {
      cat("No data points are currently selected.\n")
      cat("=> Action: Click and drag a box on the scatter plot above to inspect subset values dynamically.")
      return()
    }
    
    selected_subset <- brushedPoints(faithful, brush, xvar = "eruptions", yvar = "waiting")
    count <- nrow(selected_subset)
    
    cat("Active Subset Selected Metrics:\n")
    cat("-------------------------------\n")
    cat("Count: ", count, "of", nrow(faithful), "points\n")
    if (count > 0) {
      cat("Mean Eruptions Duration:  ", round(mean(selected_subset$eruptions), 2), "mins\n")
      cat("Mean Waiting Interval:   ", round(mean(selected_subset$waiting), 2), "mins\n")
      cat("Max Waiting Cycle:       ", max(selected_subset$waiting), "mins\n")
      cat("Min Waiting Cycle:       ", min(selected_subset$waiting), "mins\n")
    }
  })
  
  # Render the detailed brushed data table
  output$brushed_table <- renderTable({
    brush <- input$scatter_brush
    if (is.null(brush)) {
      # Return a placeholder row
      return(data.frame(
        Eruptions = "Drag a brush box over the scatter plot above.",
        Waiting = "Data points will appear here."
      ))
    }
    
    selected_subset <- brushedPoints(faithful, brush, xvar = "eruptions", yvar = "waiting")
    if (nrow(selected_subset) == 0) {
      return(data.frame(Result = "No points in the current brush bounding box."))
    }
    
    # Formatting columns
    names(selected_subset) <- c("Eruption Duration (mins)", "Waiting time (mins)")
    head(selected_subset, 10)  # limit display to first 10 for clean look
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
  
  
  # --- TAB 3: DATA TABLE EXPLORER PAGINATED ---
  
  # Track current page index
  current_page <- reactiveVal(1)
  rows_per_page <- 10
  
  # Reactive subset matching the filters
  filtered_tbl_data <- reactive({
    df <- faithful
    df <- df[df$waiting >= input$search_waiting[1] & df$waiting <= input$search_waiting[2], ]
    df <- df[df$eruptions >= input$search_eruptions[1] & df$eruptions <= input$search_eruptions[2], ]
    df
  })
  
  # Reset back to page 1 if limits are updated
  observeEvent(c(input$search_waiting, input$search_eruptions), {
    current_page(1)
  })
  
  # Next & Prev button connections
  observeEvent(input$prev_page, {
    if (current_page() > 1) {
      current_page(current_page() - 1)
    }
  })
  
  observeEvent(input$next_page, {
    max_p <- ceiling(nrow(filtered_tbl_data()) / rows_per_page)
    if (current_page() < max_p) {
      current_page(current_page() + 1)
    }
  })
  
  # Display page count label
  output$page_indicator <- renderText({
    tot_rows <- nrow(filtered_tbl_data())
    max_p <- ceiling(tot_rows / rows_per_page)
    if (max_p == 0) max_p <- 1
    sprintf("Page %d of %d (Total count: %d)", current_page(), max_p, tot_rows)
  })
  
  # Dynamic Table display
  output$geyser_data_table <- renderTable({
    df <- filtered_tbl_data()
    if (nrow(df) == 0) {
      return(data.frame(Status = "No matching records found. Please wider your slider bounds."))
    }
    
    # Calculate rows for page
    start_row <- (current_page() - 1) * rows_per_page + 1
    end_row <- min(current_page() * rows_per_page, nrow(df))
    
    # Select rows & format
    page_subset <- df[start_row:end_row, ]
    page_subset <- cbind(ID = rownames(page_subset), page_subset)
    names(page_subset) <- c("Observation ID", "Eruption Duration (mins)", "Waiting Time (mins)")
    page_subset
  }, striped = TRUE, hover = TRUE, bordered = TRUE, align = 'c')
  
  # Export to CSV Handler
  output$download_data <- downloadHandler(
    filename = function() {
      paste("old_faithful_geyser_data-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(filtered_tbl_data(), file, row.names = FALSE)
    }
  )
}

# Run the app
shinyApp(ui = ui, server = server)
