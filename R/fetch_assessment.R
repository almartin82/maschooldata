# ==============================================================================
# Assessment Data Fetching Functions
# ==============================================================================
#
# This file contains functions for downloading MCAS assessment data from the
# Massachusetts Department of Elementary and Secondary Education (DESE).
#
# Data source: DESE Socrata API (educationtocareer.data.mass.gov)
# Available years: 2017-2019, 2021-2025 (2020 not available due to COVID)
#
# ==============================================================================

#' @importFrom utils head
NULL

#' Fetch Massachusetts MCAS assessment data
#'
#' Downloads and processes MCAS assessment data from the Massachusetts Department
#' of Elementary and Secondary Education (DESE) via their Socrata API
#' (educationtocareer.data.mass.gov).
#'
#' @param end_year A school year. Year is the end of the academic year - eg 2024-25
#'   school year is year '2025'. Valid values are 2017-2019, 2021-2025.
#' @param grade Filter by grade level. Options include "03", "04", "05", "06",
#'   "07", "08", "10", "HS SCI", or "ALL (03-08)". If NULL (default), returns all grades.
#' @param subject Filter by subject. Options include "ela", "math", "science",
#'   "biology", "physics", "civics". If NULL (default), returns all subjects.
#' @param subgroup Filter by student subgroup. Use lowercase names like "all",
#'   "white", "black", "hispanic", "english_learner", "special_ed", etc.
#'   If NULL (default), returns all subgroups.
#' @param tidy If TRUE (default), returns data in long (tidy) format with
#'   subgroup column. If FALSE, returns wide format.
#' @param exclude_aggregated If TRUE (default), excludes aggregated grade rows
#'   (e.g., "ALL (03-08)"). Set to FALSE to include aggregated rows.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#'   Set to FALSE to force re-download from DESE.
#' @return Data frame with assessment data. Includes columns for end_year, type,
#'   district_id, school_id, grade, subject, subgroup, achievement counts and
#'   percentages, participation rate, scaled score, and student growth percentiles.
#' @export
#' @examples
#' \dontrun{
#' # Get 2025 assessment data (2024-25 school year)
#' assess_2025 <- fetch_assessment(2025)
#'
#' # Get grade 10 data only
#' g10 <- fetch_assessment(2025, grade = "10")
#'
#' # Get statewide math results
#' math <- fetch_assessment(2025, subject = "math")
#'
#' # Filter to all students subgroup
#' all_students <- fetch_assessment(2025, subgroup = "all")
#'
#' # Get district-level data
#' districts <- assess_2025 |>
#'   dplyr::filter(is_district)
#'
#' # Compare Boston and Springfield math achievement
#' assess_multi <- fetch_assessment_multi(2019:2025)
#' assess_multi |>
#'   dplyr::filter(district_id %in% c("0035", "0281"),
#'                grade == "10",
#'                subject == "math",
#'                subgroup == "all") |>
#'   dplyr::select(end_year, district_name, meeting_exceeding_pct)
#' }
fetch_assessment <- function(end_year,
                             grade = NULL,
                             subject = NULL,
                             subgroup = NULL,
                             tidy = TRUE,
                             exclude_aggregated = TRUE,
                             use_cache = TRUE) {

  # Validate year
  available_years <- get_available_assess_years()
  if (!end_year %in% available_years) {
    stop(paste0(
      "end_year must be one of: ", paste(available_years, collapse = ", "), ". ",
      "Note: 2020 data is not available due to COVID pandemic. ",
      "Run get_available_assess_years() to see available years."
    ))
  }

  # Determine cache type based on tidy parameter
  cache_type <- if (tidy) "assess_tidy" else "assess_wide"

  # Check cache first
  if (use_cache && cache_exists(end_year, cache_type)) {
    message(paste("Using cached data for", end_year))
    data <- read_cache(end_year, cache_type)
  } else {
    # Get raw data from DESE Socrata API
    raw <- get_raw_assessment(end_year)

    # Process to standard schema
    data <- process_assessment(raw, end_year)

    # Optionally tidy
    if (tidy) {
      data <- tidy_assessment(data)
    }

    # Cache the result
    if (use_cache) {
      write_cache(data, end_year, cache_type)
    }
  }

  # Apply filters after cache read
  if (exclude_aggregated && "is_aggregated" %in% names(data)) {
    data <- data[!data$is_aggregated, ]
  }

  if (!is.null(grade)) {
    if (!grade %in% unique(data$grade)) {
      stop(paste("Invalid grade:", grade,
                 "\nAvailable grades:", paste(unique(data$grade), collapse = ", ")))
    }
    data <- data[data$grade == grade, ]
  }

  if (!is.null(subject)) {
    if (!subject %in% unique(data$subject)) {
      stop(paste("Invalid subject:", subject,
                 "\nAvailable subjects:", paste(unique(data$subject), collapse = ", ")))
    }
    data <- data[data$subject == subject, ]
  }

  if (!is.null(subgroup)) {
    if (!subgroup %in% unique(data$subgroup)) {
      stop(paste("Invalid subgroup:", subgroup,
                 "\nAvailable subgroups:", paste(utils::head(unique(data$subgroup), 10), collapse = ", "),
                 "\nRun get_available_assess_subgroups() to see all subgroups."))
    }
    data <- data[data$subgroup == subgroup, ]
  }

  data
}


#' Fetch assessment data for multiple years
#'
#' Downloads and combines MCAS assessment data for multiple school years.
#'
#' @param end_years Vector of school year ends (e.g., c(2019, 2021, 2022))
#' @param grade Filter by grade level (see fetch_assessment for options)
#' @param subject Filter by subject (see fetch_assessment for options)
#' @param subgroup Filter by student subgroup (see fetch_assessment for options)
#' @param tidy If TRUE (default), returns data in long (tidy) format.
#' @param exclude_aggregated If TRUE (default), excludes aggregated grade rows.
#' @param use_cache If TRUE (default), uses locally cached data when available.
#' @return Combined data frame with assessment data for all requested years
#' @export
#' @examples
#' \dontrun{
#' # Get pre-COVID and post-COVID data
#' assess_multi <- fetch_assessment_multi(c(2019, 2021, 2022, 2023, 2024, 2025))
#'
#' # Track COVID recovery in grade 10 math
#' assess_multi |>
#'   dplyr::filter(is_state, grade == "10", subject == "math", subgroup == "all") |>
#'   dplyr::select(end_year, meeting_exceeding_pct, scaled_score)
#'
#' # Compare district achievement gaps over time
#' assess_multi |>
#'   dplyr::filter(district_id == "0035",
#'                grade == "08",
#'                subject == "ela",
#'                subgroup %in% c("white", "black", "hispanic")) |>
#'   dplyr::select(end_year, subgroup, meeting_exceeding_pct)
#' }
fetch_assessment_multi <- function(end_years,
                                   grade = NULL,
                                   subject = NULL,
                                   subgroup = NULL,
                                   tidy = TRUE,
                                   exclude_aggregated = TRUE,
                                   use_cache = TRUE) {

  # Validate years
  available_years <- get_available_assess_years()
  invalid_years <- end_years[!end_years %in% available_years]
  if (length(invalid_years) > 0) {
    stop(paste("Invalid years:", paste(invalid_years, collapse = ", "),
               "\nNote: 2020 data is not available due to COVID.",
               "\nAvailable years:", paste(available_years, collapse = ", ")))
  }

  # Fetch each year
  results <- purrr::map(
    end_years,
    function(yr) {
      fetch_assessment(yr,
                       grade = grade,
                       subject = subject,
                       subgroup = subgroup,
                       tidy = tidy,
                       exclude_aggregated = exclude_aggregated,
                       use_cache = use_cache)
    }
  )

  # Combine
  dplyr::bind_rows(results)
}


#' Get available assessment subgroups
#'
#' Returns a list of available student subgroups in the assessment data.
#'
#' @return Character vector of subgroup names (lowercase, underscore-separated)
#' @export
#' @examples
#' \dontrun{
#' get_available_assess_subgroups()
#' # Returns: "all", "male", "female", "white", "black", "hispanic", ...
#' }
get_available_assess_subgroups <- function() {
  c(
    "all",
    "male",
    "female",
    "white",
    "black",
    "hispanic",
    "asian",
    "native_american",
    "pacific_islander",
    "multiracial",
    "english_learner",
    "former_english_learner",
    "english_learner_and_former",
    "ever_english_learner",
    "special_ed",
    "not_special_ed",
    "econ_disadv",
    "low_income",
    "not_low_income",
    "high_needs",
    "foster_care",
    "homeless",
    "migrant",
    "military",
    "title_i",
    "not_title_i"
  )
}
