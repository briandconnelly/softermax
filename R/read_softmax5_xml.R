read_softmax5_xml_plate_well <- function(w) {
    well_attrs <- xml2::xml_attrs(w)
    rawdata <- xml2::xml_find_first(w, ".//oneDataSet/rawData")
    timedata <- xml2::xml_find_first(w, ".//oneDataSet/timeData")

    softermax.well(
        name = well_attrs[["wellName"]],
        times = as.numeric(strsplit(xml2::xml_text(timedata), " ")[[1]]),
        values = as.numeric(strsplit(xml2::xml_text(rawdata), " ")[[1]]),
        attrs = list(ID = well_attrs[["wellID"]])
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

    softermax.plate(
        name = xml2::xml_text(xml2::xml_find_first(p, ".//plateSectionName")),
        wavelengths = lapply(
            X = xml2::xml_find_all(p, ".//wave"),
            FUN = function(x) {
                softermax.wavelength(
                    wavelength = wavelengths[as.integer(xml2::xml_attr(x, "waveID"))],
                    wells = lapply(
                        X = xml2::xml_find_all(x, ".//well"),
                        FUN = read_softmax5_xml_plate_well
                    )
                )
            }
        ),
        temperatures = as.numeric(strsplit(xml2::xml_text(temps_raw), " ")[[1]]),
        attrs = list(
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
            )
        )
    )
}


read_softmax5_xml_note <- function(n) {
    softermax.note(
        name = xml2::xml_text(xml2::xml_find_first(n, ".//noteSectionName")),
        text_data = lapply(
            X = xml2::xml_find_all(n, ".//noteData/textData"),
            FUN = function(x) xml2::xml_text(x)
        )
    )
}


read_softmax5_xml_experiment <- function(e) {
    softermax.experiment(
        name = xml2::xml_attr(e, "sectionName"),
        plates = lapply(
            X = xml2::xml_find_all(e, ".//plateSection"),
            FUN = read_softmax5_xml_plate
        ),
        notes = lapply(
            X = xml2::xml_find_all(e, ".//noteSection"),
            FUN = read_softmax5_xml_note
        )
    )
}


#' @rdname read_softmax_xml
#' @export
read_softmax5_xml <- function(file, ...) {
    datafile <- xml2::read_xml(file, ...)
    xml2::xml_ns_strip(datafile)

    d <- softermax(
        experiments = lapply(
            X = xml2::xml_find_all(datafile, ".//experimentSection"),
            FUN = read_softmax5_xml_experiment
        ),
        attrs = list(
            file_version = xml2::xml_text(
                xml2::xml_find_first(datafile, ".//fileVersion")
            )
        )
    )

    class(d) <- append(class(d), "softermax5")
    d
}
