#' Read a SoftMax Pro 6 Template File
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
#' should be treated as factors (default: \code{TRUE})
#' @inheritParams utils::read.table
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
                                   wellsAsFactors = TRUE,
                                   groupsAsFactors = TRUE,
                                   typesAsFactors = TRUE,
                                   encoding = "UCS-2LE",
                                   ...) {
    d <- read.delim(
        file = file,
        header = FALSE,
        skip = 1,
        col.names = c(
            "Well",
            "Group",
            "Type",
            "SampleName", # Sample?
            "Desc1Name",  # Desc1?
            "Desc1Value", # Desc1Value
            "Desc1Units",
            "Desc2Name",
            "Desc2Value",
            "Desc2Units",
            "HANGING"
        ),
        blank.lines.skip = TRUE,
        fileEncoding = encoding,
        stringsAsFactors = FALSE
    )

    d <- subset(d, select = -HANGING)

    if (include_unspecified == FALSE) {
        d <- d[d$Type != "" & d$Desc1Name != "", ]
    }

    if (zeropad_wells == FALSE) {
        d$Well <- paste0(
            substr(d$Well, 1, 1),
            as.integer(substr(d$Well, 2, 5))
        )
    }

    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)
    if (groupsAsFactors) d$Group <- forcats::as_factor(d$Group)
    if (typesAsFactors) d$Type <- forcats::as_factor(d$Type)

    class(d) <- c("data.frame", "softermaxTemplate")
    d
}
