# ==============================================================================
# Raw Assessment Data Download Functions - Socrata API
# ==============================================================================
#
# This file contains functions for downloading raw MCAS assessment data from the
# Massachusetts DESE Socrata API (educationtocareer.data.mass.gov).
#
# Dataset: MCAS Achievement Results (i9w6-niyt)
# API endpoint: https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json
# Years available: 2017-2025 (8 years, excluding 2020 due to COVID)
#
# ==============================================================================

#' Base URL for the DESE Assessment Socrata API
#' @keywords internal
DESE_ASSESS_SOCRATA_API <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json"

#' Get available assessment years
#'
#' Returns a vector of years for which MCAS assessment data is available
#' from the Massachusetts DESE Socrata API.
#'
#' @return Integer vector of years (2017-2019, 2021-2025)
#' @export
#' @examples
#' \dontrun{
#' get_available_assess_years()
#' # Returns: 2017 2018 2019 2021 2022 2023 2024 2025
#' }
get_available_assess_years <- function() {
  c(2017:2019, 2021:2025)
}

#' Download raw assessment data from DESE Socrata API
#'
#' Downloads MCAS assessment data from the Massachusetts Education-to-Career
#' Research and Data Hub (Socrata) API.
#'
#' @param end_year School year end (2024-25 = 2025). Valid years: 2017-2019, 2021-2025.
#' @return Data frame with assessment data including district and school records
#' @keywords internal
get_raw_assessment <- function(end_year) {

  # Validate year
  available_years <- get_available_assess_years()
  if (!end_year %in% available_years) {
    stop("end_year must be one of: ", paste(available_years, collapse = ", "),
         "\nNote: 2020 data is not available due to COVID pandemic. ",
         "Run get_available_assess_years() to see available years.")
  }

  message(paste("Downloading DESE MCAS assessment data for", end_year, "from Socrata API..."))

  # Build API request - get all data for this year
  # Socrata uses 1000 row limit by default, so we need to set high limit
  # The MA assessment data has ~50,000-70,000 records per year

  url <- paste0(
    DESE_ASSESS_SOCRATA_API,
    "?$where=sy='", end_year, "'",
    "&$limit=100000",  # High limit to get all records
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
