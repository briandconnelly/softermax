#' Read a SoftMax Pro XML File
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
#' d <- read_softmax_xml("myfile.xml")
#' }
#'
read_softmax_xml <- function(file,
                             experimentsAsFactors = TRUE,
                             platesAsFactors = TRUE,
                             wellsAsFactors = TRUE) {

    datafile <- xml2::read_xml(file)

    switch(xml2::xml_name(datafile),
           microplateDoc = read_softmax5_xml(file),
           Experiment = read_softmax6_xml(file),
           stop("File type not recognized"))
}
