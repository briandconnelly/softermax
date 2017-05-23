#' @rdname read_softmax_template
#' @export
read_softmax5_template <- function(file,
                                   include_unspecified = FALSE,
                                   zeropad_wells = FALSE, #ignored
                                   wellsAsFactors = TRUE,
                                   groupsAsFactors = TRUE,
                                   typesAsFactors = TRUE,
                                   encoding = "guess",
                                   ...) {

    if (encoding == "guess") {
        encoding <- readr::guess_encoding(file)[[1, "encoding"]]
        message(sprintf("Using encoding '%s'", encoding))
    }

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
    if (zeropad_wells) x$Col <- sprintf("%02d", x$Col)
    x$Well <- paste0(x$Row, x$Col)
    d$Well <- c(x[order(x$Row), ]$Well)

    # Remove unspecified wells
    if (include_unspecified == FALSE) {
        d <- d[d$Type != "" & !is.na(d$DescriptionNumber), ]
    }

    softermax.template(
        d,
        wellsAsFactors = wellsAsFactors,
        groupsAsFactors = groupsAsFactors,
        typesAsFactors = typesAsFactors
    )
}
