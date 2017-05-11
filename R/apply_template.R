#' Annotate Plate Read Data with Metadata from a Template
#'
#' \code{apply_template} combines plate read data with metadata from a template,
#' producing a data frame that contains both the read values along with
#' additional information such as strain, medium, drug concentration, etc.
#'
#' By default, the resulting data frame will contain data only for the wells
#' specified in the template. To include all wells in the plate data (but not
#' necessarily also in the template), use the argument \code{all.x = TRUE}. To
#' include all wells specified in both, use the argument \code{all = TRUE}.
#'
#' @param plate Either a \code{softermax.plate} object (produced by
#' \code{\link{read_softmax_xml}}), or a data frame.
#' @param template A data frame containing information about wells in a plate.
#' See \code{\link{read_softmax6_template}}, or create a data frame where each
#' row contains information about a well (in the \code{Well} column), and
#' other columns specify the value of an experimental variable (e.g., drug
#' concentration).
#' @param ... Additional arguments passed to \code{\link[base]{merge}}
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' library(softermax)
#'
#' d1 <- read_softmax_xml("myfile.xml")
#' p1 <- d1$experiments[["Experiment#1"]]$plates[["Plate#1"]]
#' template <- read_softmax_template("plate_template.txt")
#'
#' annotated <- apply_template(p1, template)
#' }
#'

apply_template <- function(plate, template, ...) {
    UseMethod("apply_template")
}


#' @rdname apply_template
#' @export
apply_template.data.frame <- function(plate, template, ...) {
    merge(
        x = plate,
        y = template,
        suffixes = c(".plate", ".template"),
        ...
    )
}


#' @rdname apply_template
#' @export
apply_template.softermax.plate <- function(plate, template, ...) {
    apply_template.data.frame(
        plate = as.data.frame(plate),
        template = template,
        ...
    )
}
