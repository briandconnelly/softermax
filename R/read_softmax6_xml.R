# Read absorbance information about a single well <Well>
read_softmax6_xml_plate_well_absorbance <- function(w) {
    well_attrs <- xml2::xml_attrs(w)
    rawdata <- xml2::xml_find_first(w, ".//RawData")
    timedata <- xml2::xml_find_first(w, ".//TimeData")

    d <- softermaxWell(
        name = well_attrs[["Name"]],
        times = as.numeric(strsplit(xml2::xml_text(timedata), " ")[[1]]),
        values = as.numeric(strsplit(xml2::xml_text(rawdata), " ")[[1]])
    )

    attr(d, "ID") <- well_attrs[["WellID"]]
    attr(d, "row") <- as.integer(well_attrs[["Row"]])
    attr(d, "col") <- as.integer(well_attrs[["Col"]])

    d
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

    # TODO: maybe don't stop(), but just don't read the unsupported plate?
    read_mode <- inst_attrs[["ReadMode"]]
    well_fn <- switch(read_mode,
                      "Absorbance" = read_softmax6_xml_plate_well_absorbance,
                      #"Luminescence" = read_softmax6_xml_plate_well_luminescence,
                      stop(sprintf("'%s' read mode is unsupported", read_mode), call. = FALSE))

    d <- softermaxPlate(
        name = plate_attrs[["Name"]],
        wavelengths = lapply(
            X = xml2::xml_find_all(p, ".//Wavelengths/Wavelength"),
            FUN = function(x) {
                softermaxWavelength(
                    wavelength = wavelengths[as.integer(xml2::xml_attr(x, "WavelengthIndex"))],
                    wells = lapply(
                        X = xml2::xml_find_all(x, ".//Well"),
                        FUN = well_fn
                    )
                )

            }
        ),
        temperatures = as.numeric(strsplit(xml2::xml_text(temps_raw), " ")[[1]])
    )

    attr(d, "type") <- inst_attrs[["PlateType"]]
    attr(d, "barcode") <- xml2::xml_text(xml2::xml_find_first(p, ".//Barcode"))
    attr(d, "read_time") <- readr::parse_datetime(plate_attrs[["ReadTime"]], format = "%T %p %m/%d/%Y")
    attr(d, "instrument_info") <- plate_attrs[["InstrumentInfo"]]
    attr(d, "instrument_settings") <- list(
        read_mode = inst_attrs[["ReadMode"]],
        read_type = inst_attrs[["ReadType"]],
        # TODO: <Automix>
        # TODO: <MoreSettings>
        wavelengths = wavelengths
    )

    d
}

read_softmax6_xml_experiment <- function(e) {
    softermaxExperiment(
        name = "unknown",
        plates = lapply(
            X = xml2::xml_find_all(e, ".//PlateSections/PlateSection"),
            FUN = read_softmax6_xml_plate
        ),
        notes = list()
    )
}


#' @rdname read_softmax_xml
#' @export
read_softmax6_xml <- function(file) {
    datafile <- xml2::read_xml(file)

    softermax(
        experiments = list(read_softmax6_xml_experiment(datafile)),
        verstring = "softermax6"
    )
}
