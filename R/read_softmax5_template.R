#' @rdname read_softmax_template
#' @export
read_softmax5_template <- function(file,
                                   include_unspecified = FALSE,
                                   zeropad_wells = FALSE, #ignored
                                   wellsAsFactors = TRUE,
                                   groupsAsFactors = TRUE,
                                   typesAsFactors = TRUE,
                                   encoding = "UCS-2LE", #ignored
                                   ...) {
    d <- utils::read.delim(
        file = file,
        header = FALSE,
        skip = 0,
        col.names = c(
            "Group",
            "Type",
            "Sample",
            "DescriptionNumber",
            "Descriptor1.Units",
            "Descriptor1.Name",
            "Descriptor1.Value",
            "HANGING"
        ),
        blank.lines.skip = FALSE,
        #fileEncoding = encoding,
        stringsAsFactors = FALSE,
        ...
    )

    # Remove the HANGING column and the last row, which contains only "~End"
    d <- d[1:96, seq_len(length(d) - 1)]

    # Add Well names
    x <- expand.grid(Row = LETTERS[1:8], Col = 1:12)
    x$Well <- paste0(x$Row, x$Col)
    d$Well <- c(x[order(x$Row), ]$Well)

    # Remove unspecified wells
    if (include_unspecified == FALSE) {
        d <- d[d$Type != "" & !is.na(d$DescriptionNumber), ]
    }

    if (wellsAsFactors) d$Well <- as.factor(d$Well)
    if (groupsAsFactors) d$Group <- as.factor(d$Group)
    if (typesAsFactors) {
        d$Type <- factor(
            d$Type,
            levels = c("Empty", "Basic", "Standards", "Unknowns",
                       "Unknowns[Dilution]")
        )
    }

    # Add extra columns to match V6 output
    d$Descriptor2.Name <- NA
    d$Descriptor2.Value <- NA
    d$Descriptor2.Units <- NA

    class(d) <- append(class(d), "softermaxTemplate")
    d[c("Well", "Group", "Type", "Sample", "Descriptor1.Name",
        "Descriptor1.Value", "Descriptor1.Units", "Descriptor2.Name",
        "Descriptor2.Value", "Descriptor2.Units")]
}
