context("deprecated")

test_that("data", {
  expect_is(check_tide_harmonics(rtide::harmonics), "tide_harmonics")
})

test_that("subset.tide_harmonics works", {
  h <- rtide::harmonics
  expect_equal(subset(h, h$Station$Station[2])$Station,
                   h$Station[2,,drop = FALSE])
})

test_that("years_tide_harmonics works", {
  expect_is(years_tide_harmonics(rtide::harmonics), "integer")
})

test_that("tide_stations works", {

  expect_equal(tide_stations("Monterey", rtide::harmonics), c("Elkhorn Slough railroad bridge, Monterey Bay, California", "Monterey, Monterey Harbor, California"))
  expect_equal(tide_stations(
    c("Elkhorn Slough railroad bridge, Monterey Bay, California", "Monterey, Monterey Harbor, California")),
    c("Elkhorn Slough railroad bridge, Monterey Bay, California", "Monterey, Monterey Harbor, California"))

  expect_equal(tide_stations("Annapolis (US Naval Academy), Severn River, Maryland", rtide::harmonics), "Annapolis (US Naval Academy), Severn River, Maryland")

  expect_error(tide_stations("^Monterey$", rtide::harmonics), "no matching stations")
  expect_error(tide_stations(1, rtide::harmonics), "stations must be of class 'character'")
})

test_that("tide_height works", {
  expect_df <- function (x) expect_is(x, "data.frame")

  expect_df(check_data3(tide_height(), values = list(
    Station = "", DateTime = Sys.time(), TideHeight = 1),
    min_row = 24, max_row = 24,
    key = "DateTime"))

  expect_df(tide_height(stations = ".*"))
})


test_that("tide_height_data works", {
  expect_df <- function(x) expect_is(x, "data.frame")

  data <- data.frame(Station = "Monterey, Monterey Harbor, California",
                     DateTime = ISOdate(2015,1,1,10,tz = "PST8PDT"),
                     stringsAsFactors = FALSE)

  expect_df(check_data3(tide_height_data(data), values = list(
    Station = "", DateTime = Sys.time(), TideHeight = 1),
    min_row = 1, max_row = 1))
  expect_identical(lubridate::tz(data$DateTime), "PST8PDT")
})

test_that("tide_height_data predictions", {
  expect_equal(rtide::monterey$MLLW,
               tide_height_data(rtide::monterey)$TideHeight, tolerance = 0.002)
  expect_equal(rtide::brandywine$MLLW,
               tide_height_data(rtide::brandywine)$TideHeight, tolerance = 0.002)
})

test_that("tide_height_data checks", {
  library(lubridate)

  data <- data.frame(Station = "Monterey, Monterey Harbor, California",
                     DateTime = ISOdate(2015,1,1,10,tz = "PST8PDT"),
                     stringsAsFactors = FALSE)

  data$TideHeight <- 1

  expect_error(tide_height_data(data), "data already has 'TideHeight' column")

  data$TideHeight <- NULL
  year(data$DateTime) <- 1699
  expect_error(tide_height_data(data), "years are outside harmonics range")
})

test_that("tide_height_data tz", {
  library(lubridate)

  data <- data.frame(Station = "Monterey, Monterey Harbor, California",
                     DateTime = ISOdate(2015,1,1,10,tz = "PST8PDT"),
                     stringsAsFactors = FALSE)

  data2 <- data
  data2$DateTime <- lubridate::with_tz(data2$DateTime, tz = "EST")

  expect_equal(tide_height_data(data), tide_height_data(data2))
})

test_that("tide_datetimes works", {

  minutes <- 17L
  from <- as.Date("2000-02-01")
  to <- as.Date("2000-05-02")
  tz <- "PST8PDT"

  expect_equal(lubridate::tz(tide_datetimes(minutes = minutes, from = from, to = to, tz = tz)), "PST8PDT")
  expect_equal(tide_datetimes(minutes = minutes, from = from, to = to, tz = tz)[1], ISOdate(2000,02,01,0,tz = tz))
  expect_equal(max(lubridate::date(tide_datetimes(minutes = minutes, from = from, to = to, tz = tz))), to)

  expect_error(lubridate::tz(tide_datetimes(minutes = minutes, from = to, to = from, tz = tz)))

  expect_identical(tide_datetimes(minutes = 1), tide_datetimes(minutes = 1L))
  expect_warning(tide_datetimes(minutes = 1.9), "Truncating minutes interval to whole number")
  expect_error(tide_datetimes(minutes = 0L), "the values in minutes must lie between 1 and 60")
  expect_error(tide_datetimes(minutes = 0.9), "the values in minutes must lie between 1 and 60")
})

