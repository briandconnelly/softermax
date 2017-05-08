#' @rdname read_softmax_template
#' @export
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
            "Sample",
            "Descriptor1.Name",
            "Descriptor1.Value",
            "Descriptor1.Units",
            "Descriptor2.Name",
            "Descriptor2.Value",
            "Descriptor2.Units",
            "HANGING"
        ),
        blank.lines.skip = TRUE,
        fileEncoding = encoding,
        stringsAsFactors = FALSE
    )

    d <- subset(d, select = -HANGING)

    if (include_unspecified == FALSE) {
        d <- d[d$Type != "" & d$Descriptor1.Name != "", ]
    }

    if (zeropad_wells == FALSE) {
        d$Well <- paste0(
            substr(d$Well, 1, 1),
            as.integer(substr(d$Well, 2, 5))
        )
    }

    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)
    if (groupsAsFactors) d$Group <- forcats::as_factor(d$Group)
    if (typesAsFactors) {
        d$Type <- factor(d$Type, levels = c("Standards", "Unknowns", "Custom"))
    }

    class(d) <- c("data.frame", "softermaxTemplate")
    d
}
