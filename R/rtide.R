#' Is rtide
#'
#' @param x The object to test
#' @return A flag indicating whether x is an object of class rtide
#' @export
is.rtide <- function(x) {
  inherits(x, "rtide")
}

check_rtide <- function(x) {
  if (!is.rtide(x)) error("x must be an object of class 'rtide'")
  x
}
