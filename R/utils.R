# ==============================================================================
# Utility Functions
# ==============================================================================

#' Pipe operator
#'
#' See \code{dplyr::\link[dplyr:reexports]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL


#' Convert to numeric, handling suppression markers
#'
#' DESE uses various markers for suppressed data (*, ***, <10, etc.)
#' and may use commas in large numbers.
#'
#' @param x Vector to convert
#' @return Numeric vector with NA for non-numeric values
#' @keywords internal
safe_numeric <- function(x) {
  # Remove commas and whitespace
  x <- gsub(",", "", x)
  x <- trimws(x)

  # Handle common suppression markers
  x[x %in% c("*", "***", ".", "-", "-1", "<5", "<10", "N/A", "NA", "")] <- NA_character_
  x[grepl("^\\*+$", x)] <- NA_character_
  x[grepl("^<\\d+$", x)] <- NA_character_

  suppressWarnings(as.numeric(x))
}


#' Get available years for Massachusetts enrollment data
#'
#' Returns the range of school years for which enrollment data is available.
#'
#' @return Character vector of available school years (end year)
#' @export
#' @examples
#' get_available_years()
get_available_years <- function() {
  # Data available from 2017 (2016-17 school year) to 2024 (2023-24 school year)
  # via the Excel download system
  2017:2024
}


#' Map school year codes to end year
#'
#' Converts DESE school year codes (e.g., "2324") to end year (2024)
#'
#' @param yr_code School year code string
#' @return Integer end year
#' @keywords internal
yr_code_to_end_year <- function(yr_code) {
  # DESE uses codes like "2324" for 2023-24
  # Extract first 2 digits, add 2000 to get start year, then +1 for end year
  as.integer(paste0("20", substr(yr_code, 1, 2))) + 1
}


#' Map end year to DESE folder year
#'
#' Converts end year to the folder name used in DESE URLs
#'
#' @param end_year School year end (e.g., 2024 for 2023-24)
#' @return Integer folder year used in URLs
#' @keywords internal
end_year_to_folder <- function(end_year) {
  # DESE URLs use the end year directly in the folder path
  # e.g., /enroll/2024/ for 2023-24 school year
  end_year
}
