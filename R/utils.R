
# Find duplicate values in a list of strings
find_duplicate_strings <- function(x) {
    unique(x[duplicated(x)])
}

# Get an attribute for each element in a list
list_attrs <- function(x, a) {
    sapply(X = x, FUN = function(x) attr(x, a))
}

# Raise an error if a required package is not installed
stop_without_package <- function(package) {
    if (!requireNamespace(package, quietly = TRUE)) {
        stop(sprintf("This function requires the '%s' package", package),
             call. = FALSE)
    }
}
