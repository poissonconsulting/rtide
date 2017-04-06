datetime2seconds <- function(x) as.numeric(x)

seconds2datetime <- function(x) as.POSIXct(x, origin = ISOdate(1970,1,1,0), tz = "UTC")

error <- function(...) stop(..., call. = FALSE)

ft2m <- function(x) x * 0.3048

hours_year <- function(datetime) {
  check_vector(datetime, value = Sys.time())
  stopifnot(identical(lubridate::tz(datetime), "UTC"))

  year <- lubridate::year(datetime)

  startdatetime <- ISOdate(year, 1, 1, 0, tz = "UTC")
  hours <- difftime(datetime, startdatetime, units = 'hours')
  hours %<>% as.numeric()
  hours
}

#' Seq Date Times
#'
#' A helper function to generate a sequence of date times.
#'
#' @param from A Date of the start of the period of interest
#' @param to A Date of the end of the period of interest
#' @param minutes An integer of the number of minutes between date times.
#' @param tz A string of the time zone.
#'
#' @return A POSIXct vector.
#' @export
#' @examples
#' seq_datetime()
seq_datetime <- function(from = Sys.Date(), to = from, minutes = 360L,
                           tz = "UTC") {

  if (class(minutes) == "numeric") {
    check_scalar(minutes, c(1, 1440))
    if (minutes %% 1 != 0)	# If modulo isn't 0, decimal value is present
      warning("Truncating minutes interval to whole number", call. = FALSE)
    minutes %<>% as.integer()
  }
  check_scalar(minutes, c(1L, 1440L))

  check_date(from)
  check_date(to)
  check_string(tz)

  from <- ISOdatetime(year = lubridate::year(from), month = lubridate::month(from),
                      day = lubridate::day(from), hour = 0, min = 0, sec = 0, tz = tz)
  to <- ISOdatetime(year = lubridate::year(to), month = lubridate::month(to),
                    day = lubridate::day(to), hour = 23, min = 59, sec = 59, tz = tz)

  seq(from, to, by = paste(minutes, "min"))
}
