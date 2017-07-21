#' Test softermax Objects
#' @description \code{is.softermax} tests if an object is a softermax object
#' @param x An object
#' @return A logical value indicating whether (\code{TRUE}) or not
#' (\code{FALSE}) the object inherits from the corresponding \code{softermax}
#' class.
#' @export
is.softermax <- function(x) {
    "softermax" %in% class(x)
}


#' @rdname is.softermax
#' @description \code{is.softermax.experiment} tests if an object is a
#' softermax.experiment object
#' @export
is.softermax.experiment <- function(x) {
    "softermax.experiment" %in% class(x)
}


#' @rdname is.softermax
#' @description \code{is.softermax.plate} tests if an object is a
#' softermax.plate object
#' @export
is.softermax.plate <- function(x) {
    "softermax.plate" %in% class(x)
}


#' @rdname is.softermax
#' @description \code{is.softermax.wavelength} tests if an object is a
#' softermax.wavelength object
#' @export
is.softermax.wavelength <- function(x) {
    "softermax.wavelength" %in% class(x)
}


#' @rdname is.softermax
#' @description \code{is.softermax.well} tests if an object is a softermax.well
#' object
#' @export
is.softermax.well <- function(x) {
    "softermax.well" %in% class(x)
}


#' @rdname is.softermax
#' @description \code{is.softermax.note} tests if an object is a softermax.note
#' object
#' @export
is.softermax.note <- function(x) {
    "softermax.note" %in% class(x)
}


#' @rdname is.softermax
#' @description \code{is.softermax.template} tests if an object is a
#' softermax.template object
#' @export
is.softermax.template <- function(x) {
    "softermax.template" %in% class(x)
}
