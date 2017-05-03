#' Coerce SoftMax Pro data into data frames
#'
#' @param x A \code{softermaxPlate} object
#' @inheritParams base::as.data.frame
#' @param experimentsAsFactors Logical value indicating whether or not
#' experiment names should be treated as factors (default: \code{TRUE})
#' @param platesAsFactors Logical value indicating whether or not plate names
#' should be treated as factors (default: \code{TRUE})
#' @param wellsAsFactors Logical value indicating whether or not well names
#' (e.g., "H5") should be treated as factors (default: \code{TRUE})
#' @param ... Additional parameters (not used)
#'
#' @return A data frame
#' @export
#'
#' @examples
#' \dontrun{
#' d <- as.data.frame(read_softmax_xml("myfile.xml"))
#' }
#'
as.data.frame.softermax <- function(x,
                                    row.names = NULL,
                                    optional = FALSE,
                                    experimentsAsFactors = TRUE,
                                    platesAsFactors = TRUE,
                                    wellsAsFactors = TRUE,
                                    ...) {
    d <- dplyr::bind_rows(
        lapply(
            X = x$experiments,
            FUN = as.data.frame,
            row.names = row.names,
            optional = optional,
            experimentsAsFactors = FALSE,
            platesAsFactors = FALSE,
            wellsAsFactors = FALSE)
    )

    if (experimentsAsFactors) d$Experiment <- forcats::as_factor(d$Experiment)
    if (platesAsFactors) d$Plate <- forcats::as_factor(d$Plate)
    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    d[c("Experiment", "Plate", "Temperature", "Wavelength", "Well", "Time", "Value")]
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermaxExperiment <- function(x,
                                              row.names = NULL,
                                              optional = FALSE,
                                              experimentsAsFactors = TRUE,
                                              platesAsFactors = TRUE,
                                              wellsAsFactors = TRUE,
                                              ...) {
    d <- dplyr::bind_rows(
        lapply(
            X = x$plates,
            FUN = as.data.frame,
            row.names = row.names,
            optional = FALSE,
            platesAsFactors = FALSE,
            wellsAsFactors = FALSE
        )
    )
    d$Experiment <- attr(x, "name")

    if (experimentsAsFactors) d$Experiment <- forcats::as_factor(d$Experiment)
    if (platesAsFactors) d$Plate <- forcats::as_factor(d$Plate)
    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    d[c("Experiment", "Plate", "Temperature", "Wavelength", "Well", "Time", "Value")]
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermaxPlate <- function(x,
                                         row.names = NULL,
                                         optional = FALSE,
                                         platesAsFactors = TRUE,
                                         wellsAsFactors = TRUE,
                                         ...) {
    d <- dplyr::bind_rows(
        lapply(
            X = x$wavelengths,
            FUN = as.data.frame,
            row.names = NULL,
            optional = FALSE,
            wellsAsFactors = FALSE
        )
    )
    d$Temperature <- x$temperature # TODO: repeat this value
    d$Plate <- attr(x, "name")

    if (platesAsFactors) d$Plate <- forcats::as_factor(d$Plate)
    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    d[c("Plate", "Temperature", "Wavelength", "Well", "Time", "Value")]
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermaxWavelength <- function(x,
                                              row.names = NULL,
                                              optional = FALSE,
                                              wellsAsFactors = TRUE,
                                              ...) {
    d <- dplyr::bind_rows(
        lapply(
            X = x$wells,
            FUN = as.data.frame,
            row.names = row.names,
            optional = optional
        )
    )
    d$Wavelength <- attr(x, "wavelength")

    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    d[c("Wavelength", "Well", "Time", "Value")]
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermaxWell <- function(x,
                                        row.names = NULL,
                                        optional = FALSE,
                                        ...) {
    d <- data.frame(
        Well = attr(x, "name"),
        #ID = attr(x, "ID"),
        Time = x$Time,
        Value = x$Value,
        row.names = row.names,
        #optional = optional,
        stringsAsFactors = FALSE
    )
    d[c("Well", "Time", "Value")]
}
