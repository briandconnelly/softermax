
# Make a tibble for each well
read_softmax_xml_plate_well <- function(w, plate_name) {
    well_name <- xml2::xml_attr(w, "Name")
    rawdata <- xml2::xml_find_first(w, ".//RawData")
    timedata <- xml2::xml_find_first(w, ".//TimeData")

    tibble::tibble(
        Plate = plate_name,
        Time = as.numeric(strsplit(xml2::xml_text(timedata), " ")[[1]]),
        Well = well_name,
        Value = as.numeric(strsplit(xml2::xml_text(rawdata), " ")[[1]])
    )
}

# Make a data frame for each plate, combining the data from each well
read_softmax_xml_plate <- function(p, platesAsFactors = TRUE, wellsAsFactors = TRUE) {
    plate_name <- xml2::xml_attr(p, "Name")
    wells <- xml2::xml_find_all(p, ".//Wells/Well")
    d <- dplyr::bind_rows(lapply(X = wells, FUN = read_softmax_xml_plate_well, plate_name = plate_name))

    temps_raw <- xml2::xml_find_first(p, ".//TemperatureData")
    d$Temperature <- as.numeric(strsplit(xml2::xml_text(temps_raw), " ")[[1]])

    if (platesAsFactors) d$Plate <- forcats::as_factor(d$Plate)
    if (wellsAsFactors) d$Well <- forcats::as_factor(d$Well)

    d
}


#' Read a SoftMax Pro XML File
#'
#' TODO
#'
#' @param file Either a path to a file, a connection, or literal data (either a single string or a raw vector).
#' @param platesAsFactors Logical value indicating whether or not plate names should be factors (default: \code{TRUE})
#' @param wellsAsFactors Logical value indicating whether or not well labels should be factors (default: \code{TRUE})
#'
#' @return A softermax object (list)
#' @export
#'
#' @examples
#' \dontrun{
#' d <- read_softmax_xml("myfile.xml")
#' }
read_softmax_xml <- function(file, platesAsFactors = TRUE, wellsAsFactors = TRUE) {
    datafile <- xml2::read_xml(file)
    plates <- xml2::xml_find_all(datafile, ".//PlateSections/PlateSection")

    structure(
        list(
            plates = lapply(
                X = plates,
                FUN = read_softmax_xml_plate,
                platesAsFactors = platesAsFactors,
                wellsAsFactors = wellsAsFactors
            )
        ),
        class = "softermax"
    )
}
