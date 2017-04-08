predict_reference_station_slope_datetime <- function(date_time, rtide) {
  seconds <- lubridate::seconds(c(-1,1))
  date_time %<>% magrittr::add(seconds)
  height <- vapply(predict_rtide_height_reference_station_datetime, rtide = rtide)
  slope <- diff(height) %>% abs() %>% magrittr::divide_by(2)
  slope
}

slack <- function(date_time, periods, rtide) {
  slope <- vapply(date_time + periods, predict_reference_station_slope_datetime, 1, rtide = rtide)
  which <- which.min(slope)
  date_time %<>% magrittr::add(periods[which])
  date_time
}

predict_slack_reference_station_datetime <- function(date_time, rtide) {
  hours <- lubridate::minutes(seq(-7, 7, by = 15))
  minutes <- lubridate::minutes(seq(-15, 15, by = 1))
  seconds <- lubridate::seconds(seq(-30, 30, by = 3))
  seconds2 <- lubridate::seconds(seq(-3, 3, by = 1))

  date_time %<>% slack(hours, rtide = rtide)
  date_time %<>% slack(minutes, rtide = rtide)
  date_time %<>% slack(seconds, rtide = rtide)
  date_time %<>% slack(seconds2, rtide = rtide)

  date_time
}

predict_slack_reference_station_row <- function(data, rtide) {
  data$SlackDateTime <- predict_slack_reference_station_datetime(data$DateTime, rtide)
  data$SlackTideHeight <- predict_rtide_height_reference_station_datetime(data$SlackDateTime, rtide)
  data
}

predict_slack_reference_station <- function(data, rtide) {
  rtide %<>% subset(data$Station[1])

  rtide$station_harmonics %<>% dplyr::full_join(rtide$harmonics, by = "Harmonic")

  data %<>% plyr::adply(.margins = 1, .fun = predict_slack_reference_station_row,
                        rtide = rtide)
  data
}

#' Predict Tide Height
#'
#' Predicts closest slack tide time and height (in m) at stations and date times provided in new_data.
#'
#' @param data A data.frame with the columns DateTime and Station.
#' @param rtide The rtide object to use for the predictions.
#' @param ... Unused arguments.
#' @return An updated data.frame with the additional columns SlackDateTime, SlackTideHeight, SlackType.
#' @export
predict_slack_tide <- function(data, rtide = rtide::noaa, ...) {
  check_data2(data, values = list(DateTime = Sys.time(), Station = ""))
  check_rtide(rtide)

  rtide %<>% subset(data$Station) %>% add_speeds()

   secondary <- dplyr::filter_(rtide$stations, ~is.na(Datum))

   if (nrow(secondary))
     error("predict_tide_height is currently only defined for stations with harmonics (indicated by non-missing Datum values)")

   tz <- lubridate::tz(data$DateTime)
   data %<>% dplyr::mutate_(DateTime = ~lubridate::with_tz(DateTime, tzone = "UTC"))

   data %<>% plyr::ddply(.variables = c("Station"), predict_slack_reference_station, rtide = rtide)

   data %<>% dplyr::mutate_(DateTime = ~lubridate::with_tz(DateTime, tzone = tz)) %>%
       dplyr::arrange_(~Station, ~DateTime) %>%
       dplyr::as.tbl()

  data
}
