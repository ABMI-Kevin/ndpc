generate_stamp <- function(digits) {

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

  digits <- strsplit(digits, "")[[1]]

  tones <- list()

  for (digit in digits) {
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

    tones <- c(tones, dual_tone)

    silence <- rep(0, round(0.01 * 44100))

    tones <- c(tones, silence)

  }

  combined_tones <- unlist(tones)

  dt <- audio::play(combined_tones, rate = 44100)

  return(dt)

}

#versionid
#userid - token
#location
#timestamp
#checksum
#errorcorrection/repetition

generate_stamp("AA**DDDD**54#316402**118#43872**222235*34")
