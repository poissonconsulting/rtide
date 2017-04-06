context("predict-rtide")

test_that("predict_rtide works", {
  expect_df <- function(x) expect_is(x, "data.frame")

  data <- rtide::noaa$stations

  data <- data[data$StationName == "Monterey, Monterey Bay",]

  data$DateTime <- ISOdate(2015,1,1,10,tz = "PST8PDT")

  data <- predict_rtide(data, rtide::noaa)

  expect_identical(colnames(data), c("Station", "Datum", "Longitude", "Latitude", "StationName", "DateTime", "TideHeight"))

  expect_identical(data$Station, "9413450")
  expect_identical(data$Datum, 1.031)
  expect_identical(data$Longitude, -121.888)
  expect_identical(data$Latitude, 36.605)
  expect_identical(data$StationName, "Monterey, Monterey Bay")
  expect_identical(data$DateTime, ISOdate(2015,1,1,10,tz = "PST8PDT"))
  expect_equal(data$TideHeight, 1.376858, tolerance = 0.0000001)
})
