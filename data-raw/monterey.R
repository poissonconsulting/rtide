library(devtools)
library(readr)
library(lubridate)
library(dplyr)
library(tidyr)
library(magrittr)
library(rtide)

rm(list = ls())

# From http://tidesandcurrents.noaa.gov/noaatidepredictions/NOAATidesFacade.jsp?Stationid=9413450

monterey <- read_tsv("data-raw/9413450.txt", skip = 13)
monterey %<>% mutate(Station = "9413450")

monterey %<>% select(Station, Date, Time, TideHeight = Pred) %>%
  unite(DateTime, Date, Time, sep = " ")

monterey %<>% mutate(DateTime = ymd_hms(DateTime, tz = "PST8PDT"),
                     TideHeight = rtide:::ft2m(TideHeight))

use_data(monterey, overwrite = TRUE)
