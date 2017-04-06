context("predict-rtide")

test_that("predict_rtide monterey", {
  expect_df <- function(x) expect_is(x, "data.frame")

  data <- rtide::monterey
  data$MLLW <- data$TideHeight
  data$TideHeight <- NULL

  data <- predict_rtide(data, rtide::noaa)

  expect_identical(colnames(data), c("Station", "DateTime", "MLLW", "TideHeight"))

#  expect_equal(data$MLLW, data$TideHeight, tolerance = 0.002)
})

test_that("predict_rtide brandywine", {
  expect_df <- function(x) expect_is(x, "data.frame")

  data <- rtide::brandywine
  data$MLLW <- data$TideHeight
  data$TideHeight <- NULL

  data <- predict_rtide(data, rtide::noaa)

  expect_identical(colnames(data), c("Station", "DateTime", "MLLW", "TideHeight"))

 # expect_equal(data$MLLW, data$TideHeight, tolerance = 0.002)
})
