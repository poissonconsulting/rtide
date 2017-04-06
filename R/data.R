#' Harmonics
#'
#' A object of class tide_harmonics providing tidal harmonic data for US stations.
#' Converted from harmonics-dwf-20151227-free, NOAA web site data processed by David Flater for XTide.
#'
#' harmonics is deprecated. Please use \code{\link{noaa}} and predict instead.
"harmonics"

#' noaa
#'
#' A object of class rtide providing harmonics data for xx NOAA tide stations and offsets for additional 2,226 NOAA tide stations.
#'
#' The information was scraped from \url{"https://tidesandcurrents.noaa.gov"} on April 5, 2017.
"noaa"

#' Monterey Tide Height Data
#'
#' High/Low Tide Predictions from \url{http://tidesandcurrents.noaa.gov/tide_predictions.html}.
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{Station}{The station name (chr).}
#'   \item{DateTime}{The date time (time).}
#'   \item{TideHeight}{The tide height in m (dbl).}
#' }
"monterey"

#' Brandywine Tide Height Data
#'
#' High/Low Tide Predictions from \url{http://tidesandcurrents.noaa.gov/tide_predictions.html}.
#'
#' @format A tbl data frame:
#' \describe{
#'   \item{Station}{The station name (chr).}
#'   \item{DateTime}{The date time (time).}
#'   \item{TideHeight}{The tide height in m (dbl).}
#' }
"brandywine"
