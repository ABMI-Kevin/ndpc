# Rename zoom files by adding Square/Point locations to file names from csv file

library(stringr)
library(tidyverse)

#Set Observer/processing variable
obs_date_var <- "Kirkland-20240108"

############################################
#Below this shouldn't require any changes
############################################

#Set working directory
wd <- str_c("C:/Users/Kevin Kelly/Desktop/", obs_date_var, "/Uploaded")
setwd(wd)

#Create csv code
csv_locations_name <- str_c(obs_date_var, ".csv", sep = "")
csv_locations_dropped_name <- str_c(obs_date_var, "_dropped", ".csv", sep = "")


zoomz_locations <- read.csv(csv_locations_name)
view(zoomz_locations)

#############
#Remove unnecessary lines from csv
#############

#Drop files too short
zoomz_locations_drop <- zoomz_locations[zoomz_locations$new_path != "File too short for task length",]

#Check that number of lines in csv with location data matches number of files in folder
nrow(zoomz_locations_drop)
length(list.files(pattern = ".wav"))
identical(nrow(zoomz_locations_drop), length(list.files(pattern = ".wav")))

write.csv(zoomz_locations_drop, file=csv_locations_dropped_name)

#Get current file names - ensure only 1 copy of each exists
current_file_names <- list.files(pattern = ".wav")
current_file_names

#Remove Matchedbyuser location string
current_file_minus <- str_replace(current_file_names, "Matchedbyuser_", "_")
current_file_minus

#Read in csv with Location information - ensure lines with no subsequent file were removed
locations_dropped <- read.csv(csv_locations_dropped_name)
View(locations_dropped)

#Identify location string
location <- locations_dropped$location
location

#Combine new location string with date+time filename
new_file_names <- str_c(location, "", current_file_minus)
new_file_names

#Rename files with location string and date+time
file.rename(current_file_names, new_file_names)
