library(magrittr)
library(stringr)
library(plyr)
library(rgdal)
library(maptools)
library(dplyr)
library(rvest)

rm(list = ls())

get_tide_stations <- function(x, html) {

  html <- str_c(html, x)

  table <- read_html(html) %>% html_nodes("table") %>% html_table()
  table <- table[[1]]

  if (is.null(table$Lon)) table$Lon <- NA_character_

  table %<>% select(Station = Name, ID = Id, Latitude = Lat, Longitude = Lon, Type = Predictions)

  table %<>% filter(Type != "&nbsp")

  table$Station %<>% str_replace_all("&nbsp", "") %>% str_replace_all(" {2,}", "") %>%
    str_replace("^ ", "") %>% str_replace(" $", "")

  table$ID %<>% as.character()
  table$Latitude %<>% as.numeric()
  table$Longitude %<>% as.numeric()
  table %<>% as.tbl()
  table
}

html <- "https://tidesandcurrents.noaa.gov"
tide_stations <- read_html(str_c(html, "/tide_predictions.html")) %>% html_nodes(xpath = "//table//td//a") %>% html_attrs()
tide_stations %<>% lapply(get_tide_stations, str_c(html, "/tide_predictions.html")) %>% bind_rows()

get_offset_tide_station <- function(x, html) {
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

  x
}

get_offsets_tide_stations <- function(x, html) {
  x %<>% filter(Type == "Subordinate")
  x %<>% adply(.margins = 1, .progress = "text", get_offset_tide_station, html = html)
  x %<>% as.tbl()
  x
}

get_harmonics_tide_station <- function(x, html) {
  stopifnot(nrow(x) == 1)
  html %<>% str_c("/harcon.html?id=", x$ID)

  table <- read_html(html) %>% html_nodes("table.table.table-striped") %>% html_table()
  if (length(table)) {
    table <- table[[1]]
    table %<>% select(Harmonic = Name, Amplitude, Phase, Speed)
  } else
    table <- data_frame(Harmonic = NA_character_, Amplitude = NA_real_, Phase = NA_real_, Speed = NA_real_)

  x %<>% merge(table, by = NULL)
  x
}

get_harmonics_tide_stations <- function(x, html) {
  x %<>% filter(Type == "Harmonic")
  x %<>% adply(.margins = 1,  .progress = "text", get_harmonics_tide_station, html = html)
  as.tbl(x)
  x
}

#offsets <- get_offsets_tide_stations(tide_stations, html)

harmonics <- get_harmonics_tide_stations(tide_stations, html)

# need to update harmonics with IDs...


#
# aa = text
#
#
# result<-str_trim(result,"both")
# result<-gsub("Referenced to Station\\:","",result)
# result<-gsub("Time offset in mins \\(","",result)
# result<-gsub("Height offset in feet \\(","",result)
# result<-gsub("\\)","",result)
# result<-gsub("\\(","",result)
# result<-gsub("\\)\\\n","",result)
# result<-str_trim(result,"both")
# result<-str_split(result,"  ")
# result<-str_trim(result[[1]],"both")
# bb$ref_station[j]<-result[1]
# bb$time_offset[j]<-result[2]
# bb$height_offset[j]<-result[3]
#
#
# head(dataOut)
# dataOut<-dataOut[!duplicated(dataOut),]
# dataOut<-select(dataOut,-c(dup))
#
# # split out all the parameters
# dataOut$ref_station_id<-str_extract(dataOut$ref_station,"[0-9]{7}")
# dataOut$ref_station_name<-gsub("[0-9]{7}","",dataOut$ref_station)
# dataOut$ref_station_name<-str_trim(dataOut$ref_station_name)
# dataOut$time_offset_high<-str_extract((dataOut$time_offset),"-?\\d{1,}")
# dataOut$time_offset_low<-str_extract((dataOut$time_offset),"-?\\d{1,}$")
# dataOut$height_offset_high<-str_extract((dataOut$height_offset),"[\\-\\+\\*\\s.]{1,}\\d{1,}.\\d{1,}")
# dataOut$height_offset_low<-str_extract((dataOut$height_offset),"[\\-\\+\\*\\s\\*]{1,}\\d{1,}.\\d{1,}$")
#
# stations<-dataOut
#
#
# @####### set timezones
#
#
# # Load stations data
# stations<-readRDS("D:/tide.station.rda")
#
# # download file from: http://www.naturalearthdata.com/http//www.naturalearthdata.com/download/10m/cultural/ne_10m_time_zones.zip
# # Read Shape File
# b<-readShapePoly("D:/ne_10m_time_zones/ne_10m_time_zones")
# Data_sp<-as.data.frame(stations)
# Data_sp$Lat<-as.numeric(gsub("+",'',Data_sp$Lat))
# Data_sp$Lon<-as.numeric(gsub("+",'',Data_sp$Lon))
# head(Data_sp)
# # Make spatialpoints dataframe
# coordinates(Data_sp)<-cbind(Data_sp$Lon,Data_sp$Lat)
#
# # Use over to do a patial join getting the attributes from the shape file for each point
# pts_over_tz <- over(Data_sp, b)
#
# # Add the timezone name to your data
# stations$timezone<-as.character(pts_over_tz$tz_name1st)
#
# # Save
# saveRDS(stations,"D:/tide.station.rda")
#
#  set ID for harmonics
#  library(stringr)
# library(dplyr)
# library(rvest)
# library(rtide)
# noaa_tide <- read_html("https://tidesandcurrents.noaa.gov/tide_predictions.html")
# noaa_tide %>% html_nodes(xpath = "//table//td//a") %>% html_attrs() ->a
# dataOut<-NULL
# head(a)
# #get info for each tide station then subset for subordinate stations only
# for(i in 1:length(a)){
#   noaa_tide_temp <- read_html(paste0("https://tidesandcurrents.noaa.gov/tide_predictions.html",a[i]))
#   noaa_tide_temp %>% html_nodes("table") %>% html_table() ->b
#   b<-b[[1]][b[[1]]$Predictions!="&nbsp",]
#   head(b)
#
#   noaa_tide_temp %>% html_nodes(xpath="//table//tr//td/a") %>% html_attrs() ->bb
#   b$path<-(unlist(bb))
#   bb<-b[b$Predictions=="Harmonic",]
#
#   bb$Id<-as.character(bb$Id)
#   bb$Lat<-as.character(bb$Lat)
#   bb$Lon<-as.character(bb$Lon)
#
#   dataOut<-bind_rows(dataOut,bb)
# }
#
# head(dataOut)
# dataOut$Name<-gsub("&nbsp",'',dataOut$Name)
# dataOut<-dataOut[!duplicated(dataOut),]
# harmonic_stations<-dataOut
#
# harmonic_stations$Lat<-as.numeric(gsub("+",'',harmonic_stations$Lat))
# harmonic_stations$Lon<-as.numeric(gsub("+",'',harmonic_stations$Lon))
#
# rhar<-rtide::harmonics$Station
# rhar_full<-rtide::harmonics$Node
# # loop through the rtide::harmonics$Station data and match latitude and longitude to the data from the noaa site.
# # I had to round the lat/lon values when matching to 3 decimals because the same site in some cases were off by a little
# rhar$Id<-NA
# for(i in 1:nrow(rhar)){
#   rhar$Id[round(rhar$Longitude,3)==round(harmonic_stations$Lon[i],3)&
#           round(rhar$Latitude,3)==round(harmonic_stations$Lat[i],3)]<-harmonic_stations$Id[i]
# }
#
# head(rhar)
#
# table(unique(stations$ref_station_id)%in%rhar$Id)
# table(is.na(rhar$Id))
#
# stations[stations$ref_station_id=="9751401",]
# harmonic_stations[harmonic_stations$Id=="9751401",]
#
# # Save
# saveRDS(harmonic_stations,"D:/harmonic_stations.rda")
# saveRDS(rhar,"D:/new_harmonic_with_ref_id.rda")
