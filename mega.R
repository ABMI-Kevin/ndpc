library(tidyverse)


ice <- read_csv("/users/alexandremacphail/desktop/ice.csv")


ice %>%
  mutate(treatment = case_when(grepl('Q',location) ~ "Compressed", !grepl('-100$',location) ~ "Resized", TRUE ~ "Original"),
         scale = paste0(str_remove(str_extract(location, '([^\\-]+$)'),"Q"),"%")) %>%
  group_by(location, treatment, scale, species) %>%
  tally() %>%
  rename("Count of tags" = 5) %>%
  ggplot(., aes(x=species, y=`Count of tags`, fill=species)) +
  geom_boxplot() +
  scale_fill_viridis_d() +
  facet_grid(cols = vars(treatment), rows = vars(scale)) +
  theme_bw() +
  ggtitle("Effect of image compression on count of tags from Megadetector V5 and Megaclassifier V0.1",
          subtitle = "
          Images were compressed and resized to 75%, 50%, 25% and 10% of their original size (100%).
          Each treatment (compression, resizing) was done separately.
          Only one image set (1005-NW) of 126 images was used.")

can2 <- can2 %>%
  st_make_valid() %>%
  st_transform(4269) %>%
  st_set_crs(4269)

nnp <- read_sf("/users/alexandremacphail/desktop/nnp/National_Parks_and_National_Park_Reserves_of_Canada_Legislative_Boundaries.shp") %>%
  st_make_valid() %>%
  st_transform(4269) %>%
  st_set_crs(4269)
