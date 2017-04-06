context("seq-datetime")

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
