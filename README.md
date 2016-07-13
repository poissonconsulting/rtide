
<!-- README.md is generated from README.Rmd. Please edit that file -->
rtide
=====

R package to calculate tide heights

``` r
library(ggplot2)
library(rtide)
#> rtide is not suitable for navigation
data <- tide_height(
  "Monterey Harbor", from = as.Date("2015-01-01"), to = as.Date("2015-01-01"),
  minutes = 10L, tz = "PST8PDT")

ggplot(data = data, aes(x = DateTime, y = TideHeight)) + 
  geom_line() + 
  scale_x_datetime(name = "January 1st, 2015", date_labels = "%H:%M") +
  scale_y_continuous(name = "Tide Height (m)") +
  ggtitle(data$Station[1]) +
  expand_limits(y = 0)
```

![](README-unnamed-chunk-2-1.png)
