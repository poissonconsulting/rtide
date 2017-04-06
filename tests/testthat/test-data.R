context("data")

test_that("data", {
  expect_is(check_rtide(rtide::noaa), "rtide")
})
