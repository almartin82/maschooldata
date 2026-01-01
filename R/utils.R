# ==============================================================================
# Utility Functions
# ==============================================================================

#' @importFrom rlang .data
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
#' Returns the range of school years for which enrollment data is available
#' from the DESE Socrata API. Data is available from 1994-2025.
#'
#' Note: Years 1992-1993 exist in the API but have very limited data
#' (only special populations). Full enrollment data starts in 1994.
#'
#' @return Integer vector of available school years (end year)
#' @export
#' @examples
#' get_available_years()
#' # Returns: 1994, 1995, ..., 2024, 2025
get_available_years <- function() {

  # Data available from 1994 (1993-94 school year) to 2025 (2024-25 school year)
  # via the DESE Socrata API (educationtocareer.data.mass.gov)
  #
  # Historical note:

  # - 1992-1993: Limited data (special populations only, no grade counts)
  # - 1994-2016: Full data via Socrata API
  # - 2017-2024: Also available via Excel downloads (legacy method)
  # - 2025: Latest year, available via Socrata API
  1994:2025
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
