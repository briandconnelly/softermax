#' Create softermax Objects
#'
#' @description \code{softermax} creates a softermax object
#'
#' @param experiments A list of \code{softermax.experiment} objects
#' @param attrs A list of attributres relevant to the object
#'
#' @return An object of the corresponding type
#' @export
#' @seealso \code{\link{is.softermax}}
softermax <- function(experiments = list(), attrs = list()) {
    x <- structure(
        list(
            experiments = experiments
        ),
        class = "softermax"
    )

    names(x$experiments) <- list_attrs(x$experiments, "name")
    x <- set_attributes(x, attrs)
    x
}


#' @rdname softermax
#' @description \code{softermax.experiment} creates a softermax.experiment
#' object, which stores information about an experiment
#' @param name Name describing the experiment/plate/name/etc.
#' @param plates A list of \code{softermax.plate} objects
#' @param notes A list of \code{softermax.note} objects
#' @export
softermax.experiment <- function(name,
                                 plates = list(),
                                 notes = list(),
                                 attrs = list()) {
    x <- structure(
        list(
            plates = plates,
            notes = notes
        ),
        name = name,
        class = "softermax.experiment"
    )

    plate_names <- list_attrs(x$plates, "name")

    # Warn if there are duplicate plate names
    dup_names <- find_duplicate_strings(plate_names)
    if (length(dup_names) > 0) {
        warning(
            sprintf(
                "Experiment contains multiple plates with name(s): %s",
                paste0(dup_names, collapse = ", ")
            ),
            call. = FALSE
        )
    }

    names(x$plates) <- plate_names
    names(x$notes) <- list_attrs(x$notes, "name")
    x <- set_attributes(x, attrs)

    # Remove empty plates, which seem to appear in some XML files
    x$plates <- x$plates[!is.na(x$plates)]
    x$notes <- x$notes[!is.na(x$notes)]

    x
}


#' @rdname softermax
#' @description \code{softermax.plate} creates a softermax.plate
#' object, which stores information about a plate
#' @param wavelengths A list of \code{softermax.wavelength} objects
#' @param temperatures Temperature(s) at which plate was read (default: \code{NULL})
#' @export
softermax.plate <- function(name,
                            wavelengths = list(),
                            temperatures = NULL,
                            attrs = list()) {
    x <- structure(
        list(
            wavelengths = wavelengths,
            temperatures = temperatures
        ),
        name = name,
        class = "softermax.plate"
    )

    names(x$wavelengths) <- list_attrs(x$wavelengths, "wavelength")
    x <- set_attributes(x, attrs)
    x
}


#' @rdname softermax
#' @description \code{softermax.note} creates a softermax.note
#' object, which stores information about a note
#' @param text_data A list of strings
#' @export
softermax.note <- function(name, text_data = list(), attrs = list()) {
    x <- structure(
        list(
            text_data = text_data
        ),
        name = name,
        class = "softermax.note"
    )

    x <- set_attributes(x, attrs)
    x
}


#' @rdname softermax
#' @description \code{softermax.wavelength} creates a softermax.wavelength
#' object, which stores information about a read at a particular wavelength
#' @param wavelength An integer specifying a read wavelength
#' @param wells A list of \code{softermax.well} objects
#' @export
softermax.wavelength <- function(wavelength, wells = list(), attrs = list()) {
    x <- structure(
        list(
            wells = wells
        ),
        wavelength = wavelength,
        class = "softermax.wavelength"
    )

    names(x$wells) <- list_attrs(x$wells, "name")
    x <- set_attributes(x, attrs)
    x
}


#' @rdname softermax
#' @description \code{softermax.well} creates a softermax.well
#' object, which stores information about a well in a microtiter plate
#' @param times A vector of read times (numeric)
#' @param values A vector of read values (numeric)
#' @export
softermax.well <- function(name, times, values, attrs = list()) {
    x <- structure(
        list(
            times = times,
            values = values
        ),
        name = name,
        class = "softermax.well"
    )

    x <- set_attributes(x, attrs)
    x
}


#' @rdname softermax
#' @description \code{softermax.template} creates a softermax.template
#' object, which stores layout information for a microtiter plate
#' @param x A data frame
#' @param wellsAsFactors A logical value indicating whether well names (e.g., "A6") should be treated as factors or not (default: \code{TRUE})
#' @param groupsAsFactors A logical value indicating whether well groups should be treated as factors or not (default: \code{TRUE})
#' @param typesAsFactors A logical value indicating whether well group types should be treated as factors or not (default: \code{TRUE})
#' @export
softermax.template <- function(x,
                              wellsAsFactors = TRUE,
                              groupsAsFactors = TRUE,
                              typesAsFactors = TRUE) {

    if (wellsAsFactors) x$Well <- as.factor(x$Well)
    if (groupsAsFactors) x$Group <- as.factor(x$Group)
    if (typesAsFactors) x$Type <- as.factor(x$Type)

    # Add extra columns to match V6 output
    if (!"Descriptor2.Name" %in% names(x)) {
        x$Descriptor2.Name <- NA
        x$Descriptor2.Value <- NA
        x$Descriptor2.Units <- NA
    }

    class(x) <- append(class(x), "softermax.template")
    x[c("Well", "Group", "Type", "Sample", "Descriptor1.Name",
        "Descriptor1.Value", "Descriptor1.Units", "Descriptor2.Name",
        "Descriptor2.Value", "Descriptor2.Units")]
}

