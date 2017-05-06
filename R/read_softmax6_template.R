#' Read a SoftMax Pro 6 Template File
#'
#' @param file Either a path to a file, a connection, or literal data (either a
#' single string or a raw vector).
#' @param include_unspecified Logical value indicating whether (\code{TRUE}) or
#' not (\code{FALSE}) to include non-annotated wells (default: \code{FALSE})
#' @param zeropad_wells Logical value indicating whether or not well names should
#' be zero padded (e.g., "A04") (default: \code{FALSE})
#' @param ... Additional parameters (not used)
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' t1 <- read_softmax6_template("plate_template.txt")
#' }
read_softmax6_template <- function(file,
                                   include_unspecified = FALSE,
                                   zeropad_wells = FALSE,
                                   ...) {
    d <- read.delim(
        file = file,
        header = FALSE,
        skip = 1,
        col.names = c(
            "Well",
            "GroupName",
            "GroupType",
            "SampleName",
            "Desc1Name",
            "Desc1Value",
            "Desc1Units",
            "Desc2Name",
            "Desc2Value",
            "Desc2Units",
            "HANGING"
        ),
        blank.lines.skip = TRUE,
        fileEncoding = "UCS-2LE"
    )

    d <- subset(d, select = -HANGING)

    if (include_unspecified == FALSE) {
        d <- d[d$GroupType != "" & d$Desc1Name != "", ]
    }

    if (zeropad_wells == FALSE) {
        # TODO: rename the wells
        warning("zeropad_wells == FALSE not yet implemented")
    }

    d
}
