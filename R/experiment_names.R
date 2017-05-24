#' Return the names of all experiments in a dataset
#'
#' @param x A \code{softermax} object containing information
#' about one or more experiments in SoftMax Pro
#'
#' @note Experiment names are not exported by SoftMax Pro version 6, and data
#' are grouped under a single experiment, so \code{"unknown"} is returned.
#'
#' @return A vector of strings
#' @export
#'
#' @examples
#' \dontrun{
#' d <- read_softmax_xml("myfile.xml")
#' experiment_names(d)
#' }
experiment_names <- function(x) {
    unname(
        vapply(
            X = x$experiments,
            FUN = function(x) attr(x, "name"),
            FUN.VALUE = character(1)
        )
    )
}
