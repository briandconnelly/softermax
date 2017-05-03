#' Coerce SoftMax Pro data into data frames
#'
#' @param x A \code{softermaxPlate} object
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
                                    experimentsAsFactors = TRUE,
                                    platesAsFactors = TRUE,
                                    wellsAsFactors = TRUE,
                                    ...) {
    d <- dplyr::bind_rows(
        lapply(
            X = x$experiments,
            FUN = as.data.frame,
            experimentsAsFactors = FALSE,
            platesAsFactors = FALSE,
            wellsAsFactors = FALSE)
    )

    if (experimentsAsFactors) d$Experiment <- forcats::as_factor(d$Experiment)
    if (platesAsFactors) d$Plate <- forcats::as_factor(d$Plate)
    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    d %>%
        dplyr::select(
            Experiment,
            Plate,
            Time,
            Temperature,
            Wavelength,
            Well,
            Value
        )
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermaxExperiment <- function(x,
                                              experimentsAsFactors = TRUE,
                                              platesAsFactors = TRUE,
                                              wellsAsFactors = TRUE,
                                              ...) {
    d <- dplyr::bind_rows(
        lapply(
            X = x$plates,
            FUN = as.data.frame,
            platesAsFactors = FALSE,
            wellsAsFactors = FALSE
        )
    )
    d$Experiment <- attr(x, "name")

    if (experimentsAsFactors) d$Experiment <- forcats::as_factor(d$Experiment)
    if (platesAsFactors) d$Plate <- forcats::as_factor(d$Plate)
    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    d
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermaxPlate <- function(x,
                                         platesAsFactors = TRUE,
                                         wellsAsFactors = TRUE,
                                         ...) {
    d <- dplyr::bind_rows(
        lapply(
            X = x$wavelengths,
            FUN = as.data.frame,
            wellsAsFactors = FALSE
        )
    )
    d$Temperature <- x$Temperature # TODO: repeat this value
    d$Plate <- attr(x, "name")

    if (platesAsFactors) d$Plate <- forcats::as_factor(d$Plate)
    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    d
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermaxWavelength <- function(x,
                                              wellsAsFactors = TRUE,
                                              ...) {
    d <- dplyr::bind_rows(lapply(x$wells, as.data.frame))
    d$Wavelength <- attr(x, "wavelength")

    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    d
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermaxWell <- function(x, wellsAsFactors = TRUE, ...) {
    data.frame(
        Well = attr(x, "name"),
        #ID = attr(x, "ID"),
        Time = x$Time,
        Value = x$Value,
        row.names = NULL,
        stringsAsFactors = FALSE
    )
}
