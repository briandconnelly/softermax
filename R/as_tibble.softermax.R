#' Coerce SoftMax Pro data into tibbles
#'
#' @param x A \code{softermax} object
#' @param nest Logical value indicating whether or not the resulting tibble
#' should be nested (default: \code{FALSE}).
#' @param ... Additional arguments passed to \code{\link[base]{as.data.frame}}
#'
#' @note Nesting could be done in different ways, for example by Time in
#' kinetic reads. For these cases, nest manually with \code{\link[tidyr]{nest}}.
#'
#' @return A \code{tbl_df} object (see: \code{\link[tibble]{tibble-package}})
#' @importFrom tibble as_tibble
#' @export
#'
#' @examples
#' \dontrun{
#' d <- read_softmax_xml("mydata")
#' dX <- as_tibble(d, nest = TRUE)
#' }
as_tibble.softermax <- function(x, nest = FALSE, ...) {
    d <- tibble::as_tibble(as.data.frame(x, ...))

    if (nest) {
        stop_without_package("tidyr")
        d <- tidyr::nest(
            dplyr::group_by_(d, "Experiment", "Plate", "Wavelength")
        )
    }

    d
}


#' @rdname as_tibble.softermax
#' @export
as_tibble.softermaxExperiment <- function(x, nest = FALSE, ...) {
    d <- tibble::as_tibble(as.data.frame(x, ...))

    if (nest) {
        stop_without_package("tidyr")
        d <- tidyr::nest(
            dplyr::group_by_(d, "Experiment", "Plate", "Wavelength")
        )
    }

    d
}


#' @rdname as_tibble.softermax
#' @export
as_tibble.softermaxPlate <- function(x, nest = FALSE, ...) {
    d <- tibble::as_tibble(as.data.frame(x, ...))

    if (nest) {
        stop_without_package("tidyr")
        d <- tidyr::nest(dplyr::group_by_(d, "Plate", "Wavelength"))
    }

    d
}


#' @rdname as_tibble.softermax
#' @export
as_tibble.softermaxWavelength <- function(x, nest = FALSE, ...) {
    d <- tibble::as_tibble(as.data.frame(x, ...))

    if (nest) {
        stop_without_package("tidyr")
        d <- tidyr::nest(dplyr::group_by_(d, "Wavelength"))
    }

    d
}


#' @rdname as_tibble.softermax
#' @export
as_tibble.softermaxWell <- function(x, nest = FALSE, ...) {
    d <- tibble::as_tibble(as.data.frame(x, ...))

    if (nest) {
        stop_without_package("tidyr")
        d <- tidyr::nest(dplyr::group_by_(d, "Well"))
    }

    d
}
