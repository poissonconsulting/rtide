library(magrittr)
library(stringr)
library(plyr)
library(rgdal)
library(maptools)
library(dplyr)
library(rvest)
library(TideHarmonics)

rm(list = ls())

ft_2_m <- function(x) x * 0.3048

html <- "https://tidesandcurrents.noaa.gov"
