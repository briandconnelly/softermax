#' Return the names of all plates in an experiment
#'
#' @param x A \code{softermax.experiment} object containing information
#' about an experiment in SoftMax Pro
#'
#' @return A vector of strings
#' @export
#'
#' @examples
#' \dontrun{
#' d <- read_softmax_xml("myfile.xml")
#' plate_names(d$experiments[[1]])
#' }
plate_names <- function(x) {
    vapply(
        X = x$plates,
        FUN = function(x) attr(x, "name"),
        FUN.VALUE = character(1),
        USE.NAMES = FALSE
    )
}
