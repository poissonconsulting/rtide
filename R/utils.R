datetime2seconds <- function(x) {
  as.numeric(x)
}

seconds2datetime <- function(x) {
  as.POSIXct(x, origin = ISOdate(1970,1,1,0), tz = "UTC")
}

error <- function(...) {
  stop(..., call. = FALSE)
}

ft2m <- function(x) {
  x %<>% magrittr::multiply_by(0.3048)
  x
}
