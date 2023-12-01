library(shiny)
library(qrcode)
library(audio)

shinyApp(

ui <- fluidPage(
  titlePanel("DTMF Tone Generator and QR Code Generator"),
  theme = 'flatly',
  sidebarLayout(
    sidebarPanel(
      textInput("userid", "Enter User ID:"),
      textInput("projectid", "Enter Project ID:"),
      numericInput("latitude", "Enter Latitude:", value = 0),
      numericInput("longitude", "Enter Longitude:", value = 0),
      textInput("time_input", "Enter time", value = strptime("12:34:56", "%T")),
      actionButton("generate", "Generate Stamp"),
      br(),
      actionButton("generateQR", "Generate QR Code"),
      checkboxInput("convert_ultrasonic", "Convert to Ultrasonic Frequencies (+20000 Hz)")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("DTMF Tone", plotOutput("waveform")),
        tabPanel("QR Code", imageOutput("qrcodeImage"))
      )
    )
  )
)
,
server <- function(input, output) {

  dtmf_frequencies <- list(
    "1" = c(697, 1209),
    "2" = c(697, 1336),
    "3" = c(697, 1477),
    "4" = c(770, 1209),
    "5" = c(770, 1336),
    "6" = c(770, 1477),
    "7" = c(852, 1209),
    "8" = c(852, 1336),
    "9" = c(852, 1477),
    "*" = c(941, 1209),
    "0" = c(941, 1336),
    "#" = c(941, 1477),
    "A" = c(697, 1633),
    "B" = c(770, 1633),
    "C" = c(852, 1633),
    "D" = c(941, 1633)
  )

  characters_to_dual_tones <- list(
    "." = "99",
    "," = "88",
    "-" = "77",
    ":" = "66",
    " " = "55"
    # Add more characters and their corresponding dual tones as needed
  )

  output$waveform <- renderPlot({

    req(input$generate)

    user_id <- strsplit(input$userid, "")[[1]]
    project_id <- as.character(input$projectid)
    latitude <- input$latitude
    longitude <- input$longitude
    time_value <- input$time_input

    # Concatenate the input data to create the string for the audio stamp
    audio_stamp <- paste(user_id, project_id, latitude, longitude, time_value, collapse = "")

    digits <- strsplit(audio_stamp, "")[[1]]
    tones <- list()

    for (digit in digits) {
      if (digit %in% names(characters_to_dual_tones)) {
        dual_tone_sequence <- characters_to_dual_tones[[digit]]
        frequencies <- sapply(strsplit(dual_tone_sequence, "")[[1]], function(digit) dtmf_frequencies[[digit]])
        t <- seq(0, 0.05, by = 1/44100)
        tone1 <- sin(2 * pi * frequencies[1, ] * t)
        tone2 <- sin(2 * pi * frequencies[2, ] * t)
        amplitude1 <- 0.5
        amplitude2 <- 0.5
        dual_tone <- (amplitude1 * tone1 + amplitude2 * tone2)
      } else {
        if (!(digit %in% names(dtmf_frequencies)) | is.na(digit)) {
          stop(paste("Invalid digit:", digit))
        }

        frequencies <- dtmf_frequencies[[digit]]

        t <- seq(0, 0.05, by = 1/44100)

        tone1 <- sin(2 * pi * frequencies[1] * t)
        tone2 <- sin(2 * pi * frequencies[2] * t)

        amplitude1 <- 0.5  # Amplitude of tone 1
        amplitude2 <- 0.5  # Amplitude of tone 2

        dual_tone <- (amplitude1 * tone1 + amplitude2 * tone2)
      }

      # Apply ultrasonic conversion if checkbox is checked
      if (input$convert_ultrasonic) {
        ultrasonic_frequency <- 20000
        t_ultrasonic <- seq(0, 0.05, by = 1/88200) # Higher sample rate for ultrasonic
        ultrasonic_tone <- sin(2 * pi * ultrasonic_frequency * t_ultrasonic)
        dual_tone <- c(dual_tone, rep(0, length(t_ultrasonic) - length(dual_tone))) + ultrasonic_tone
      }

      tones <- c(tones, dual_tone)

      silence <- rep(0, round(0.01 * 44100))

      tones <- c(tones, silence)
    }

    combined_tones <- unlist(tones)

    plot(combined_tones, type = "l", xlab = "Time", ylab = "Amplitude", main = "Generated DTMF Tone")

    play(combined_tones, rate = 44100)

  })

  output$qrcodeImage <- renderImage({

    req(input$generateQR)

    qr_code <- qr_code(paste(input$userid, input$projectid, input$latitude, input$longitude, input$time_value))

    # Save the QR code as a temporary file
    tmp_file <- tempfile(fileext = ".png")
    png(tmp_file)
    plot(qr_code, asp = 1)
    dev.off()

    list(src = tmp_file, alt = "QR Code")
  }, deleteFile = TRUE)

})
