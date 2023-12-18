#Rename zoom files with Square/Point locations
library(stringr)
library(tidyverse)

#Set Observer/processing variable
obs_date_var <- "Jesus-20231215"

############################################
#Below this shouldn't require any changes
############################################

#Set working directory
wd <- str_c("C:/Users/Kevin Kelly/Desktop/", obs_date_var, "/Uploaded")
setwd(wd)

#Create csv code
csv_read_name <- str_c(obs_date_var, ".csv", sep = "")
csv_dropped_name <- str_c(obs_date_var, "_dropped", ".csv", sep = "")


zoomz_csv <- read.csv(csv_read_name)
view(zoomz_csv)

#############
#Remove unnecessary lines from csv
#############

#Drop files too short
zoomz_csv_drop1 <- zoomz_csv[zoomz_csv$new_path != "File too short for task length",]

#Check that number of lines matches number of files in folder#
view(zoomz_csv_drop1)

write.csv(zoomz_csv_drop1, file=csv_dropped_name)

#Get current file names - ensure only 1 copy of each exists
current_file_names <- list.files(pattern = ".wav")
current_file_names
view(current_file_names)

#Remove Matchedbyuser location string
current_file_minus <- str_replace(current_file_names, "Matchedbyuser_", "_")
current_file_minus

#Read in csv with metadata Location information - ensure lines with no subsequent file are removed
csv_dropped <- read.csv(csv_dropped_name)
View(csv_dropped)

#Identify location string
location <- csv_dropped$location
location


#Combine new location string with date+time filename
new_file_names <- str_c(location, "", current_file_minus)
new_file_names

#Rename files with location string and date+time
file.rename(current_file_names, new_file_names)
