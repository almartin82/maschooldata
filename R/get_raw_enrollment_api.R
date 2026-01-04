# ==============================================================================
# Raw Enrollment Data Download Functions - Socrata API
# ==============================================================================
#
# This file contains functions for downloading raw enrollment data from the
# Massachusetts DESE Socrata API (educationtocareer.data.mass.gov).
#
# The Socrata API provides enrollment data from 1994-2025, which is more
# comprehensive than the Excel downloads (2017-2024).
#
# Dataset: Enrollment: Grade, Race/Ethnicity, Gender, and Selected Populations
# API endpoint: https://educationtocareer.data.mass.gov/resource/t8td-gens.json
#
# Note: Years 1992-1993 have limited data (only special populations).
# Full enrollment data (grade counts, demographics) starts in 1994.
#
# ==============================================================================

#' Base URL for the DESE Socrata API
#' @keywords internal
DESE_SOCRATA_API <- "https://educationtocareer.data.mass.gov/resource/t8td-gens.json"

#' Download raw enrollment data from DESE Socrata API
#'
#' Downloads enrollment data from the Massachusetts Education-to-Career
#' Research and Data Hub (Socrata) API.
#'
#' @param end_year School year end (2023-24 = 2024). Valid years: 1994-2025.
#' @return Data frame with enrollment data including district and school records
#' @keywords internal
get_raw_enr_api <- function(end_year) {

  # Validate year
  available_years <- get_available_years()
  if (!end_year %in% available_years) {
    stop("end_year must be between ", min(available_years), " and ",
         max(available_years), ". Run get_available_years() to see available years.")
  }

  message(paste("Downloading DESE enrollment data for", end_year, "from Socrata API..."))

  # Build API request - get all data for this year
  # Socrata uses 1000 row limit by default, so we need to paginate or set high limit
  # The MA enrollment data has ~2500 records per year, so set limit high

  url <- paste0(
    DESE_SOCRATA_API,
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


#' Process API data into standard schema
#'
#' Transforms raw Socrata API data into the standardized schema used by
#' the package, matching the format produced by the Excel-based processing.
#'
#' @param api_data Data frame from get_raw_enr_api
#' @param end_year School year end
#' @return Processed data frame with standardized columns
#' @keywords internal
process_enr_api <- function(api_data, end_year) {

  # Helper to safely get a column value (handles missing columns)
  safe_col <- function(df, col_name) {
    if (col_name %in% names(df)) {
      return(df[[col_name]])
    }
    return(rep(NA_character_, nrow(df)))
  }

  # Helper to safely convert to numeric (handles NULL/NA/missing)
  safe_num <- function(x) {
    if (is.null(x) || length(x) == 0) return(NA_real_)
    x <- as.character(x)
    x[x == ""] <- NA_character_
    suppressWarnings(as.numeric(x))
  }

  # Extract columns safely (some may not exist in all years)
  org_type <- safe_col(api_data, "org_type")
  dist_code <- safe_col(api_data, "dist_code")
  dist_name <- safe_col(api_data, "dist_name")
  org_code <- safe_col(api_data, "org_code")
  org_name <- safe_col(api_data, "org_name")
  total_cnt <- safe_num(safe_col(api_data, "total_cnt"))

  # Get charter codes once (cached) for efficient lookup
  charter_school_codes <- get_charter_codes(use_cache = TRUE)
  charter_district_codes <- get_charter_district_codes(use_cache = TRUE)
  all_charter_codes <- c(charter_school_codes, charter_district_codes)

  # Build processed data frame
  processed <- data.frame(
    end_year = end_year,

    # Type from org_type
    type = dplyr::case_when(
      org_type == "State" ~ "State",
      org_type == "District" ~ "District",
      org_type == "School" ~ "Campus",
      TRUE ~ org_type
    ),

    # IDs
    district_id = dplyr::if_else(
      org_type == "State",
      NA_character_,
      substr(dist_code, 1, 4)
    ),
    campus_id = dplyr::if_else(
      org_type == "School",
      org_code,
      NA_character_
    ),

    # Names
    district_name = dplyr::if_else(
      org_type == "State",
      NA_character_,
      dist_name
    ),
    campus_name = dplyr::if_else(
      org_type == "School",
      org_name,
      NA_character_
    ),

    # Placeholders for fields not in API
    county = NA_character_,
    region = NA_character_,

    # Charter flag from MassGIS school types lookup
    # Uses org_code for schools, dist_code for districts
    charter_flag = dplyr::if_else(
      dplyr::coalesce(org_code, dist_code) %in% all_charter_codes,
      "Y",
      "N"
    ),

    # Total enrollment
    row_total = total_cnt,

    # Grade-level counts
    grade_pk = safe_num(safe_col(api_data, "pk_cnt")),
    grade_k = safe_num(safe_col(api_data, "k_cnt")),
    grade_01 = safe_num(safe_col(api_data, "g1_cnt")),
    grade_02 = safe_num(safe_col(api_data, "g2_cnt")),
    grade_03 = safe_num(safe_col(api_data, "g3_cnt")),
    grade_04 = safe_num(safe_col(api_data, "g4_cnt")),
    grade_05 = safe_num(safe_col(api_data, "g5_cnt")),
    grade_06 = safe_num(safe_col(api_data, "g6_cnt")),
    grade_07 = safe_num(safe_col(api_data, "g7_cnt")),
    grade_08 = safe_num(safe_col(api_data, "g8_cnt")),
    grade_09 = safe_num(safe_col(api_data, "g9_cnt")),
    grade_10 = safe_num(safe_col(api_data, "g10_cnt")),
    grade_11 = safe_num(safe_col(api_data, "g11_cnt")),
    grade_12 = safe_num(safe_col(api_data, "g12_cnt")),

    # Demographics - convert from percentages to counts
    # API returns percentages as decimals (0.15 = 15%)
    white = round(safe_num(safe_col(api_data, "wh_pct")) * total_cnt),
    black = round(safe_num(safe_col(api_data, "baa_pct")) * total_cnt),
    hispanic = round(safe_num(safe_col(api_data, "hl_pct")) * total_cnt),
    asian = round(safe_num(safe_col(api_data, "as_pct")) * total_cnt),
    native_american = round(safe_num(safe_col(api_data, "aian_pct")) * total_cnt),
    pacific_islander = round(safe_num(safe_col(api_data, "nhpi_pct")) * total_cnt),
    multiracial = round(safe_num(safe_col(api_data, "mnhl_pct")) * total_cnt),

    # Special populations
    special_ed = safe_num(safe_col(api_data, "swd_cnt")),
    lep = safe_num(safe_col(api_data, "el_cnt")),

    # Economic status - varies by year
    # 2015-2021: ecd_cnt (Economically Disadvantaged)
    # Pre-2015 and 2022+: li_cnt (Low Income)
    econ_disadv = dplyr::coalesce(
      safe_num(safe_col(api_data, "ecd_cnt")),
      safe_num(safe_col(api_data, "li_cnt"))
    ),

    stringsAsFactors = FALSE
  )

  processed
}
