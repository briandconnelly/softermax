read_softmax5_xml_plate_well <- function(w) {
    well_attrs <- xml2::xml_attrs(w)
    rawdata <- xml2::xml_find_first(w, ".//oneDataSet/rawData")
    timedata <- xml2::xml_find_first(w, ".//oneDataSet/timeData")

    structure(
        list(
            Time = as.numeric(strsplit(xml2::xml_text(timedata), " ")[[1]]),
            Value = as.numeric(strsplit(xml2::xml_text(rawdata), " ")[[1]])
        ),
        name = well_attrs[["wellName"]],
        ID = well_attrs[["wellID"]],
        class = "softermaxWell"
    )
}

read_softmax5_xml_plate <- function(p) {

    if (xml2::xml_text(p) == "") return(NA)

    wavelengths <- unlist(
        lapply(
            X = xml2::xml_find_all(p, ".//instrumentSettings/wavelengthInfo/waveSet"),
            FUN = function(x) as.numeric(xml2::xml_text(xml2::xml_find_first(x, ".//waveValue")))
        )
    )

    temps_raw <- xml2::xml_find_first(p, ".//temperatureData")
    readtime_raw <- xml2::xml_text(xml2::xml_find_first(p, ".//plateReadTime"))

    d <- structure(
        list(
            wavelengths = lapply(
                X = xml2::xml_find_all(p, ".//wave"),
                FUN = function(x) {
                    d <- structure(
                        list(
                            wells = lapply(
                                X = xml2::xml_find_all(x, ".//well"),
                                FUN = read_softmax5_xml_plate_well
                            )
                        ),
                        wavelength = wavelengths[as.integer(xml2::xml_attr(x, "waveID"))],
                        class = "softermaxWavelength"
                    )

                    names(d$wells) <- list_attrs(d$wells, "name")
                    d
                }
            ),
            temperature = as.numeric(strsplit(xml2::xml_text(temps_raw), " ")[[1]])
        ),
        name = xml2::xml_text(xml2::xml_find_first(p, ".//plateSectionName")),
        type = xml2::xml_text(xml2::xml_find_first(p, ".//plateType")),
        num_wells = as.integer(xml2::xml_text(xml2::xml_find_first(p, ".//microplateData/noOfWells"))),
        read_time = readr::parse_datetime(readtime_raw, format = "%T %p %m/%d/%Y"),
        instrument_info = xml2::xml_text(xml2::xml_find_first(p, ".//instrumentInfo")),
        instrument_settings = list(
            read_mode = xml2::xml_text(xml2::xml_find_first(p, ".//instrumentSettings/readMode")),
            read_type = xml2::xml_text(xml2::xml_find_first(p, ".//instrumentSettings/readType")),
            abs_data_type = xml2::xml_text(xml2::xml_find_first(p, ".//instrumentSettings/absDataType")),
            num_reads = as.integer(xml2::xml_text(xml2::xml_find_first(p, ".//instrumentSettings/noOfReads"))),
            wavelengths = wavelengths
        ),
        class = "softermaxPlate"
    )

    names(d$wavelengths) <- list_attrs(d$wavelengths, "wavelength")
    d
}


read_softmax5_xml_note <- function(n) {
    structure(
        list(
            text_data = lapply(
                X = xml2::xml_find_all(n, ".//noteData/textData"),
                FUN = function(x) xml2::xml_text(x)
            )
        ),
        name = xml2::xml_text(xml2::xml_find_first(n, ".//noteSectionName")),
        class = "softermaxNote"
    )
}


read_softmax5_xml_experiment <- function(e) {
    res <- structure(
        list(
            plates = lapply(
                X = xml2::xml_find_all(e, ".//plateSection"),
                FUN = read_softmax5_xml_plate
            ),
            notes = lapply(
                X = xml2::xml_find_all(e, ".//noteSection"),
                FUN = read_softmax5_xml_note
            )
        ),
        name = xml2::xml_attr(e, "sectionName"),
        class = "softermaxExperiment"
    )

    names(res$plates) <- list_attrs(res$plates, "name")
    names(res$notes) <- list_attrs(res$notes, "name")

    # Remove empty plates, which seem to appear in some XML files
    res$plates <- res$plates[!is.na(res$plates)]

    res
}


#' @rdname read_softmax_xml
#' @export
read_softmax5_xml <- function(file) {

    datafile <- xml2::read_xml(file)
    xml2::xml_ns_strip(datafile)

    d <- structure(
        list(
            experiments = lapply(
                X = xml2::xml_find_all(datafile, ".//experimentSection"),
                FUN = read_softmax5_xml_experiment
            )
        ),
        file_version = xml2::xml_text(
            xml2::xml_find_first(datafile, ".//fileVersion")
        ),
        class = c("softermax", "softermax5")
    )

    names(d$experiments) <- list_attrs(d$experiments, "name")
    d
}
