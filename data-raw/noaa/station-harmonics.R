source("data-raw/noaa/header.R")

get_station_harmonics <- function(x, harmonics, html) {
  stopifnot(nrow(x) == 1)

  html %<>% str_c("/harcon.html?unit=0&timezone=0&id=", x$Station) # harmonics for m in GMT

  table <- read_html(html) %>% html_nodes("table.table.table-striped") %>% html_table()

  if (!length(table)) return(NULL)

  table <- table[[1]]

  x %<>% merge(table, by = NULL)

  if (!identical(x$Name, harmonics$Harmonic)) return(NULL)
  stopifnot(!identical(x$Speed, harmonics$Speed))

  x %<>% select(Station, Harmonic = Name, Amplitude, Phase)

  x
}

get_stations_harmonics <- function(x, harmonics, html) {
  x %<>% filter(Reference)
  x %<>% alply(.margins = 1,  .progress = "text", get_station_harmonics, harmonics = harmonics, html = html)
  x %<>% bind_rows()
  x %<>% as.tbl()
  x
}

harmonics <- readRDS("data-raw/noaa/data/harmonics.rds")

stations <- readRDS("data-raw/noaa/data/stations.rds")

station_harmonics <- get_stations_harmonics(stations, harmonics, html)

saveRDS(station_harmonics, "data-raw/noaa/data/station_harmonics.rds")
