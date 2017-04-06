context("utils")

test_that("datetimes and seconds work", {
  start <- ISOdate(1970,1,1,0)
  expect_identical(datetime2seconds(seconds2datetime(datetime2seconds(start))), 0)
  expect_identical(datetime2seconds(seconds2datetime(datetime2seconds(start + lubridate::seconds(3)))), 3)
})

test_that("ft2m", {
  expect_identical(ft2m(2), 0.6096)
})

test_that("hours_year works", {
  expect_error(hours_year(1))
  expect_identical(hours_year(ISOdate(2000,1,1,1,tz = "UTC")), 1)
  expect_identical(hours_year(ISOdate(2000,1,1,c(1,3,1),tz = "UTC")), c(1L,3,1))
  expect_identical(hours_year(ISOdate(2001,1,1,c(1,3,1),tz = "UTC")), c(1,3,1))
  expect_identical(hours_year(ISOdate(2001,1,2,c(1,3,1),tz = "UTC")), c(25,27,25))
})

test_that("seq_datetime works", {

  minutes <- 17L
  from <- as.Date("2000-02-01")
  to <- as.Date("2000-05-02")
  tz <- "PST8PDT"

  expect_equal(lubridate::tz(seq_datetime(minutes = minutes, from = from, to = to, tz = tz)), "PST8PDT")
  expect_equal(seq_datetime(minutes = minutes, from = from, to = to, tz = tz)[1], ISOdate(2000,02,01,0,tz = tz))
  expect_equal(max(lubridate::date(seq_datetime(minutes = minutes, from = from, to = to, tz = tz))), to)
  expect_equal(length(seq_datetime()), 4L)

  expect_error(lubridate::tz(seq_datetime(minutes = minutes, from = to, to = from, tz = tz)))

  expect_identical(seq_datetime(minutes = 1), seq_datetime(minutes = 1L))
  expect_warning(seq_datetime(minutes = 1.9), "Truncating minutes interval to whole number")
  expect_error(seq_datetime(minutes = 0L), "the values in minutes must lie between 1 and 1440")
  expect_error(seq_datetime(minutes = 0.9), "the values in minutes must lie between 1 and 1440")
})
