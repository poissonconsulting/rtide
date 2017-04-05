source("data-raw/noaa/header.R")

get_stations <- function(x, html) {

  html <- str_c(html, x)

  table <- read_html(html) %>% html_nodes("table") %>% html_table()
  table <- table[[1]]

  if (is.null(table$Lon)) table$Lon <- NA_character_

  table %<>% filter(Predictions != "&nbsp")

  table$Name %<>% str_replace_all("&nbsp", "") %>% str_replace_all(" {2,}", "") %>%
    str_replace("^ ", "") %>% str_replace(" $", "")

  table$Reference <- table$Predictions == "Harmonic"

  table %<>% select(Station = Id, Reference, Longitude = Lon, Latitude = Lat, StationName = Name)

  table$Station %<>% as.character()
  table$Latitude %<>% as.numeric()
  table$Longitude %<>% as.numeric()
  table %<>% as.tbl()

  table
}

stations <- read_html(str_c(html, "/tide_predictions.html")) %>% html_nodes(xpath = "//table//td//a") %>% html_attrs()
stations %<>% lapply(get_stations, str_c(html, "/tide_predictions.html")) %>% bind_rows()

saveRDS(stations, "data-raw/noaa/data/stations.rds")

