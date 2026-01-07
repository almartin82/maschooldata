# ==============================================================================
# Graduation Rate Data Fetching Functions
# ==============================================================================
#
# This file contains functions for downloading graduation rate data from the
# Massachusetts Department of Elementary and Secondary Education (DESE).
#
# Data source: DESE Socrata API (educationtocareer.data.mass.gov)
# Available years: 2006-2024
#
# ==============================================================================

#' Fetch Massachusetts graduation rate data
#'
#' Downloads and processes graduation rate data from the Massachusetts Department
#' of Elementary and Secondary Education (DESE) via their Socrata API
#' (educationtocareer.data.mass.gov).
#'
#' @param end_year A school year. Year is the end of the academic year - eg 2023-24
#'   school year is year '2024'. Valid values are 2006-2024.
#' @param tidy If TRUE (default), returns data in long (tidy) format with
#'   subgroup column. If FALSE, returns wide format.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#'   Set to FALSE to force re-download from DESE.
#' @return Data frame with graduation rate data. Wide format includes columns for
#'   district_id, school_id, names, subgroup, cohort_type, cohort_count,
#'   graduate_count, and grad_rate. Tidy format is the same (API data is already
#'   in long format).
#' @export
#' @examples
#' \dontrun{
#' # Get 2024 graduation data (2023-24 school year)
#' grad_2024 <- fetch_graduation(2024)
#'
#' # Get historical data from 2010
#' grad_2010 <- fetch_graduation(2010)
#'
#' # Get wide format (already wide from API)
#' grad_wide <- fetch_graduation(2024, tidy = FALSE)
#'
#' # Force fresh download (ignore cache)
#' grad_fresh <- fetch_graduation(2024, use_cache = FALSE)
#'
#' # Filter to Boston Public Schools
#' boston <- grad_2024 |>
#'   dplyr::filter(district_id == "0035")
#'
#' # Compare 4-year and 5-year rates
#' rates <- grad_2024 |>
#'   dplyr::filter(is_state, subgroup == "all") |>
#'   dplyr::select(cohort_type, grad_rate, cohort_count)
#' }
fetch_graduation <- function(end_year, tidy = TRUE, use_cache = TRUE) {

  # Validate year
  available_years <- get_available_grad_years()
  if (!end_year %in% available_years) {
    stop(paste0(
      "end_year must be between ", min(available_years), " and ", max(available_years), ". ",
      "Run get_available_grad_years() to see available years."
    ))
  }

  # Determine cache type based on tidy parameter
  cache_type <- if (tidy) "grad_tidy" else "grad_wide"

  # Check cache first
  if (use_cache && cache_exists(end_year, cache_type)) {
    message(paste("Using cached data for", end_year))
    return(read_cache(end_year, cache_type))
  }

  # Get raw data from DESE Socrata API
  raw <- get_raw_graduation(end_year)

  # Process to standard schema
  processed <- process_graduation(raw, end_year)

  # Optionally tidy
  if (tidy) {
    processed <- tidy_graduation(processed)
  }

  # Cache the result
  if (use_cache) {
    write_cache(processed, end_year, cache_type)
  }

  processed
}


#' Fetch graduation rate data for multiple years
#'
#' Downloads and combines graduation rate data for multiple school years.
#'
#' @param end_years Vector of school year ends (e.g., c(2020, 2021, 2022))
#' @param tidy If TRUE (default), returns data in long (tidy) format.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#' @return Combined data frame with graduation rate data for all requested years
#' @export
#' @examples
#' \dontrun{
#' # Get 5 years of data
#' grad_multi <- fetch_graduation_multi(2020:2024)
#'
#' # Track graduation rate trends
#' grad_multi |>
#'   dplyr::filter(is_state, subgroup == "all", cohort_type == "4-year") |>
#'   dplyr::select(end_year, grad_rate, cohort_count)
#'
#' # Compare Boston and Springfield over time
#' grad_multi |>
#'   dplyr::filter(district_id %in% c("0035", "0281"),
#'                subgroup == "all",
#'                cohort_type == "4-year") |>
#'   dplyr::select(end_year, district_name, grad_rate)
#' }
fetch_graduation_multi <- function(end_years, tidy = TRUE, use_cache = TRUE) {

  # Validate years
  available_years <- get_available_grad_years()
  invalid_years <- end_years[!end_years %in% available_years]
  if (length(invalid_years) > 0) {
    stop(paste("Invalid years:", paste(invalid_years, collapse = ", "),
               "\nAvailable years:", paste(range(available_years), collapse = "-")))
  }

  # Fetch each year
  results <- purrr::map(
    end_years,
    function(yr) {
      message(paste("Fetching", yr, "..."))
      fetch_graduation(yr, tidy = tidy, use_cache = use_cache)
    }
  )

  # Combine
  dplyr::bind_rows(results)
}
