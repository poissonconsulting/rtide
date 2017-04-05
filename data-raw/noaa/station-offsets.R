source("data-raw/noaa/header.R")

get_station_offsets <- function(x, html) {
  stopifnot(nrow(x) == 1)

  x %<>% select(Station)

  html %<>% str_c("/noaatidepredictions/NOAATidesFacade.jsp?Stationid=", x$Station)

  text <- read_html(html) %>% html_nodes(xpath = "//p") %>% html_text()
  text <- text[str_detect(text, "Referenced")]

  x$ReferenceStation <- str_replace(text, "(.*Referenced to Station:[^\\(]+\\(\\s+)(\\w+)(\\s+\\).*\n)", "\\2")
  time_offset <- str_replace(text, "(.*Time offset in mins\\s+\\()(.*)(\\)\\s+Height offset.*)", "\\2")
  height_offset <- str_replace(text, "(.*Height offset in feet\\s+\\()(.*)(\\)\n.*)", "\\2")

  x$TimeOffsetHigh <- str_replace(time_offset, "(.*high:\\s*)(.*)(\\s+low:.*\n)", "\\2") %>% str_replace_all("\\s{1,}", "") %>% as.numeric()
  x$TimeOffsetLow <- str_replace(time_offset, "(.*low:\\s*)(.*)(\\s+.*)", "\\2") %>% str_replace_all("\\s{1,}", "") %>% as.numeric()

  x$HeightOffsetHigh <- str_replace(height_offset, "(.*high:\\s*)(.*)(\\s+low:.*)", "\\2") %>% str_replace_all("\\s{1,}", "")
  x$HeightOffsetLow <- str_replace(height_offset, "(.*low:\\s*)(.*)", "\\2") %>% str_replace_all("\\s{1,}", "")

  if (!str_detect(x$HeightOffsetHigh, "^[*]")) x$HeightOffsetHigh %<>% as.numeric() %>% ft_2_m() %>% as.character()
  if (!str_detect(x$HeightOffsetLow, "^[*]")) x$HeightOffsetLow %<>% as.numeric() %>% ft_2_m() %>% as.character()
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
