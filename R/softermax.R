# Constructors for softermax objects

softermax <- function(experiments, verstring = NULL) {
    if (missing(experiments)) experiments = list()

    x <- structure(
        list(
            experiments = experiments
        ),
        class = c("softermax", verstring)
    )

    names(x$experiments) <- list_attrs(x$experiments, "name")
    x
}


softermaxExperiment <- function(name, plates = list(), notes = list()) {
    x <- structure(
        list(
            plates = plates,
            notes = notes
        ),
        name = name,
        class = "softermaxExperiment"
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

    # Remove empty plates, which seem to appear in some XML files
    x$plates <- x$plates[!is.na(x$plates)]
    x$notes <- x$notes[!is.na(x$notes)]

    x
}


softermaxPlate <- function(name, wavelengths = list(), temperatures = NA) {
    x <- structure(
        list(
            wavelengths = wavelengths,
            temperatures = temperatures
        ),
        name = name,
        class = "softermaxPlate"
    )

    names(x$wavelengths) <- list_attrs(x$wavelengths, "wavelength")
    x
}


softermaxNote <- function(name, text_data = list()) {
    x <- structure(
        list(
            text_data = text_data
        ),
        name = name,
        class = "softermaxNote"
    )

    x
}


softermaxWavelength <- function(wavelength, wells = list()) {
    x <- structure(
        list(
            wells = wells
        ),
        wavelength = wavelength,
        class = "softermaxWavelength"
    )

    names(x$wells) <- list_attrs(x$wells, "name")
    x
}


softermaxWell <- function(name, times, values) {
    x <- structure(
        list(
            times = times,
            values = values
        ),
        name = name,
        class = "softermaxWell"
    )
    x
}
