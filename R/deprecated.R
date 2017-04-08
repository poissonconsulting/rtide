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
tide_datetimes <- function(minutes = 60L, from = as.Date("2015-01-01"), to = as.Date("2015-12-31"),
                           tz = "PST8PDT") {
  .Deprecated("seq_datetimes")

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

#' Tide Stations
#'
#' Gets vector of matching stations.
#'
#' @param stations A character vector of stations to match - treated as regular expressions.
#' @param harmonics The harmonics object.
#' @export
tide_stations <- function(stations = ".*", harmonics = rtide::harmonics) {
  .Deprecated(msg = "tide_stations is deprecated for direct querying of rtide objects such as rtide::noaa")
  check_vector(stations, value = c(""))
  check_tide_harmonics(harmonics)
  if (!is.tide_harmonics(harmonics))
    stop("harmonics must be an object of class 'tide_harmonics'", call. = FALSE)

  stations %<>% stringr::str_replace_all("[(]", "[(]") %>% stringr::str_replace_all("[)]", "[)]")
  stations <- paste0("(", paste(stations, collapse = ")|("), ")")
  match <- stringr::str_detect(harmonics$Station$Station, stations)
  match %<>% which()
  if (!length(match)) stop("no matching stations", call. = FALSE)
  harmonics$Station$Station[sort(unique(match))]
}

tide_height_datetime <- function(d, h) {
  h$NodeYear <- h$NodeYear[,as.character(lubridate::year(d)),,drop = FALSE]

  print(h$Station$Datum)

  x <- data.frame(Amplitude = h$StationNode[,,"A"],
                  Phase = h$StationNode[,,"Kappa"],
                  Speed = h$Node$Speed,
                  AmplitudeCor = h$NodeYear[,,"NodeFactor"],
                  PhaseAdj = h$NodeYear[,,"EquilArg"])

  x <- x[x$Amplitude != 0,]

  print(x)

  height <- h$Station$Datum + sum(h$NodeYear[,,"NodeFactor"] * h$StationNode[,,"A"] *
                                    cos((h$Node$Speed * (hours_year(d) - h$Station$Hours) +
                                           h$NodeYear[,,"EquilArg"] - h$StationNode[,,"Kappa"]) * pi/180))

  height
}

tide_height_data_datetime <- function(d, h) {
  d$TideHeight <- tide_height_datetime(d$DateTime, h)
  d
}

tide_height_data_station <- function(data, harmonics) {
  harmonics %<>% subset(stringr::str_c("^", data$Station[1], "$"))
  data <- plyr::adply(.data = data, .margins = 1, .fun = tide_height_data_datetime,
                      h = harmonics)
  if (harmonics$Station$Units %in% c("feet", "ft"))
    data %<>% dplyr::mutate_(TideHeight = ~ft2m(TideHeight))
  data
}


#' Tide Height Data
#'
#' Calculates tide height at specified stations at particular date times based on the supplied harmonics object.
#'
#' @param data A data frame with the columns Station and DateTime.
#' @inheritParams tide_stations
#' @return A tibble of the tide heights in m.
#' @export
tide_height_data <- function(data, harmonics = rtide::harmonics) {
  .Deprecated("predict_tide_height")

  data %<>% check_data2(values = list(Station = "", DateTime = Sys.time()))

  if (!all(data$Station %in% tide_stations(harmonics = harmonics)))
    stop("unrecognised stations", call. = FALSE)

  if (tibble::has_name(data, "TideHeight"))
    stop("data already has 'TideHeight' column", call. = FALSE)

  tz <- lubridate::tz(data$DateTime)
  data %<>% dplyr::mutate_(DateTime = ~lubridate::with_tz(DateTime, tzone = "UTC"))

  years <- range(lubridate::year(data$DateTime), na.rm = TRUE)
  if (!all(years %in% years_tide_harmonics(harmonics)))
    stop("years are outside harmonics range", call. = FALSE)

  data %<>% plyr::ddply(.variables = c("Station"), tide_height_data_station, harmonics = harmonics)

  data %<>% dplyr::mutate_(DateTime = ~lubridate::with_tz(DateTime, tzone = tz))
  data %<>% dplyr::arrange_(~Station, ~DateTime)
  data %<>% dplyr::as.tbl()
  data
}

#' Tide Height
#'
#' Calculates tide height at specified stations based on the supplied harmonics object.
#'
#' @inheritParams tide_stations
#' @inheritParams tide_datetimes
#' @return A tibble of the tide heights in m by the number of minutes for each station from from to to.
#' @export
tide_height <- function(
  stations = "Monterey Harbor", minutes = 60L,
  from = as.Date("2015-01-01"), to = as.Date("2015-01-01"), tz = "UTC",
  harmonics = rtide::harmonics) {
  stations %<>% tide_stations(harmonics)
  datetimes <- tide_datetimes(minutes = minutes, from = from, to = to, tz = tz)

  data <- tidyr::crossing(Station = stations, DateTime = datetimes)
  tide_height_data(data, harmonics = harmonics)
}

#' Is tide_harmonics
#'
#' Tests if object inherits from class tide_harmonics.
#'
#' @param x The object to test.
#' @export
is.tide_harmonics <- function(x) {
  .Deprecated(msg = "tide_harmonics objects are deprecated for rtide objects such as rtide::noaa")
  inherits(x, "tide_harmonics")
}

check_tide_harmonics <- function(x) {
  if (!is.tide_harmonics(x)) stop("x is not class 'tide_harmonics'")

  if (!all(c("Station", "Node", "StationNode", "NodeYear") %in% names(x)))
    stop("x is missing components", call. = FALSE)

  check_data2(x$Station, values = list(
    Station = "",
    Units = c("feet", "ft", "m", "metre"),
    Longitude = 1,
    Latitude = 1,
    Hours = c(-12,12),
    TZ = "",
    Datum = 1),
    key = "Station")

  check_data2(x$Node, values = list(
    Node = "",
    Speed = 1),
    key = "Node")

  if (!is.array(x$StationNode)) stop("StationNode must be an array", call. = FALSE)
  if (!is.array(x$NodeYear)) stop("NodeYear must be an array", call. = FALSE)
  if (mode(x$StationNode) != "numeric")
    stop("StationNode must be a numeric array", call. = FALSE)
  if (mode(x$NodeYear) != "numeric")
    stop("NodeYear must be a numeric array", call. = FALSE)

  if (!identical(dimnames(x$StationNode), list(x$Station$Station, x$Node$Node, c("A", "Kappa"))))
    stop("StationNode has invalid dimnames", call. = FALSE)

  if (!identical(dimnames(x$NodeYear)[c(1,3)], list(x$Node$Node, c("NodeFactor", "EquilArg"))))
    stop("NodeYear has invalid dimnames", call. = FALSE)

  years <- dimnames(x$NodeYear)[2][[1]]
  years <- as.numeric(years)
  years <- diff(years)
  if (!all(years == 1)) stop("NodeYear has invalid dimnames", call. = FALSE)
  x
}

tide_harmonics <- function (x) {
  if (!is.list(x)) stop("x must be a list", call. = FALSE)

  if (!all(c("name", "speed", "startyear", "equilarg", "nodefactor", "station",
             "units", "longitude", "latitude", "timezone", "tzfile", "datum",
             "A", "kappa") %in% names(x))) stop("x missing components", call. = FALSE)


  x$Station <- dplyr::data_frame(
    Station = x$station, Units = x$unit, Longitude = x$longitude, Latitude = x$latitude,
    Hours = x$timezone, TZ = x$tzfile, Datum = x$datum)

  x$Station$Station %<>% enc2utf8()

  x$Node <- dplyr::data_frame(Node = x$name, Speed = x$speed)
  x$StationNode <- abind::abind(A = x$A, Kappa = x$kappa, along = 3)
  dimnames(x$StationNode) <- list(x$Station$Station, x$Node$Node, c("A", "Kappa"))

  x$NodeYear <- abind::abind(NodeFactor = x$nodefactor, EquilArg = x$equilarg, along = 3)
  dimnames(x$NodeYear) <- list(x$Node$Node, seq(x$startyear, length.out = dim(x$NodeYear)[2]),
                               c("NodeFactor", "EquilArg"))

  x <- x[c("Station", "Node", "StationNode", "NodeYear")]

  station <- order(x$Station$Station)
  x$Station <- x$Station[station,,drop = FALSE]
  x$StationNode <- x$StationNode[station,,,drop = FALSE]

  node <- order(x$Node$Node)
  x$Node <- x$Node[node,,drop = FALSE]
  x$StationNode <- x$StationNode[,node,,drop = FALSE]
  x$NodeYear <- x$NodeYear[node,,,drop = FALSE]

  class(x) <- c("tide_harmonics")
  check_tide_harmonics(x)
  x
}

#' @export
subset.tide_harmonics <- function(x, stations, ...) {
  .Deprecated(msg = "tide_harmonics objects are deprecated for rtide objects such as rtide::noaa")
  stations %<>% tide_stations(x)
  stations <- x$Station$Station %in% stations %>% which()
  x$Station %<>% dplyr::slice(stations)
  x$StationNode <- x$StationNode[stations,,,drop = FALSE]
  x
}

#' @export
format.tide_harmonics <- function(x, ...) {
  utils::str(x, ...)
}

#' @export
print.tide_harmonics <- function(x, ...) {
  cat(format(x, ...), "\n")
}

years_tide_harmonics <- function(x) {
  x <- dimnames(x$NodeYear)[[2]]
  x %<>% as.character() %>% as.integer()
  x
}
