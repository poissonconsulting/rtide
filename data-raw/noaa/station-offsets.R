source("data-raw/noaa/header.R")

get_station_offsets <- function(x, html) {
  stopifnot(nrow(x) == 1)
  html %<>% str_c("/noaatidepredictions/NOAATidesFacade.jsp?Stationid=", x$ID)
  text <- read_html(html) %>% html_nodes(xpath="//div//div//ul//div//div//div//div") %>% html_text()

  text %<>% str_c(collapse = "\t") %>% str_replace_all("\n", "\t")

  x$Datum <- str_replace(text, "(.*Datum:\\s+)([^\t]+)(.*)", "\\2")
  x$Units <- str_replace(text, "(.*Daily Tide Prediction in\\s+)([^\\s]+)(.*)", "\\2")
  x$TimeZone <- str_replace(text, "(.*Time Zone:\\s+)([\\w//]+)(Datum:.*)", "\\2")

  text <- read_html(html) %>% html_nodes(xpath = "//p") %>% html_text()
  text <- text[str_detect(text, "Referenced")]

  x$ReferenceID <- str_replace(text, "(.*Referenced to Station:[^\\(]+\\(\\s+)(\\w+)(\\s+\\).*\n)", "\\2")
  x$TimeOffset <- str_replace(text, "(.*Time offset in mins\\s+\\()(.*)(\\)\\s+Height offset.*)", "\\2")
  x$HeightOffset <- str_replace(text, "(.*Height offset in feet\\s+\\()(.*)(\\)\n.*)", "\\2")

  print(x)
  stop()

  x
}

get_stations_offsets <- function(x, html) {
  x %<>% filter(!Reference)
  x %<>% alply(.margins = 1, .progress = "text", get_station_offsets, html = html)
  x %<>% bind_rows()
  x %<>% as.tbl()
  x
}

stations <- readRDS("data-raw/noaa/data/stations.rds")

station_offsets <- get_stations_offsets(stations, html)

saveRDS(station_offsets, "data-raw/noaa/data/station_offsets.rds")
