#Move name to beginning of file name
library(stringr)
library(tidyverse)

#Set working directory
setwd("C:/Users/Kevin Kelly/Desktop/Hill-Test3")

#Read files
file_names_current <- list.files(pattern = ".WAV")
file_names_current
view(file_names_current)

#Extract location
location <- str_sub(file_names_current, 15, -5)
location

#Extract location string
location_string <- str_sub(file_names_current, 14, -5)
location_string

#Remove location from file name
file_names_no_location <- str_replace(file_names_current, location_string, "")
file_names_no_location

#Rename files without location
file.rename(file_names_current, file_names_no_location)


#############################
#Run python "zoomz" script
#############################


#Get updated file names after zoomz script
file_names_zoomz


#Add location to beginning of file names
file_names_location <- str_c(location, file_names_no_location, sep = "_")
file_names_location

#Extract location name string
x <- str_c(location, "_", current_file_names)
x

str_sub(x, 25, -5) <- ""; x
