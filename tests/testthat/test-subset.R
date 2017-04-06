context("subset")

test_that("subset.tide_harmonics works", {
  h <- rtide::harmonics
  expect_equal(subset(h, h$Station$Station[2])$Station,
                   h$Station[2,,drop = FALSE])
})

test_that("subset.rtide works", {
  noaa <- rtide::noaa
  expect_equal(subset(noaa, "TWC0401")$stations$Stations,
                   c("TWC0401", "9410170"))
})
