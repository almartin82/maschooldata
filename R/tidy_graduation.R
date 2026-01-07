# ==============================================================================
# Graduation Rate Data Tidying Functions
# ==============================================================================
#
# This file contains functions for transforming graduation data from wide
# format to long (tidy) format.
#
# Note: The graduation data from Socrata API is already in a semi-long format
# (one row per organization x subgroup x rate_type). This function ensures
# consistency and adds any missing transformations.
#
# ==============================================================================

#' Tidy graduation data
#'
#' Transforms processed graduation data to ensure consistent long format.
#' The Socrata API data is already in long format, so this function primarily
#' validates and ensures schema consistency.
#'
#' @param df A processed graduation data frame from process_graduation()
#' @return A long data frame of tidied graduation data
#' @keywords internal
tidy_graduation <- function(df) {

  # Data is already in long format from Socrata API
  # Just ensure column order and data types

  # Ensure correct column order
  column_order <- c(
    "end_year", "type",
    "district_id", "district_name",
    "school_id", "school_name",
    "subgroup", "cohort_type",
    "cohort_count", "graduate_count", "grad_rate",
    "is_state", "is_district", "is_school"
  )

  # Select only columns that exist
  existing_cols <- column_order[column_order %in% names(df)]

  tidy_df <- df |>
    dplyr::select(dplyr::all_of(existing_cols))

  # Remove rows with NA subgroup (data quality issue)
  tidy_df <- tidy_df[!is.na(tidy_df$subgroup), ]

  # Ensure IDs are character type (preserve leading zeros)
  tidy_df$district_id <- as.character(tidy_df$district_id)
  tidy_df$school_id <- as.character(tidy_df$school_id)

  tidy_df
}
