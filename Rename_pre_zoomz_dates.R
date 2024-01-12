# Rename zoom files by adding Square/Point locations to file names
# AND changing Date/Time to be accurate in filename from csv file

library(stringr)
library(tidyverse)

#Set Observer/processing variable
obs_date_var <- "Kay-20240111"

############################################
#Below this shouldn't require any changes
############################################

#Set working directory
wd <- str_c("C:/Users/Kevin Kelly/Desktop/", obs_date_var)
setwd(wd)

#Read in new filename
file_rename_csv <- str_c(obs_date_var, "-rename.csv", sep = "")
View(file_rename_csv)

file_rename <- read.csv(file_rename_csv)
view(file_rename)

#Check that number of lines in csv with location data matches number of files in folder
nrow(file_rename)
length(list.files(pattern = ".WAV"))
identical(nrow(file_rename), length(list.files(pattern = ".WAV")))

#Get current file names - ensure only 1 copy of each exists
filenames_current <- list.files(pattern = ".WAV")
filenames_current

#Combine new location string with date+time filename
filenames_new <- file_rename$filename_new
filenames_new

length(filenames_current)
length(filenames_new)

#Rename files with location string and date+time
file.rename(filenames_current, filenames_new)
