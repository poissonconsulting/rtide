context("predict-rtide")

test_that("add_speeds", {
  data <- rtide::noaa
  data %<>% subset("9413450")
  data %<>% add_speeds()
  data <- data$station_harmonics
  expect_identical(names(data), c("Station", "Harmonic", "Amplitude", "Phase", "Speed"))
  expect_equal(data$Speed[data$Harmonic == "S4"], 60)
  expect_equal(data$Speed[data$Harmonic == "S2"], 30)
})

test_that("predict_tide_height monterey", {
  expect_df <- function(x) expect_is(x, "data.frame")

  data <- rtide::monterey
  data$MLLW <- data$TideHeight
  data$TideHeight <- NULL

  data <- predict_tide_height(data, rtide::noaa)

  expect_identical(colnames(data), c("Station", "DateTime", "MLLW", "TideHeight"))

#  expect_equal(data$MLLW, data$TideHeight, tolerance = 0.002)
})

test_that("predict_tide_height brandywine", {
  expect_df <- function(x) expect_is(x, "data.frame")

  data <- rtide::brandywine
  data$MLLW <- data$TideHeight
  data$TideHeight <- NULL

  data <- predict_tide_height(data, rtide::noaa)

  expect_identical(colnames(data), c("Station", "DateTime", "MLLW", "TideHeight"))

 # expect_equal(data$MLLW, data$TideHeight, tolerance = 0.002)
})
