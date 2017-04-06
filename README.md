
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Travis-CI Build Status](https://travis-ci.org/poissonconsulting/rtide.svg?branch=master)](https://travis-ci.org/poissonconsulting/rtide) [![AppVeyor Build status](https://ci.appveyor.com/api/projects/status/598p54bq0m5qv0j1/branch/master?svg=true)](https://ci.appveyor.com/project/joethorley/rtide/branch/master) [![codecov](https://codecov.io/gh/poissonconsulting/rtide/branch/master/graph/badge.svg)](https://codecov.io/gh/poissonconsulting/rtide) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/rtide)](https://cran.r-project.org/package=rtide) [![CRAN Downloads](http://cranlogs.r-pkg.org/badges/grand-total/rtide)](https://cran.r-project.org/package=rtide)

rtide
=====

Introduction
------------

`rtide` is an R package to calculate tide heights.

The included rtide object `noaa` includes the harmonics for 819 reference, and the offsets for 2228 secondary, NOAA tide stations.

Utilisation
-----------

``` r
library(magrittr)
library(stringr)
library(dplyr)
```

``` r
library(rtide)
#> rtide is not suitable for navigation

stations <- rtide::noaa$stations
stations %<>% filter(str_detect(StationName, "Santa Barbara"))
stations
#> # A tibble: 3 × 5
#>   Station Datum Longitude Latitude             StationName
#>     <chr> <dbl>     <dbl>    <dbl>                   <chr>
#> 1 9411340 0.964 -119.6850  34.4083           Santa Barbara
#> 2 TWC0463    NA -119.0333  33.4833    Santa Barbara Island
#> 3 TEC4715    NA  -69.3333  19.2000 Santa Barbara de Samana

datetime <- seq_datetime(from = as.Date("2016-07-13"), minutes = 10L, tz = "PST8PDT")

data <- expand.grid(Station = stations$Station, DateTime = datetime, stringsAsFactors = FALSE) %>% as.tbl()
data
#> # A tibble: 432 × 2
#>    Station            DateTime
#>      <chr>              <dttm>
#> 1  9411340 2016-07-13 00:00:00
#> 2  TWC0463 2016-07-13 00:00:00
#> 3  TEC4715 2016-07-13 00:00:00
#> 4  9411340 2016-07-13 00:10:00
#> 5  TWC0463 2016-07-13 00:10:00
#> 6  TEC4715 2016-07-13 00:10:00
#> 7  9411340 2016-07-13 00:20:00
#> 8  TWC0463 2016-07-13 00:20:00
#> 9  TEC4715 2016-07-13 00:20:00
#> 10 9411340 2016-07-13 00:30:00
#> # ... with 422 more rows

#data %<>% predict_rtide(rtide = rtide::noaa)
```

``` r
library(ggplot2)
library(scales)
```

    ggplot(data = data, aes(x = DateTime, y = TideHeight)) + 
      geom_line() + 
      scale_x_datetime(name = "Date", 
                       labels = date_format("%d %b %Y", tz="PST8PDT")) +
      scale_y_continuous(name = "Tide Height (m)") +
      ggtitle("Monterey Harbour")

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

The code to calculate tide heights from the harmonics is inspired by XTide.

The (deprecated) harmonics data was converted from harmonics-dwf-20151227-free, NOAA web site data processed by David Flater for [XTide](http://www.flaterco.com/xtide/).
