# Make a tibble for each well
read_softmax5_xml_plate_well <- function(w) {

    well_name <- xml2::xml_attr(w, "wellName")
    rawdata <- xml2::xml_find_first(w, ".//oneDataSet/rawData")
    timedata <- xml2::xml_find_first(w, ".//oneDataSet/timeData")

    tibble::tibble(
        Time = as.numeric(strsplit(xml2::xml_text(timedata), " ")[[1]]),
        Well = well_name,
        Value = as.numeric(strsplit(xml2::xml_text(rawdata), " ")[[1]])
    )
}

# Make a data frame for each plate, combining the data from each well
read_softmax5_xml_plate <- function(p,
                                    platesAsFactors = TRUE,
                                    wellsAsFactors = TRUE) {

    if (xml2::xml_text(p) == "") return(NA)

    wavelengths <- unlist(
        lapply(
            xml2::xml_find_all(p, ".//wavelengthInfo/waveSet"),
            function(x) as.numeric(xml2::xml_text(xml2::xml_find_first(x, ".//waveValue")))
        )
    )

    d <- dplyr::bind_rows(
        lapply(
            xml2::xml_find_all(p, ".//wave"),
            function(x) {
                d <- dplyr::bind_rows(
                    lapply(
                        X = xml2::xml_find_all(x, ".//well"),
                        FUN = read_softmax5_xml_plate_well
                    )
                )
                d$Wavelength <- wavelengths[as.integer(xml2::xml_attr(x, "waveID"))]
                d
            }
        )
    )

    d$Plate <- xml2::xml_text(xml2::xml_find_first(p, ".//plateSectionName"))

    temps_raw <- xml2::xml_find_first(p, ".//temperatureData")
    d$Temperature <- as.numeric(strsplit(xml2::xml_text(temps_raw), " ")[[1]])

    if (platesAsFactors) d$Plate <- forcats::as_factor(d$Plate)
    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    # TODO: add other attributres to the result (read time, etc.)

    d
}


read_softmax5_xml_experiment <- function(e,
                                         experimentsAsFactors = TRUE,
                                         platesAsFactors = TRUE,
                                         wellsAsFactors = TRUE) {
    res <- structure(
        list(
            name = xml2::xml_attr(e, "sectionName"),
            plates = lapply(
                X = xml2::xml_find_all(e, ".//plateSection"),
                FUN = read_softmax5_xml_plate,
                platesAsFactors = platesAsFactors,
                wellsAsFactors = wellsAsFactors
            )
        ),
        class = "softermaxExperiment"
    )

    res$plates <- res$plates[!is.na(res$plates)]
    res
}


#' Read a SoftMax Pro v5 XML File
#'
#' @param file Either a path to a file, a connection, or literal data (either a single string or a raw vector).
#' @param experimentsAsFactors Logical value indicating whether or not experiment names should be factors (default: \code{TRUE})
#' @param platesAsFactors Logical value indicating whether or not plate names should be factors (default: \code{TRUE})
#' @param wellsAsFactors Logical value indicating whether or not well labels should be factors (default: \code{TRUE})
#'
#' @return TODO
#' @export
#'
#' @examples
#' \dontrun{
#' d <- read_softmax5_xml("myfile.xml")
#' }
read_softmax5_xml <- function(file,
                              experimentsAsFactors = TRUE,
                              platesAsFactors = TRUE,
                              wellsAsFactors = TRUE) {

    datafile <- xml2::read_xml(file)
    xml2::xml_ns_strip(datafile)

    structure(
        list(
            experiments = lapply(
                X = xml2::xml_find_all(datafile, ".//experimentSection"),
                FUN = read_softmax5_xml_experiment,
                experimentsAsFactors = experimentsAsFactors,
                platesAsFactors = platesAsFactors,
                wellsAsFactors = wellsAsFactors
            ),
            notes = NULL # TODO: get an example note
        ),
        class = "softermax"
    )
}
