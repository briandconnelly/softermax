#' Combine Data from Multiple Plates into one Data Frame
#'
#' @param s A \code{softermax} object
#'
#' @return A data frame
#' @export
#'
#' @examples
#' # TODO
combine_plates <- function(s) {
    # TODO make sure s is a softermax object - generic?
    # TODO: option to merge attributes?
    # TODO: seems possible that an XML file could have two plates with the same name. How to handle?

    if (!"softermax" %in% class(s)) stop("object is not a softermax object")

    if (length(s$plates) < 1) message("object has no plates")
    else if (length(s$plates) == 1) message("object only has one plate")

    dplyr::bind_rows(s$plates)
}
