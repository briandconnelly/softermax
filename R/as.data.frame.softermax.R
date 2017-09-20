#' Coerce 'SoftMax Pro' data into data frames
#'
#' @param x A \code{softermax} object
#' @inheritParams base::as.data.frame
#' @param experimentsAsFactors Logical value indicating whether or not
#' experiment names should be treated as factors (default: \code{TRUE})
#' @param platesAsFactors Logical value indicating whether or not plate names
#' should be treated as factors (default: \code{TRUE})
#' @param readModesAsFactors Logical value indicating whether or not read modes
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
                                    readModesAsFactors = TRUE,
                                    wellsAsFactors = TRUE,
                                    ...) {
    d <- do.call(
        "rbind",
        lapply(
            X = x$experiments,
            FUN = as.data.frame,
            experimentsAsFactors = FALSE,
            platesAsFactors = FALSE,
            wellsAsFactors = FALSE)
    )

    row.names(d) <- row.names
    if (experimentsAsFactors) d$Experiment <- as.factor(d$Experiment)
    if (platesAsFactors) d$Plate <- as.factor(d$Plate)
    if (readModesAsFactors) d$ReadMode <- as.factor(d$ReadMode)
    if (wellsAsFactors) d$Well <- as.factor(d$Well)

    d[c("Experiment", "Plate", "ReadMode", "Temperature", "Wavelength", "Well",
        "Time", "Value")]
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermax.experiment <- function(x,
                                              row.names = NULL,
                                              optional = FALSE,
                                              experimentsAsFactors = TRUE,
                                              platesAsFactors = TRUE,
                                              readModesAsFactors = TRUE,
                                              wellsAsFactors = TRUE,
                                              ...) {
    d <- do.call(
        "rbind",
        lapply(
            X = x$plates,
            FUN = as.data.frame,
            platesAsFactors = FALSE,
            wellsAsFactors = FALSE
        )
    )

    row.names(d) <- row.names
    d$Experiment <- attr(x, "name")

    if (experimentsAsFactors) d$Experiment <- as.factor(d$Experiment)
    if (platesAsFactors) d$Plate <- as.factor(d$Plate)
    if (readModesAsFactors) d$ReadMode <- as.factor(d$ReadMode)
    if (wellsAsFactors) d$Well <- as.factor(d$Well)

    d[c("Experiment", "Plate", "ReadMode", "Temperature", "Wavelength", "Well",
        "Time", "Value")]
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermax.plate <- function(x,
                                         row.names = NULL,
                                         optional = FALSE,
                                         platesAsFactors = TRUE,
                                         readModesAsFactors = TRUE,
                                         wellsAsFactors = TRUE,
                                         ...) {
    d <- do.call(
        "rbind",
        lapply(
            X = x$wavelengths,
            FUN = as.data.frame,
            wellsAsFactors = FALSE
        )
    )

    row.names(d) <- row.names
    d$ReadMode <- attr(x, "instrument_settings")$read_mode
    d$Temperature <- x$temperatures
    d$Plate <- attr(x, "name")

    if (platesAsFactors) d$Plate <- as.factor(d$Plate)
    if (readModesAsFactors) d$ReadMode <- as.factor(d$ReadMode)
    if (wellsAsFactors) d$Well <- as.factor(d$Well)

    d[c("Plate", "ReadMode", "Temperature", "Wavelength", "Well", "Time",
        "Value")]
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermax.wavelength <- function(x,
                                              row.names = NULL,
                                              optional = FALSE,
                                              wellsAsFactors = TRUE,
                                              ...) {
    d <- do.call(
        "rbind",
        lapply(
            X = x$wells,
            FUN = as.data.frame
        )
    )

    row.names(d) <- row.names
    d$Wavelength <- attr(x, "wavelength")

    if (wellsAsFactors) d$Well <- as.factor(d$Well)

    d[c("Wavelength", "Well", "Time", "Value")]
}


#' @rdname as.data.frame.softermax
#' @export
as.data.frame.softermax.well <- function(x,
                                        row.names = NULL,
                                        optional = FALSE,
                                        ...) {
    d <- data.frame(
        Well = attr(x, "name"),
        #ID = attr(x, "ID"),
        Time = x$times,
        Value = x$values,
        row.names = row.names,
        stringsAsFactors = FALSE
    )
    d[c("Well", "Time", "Value")]
}
