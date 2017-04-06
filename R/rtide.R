#' Is rtide
#'
#' @param x The object to test
#' @return A flag indicating whether x is an object of class rtide
#' @export
is.rtide <- function(x) {
  inherits(x, "rtide")
}

check_rtide <- function(x) {
  if (!is.rtide(x)) error("x must be an object of class 'rtide'")
  if (!is.list(x)) error("x must be a list")

  if (!all(c("stations", "harmonics", "station_harmonics", "station_offsets") %in% names(x)))
    error("x must include the named objects 'stations', 'harmonics', 'station_harmonics' and 'station_offsets'")

  check_data2(x$stations, values = list(Station = "", Datum = c(1, NA), Longitude = c(-180, 180), Latitude = c(-180, 180), StationName = ""),
              key = "Station")

  check_data2(x$harmonics, values = list(Harmonic = "", HarmonicName = ""),
              key = "Harmonic")

  check_key(x$harmonics, key = "HarmonicName")

  check_join(x$harmonics, TideHarmonics::harmonics, join = c("HarmonicName" = "name"))

  check_data2(x$station_harmonics, values = list(Station = "", Harmonic = "", Amplitude = c(0, 10), Phase = c(0, 360)),
              key = c("Station", "Harmonic"))

  check_join(x$station_harmonics, dplyr::filter_(x$stations, ~!is.na(Datum)), join = "Station")
  check_join(x$station_harmonics, x$harmonics, join = "Harmonic")

  check_data2(x$station_offsets, values = list(
    Station = "", ReferenceStation = "", TimeHigh = c(-1000,1000), TimeLow = c(-1000,1000),
    HeightHigh = "", HeightLow = ""),
              key = c("Station"))

  check_join(x$station_offsets, dplyr::filter_(x$stations, ~is.na(Datum)), join = "Station")
  check_join(x$station_offsets, dplyr::filter_(x$stations, ~!is.na(Datum)), join = c("ReferenceStation" = "Station"))

  if (!all(x$stations$Station %in% c(x$station_harmonics$Station, x$station_offsets$Station)))
    error("all stations must be in station_harmonics and station_offsets")

  x
}

#' @export
subset.rtide <- function(x, stations) {
  check_vector(stations, "")
  stations %<>% unique()
  if (!all(stations %in% x$stations$Station)) error("unrecognized stations")

  x$station_offsets %<>% filter(Station %in% stations)
  print(c(stations, x$station_offsets$ReferenceStation))
  x$stations %<>% filter(Station %in% c(stations, x$station_offsets$ReferenceStation))
  x$station_harmonics %<>% filter(Station %in% x$stations$Station)
  x
}

