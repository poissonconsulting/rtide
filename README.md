
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/poissonconsulting/rtide.svg?branch=master)](https://travis-ci.org/poissonconsulting/rtide) [![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/598p54bq0m5qv0j1/branch/master?svg=true)](https://ci.appveyor.com/project/joethorley/rtide/branch/master) [![codecov](https://codecov.io/gh/poissonconsulting/rtide/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/rtide) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/rtide)](https://cran.r-project.org/package=rtide) [![CRAN Downloads](http://cranlogs.r-pkg.org/badges/grand-total/rtide)](https://cran.r-project.org/package=rtide)

rtide
=====

Introduction
------------

`rtide` is an R package to calculate tide heights and the timing of slack tides.

The object `rtide::noaa` allows predictions for 3042 [NOAA](https://tidesandcurrents.noaa.gov) tide stations.

Utilisation
-----------

``` r
# load helper packages
library(ggplot2)
library(lubridate)
library(magrittr)
library(scales)
library(stringr)
library(dplyr)
```

``` r
library(rtide)
#> rtide is not suitable for navigation

# get all tide stations
data <- rtide::noaa$stations 

# select Monterey by name
data %<>% filter(str_detect(StationName, "Monterey,")) 
data
#> # A tibble: 1 × 5
#>   Station Datum Longitude Latitude            StationName
#>     <chr> <dbl>     <dbl>    <dbl>                  <chr>
#> 1 9413450 1.893  -121.888   36.605 Monterey, Monterey Bay

# set up date times for predictions
datetime <- rtide::seq_datetime(from = as.Date("2016-07-13"), to = as.Date("2016-07-15"), minutes = 10L, tz = "PST8PDT") 

# add to stations
data %<>% merge(data_frame(DateTime = datetime)) %>% as.tbl()

# predict tide heights
data %<>% rtide::predict_tide_height(rtide = rtide::noaa)
```

``` r
# plot tide heights
ggplot(data = data, aes(x = DateTime, y = TideHeight)) + 
  geom_line() + 
  scale_x_datetime(name = "Date", labels = date_format("%d %b %Y", tz = tz(data$DateTime))) +
  scale_y_continuous(name = "Tide Height (m)") +
  ggtitle(str_c(data$StationName[1], " (", data$Station[1],")"))
```

![](tools/README-unnamed-chunk-4-1.png)

Installation
------------

To install the release version from CRAN

    install.packages("rtide")

Or the development version from GitHub

    # install.packages("devtools")
    devtools::install_github("poissonconsulting/rtide")

Contribution
------------

Please report any [issues](https://github.com/poissonconsulting/rtide/issues).

[Pull requests](https://github.com/poissonconsulting/rtide/pulls) are always welcome.

Inspiration
-----------

The code to calculate tide heights from the harmonics is inspired by [XTide](http://www.flaterco.com/xtide/).
