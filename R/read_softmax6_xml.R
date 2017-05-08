# Read absorbance information about a single well <Well>
read_softmax6_xml_plate_well_absorbance <- function(w) {
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


# Read luminescence information about a single well <Well>
read_softmax6_xml_plate_well_luminescence <- function(w) {
    well_attrs <- xml2::xml_attrs(w)
    rawdata <- xml2::xml_find_first(w, ".//RawData")
    timedata <- xml2::xml_find_first(w, ".//TimeData")

    cat("LOOKING AT A LUMINESCENCE WELL\n")

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

    # TODO: maybe don't stop(), but just don't read the unsupported plate?
    read_mode <- inst_attrs[["ReadMode"]]
    well_fn <- switch(read_mode,
                      "Absorbance" = read_softmax6_xml_plate_well_absorbance,
                      #"Luminescence" = read_softmax6_xml_plate_well_luminescence,
                      stop(sprintf("'%s' read mode is unsupported", read_mode), call. = FALSE))

    d <- structure(
        list(
            wavelengths = lapply(
                X = xml2::xml_find_all(p, ".//Wavelengths/Wavelength"),
                FUN = function(x) {
                    d <- structure(
                        list(
                            wells = lapply(
                                X = xml2::xml_find_all(x, ".//Well"),
                                FUN = well_fn
                            )
                        ),
                        wavelength = wavelengths[as.integer(xml2::xml_attr(x, "WavelengthIndex"))],
                        class = "softermaxWavelength"
                    )

                    names(d$wells) <- list_attrs(d$wells, "name")
                    d
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

    names(d$wavelengths) <- list_attrs(d$wavelengths, "wavelength")
    d
}

read_softmax6_xml_experiment <- function(e) {
    d <- structure(
        list(
            plates = lapply(
                X = xml2::xml_find_all(e, ".//PlateSections/PlateSection"),
                FUN = read_softmax6_xml_plate
            ),
            notes = list()
        ),
        name = "unknown",
        class = "softermaxExperiment"
    )

    plate_names <- list_attrs(d$plates, "name")
    dup_names = find_duplicate_strings(plate_names)
    if (length(dup_names) > 0) {
        warning(
            sprintf(
                "Experiment contains multiple plates with name(s): %s",
                paste0(dup_names, collapse = ", ")
            ),
            call. = FALSE
        )
    }

    names(d$plates) <- plate_names

    d
}


#' @rdname read_softmax_xml
#' @export
read_softmax6_xml <- function(file) {
    datafile <- xml2::read_xml(file)

    d <- structure(
        list(
            experiments = list(read_softmax6_xml_experiment(datafile))
        ),
        class = c("softermax", "softermax6")
    )

    names(d$experiments) <- list_attrs(d$experiments, "name")
    d
}
