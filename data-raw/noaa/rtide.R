source("data-raw/noaa/header.R")

harmonics <- readRDS("data-raw/noaa/data/harmonics.rds")
stations <- readRDS("data-raw/noaa/data/stations.rds")
station_datums <- readRDS("data-raw/noaa/data/station_datums.rds")
station_harmonics <- readRDS("data-raw/noaa/data/station_harmonics.rds")
station_offsets <- readRDS("data-raw/noaa/data/station_offsets.rds")

harmonics %<>% select(Harmonic, HarmonicName)

station_harmonics %<>% semi_join(filter(stations, Reference), by = "Station")
station_offsets %<>% semi_join(filter(stations, !Reference), by = "Station")

station_offsets %<>% semi_join(station_harmonics, by = c("ReferenceStation" = "Station"))

stations %<>% filter(Station %in% c(station_harmonics$Station, station_offsets$Station))

stations %<>% left_join(station_datums, by = "Station")

stations %<>% select(Station, Datum, Longitude, Latitude, StationName)

noaa <- list(stations = stations,
               harmonics = harmonics,
               station_harmonics = station_harmonics,
               station_offsets = station_offsets)

class(noaa) <- "rtide"

rtide:::check_rtide(noaa)

use_data(noaa, overwrite = TRUE)
