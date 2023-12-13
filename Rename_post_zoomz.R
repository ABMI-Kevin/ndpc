#Rename zoom files with Square/Point locations
library(stringr)
library(tidyverse)

#Set working directory
setwd("C:/Users/Kevin Kelly/Desktop/Thompson-20231207")

#############
#Remove unnecessary lines from csv
#############
#Create csv code
csv_name <- "Thompson_20231207"
csv_read_name <- paste(csv_name, ".csv", sep = "")
csv_write_name <- paste(csv_name, "_dropped", ".csv", sep = "")

test_csv <- read.csv(csv_read_name)
view(test_csv)

#Drop files too short
test_csv_drop1 <- test_csv[test_csv$new_path != "File too short for task length",]
view(test_csv_drop)

#Drop nonsense files
test_csv_drop2 <- test_csv_drop1[test_csv_drop1$Location != "Nonsense",]
view(test_csv_drop2)

write.csv(test_csv_drop2,file=csv_write_name)



#Get current file names - ensure only 1 copy of each exists
current_file_names <- list.files(pattern = ".wav")
current_file_names
view(current_file_names)

#Remove nonsense location string
current_file_minus <- str_replace(current_file_names, "Matchedbyuser_", "_")
current_file_minus

#Read in csv with metadata Location information - ensure lines with no subsequent file are removed
csv <- read.csv("Thompson_20231207_dropped.csv")
View(csv)
str(csv)

#Identify location string
location <- csv$Location
location


#Combine new location string with date+time filename
new_file_names <- str_c(location, "", current_file_minus)
new_file_names

#Rename files with location string and date+time
file.rename(current_file_names, new_file_names)



