# ==============================================================================
# Raw Graduation Rate Data Download Functions - Socrata API
# ==============================================================================
#
# This file contains functions for downloading raw graduation rate data from the
# Massachusetts DESE Socrata API (educationtocareer.data.mass.gov).
#
# Dataset: High School Graduation Rates (n2xa-p822)
# API endpoint: https://educationtocareer.data.mass.gov/resource/n2xa-p822.json
# Years available: 2006-2024 (19 years)
#
# ==============================================================================

#' Base URL for the DESE Graduation Socrata API
#' @keywords internal
DESE_GRAD_SOCRATA_API <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json"

#' Get available graduation years
#'
#' Returns a vector of years for which graduation rate data is available
#' from the Massachusetts DESE Socrata API.
#'
#' @return Integer vector of years (2006-2024)
#' @export
#' @examples
#' \dontrun{
#' get_available_grad_years()
#' # Returns: 2006 2007 2008 ... 2024
#' }
get_available_grad_years <- function() {
  2006:2024
}

#' Download raw graduation data from DESE Socrata API
#'
#' Downloads graduation rate data from the Massachusetts Education-to-Career
#' Research and Data Hub (Socrata) API.
#'
#' @param end_year School year end (2023-24 = 2024). Valid years: 2006-2024.
#' @return Data frame with graduation data including district and school records
#' @keywords internal
get_raw_graduation <- function(end_year) {

  # Validate year
  available_years <- get_available_grad_years()
  if (!end_year %in% available_years) {
    stop("end_year must be between ", min(available_years), " and ",
         max(available_years), ". Run get_available_grad_years() to see available years.")
  }

  message(paste("Downloading DESE graduation data for", end_year, "from Socrata API..."))

  # Build API request - get all data for this year
  # Socrata uses 1000 row limit by default, so we need to set high limit
  # The MA graduation data has ~13,000-26,000 records per year

  url <- paste0(
    DESE_GRAD_SOCRATA_API,
    "?sy=", end_year,
    "&$limit=50000",  # High limit to get all records
    "&$order=org_code"
  )

  # Download with error handling (300 second timeout for large datasets)
  response <- tryCatch({
    httr::GET(
      url,
      httr::timeout(300),
      httr::add_headers(
        Accept = "application/json"
      )
    )
  }, error = function(e) {
    stop("Failed to connect to DESE Socrata API: ", e$message)
  })

  if (httr::http_error(response)) {
    stop(paste("HTTP error:", httr::status_code(response),
               "\nAPI returned error for year", end_year))
  }

  # Parse JSON response
  content <- httr::content(response, as = "text", encoding = "UTF-8")

  df <- tryCatch({
    jsonlite::fromJSON(content, flatten = TRUE)
  }, error = function(e) {
    stop("Failed to parse API response: ", e$message)
  })

  if (nrow(df) == 0) {
    stop(paste("No data returned for year", end_year))
  }

  message(paste("  Downloaded", nrow(df), "records"))

  # Add end_year column
  df$end_year <- end_year

  df
}
