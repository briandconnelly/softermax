#' Return the names of all notes in an experiment
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
#' note_names(d$experiments[[1]])
#' }
note_names <- function(x) {
    unname(
        vapply(
            X = x$notes,
            FUN = function(x) attr(x, "name"),
            FUN.VALUE = character(1)
        )
    )
}
