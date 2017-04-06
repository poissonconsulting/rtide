datetime2seconds <- function(x) {
  as.numeric(x)
}

seconds2datetime <- function(x) {
  as.POSIXct(x, origin = ISOdate(1970,1,1,0), tz = "UTC")
}

error <- function(...) {
  stop(..., call. = FALSE)
}

ft2m <- function(x) {
  x %<>% magrittr::multiply_by(0.3048)
  x
}

#' Tide Date Times
#'
#' Generates sequence of date times.
#'
#' @param minutes An integer of the number of minutes between tide heights
#' @param from A Date of the start of the period of interest
#' @param to A Date of the end of the period of interest
#' @param tz A string of the time zone.
#'
#' @return A POSIXct vector.
#' @export
#'
#' @examples
#' tide_datetimes()
tide_datetimes <- function(minutes = 60L, from = as.Date("2015-01-01"), to = as.Date("2015-12-31"),
                           tz = "PST8PDT") {

  if (class(minutes) == "numeric"){
    check_scalar(minutes, c(1,60))
    if (minutes %% 1 != 0)	# If modulo isn't 0, decimal value is present
      warning("Truncating minutes interval to whole number", call.=FALSE)
    minutes %<>% as.integer()
  }
  check_scalar(minutes, c(1L, 60L))

  check_date(from)
  check_date(to)
  check_string(tz)

  from <- ISOdatetime(year = lubridate::year(from), month = lubridate::month(from),
                      day = lubridate::day(from), hour = 0, min = 0, sec = 0, tz = tz)
  to <- ISOdatetime(year = lubridate::year(to), month = lubridate::month(to),
                    day = lubridate::day(to), hour = 23, min = 59, sec = 59, tz = tz)

  seq(from, to, by = paste(minutes, "min"))
}
