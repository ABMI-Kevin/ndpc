library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("Data Volume Calculator"),
  sidebarLayout(
    mainPanel(
      verbatimTextOutput("output"),
    sidebarPanel(
      numericInput("sample_rate", "Sample Rate (Hz):", value = 44100),
      numericInput("recordings_per_day", "Number of Recordings Per Day:", value = 10),
      numericInput("recording_duration", "Recording Duration (minutes):", value = 5),
      numericInput("days", "Number of survey days:", value = 1)
    )
    )
  )
)

# Define server
server <- function(input, output) {

  # Calculate data volume
  data_volume <- reactive({
    sample_rate <- input$sample_rate
    recordings_per_day <- input$recordings_per_day
    recording_duration <- input$recording_duration
    days <- input$days
    data_volume <- (sample_rate * 60 * recording_duration * recordings_per_day * 2 / 1000000000) * days # in megabytes
    return(data_volume)
  })

  # Display output
  output$output <- renderText({
    paste0("The estimated data volume accumulated is: ", round(data_volume(), 2), " GB.")
  })
}

# Run the app
shinyApp(ui = ui, server = server)
