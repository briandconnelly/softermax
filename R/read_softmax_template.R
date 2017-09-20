#' Read a 'SoftMax Pro' Template File
#'
#' @param file Either a path to a file, a connection, or literal data (either a
#' single string or a raw vector).
#' @param include_unspecified Logical value indicating whether (\code{TRUE}) or
#' not (\code{FALSE}) to include non-annotated wells (default: \code{FALSE})
#' @param zeropad_wells Logical value indicating whether or not well names should
#' be zero padded (e.g., "A04") (default: \code{FALSE})
#' @param wellsAsFactors Logical value indicating whether or not well names
#' (e.g., "H5") should be treated as factors (default: \code{TRUE})
#' @param groupsAsFactors Logical value indicating whether or not groups
#' should be treated as factors (default: \code{TRUE})
#' @param typesAsFactors Logical value indicating whether or not types
#' should be treated as factors (default: \code{TRUE}). The set of valid types
#' supported by 'SoftMax Pro' differs from version to version.
#' @param encoding Encoding for the template file. If \code{"guess"}, the
#' default, the encoding will be guessed.
#' @inheritParams utils::read.table
#' @note Different versions of 'SoftMax Pro' write units differently. For example,
#' v5.2 uses "l" for liters, while v6.4 uses "L".
#' @param ... Additional parameters passed to \code{\link[utils]{read.delim}}
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' t1 <- read_softmax_template("plate_template.txt")
#' }
#'

read_softmax_template <- function(file,
                                  include_unspecified = FALSE,
                                  zeropad_wells = FALSE,
                                  wellsAsFactors = TRUE,
                                  groupsAsFactors = TRUE,
                                  typesAsFactors = TRUE,
                                  encoding = "guess",
                                  ...) {
    warning("Using read_softmax6_template", call. = FALSE)

    read_softmax6_template(file = file,
                           include_unspecified = include_unspecified,
                           zeropad_wells = zeropad_wells,
                           wellsAsFactors = wellsAsFactors,
                           groupsAsFactors = groupsAsFactors,
                           typesAsFactors = typesAsFactors,
                           encoding = encoding,
                           ...)
}
