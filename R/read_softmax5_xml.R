read_softmax5_xml_plate_well <- function(w) {
    well_attrs <- xml2::xml_attrs(w)
    rawdata <- xml2::xml_find_first(w, ".//oneDataSet/rawData")
    timedata <- xml2::xml_find_first(w, ".//oneDataSet/timeData")

    structure(
        list(
            Time = as.numeric(strsplit(xml2::xml_text(timedata), " ")[[1]]),
            Value = as.numeric(strsplit(xml2::xml_text(rawdata), " ")[[1]])
        ),
        name = well_attrs["wellName"],
        ID = well_attrs["wellID"],
        class = "softermaxWell"
    )
}

read_softmax5_xml_plate <- function(p) {

    if (xml2::xml_text(p) == "") return(NA)

    wavelengths <- unlist(
        lapply(
            X = xml2::xml_find_all(p, ".//wavelengthInfo/waveSet"),
            FUN = function(x) as.numeric(xml2::xml_text(xml2::xml_find_first(x, ".//waveValue")))
        )
    )

    temps_raw <- xml2::xml_find_first(p, ".//temperatureData")
    readtime_raw <- xml2::xml_text(xml2::xml_find_first(p, ".//plateReadTime"))

    structure(
        list(
            Wavelengths = lapply(
                X = xml2::xml_find_all(p, ".//wave"),
                FUN = function(x) {
                    structure(
                        list(
                            Wells = lapply(
                                X = xml2::xml_find_all(x, ".//well"),
                                FUN = read_softmax5_xml_plate_well
                            ),
                            Wavelength = wavelengths[as.integer(xml2::xml_attr(x, "waveID"))]
                        ),
                        class = "softermaxWavelength"
                    )
                }
            ),
            Temperature = as.numeric(strsplit(xml2::xml_text(temps_raw), " ")[[1]])
        ),
        name = xml2::xml_text(xml2::xml_find_first(p, ".//plateSectionName")),
        type = xml2::xml_text(xml2::xml_find_first(p, ".//plateType")),
        read_time = readr::parse_datetime(readtime_raw, format="%T %p %m/%d/%Y"),
        instrument_info = xml2::xml_text(xml2::xml_find_first(p, ".//instrumentInfo")),
        # TODO: other attribures
        class = "softermaxPlate"
    )
}

# Option to coerce as data.frame
read_softmax5_xml_experiment <- function(e,
                                         experimentsAsFactors = TRUE,
                                         platesAsFactors = TRUE,
                                         wellsAsFactors = TRUE) {
    res <- structure(
        list(
            plates = lapply(
                X = xml2::xml_find_all(e, ".//plateSection"),
                FUN = read_softmax5_xml_plate
            ),
            notes = NULL # TODO: get an example note
        ),
        name = xml2::xml_attr(e, "sectionName"),
        class = "softermaxExperiment"
    )

    # Remove empty plates, which seem to appear in some XML files
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
            )
        ),
        class = "softermax"
    )
}
