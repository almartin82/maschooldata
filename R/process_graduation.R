# ==============================================================================
# Graduation Rate Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw graduation data from the
# Socrata API into a standardized schema.
#
# ==============================================================================

#' Process raw graduation data into standard schema
#'
#' Transforms raw Socrata API data into the standardized schema used by
#' the package.
#'
#' @param raw_data Data frame from get_raw_graduation()
#' @param end_year School year end
#' @return Processed data frame with standardized columns
#' @keywords internal
process_graduation <- function(raw_data, end_year) {

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

  # Extract columns safely
  org_type <- safe_col(raw_data, "org_type")
  dist_code <- safe_col(raw_data, "dist_code")
  dist_name <- safe_col(raw_data, "dist_name")
  org_code <- safe_col(raw_data, "org_code")
  org_name <- safe_col(raw_data, "org_name")
  grad_rate_type <- safe_col(raw_data, "grad_rate_type")
  stu_grp <- safe_col(raw_data, "stu_grp")
  cohort_cnt <- safe_num(safe_col(raw_data, "cohort_cnt"))
  grad_pct <- safe_num(safe_col(raw_data, "grad_pct"))

  # Build processed data frame
  processed <- data.frame(
    end_year = end_year,

    # Type from org_type
    type = dplyr::case_when(
      org_type == "State" ~ "State",
      org_type == "District" ~ "District",
      org_type == "School" ~ "School",
      TRUE ~ org_type
    ),

    # IDs - extract first 4 digits for district_id
    district_id = dplyr::if_else(
      org_type == "State",
      NA_character_,
      substr(dist_code, 1, 4)
    ),
    district_name = dplyr::if_else(
      org_type == "State",
      NA_character_,
      dist_name
    ),

    # School ID and name
    school_id = dplyr::if_else(
      org_type == "School",
      org_code,
      NA_character_
    ),
    school_name = dplyr::if_else(
      org_type == "School",
      org_name,
      NA_character_
    ),

    # Subgroup (student group)
    subgroup = stu_grp,

    # Graduation rate type
    cohort_type = grad_rate_type,

    # Cohort and graduate counts
    cohort_count = as.integer(cohort_cnt),
    graduate_count = as.integer(round(cohort_cnt * grad_pct)),

    # Graduation rate (already 0-1 scale in API)
    grad_rate = grad_pct,

    stringsAsFactors = FALSE
  )

  # Standardize subgroup names to match expected values
  processed$subgroup <- dplyr::case_when(
    processed$subgroup == "All Students" ~ "all",
    processed$subgroup == "Male" ~ "male",
    processed$subgroup == "Female" ~ "female",
    processed$subgroup == "White" ~ "white",
    processed$subgroup == "Black or African American" ~ "black",
    processed$subgroup == "Hispanic or Latino" ~ "hispanic",
    processed$subgroup == "Asian" ~ "asian",
    processed$subgroup == "American Indian or Alaska Native" ~ "native_american",
    processed$subgroup == "Native Hawaiian or Other Pacific Islander" ~ "pacific_islander",
    processed$subgroup == "Multi-Race, Not Hispanic or Latino" ~ "multiracial",
    processed$subgroup == "English Learners" ~ "english_learner",
    processed$subgroup == "Students with Disabilities" ~ "special_ed",
    processed$subgroup == "Low Income" ~ "low_income",
    processed$subgroup == "High Needs" ~ "high_needs",
    processed$subgroup == "Foster Care" ~ "foster_care",
    processed$subgroup == "Homeless" ~ "homeless",
    is.na(processed$subgroup) ~ NA_character_,
    TRUE ~ tolower(gsub(" ", "_", processed$subgroup))
  )

  # Standardize cohort_type names
  processed$cohort_type <- dplyr::case_when(
    processed$cohort_type == "4-Year Graduation Rate" ~ "4-year",
    processed$cohort_type == "4-Year Adjusted Cohort Graduation Rate" ~ "4-year-adjusted",
    processed$cohort_type == "5-Year Graduation Rate" ~ "5-year",
    processed$cohort_type == "5-Year Adjusted Cohort Graduation Rate" ~ "5-year-adjusted",
    is.na(processed$cohort_type) ~ NA_character_,
    TRUE ~ tolower(gsub(" ", "_", processed$cohort_type))
  )

  # Add aggregation level flags
  processed$is_state <- processed$type == "State"
  processed$is_district <- processed$type == "District"
  processed$is_school <- processed$type == "School"

  processed
}
