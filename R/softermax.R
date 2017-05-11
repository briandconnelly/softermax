# Constructors for softermax objects

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

    #Warn if there are duplicate plate names
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


softermax.plate <- function(name,
                            wavelengths = list(),
                            temperatures = NA,
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
