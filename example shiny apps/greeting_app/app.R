library(shiny)

# Define UI for application that prints a greeting
ui <- fluidPage(
  theme = bslib::bs_theme(version = 5, bootswatch = "flatly"),
  
  titlePanel("Shiny Greeting App"),
  
  sidebarLayout(
    sidebarPanel(
      textInput(
        inputId = "name_input",
        label = "What is your name?",
        value = "",
        placeholder = "Type your name here..."
      ),
      actionButton(
        inputId = "greet_btn",
        label = "Say Hello",
        class = "btn-primary w-100"
      )
    ),
    
    mainPanel(
      # We use HTML output to allow rich styling of the greeting
      uiOutput("greeting_output")
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive expression to structure the greeting when the button is clicked
  greeting <- eventReactive(input$greet_btn, {
    name <- trimws(input$name_input)
    if (name == "") {
      return("Please enter a name above to get started!")
    } else {
      return(paste("Hello, ", name, "! Welcome to Shiny. Have a wonderful day!", sep = ""))
    }
  }, ignoreNULL = FALSE) # run on startup to show instructions/prompt
  
  # Render the greeting with clear typography and styling
  output$greeting_output <- renderUI({
    text <- greeting()
    
    if (text == "Please enter a name above to get started!") {
      div(
        class = "alert alert-info mt-3",
        role = "alert",
        text
      )
    } else {
      div(
        class = "p-4 bg-light border rounded mt-3 text-center",
        h2(text, class = "text-primary fw-bold")
      )
    }
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
