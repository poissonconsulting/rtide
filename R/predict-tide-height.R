add_corrections <- function(rtide, date) {
  lamb <- TideHarmonics::lambdas(date)
  adj <- nodal_adj(lamb[3,], lamb[4,], lamb[5,])

  adj <- dplyr::data_frame(Harmonic = rownames(adj[[1]]), AmplitudeCor = adj$fn[,1], PhaseAdj = adj$un[,1])

  rtide$station_harmonics$AmplitudeCor <- NULL
  rtide$station_harmonics$PhaseAdj <- NULL

  rtide$station_harmonics %<>% dplyr::left_join(adj, by = "Harmonic")
  rtide
}

add_speeds <- function(rtide) {
  rtide$station_harmonics$Speed <- NULL
  rtide$station_harmonics %<>% dplyr::inner_join(dplyr::select_(TideHarmonics::harmonics, Harmonic = ~name, Speed = ~speed), by = "Harmonic")
  rtide
}

predict_rtide_height_reference_station_datetime <- function(date_time, rtide) {
  rtide %<>% add_corrections(date_time)

  print(rtide$stations$Datum)
  print(rtide$station_harmonics)

  rtide$station_harmonics %<>% dplyr::mutate_(Term = ~Amplitude * AmplitudeCor * cosd(Speed * hours_year(date_time) + PhaseAdj - Phase))
  sum(rtide$station_harmonics$Term) + rtide$stations$Datum
}

predict_rtide_reference_station_row <- function(data, rtide) {
  data$TideHeight <- predict_rtide_height_reference_station_datetime(data$DateTime, rtide)
  data
}

predict_rtide_reference_station <- function(data, rtide) {
  rtide %<>% subset(data$Station[1])

  rtide$station_harmonics %<>% dplyr::full_join(rtide$harmonics, by = "Harmonic")

  data %<>% plyr::adply(.margins = 1, .fun = predict_rtide_reference_station_row,
                        rtide = rtide)
  data
}

#' Predict Tide Height
#'
#' Predicts tide heights (in m) at stations and date times provided in new_data.
#'
#' @param data A data.frame with the columns DateTime and Station.
#' @param rtide The rtide object to use for the predictions.
#' @param ... Unused arguments.
#' @return An updated data.frame with the additional column TideHeight.
#' @export
predict_tide_height <- function(data, rtide = rtide::noaa, ...) {
  check_data2(data, values = list(DateTime = Sys.time(), Station = ""))
  check_rtide(rtide)

  rtide %<>% subset(data$Station) %>% add_speeds()

  secondary <- dplyr::filter_(rtide$stations, ~is.na(Datum))

  if (nrow(secondary))
    error("predict_tide_height is currently only defined for stations with harmonics (indicated by non-missing Datum values)")

  tz <- lubridate::tz(data$DateTime)
  data %<>% dplyr::mutate_(DateTime = ~lubridate::with_tz(DateTime, tzone = "UTC"))

  data %<>% plyr::ddply(.variables = c("Station"), predict_rtide_reference_station, rtide = rtide)

  data %<>% dplyr::mutate_(DateTime = ~lubridate::with_tz(DateTime, tzone = tz)) %>%
      dplyr::arrange_(~Station, ~DateTime) %>%
      dplyr::as.tbl()

  data
}
