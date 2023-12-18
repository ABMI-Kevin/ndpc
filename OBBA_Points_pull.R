library(httr)
library(tidyverse)
library(sf)
# Define the URL
url <- "https://naturecounts.ca/atlas_data/waypoints/waypoints.txt"
# Make a GET request
response <- GET(url)
res <- list(content(response, as = "text", encoding = "UTF-8"))
# Split the text by line breaks
lines <- unlist(strsplit(res[[1]], "\r\n"))
# Split each line by commas and create a tibble
data <- as_tibble(data.frame(do.call(rbind, strsplit(lines, ","))))
data <- data %>% slice(-1)
# Set column names
colnames(data) <- c("Type", "Coord_System", "Zone", "Zone_Designator", "Easting", "Northing", "Date", "Time")
utm_zones <- c("15", "16", "17", "18")
crs_codes <- c(32615, 32616, 32617, 32618)
data_z <- data %>%
  filter(grepl('^15|^16|^17|^18', Zone_Designator)) %>%
  select(-(Date:Time)) %>%
  select(-(Type:Coord_System)) %>%
  rename("location" = 1) %>%
  mutate(Zone_Numeric = as.numeric(gsub("[^[:digit:]., ]", "", Zone_Designator)))
# Add a new column to the data with the CRS code based on the UTM zone
data_zs <- data_z %>%
  mutate(
    CRS = case_when(
      Zone_Numeric %in% utm_zones ~ crs_codes[match(Zone_Numeric, utm_zones)],
      TRUE ~ NA_integer_
    )
  )
# Create a new spatial object with the assigned CRS per group
splits <- data_zs %>%
  group_split(Zone_Numeric)

split1 <- splits[[1]]
split2 <- splits[[2]]
split3 <- splits[[3]]
split4 <- splits[[4]]

sc1 <- split1 %>%
  st_as_sf(coords = c("Easting", "Northing"), crs = 32615) %>%
  st_transform(4326)

sc2 <- split2 %>%
  st_as_sf(coords = c("Easting", "Northing"), crs = 32616) %>%
  st_transform(4326)

sc3 <- split3 %>%
  st_as_sf(coords = c("Easting", "Northing"), crs = 32617) %>%
  st_transform(4326)

sc4 <- split4 %>%
  st_as_sf(coords = c("Easting", "Northing"), crs = 32618) %>%
  st_transform(4326)

sc <- rbind(sc1, sc2, sc3, sc4)

data_final <- as_tibble(cbind(data_zs, st_coordinates(sc))) %>%
  mutate(location = str_replace(location, "-0", "-"))

write.csv(data_final, "OBBA_pts_full.csv", row.names = FALSE)
