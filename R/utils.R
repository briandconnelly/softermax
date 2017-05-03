#' @importFrom magrittr %>%
#' @export
magrittr::`%>%`


# Find duplicate values in a list of strings
find_duplicate_strings <- function(x) {
    unique(x[duplicated(x)])
}

# Raise an error if a required package is not installed
stop_without_package <- function(package) {
    if (!requireNamespace(package, quietly = TRUE)) {
        stop(sprintf("This function requires the '%s' package", package),
             call. = FALSE)
    }
}
