#' Read a SoftMax Pro XML File
#'
#' \code{read_softmax_xml} will attempt to automatically determine the
#' appropriate file version. \code{read_softmax5_xml} and
#' \code{read_softmax6_xml} will attempt to read the data as SoftMax Pro version
#' 5 and 6 format, respectively.
#'
#' @note XML files created by SoftMax Pro version 6 do not differentiate among
#' multiple experiments, so only one experiment will be present in the results.
#' This can lead to problems when multiple experiments have plates with the same
#' name. Future versions will detect this situation and rename plates with
#' name collisions.
#'
#' @param file Either a path to a file, a connection, or literal data (either a
#' single string or a raw vector).
#'
#' @return A \code{softermax} object that contains data for each experiment and
#' plate specified in the given file
#' @export
#'
#' @examples
#' \dontrun{
#' d <- read_softmax_xml("myfile.xml")
#' }
#'
read_softmax_xml <- function(file) {

    datafile <- xml2::read_xml(file)

    switch(xml2::xml_name(datafile),
           microplateDoc = read_softmax5_xml(file),
           Experiment = read_softmax6_xml(file),
           stop("File type not recognized"))
}
