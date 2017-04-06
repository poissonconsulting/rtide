library(devtools)
library(readr)
library(lubridate)
library(dplyr)
library(tidyr)
library(magrittr)
library(rtide)

rm(list = ls())

# From http://tidesandcurrents.noaa.gov/noaatidepredictions/NOAATidesFacade.jsp?Stationid=9413450

brandywine <- read_tsv("data-raw/8555889.txt", skip = 13)
brandywine %<>% mutate(Station = "8555889")

brandywine %<>% select(Station, Date, Time, TideHeight = Pred) %>%
  unite(DateTime, Date, Time, sep = " ")

brandywine %<>% mutate(DateTime = ymd_hms(DateTime, tz = "EST5EDT"),
                     TideHeight = rtide:::ft2m(TideHeight))

use_data(brandywine, overwrite = TRUE)
