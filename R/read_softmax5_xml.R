# Make a tibble for each well
read_softmax5_xml_plate_well <- function(w,
                                         experiment_name,
                                         plate_name,
                                         wavelength,
                                         experimentsAsFactors = TRUE,
                                         platesAsFactors = TRUE,
                                         wellsAsFactors = TRUE) {

    well_name <- xml2::xml_attr(w, "wellName")
    rawdata <- xml2::xml_find_first(w, ".//oneDataSet/rawData")
    timedata <- xml2::xml_find_first(w, ".//oneDataSet/timeData")

    tibble::tibble(
        Experiment = experiment_name,
        Plate = plate_name,
        Wavelength = wavelength,
        Time = as.numeric(strsplit(xml2::xml_text(timedata), " ")[[1]]),
        Well = well_name,
        Value = as.numeric(strsplit(xml2::xml_text(rawdata), " ")[[1]])
    )
}

# Make a data frame for each plate, combining the data from each well
read_softmax5_xml_plate <- function(p,
                                    experiment_name = NULL,
                                    experimentsAsFactors = TRUE,
                                    platesAsFactors = TRUE,
                                    wellsAsFactors = TRUE) {

    if (xml2::xml_text(p) == "") return(NA)

    plate_name <- xml2::xml_text(xml2::xml_find_first(p, ".//plateSectionName"))

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
                wavelength <- wavelengths[as.integer(xml2::xml_attr(x, "waveID"))]

                dplyr::bind_rows(
                    lapply(
                        X = xml2::xml_find_all(x, ".//well"),
                        FUN = read_softmax5_xml_plate_well,
                        experiment_name = experiment_name,
                        plate_name = plate_name,
                        wavelength = wavelength
                    )
                )
            }
        )
    )

    temps_raw <- xml2::xml_find_first(p, ".//temperatureData")
    d$Temperature <- as.numeric(strsplit(xml2::xml_text(temps_raw), " ")[[1]])

    if (experimentsAsFactors) d$Experiment <- forcats::as_factor(d$Experiment)
    if (platesAsFactors) d$Plate <- forcats::as_factor(d$Plate)
    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    d
}


read_softmax5_xml_experiment <- function(e, experimentsAsFactors = TRUE, platesAsFactors = TRUE, wellsAsFactors = TRUE) {
    experiment_name <- xml2::xml_attr(e, "sectionName")

    structure(
        list(
            plates = lapply(
                X = xml2::xml_find_all(e, ".//plateSection"),
                FUN = read_softmax5_xml_plate,
                experiment_name = experiment_name
            )
        ),
        class = "softermaxExperiment"
    )
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
