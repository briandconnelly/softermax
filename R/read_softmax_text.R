#' Read a SoftMax Pro Text File
#'
#' @param file Either a path to a file, a connection, or literal data (either a
#' single string or a raw vector).
#' @param ... Additional arguments (not used)
#'
#' @return A \code{softermax} object that contains data for each experiment and
#' plate specified in the given file
#' @export
#'
#' @examples
#' \dontrun{
#' d <- read_softmax_text("myfile.txt")
#' }
#'
read_softmax_text <- function(file, ...) {
    nblocks_raw <- readr::read_lines(file = file, n_max = 1L)
    nblocks_parse <- stringi::stri_match(
        str = nblocks_raw,
        regex = "^##BLOCKS=\\s*(\\d+)\\s*$"
    )

    if (nrow(nblocks_parse) == 1 && ncol(nblocks_parse) == 2) {
        num_blocks <- as.integer(nblocks_parse[1,2])
    } else {
        stop("Unable to parse file (A)", call. = FALSE)
    }

    raw <- readr::read_lines(file = file, skip = 1)
    # Remove empty lines
    raw <- raw[raw != ""]

    start_linenos <- which(
        stringi::stri_detect(
            str = raw,
            regex = "^(Plate|Cuvette|Note|Group):\\s*"
        )
    )
    end_linenos <- which(stringi::stri_detect(str = raw, regex = "^~End\\s*$"))

    # cat(sprintf("- Num Blocks [%d]\n", num_blocks))
    # cat("- Start Linenos:", start_linenos, "\n")
    # cat("- End Linenos:", end_linenos, "\n")

    if ( (num_blocks != length(start_linenos)) || (num_blocks != length(end_linenos)) ) {
        stop("Unable to parse file (B)", call. = FALSE)
    }

    # TODO: switch to lapply?
    blocks <- purrr::map2(
        start_linenos,
        end_linenos - 1,
        function(x, y) {
            block_raw <- raw[x:y]
            block_info <- stringi::stri_split_regex(
                str = block_raw[1],
                pattern = "\t"
            )[[1]]

            # TODO: note number support
            res <- switch(stringi::stri_trim_both(block_info[1]),
                          "Plate:" = read_softmax_text_plate(block_info, block_raw),
                          "Cuvette:" = read_softmax_text_cuvette(block_info, block_raw),
                          "Note:" = read_softmax_text_note(block_info, block_raw),
                          "Group:" = read_softmax_text_group(block_info, block_raw)
            )

            res
        }
    )

    # TODO: parse the last line for Original Filename and date last saved?

    # Use this to add Notes, Plates, etc. to x
    block_type <- lapply(blocks, class)

    # SMP6 (at least), puts everything together, so there could be plates/notes/etc with duplicate names.
    x <- softermax(
        experiments = list(
            softermax.experiment(name = "unknown")
        ),
        attrs = NULL
    )

    # Set the plates for the experiment
    x$experiments[[1]]$plates <- blocks[block_type == "softermax.plate"]
    x$experiments[[1]]$plates <- blocks[block_type == "data.frame"]
    # TODO: set the plate names

    x$experiments[[1]]$notes <- blocks[block_type == "softermax.note"]
    names(x$experiments[[1]]$notes) <- sprintf("unknown%d", seq_along(x$experiments[[1]]$notes))
    # TODO: set name attribute in each note object

    #blocks
    x
}

read_softmax_text_blockheader <- function(block_info, ...) {
    block_info_names <- c("section_kind",     #1
                          "section_name",
                          "export_version",
                          "export_format",
                          "read_mode",        #5
                          "data_mode",
                          "data_type",
                          "pre_read",
                          "kinetic_points",
                          "TODO1",            #10
                          "TODO2",
                          "start_wavelength",
                          "end_wavelength",
                          "wavelength_step",
                          "num_wavelengths",  #15
                          "read_wavelengths",
                          "first_column",
                          "num_columns",
                          "num_wells",
                          "excitation_wavelengths", #20
                          "cutoff_option",
                          "cutoff_filters",
                          "sweep_wave",
                          "sweep_fixed_wave",
                          "reads_per_well",   #25
                          "PMT",
                          "start_integration_time",
                          "end_integration_time",
                          "first_row_read",
                          "num_rows",         #30
                          "time_tags")

    names(block_info) <- block_info_names[1:length(block_info)]
    block_info <- as.list(block_info)

    block_info$pre_read <- as.logical(block_info$pre_read)
    block_info$kinetic_points <- as.integer(block_info$kinetic_points)

    block_info$TODO1 <- as.integer(block_info$TODO1)
    block_info$TODO2 <- as.integer(block_info$TODO2)

    block_info$start_wavelength <- as.numeric(block_info$start_wavelength)
    block_info$end_wavelength <- as.numeric(block_info$end_wavelength)
    block_info$wavelength_step <- as.numeric(block_info$wavelength_step)

    block_info$num_wavelengths <- as.integer(block_info$num_wavelengths)
    block_info$read_wavelengths <- as.numeric(block_info$read_wavelengths)
    block_info$first_column <- as.integer(block_info$first_column)
    block_info$num_columns <- as.integer(block_info$num_columns)
    block_info$num_wells <- as.integer(block_info$num_wells)

    if ("excitation_wavelengths" %in% names(block_info)) {
        block_info$excitation_wavelengths <- as.integer(block_info$excitation_wavelengths)
    }

    if ("cutoff_filters" %in% names(block_info)) {
        if (block_info$cutoff_filters != "None") {
            block_info$cutoff_filters <- as.integer(block_info$cutoff_filters)
            # TODO: test this
        }
    }

    if ("reads_per_well" %in% names(block_info)) {
        # TODO: test this
        block_info$reads_per_well <- as.integer(block_info$reads_per_well)
    }

    if ("start_integration_time" %in% names(block_info)) {
        block_info$start_integration_time <- as.numeric(block_info$start_integration_time)
    }

    if ("end_integration_time" %in% names(block_info)) {
        block_info$end_integration_time <- as.numeric(block_info$end_integration_time)
    }

    if ("first_row_read" %in% names(block_info)) {
        block_info$first_row_read <- as.integer(block_info$first_row_read)
    }

    if ("num_rows" %in% names(block_info)) {
        block_info$num_rows <- as.integer(block_info$num_rows)
    }

    block_info
}

# Parse a plate block in a SoftMax Pro text file
read_softmax_text_plate <- function(block_info, block_raw, ...) {
    block_info <- read_softmax_text_blockheader(block_info)

    block_data <- stringi::stri_split_regex(
        str = block_raw[2:length(block_raw)],
        pattern = "\t"
    )
    block_data[[1]][1:2] <- c("Time", "Temperature")

    lX <- lapply(block_data, length)
    x2 <- block_data[lX > 1]
    mX <- matrix(unlist(x2[2:length(x2)]), nrow = length(x2) - 1, byrow = TRUE)
    dX <- as.data.frame(mX, row.names = FALSE, stringsAsFactors = FALSE)
    names(dX) <- block_data[[1]]

    if (block_info$export_format == "PlateFormat") {
        dX$Time <- as.numeric(dX$Time[1])
        dX$Temperature <- as.numeric(dX$Temperature[1])

        # Remove the trailing columns
        # Note: this doesn't check to see if the column has no data...
        dX[which(names(dX) == "")] <- NULL

        dX$Row <- seq_len(nrow(dX))

        # TODO: use non-NSE version, gather_
        dX <- tidyr::gather(dX, key = Column, value = Value, -Time, -Temperature, -Row)
        dX$Column <- as.integer(dX$Column)
        dX$Value <- as.numeric(dX$Value)

    } else if (block_info$export_format == "TimeFormat") {
        # Handle empty last column
        if (all(is.na(dX[[ncol(dX)]])) || all(dX[[ncol(dX)]] == "")) {
            dX[[ncol(dX)]] <- NULL
        }

        # Make columns numeric.
        dX[, 2:ncol(dX)] <- lapply(dX[, 2:ncol(dX)], as.numeric)

        # TODO: make tidy?
    }

    # Use readr::parse_time on the time column



    # TODO: make an object
    #block_data
    dX
}


# Parse a cuvette block in a SoftMax Pro text file
read_softmax_text_cuvette <- function(block_info, block_raw, ...) {
    cat("Parsing a cuvette\n")
    cat("------------------------------------------------------------------\n")
    "(CUVETTE)"
}


# Parse a note block in a SoftMax Pro text file
read_softmax_text_note <- function(block_info,
                                   block_raw,
                                   collapse = " ",
                                   ...) {
    note_text <- ifelse(
        length(block_raw) > 1,
        stringi::stri_trim_both(
            str = paste(block_raw[2:length(block_raw)],
                        collapse = collapse)
        ),
        ""
    )

    softermax.note(
        name = "unknown",
        text_data = list(note_text)
    )
}


# Parse a group block in a SoftMax Pro text file
read_softmax_text_group <- function(block_info, block_raw, ...) {
    # TODO
    "(GROUP)"
}
