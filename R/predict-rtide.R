# tide_slack_datetime <- function(d, h, high = TRUE, forward = TRUE) {
#   hours <- lubridate::minutes(cumsum(c(0,rep(15,25)))) * if (forward) 1 else -1
#   height <- vapply(d + hours, tide_height_datetime, 1, h = h)
#   which <- which.max(height * if (high) 1 else -1)
#   d %<>% magrittr::add(hours[which])
#
#   minutes <- lubridate::minutes(c(cumsum(rep(-1,15)), 0, cumsum(rep(1,15))))
#   height <- vapply(d + minutes, tide_height_datetime, 1, h = h)
#   which <- which.max(height * if (high) 1 else -1)
#   d %<>% magrittr::add(minutes[which])
#
#   seconds <- lubridate::seconds(c(cumsum(rep(-3,10)), 0, cumsum(rep(3,10))))
#   height <- vapply(d + seconds, tide_height_datetime, 1, h = h)
#   which <- which.max(height * if (high) 1 else -1)
#   d %<>% magrittr::add(seconds[which])
#
#   seconds <- lubridate::seconds(c(cumsum(rep(-1,3)), 0, cumsum(rep(1,3))))
#   height <- vapply(d + seconds, tide_height_datetime, 1, h = h)
#   which <- which.max(height * if (high) 1 else -1)
#   d %<>% magrittr::add(seconds[which])
#
#   d
# }
#
# tide_slack_data_datetime <- function(d, h) {
#   datetimes <- list(
#     tide_slack_datetime(d$DateTime, h, TRUE, TRUE),
#     tide_slack_datetime(d$DateTime, h, TRUE, FALSE),
#     tide_slack_datetime(d$DateTime, h, FALSE, TRUE),
#     tide_slack_datetime(d$DateTime, h, FALSE, FALSE))
#
#   seconds <- vapply(datetimes, datetime2seconds, 1)
#   which <- which.min(abs(seconds - datetime2seconds(d$DateTime)))
#
#   d$SlackDateTime <- datetimes[[which]]
#   d$SlackTideHeight <- tide_height_datetime(d$SlackDateTime, h = h)
#   d$SlackType <- if(which %in% 1:2) "high" else "low"
#   d
# }
#
# tide_slack_data_station <- function(data, harmonics) {
#   harmonics %<>% subset(stringr::str_c("^", data$Station[1], "$"))
#   data <- plyr::adply(.data = data, .margins = 1, .fun = tide_slack_data_datetime,
#                       h = harmonics)
#   if (harmonics$Station$Units %in% c("feet", "ft"))
#     data %<>% dplyr::mutate_(SlackTideHeight = ~ft2m(SlackTideHeight))
#   data
# }
#
# tide_slack_data <- function (data, harmonics = rtide::harmonics) {
#   data %<>% check_data2(values = list(Station = "", DateTime = Sys.time()))
#
#   if (!all(data$Station %in% tide_stations(harmonics = harmonics)))
#     stop("unrecognised stations", call. = FALSE)
#
#   if (tibble::has_name(data, "SlackTideHeight"))
#     stop("data already has 'SlackTideHeight' column", call. = FALSE)
#
#   if (tibble::has_name(data, "SlackDateTime"))
#     stop("data already has 'SlackDateTime' column", call. = FALSE)
#
#   if (tibble::has_name(data, "SlackType"))
#     stop("data already has 'SlackType' column", call. = FALSE)
#
#   tz <- lubridate::tz(data$DateTime)
#   data %<>% dplyr::mutate_(DateTime = ~lubridate::with_tz(DateTime, tzone = "UTC"))
#
#   years <- range(lubridate::year(data$DateTime), na.rm = TRUE)
#   if (!all(years %in% years_tide_harmonics(harmonics)))
#     stop("years are outside harmonics range", call. = FALSE)
#
#   data %<>% plyr::ddply(.variables = c("Station"), tide_slack_data_station, harmonics = harmonics)
#
#   data %<>% dplyr::mutate_(DateTime = ~lubridate::with_tz(DateTime, tzone = tz))
#   data %<>% dplyr::mutate_(SlackDateTime = ~lubridate::with_tz(SlackDateTime, tzone = tz))
#   data %<>% dplyr::arrange_(~Station, ~DateTime)
#   data %<>% dplyr::as.tbl()
#   data
# }
#

predict_rtide_height_reference_station_datetime <- function(date_time, rtide) {

  amplitude <- rtide$station_harmonics$Amplitude
  speed <- rtide$station_harmonics$Speed
  phase <- rtide$station_harmonics$Phase
  datum <- rtide$stations$Datum

  height <- amplitude * cosd(speed * hours_year(date_time) - phase)
  height %<>% sum() %>% magrittr::add(datum)
  height
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

add_speeds <- function(rtide) {
  rtide$Speed <- NULL
  rtide$harmonics %<>% dplyr::inner_join(dplyr::select_(TideHarmonics::harmonics, HarmonicName = ~name, Speed = ~speed), by = "HarmonicName")
  rtide
}

#' Predict Tide Height
#'
#' Predicts tide heights (in m) at stations and date times provided in new_data.
#'
#' @param data A data.frame with the columns DateTime and Station.
#' @param rtide The rtide object to use for the predictions.
#' @param slack A flag indicating whether to also calculate the time and height of the next slack tide.
#' @param ... Unused arguments.
#' @return An updated data.frame with the additional column TideHeight and if \code{slack = TRUE}
#' the additional columns DateTimeSlack and TideHeightSlack.
#' @export
predict_rtide <- function(data, rtide = rtide::noaa, slack = FALSE, ...) {
  check_data2(data, values = list(DateTime = Sys.time(), Station = ""))
  check_rtide(rtide)
  check_flag(slack)

  if (slack) error("predict_rtide is currently not implemented for slack tides")

  rtide %<>% subset(data$Station) %>% add_speeds()

  tz <- lubridate::tz(data$DateTime)
  data %<>% dplyr::mutate_(DateTime = ~lubridate::with_tz(DateTime, tzone = "UTC"))

  primary <- dplyr::semi_join(data, dplyr::filter_(rtide$stations, ~!is.na(Datum)), by = "Station")
  secondary <- dplyr::semi_join(data, dplyr::filter_(rtide$stations, ~is.na(Datum)), by = "Station")

  if (nrow(secondary)) error("predict_rtide is currently not implemented for secondary tide stations")

  primary %<>% plyr::ddply(.variables = c("Station"), predict_rtide_reference_station, rtide = rtide)

  data <- primary

  data %<>% dplyr::mutate_(DateTime = ~lubridate::with_tz(DateTime, tzone = tz)) %>%
      dplyr::arrange_(~Station, ~DateTime) %>%
      dplyr::as.tbl()

  data
}
