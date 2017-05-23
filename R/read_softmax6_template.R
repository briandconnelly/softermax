#' @rdname read_softmax_template
#' @export
read_softmax6_template <- function(file,
                                   include_unspecified = FALSE,
                                   zeropad_wells = FALSE,
                                   wellsAsFactors = TRUE,
                                   groupsAsFactors = TRUE,
                                   typesAsFactors = TRUE,
                                   #encoding = "UTF-16",
                                   ...) {
    d <- utils::read.delim(
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
        #fileEncoding = encoding,
        stringsAsFactors = FALSE,
        ...
    )

    # Remove the HANGING column
    d <- d[, seq_len(length(d) - 1)]

    # Make sure the Sample field is treated as a string
    if (!is.character(d$Sample)) {
        d$Sample <- as.character(d$Sample)
    }

    if (include_unspecified == FALSE) {
        d <- d[d$Type != "" & d$Descriptor1.Name != "", ]
    }

    if (zeropad_wells == FALSE) {
        d$Well <- paste0(
            substr(d$Well, 1, 1),
            as.integer(substr(d$Well, 2, 5))
        )
    }

    softermax.template(
        d,
        wellsAsFactors = wellsAsFactors,
        groupsAsFactors = groupsAsFactors,
        typesAsFactors = typesAsFactors
    )
}
