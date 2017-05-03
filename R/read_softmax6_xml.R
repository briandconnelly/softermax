# Read information about a single well <Well>
read_softmax6_xml_plate_well <- function(w) {
    well_attrs <- xml2::xml_attrs(w)
    rawdata <- xml2::xml_find_first(w, ".//RawData")
    timedata <- xml2::xml_find_first(w, ".//TimeData")

    structure(
        list(
            Time = as.numeric(strsplit(xml2::xml_text(timedata), " ")[[1]]),
            Value = as.numeric(strsplit(xml2::xml_text(rawdata), " ")[[1]])
        ),
        name = well_attrs[["Name"]],
        ID = well_attrs[["WellID"]],
        Row = as.integer(well_attrs[["Row"]]),
        Col = as.integer(well_attrs[["Col"]]),
        class = "softermaxWell"
    )
}


# Read information about a plate <PlateSection>
read_softmax6_xml_plate <- function(p) {
    plate_attrs <- xml2::xml_attrs(p)
    inst_attrs <- xml2::xml_attrs(xml2::xml_find_first(p, ".//InstrumentSettings"))

    wavelengths <- unlist(
        lapply(
            X = xml2::xml_find_all(p, ".//InstrumentSettings/WavelengthSettings/Wavelength"),
            FUN = function(x) as.numeric(xml2::xml_text(x))
        )
    )

    temps_raw <- xml2::xml_find_first(p, ".//TemperatureData")

    structure(
        list(
            wavelengths = lapply(
                X = xml2::xml_find_all(p, ".//Wavelengths/Wavelength"),
                FUN = function(x) {
                    structure(
                        list(
                            wells = lapply(
                                X = xml2::xml_find_all(x, ".//Well"),
                                FUN = read_softmax6_xml_plate_well
                            )
                        ),
                        wavelength = wavelengths[as.integer(xml2::xml_attr(x, "WavelengthIndex"))],
                        class = "softermaxWavelength"
                    )
                }
            ),
            temperature = as.numeric(strsplit(xml2::xml_text(temps_raw), " ")[[1]])
        ),
        name = plate_attrs[["Name"]],
        type = inst_attrs[["PlateType"]],
        barcode = xml2::xml_text(xml2::xml_find_first(p, ".//Barcode")),
        read_time = readr::parse_datetime(plate_attrs[["ReadTime"]], format = "%T %p %m/%d/%Y"),
        instrument_info = plate_attrs[["InstrumentInfo"]],
        instrument_settings = list(
            read_mode = inst_attrs[["ReadMode"]],
            read_type = inst_attrs[["ReadType"]],
            # TODO: <Automix>
            # TODO: <MoreSettings>
            wavelengths = wavelengths
        ),
        class = "softermaxPlate"
    )

}

read_softmax6_xml_experiment <- function(e) {
    structure(
        list(
            plates = lapply(
                X = xml2::xml_find_all(e, ".//PlateSections/PlateSection"),
                FUN = read_softmax6_xml_plate
            )
        ),
        name = "unknown",
        class = "softermaxExperiment"
    )
}


#' @rdname read_softmax_xml
#' @export
read_softmax6_xml <- function(file) {

    datafile <- xml2::read_xml(file)

    #experiments <- xml2::xml_find_all(datafile, ".//Experiment")
    #cat(sprintf("EXPERIMENTS (%d): %s\n", length(experiments), experiments))

    structure(
        list(
            experiments = list(read_softmax6_xml_experiment(datafile))
        ),
        class = c("softermax", "softermax6")
    )
}
