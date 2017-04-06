source("data-raw/noaa/header.R")

get_station_datum <- function(x, html) {
  stopifnot(nrow(x) == 1)

  html %<>% str_c("/datums.html?units=1&epoch=0&id=", x$Station) # datums in m

  table <- read_html(html) %>% html_table()

  if (!length(table)) return(NULL)

  table <- table[[1]]

  table %<>% filter(Datum == "MSL")

  x$Datum <- table$Value %>% as.numeric()

  x %<>% select(Station, Datum)

  x
}

get_stations_datum <- function(x, html) {
  x %<>% filter(Reference)
  x %<>% alply(.margins = 1,  .progress = "text", get_station_datum, html = html)
  x %<>% bind_rows()
  x %<>% as.tbl()
  x
}

stations <- readRDS("data-raw/noaa/data/stations.rds")

station_datums <- get_stations_datum(stations, html)

saveRDS(station_datums, "data-raw/noaa/data/station_datums.rds")
