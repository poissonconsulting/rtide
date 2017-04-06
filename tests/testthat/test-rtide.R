context("rtide")

test_that("is.rtide", {
  expect_true(is.rtide(rtide::noaa))
})

test_that("subset.rtide", {
  noaa <- rtide::noaa
  expect_equal(subset(noaa, "TWC0401")$stations$Station,
                   c("TWC0401", "9410170"))

  expect_identical(nrow(subset(noaa, "9411340")$station_harmonics), 37L)
})
