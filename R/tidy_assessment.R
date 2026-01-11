# ==============================================================================
# Assessment Data Tidying Functions
# ==============================================================================
#
# This file contains functions for transforming assessment data from wide
# format to long (tidy) format.
#
# Note: The assessment data from Socrata API is already in a semi-long format
# (one row per organization x grade x subject x subgroup). This function ensures
# consistency and adds any missing transformations.
#
# ==============================================================================

#' Tidy assessment data
#'
#' Transforms processed assessment data to ensure consistent long format.
#' The Socrata API data is already in long format, so this function primarily
#' validates and ensures schema consistency.
#'
#' @param df A processed assessment data frame from process_assessment()
#' @return A long data frame of tidied assessment data
#' @keywords internal
tidy_assessment <- function(df) {

  # Data is already in long format from Socrata API
  # Just ensure column order and data types

  # Ensure correct column order
  column_order <- c(
    "end_year", "type",
    "district_id", "district_name",
    "school_id", "school_name",
    "grade", "subject", "subgroup",
    "meeting_exceeding_cnt", "exceeding_cnt", "meeting_cnt",
    "partially_meeting_cnt", "not_meeting_cnt", "student_count",
    "meeting_exceeding_pct", "exceeding_pct", "meeting_pct",
    "partially_meeting_pct", "not_meeting_pct",
    "participation_rate", "scaled_score", "sgp", "sgp_n",
    "is_state", "is_district", "is_school", "is_aggregated"
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
