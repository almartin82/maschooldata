# ==============================================================================
# Enrollment Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw DESE enrollment data into a
# clean, standardized format.
#
# ==============================================================================

#' Process raw DESE enrollment data
#'
#' Transforms raw DESE data into a standardized schema combining district
#' and school data.
#'
#' @param raw_data List containing district_race, school_race, and special_pop
#'   data frames from get_raw_enr
#' @param end_year School year end
#' @return Processed data frame with standardized columns
#' @keywords internal
process_enr <- function(raw_data, end_year) {

  # Process district data
  district_processed <- process_district_enr(
    raw_data$district_race,
    raw_data$special_pop,
    end_year
  )

  # Process school data
  school_processed <- process_school_enr(raw_data$school_race, end_year)

  # Create state aggregate
  state_processed <- create_state_aggregate(district_processed, end_year)

  # Combine all levels
  result <- dplyr::bind_rows(state_processed, district_processed, school_processed)

  result
}


#' Process district-level enrollment data
#'
#' @param race_df Raw district race data frame
#' @param special_df Raw special populations data frame (can be NULL)
#' @param end_year School year end
#' @return Processed district data frame
#' @keywords internal
process_district_enr <- function(race_df, special_df, end_year) {

  # Standardize column names (handle different year formats)
  names(race_df) <- standardize_column_names(names(race_df))

  # Filter out rows with invalid org_codes (notes, headers, etc.)
  # Valid org_codes are 4-digit numeric strings, but exclude 0000 (State Totals)
  race_df <- race_df |>
    dplyr::filter(grepl("^[0-9]{4}$", org_code), org_code != "0000")

  # Aggregate from grade-level to district-level
  # Group by district and sum across grades
  # Handle columns that may or may not exist
  cols <- names(race_df)

  district_agg <- race_df |>
    dplyr::group_by(org_code, district_name, county) |>
    dplyr::summarize(
      row_total = sum(safe_numeric(district_total), na.rm = TRUE),
      black = if ("black" %in% cols) sum(safe_numeric(black), na.rm = TRUE) else NA_real_,
      asian = if ("asian" %in% cols) sum(safe_numeric(asian), na.rm = TRUE) else NA_real_,
      hispanic = if ("hispanic" %in% cols) sum(safe_numeric(hispanic), na.rm = TRUE) else NA_real_,
      multiracial = if ("multiracial" %in% cols) sum(safe_numeric(multiracial), na.rm = TRUE) else NA_real_,
      native_american = if ("native_american" %in% cols) sum(safe_numeric(native_american), na.rm = TRUE) else NA_real_,
      pacific_islander = if ("pacific_islander" %in% cols) sum(safe_numeric(pacific_islander), na.rm = TRUE) else NA_real_,
      white = if ("white" %in% cols) sum(safe_numeric(white), na.rm = TRUE) else NA_real_,
      .groups = "drop"
    )

  # Also create grade-level totals for each district
  grade_totals <- race_df |>
    dplyr::mutate(
      grade_std = standardize_grade(grade),
      total = safe_numeric(district_total)
    ) |>
    dplyr::filter(!is.na(grade_std)) |>
    dplyr::group_by(org_code) |>
    dplyr::summarize(
      grade_pk = sum(total[grade_std == "PK"], na.rm = TRUE),
      grade_k = sum(total[grade_std == "K"], na.rm = TRUE),
      grade_01 = sum(total[grade_std == "01"], na.rm = TRUE),
      grade_02 = sum(total[grade_std == "02"], na.rm = TRUE),
      grade_03 = sum(total[grade_std == "03"], na.rm = TRUE),
      grade_04 = sum(total[grade_std == "04"], na.rm = TRUE),
      grade_05 = sum(total[grade_std == "05"], na.rm = TRUE),
      grade_06 = sum(total[grade_std == "06"], na.rm = TRUE),
      grade_07 = sum(total[grade_std == "07"], na.rm = TRUE),
      grade_08 = sum(total[grade_std == "08"], na.rm = TRUE),
      grade_09 = sum(total[grade_std == "09"], na.rm = TRUE),
      grade_10 = sum(total[grade_std == "10"], na.rm = TRUE),
      grade_11 = sum(total[grade_std == "11"], na.rm = TRUE),
      grade_12 = sum(total[grade_std == "12"], na.rm = TRUE),
      .groups = "drop"
    )

  # Join grade totals to district aggregate
  result <- dplyr::left_join(district_agg, grade_totals, by = "org_code")

  # Add special populations if available
  if (!is.null(special_df) && nrow(special_df) > 0) {
    names(special_df) <- standardize_column_names(names(special_df))

    # Filter to valid org_codes
    special_df <- special_df |>
      dplyr::filter(grepl("^[0-9]{4}$", org_code))

    # Find the relevant columns (names vary by year)
    cols <- names(special_df)
    swd_col <- cols[grepl("disabilities|swd", cols, ignore.case = TRUE)][1]
    el_col <- cols[grepl("english_learner|ell", cols, ignore.case = TRUE)][1]
    econ_col <- cols[grepl("low_income|ecodis|economically", cols, ignore.case = TRUE)][1]
    total_col <- cols[grepl("^total_enrol", cols, ignore.case = TRUE)][1]

    # Build special populations data with available columns
    special_clean <- special_df |>
      dplyr::transmute(
        org_code = org_code,
        special_ed = if (!is.na(swd_col) && !is.na(total_col)) {
          extract_pct_to_count(.data[[swd_col]], safe_numeric(.data[[total_col]]))
        } else { NA_integer_ },
        lep = if (!is.na(el_col) && !is.na(total_col)) {
          extract_pct_to_count(.data[[el_col]], safe_numeric(.data[[total_col]]))
        } else { NA_integer_ },
        econ_disadv = if (!is.na(econ_col) && !is.na(total_col)) {
          extract_pct_to_count(.data[[econ_col]], safe_numeric(.data[[total_col]]))
        } else { NA_integer_ }
      )

    result <- dplyr::left_join(result, special_clean, by = "org_code")
  }

  # Add standard columns
  result <- result |>
    dplyr::mutate(
      end_year = end_year,
      type = "District",
      district_id = org_code,
      campus_id = NA_character_,
      campus_name = NA_character_,
      charter_flag = NA_character_,
      region = NA_character_
    ) |>
    dplyr::select(
      end_year, type, district_id, campus_id, district_name, campus_name,
      county, region, charter_flag, row_total,
      dplyr::everything(),
      -org_code
    )

  result
}


#' Process school-level enrollment data
#'
#' @param race_df Raw school race data frame
#' @param end_year School year end
#' @return Processed school data frame
#' @keywords internal
process_school_enr <- function(race_df, end_year) {

  # Standardize column names
  names(race_df) <- standardize_column_names(names(race_df))

  # Filter out rows with invalid school codes (notes, headers, etc.)
  # Valid school codes are 8-digit numeric strings, but exclude 00000000 (State Totals)
  race_df <- race_df |>
    dplyr::filter(grepl("^[0-9]{8}$", school), school != "00000000")

  # Aggregate from grade-level to school-level
  # Handle columns that may or may not exist
  cols <- names(race_df)

  school_agg <- race_df |>
    dplyr::group_by(org_code, district_name, school, school_name, county) |>
    dplyr::summarize(
      row_total = sum(safe_numeric(school_total), na.rm = TRUE),
      black = if ("black" %in% cols) sum(safe_numeric(black), na.rm = TRUE) else NA_real_,
      asian = if ("asian" %in% cols) sum(safe_numeric(asian), na.rm = TRUE) else NA_real_,
      hispanic = if ("hispanic" %in% cols) sum(safe_numeric(hispanic), na.rm = TRUE) else NA_real_,
      multiracial = if ("multiracial" %in% cols) sum(safe_numeric(multiracial), na.rm = TRUE) else NA_real_,
      native_american = if ("native_american" %in% cols) sum(safe_numeric(native_american), na.rm = TRUE) else NA_real_,
      pacific_islander = if ("pacific_islander" %in% cols) sum(safe_numeric(pacific_islander), na.rm = TRUE) else NA_real_,
      white = if ("white" %in% cols) sum(safe_numeric(white), na.rm = TRUE) else NA_real_,
      .groups = "drop"
    )

  # Create grade-level totals for each school
  grade_totals <- race_df |>
    dplyr::mutate(
      grade_std = standardize_grade(grade),
      total = safe_numeric(school_total)
    ) |>
    dplyr::filter(!is.na(grade_std)) |>
    dplyr::group_by(school) |>
    dplyr::summarize(
      grade_pk = sum(total[grade_std == "PK"], na.rm = TRUE),
      grade_k = sum(total[grade_std == "K"], na.rm = TRUE),
      grade_01 = sum(total[grade_std == "01"], na.rm = TRUE),
      grade_02 = sum(total[grade_std == "02"], na.rm = TRUE),
      grade_03 = sum(total[grade_std == "03"], na.rm = TRUE),
      grade_04 = sum(total[grade_std == "04"], na.rm = TRUE),
      grade_05 = sum(total[grade_std == "05"], na.rm = TRUE),
      grade_06 = sum(total[grade_std == "06"], na.rm = TRUE),
      grade_07 = sum(total[grade_std == "07"], na.rm = TRUE),
      grade_08 = sum(total[grade_std == "08"], na.rm = TRUE),
      grade_09 = sum(total[grade_std == "09"], na.rm = TRUE),
      grade_10 = sum(total[grade_std == "10"], na.rm = TRUE),
      grade_11 = sum(total[grade_std == "11"], na.rm = TRUE),
      grade_12 = sum(total[grade_std == "12"], na.rm = TRUE),
      .groups = "drop"
    )

  # Join grade totals
  result <- dplyr::left_join(school_agg, grade_totals, by = "school")

  # Add standard columns
  result <- result |>
    dplyr::mutate(
      end_year = end_year,
      type = "Campus",
      district_id = org_code,
      campus_id = school,
      campus_name = school_name,
      charter_flag = NA_character_,
      region = NA_character_,
      # Special populations not available at school level in this file
      special_ed = NA_integer_,
      lep = NA_integer_,
      econ_disadv = NA_integer_
    ) |>
    dplyr::select(
      end_year, type, district_id, campus_id, district_name, campus_name,
      county, region, charter_flag, row_total,
      dplyr::everything(),
      -org_code, -school, -school_name
    )

  result
}


#' Create state-level aggregate from district data
#'
#' @param district_df Processed district data frame
#' @param end_year School year end
#' @return Single-row data frame with state totals
#' @keywords internal
create_state_aggregate <- function(district_df, end_year) {

  # Columns to sum
  sum_cols <- c(
    "row_total",
    "white", "black", "hispanic", "asian",
    "pacific_islander", "native_american", "multiracial",
    "econ_disadv", "lep", "special_ed",
    "grade_pk", "grade_k",
    "grade_01", "grade_02", "grade_03", "grade_04",
    "grade_05", "grade_06", "grade_07", "grade_08",
    "grade_09", "grade_10", "grade_11", "grade_12"
  )

  # Filter to columns that exist
  sum_cols <- sum_cols[sum_cols %in% names(district_df)]

  # Create state row
  state_row <- data.frame(
    end_year = end_year,
    type = "State",
    district_id = NA_character_,
    campus_id = NA_character_,
    district_name = NA_character_,
    campus_name = NA_character_,
    county = NA_character_,
    region = NA_character_,
    charter_flag = NA_character_,
    stringsAsFactors = FALSE
  )

  # Sum each column
  for (col in sum_cols) {
    state_row[[col]] <- sum(district_df[[col]], na.rm = TRUE)
  }

  state_row
}


#' Standardize column names across different year formats
#'
#' @param col_names Vector of column names
#' @return Vector of standardized column names
#' @keywords internal
standardize_column_names <- function(col_names) {

  # Convert to lowercase and replace spaces/special chars
  col_names <- tolower(col_names)
  col_names <- gsub(" ", "_", col_names)
  col_names <- gsub("-", "_", col_names)
  col_names <- gsub("%", "_pct", col_names)

  # Specific mappings for known column variations
  # Maps old name -> standard name
  col_map <- c(
    # Basic identifiers
    "org_code" = "org_code",
    "district_name" = "district_name",
    "district_total" = "district_total",
    "school_total" = "school_total",
    "school_name" = "school_name",

    # Demographics - race names vary by year
    "african_american" = "black",
    "mult_race,_non_hispanic" = "multiracial",
    "native_hawaiian_pacificislander" = "pacific_islander",
    "nativehawaiianpacificislander" = "pacific_islander",
    "native_hawaiian,_pacific_islander" = "pacific_islander",
    "native_hawaiian_pacific_islander" = "pacific_islander",
    "nativeamerican" = "native_american",
    "native_american" = "native_american",

    # Special populations - 2024 format
    "students_with_disabilities__pct" = "students_with_disabilities_pct",
    "english_learners__pct" = "english_learners_pct",
    "low_income__pct" = "low_income_pct",
    "high_needs__pct" = "high_needs_pct",
    "first_language_not_english__pct" = "first_language_not_english_pct",

    # Special populations - 2017-2020 format (abbreviated)
    "swd_pct" = "students_with_disabilities_pct",
    "ell_pct" = "english_learners_pct",
    "ecodis_pct" = "low_income_pct",
    "hn_pct" = "high_needs_pct",
    "flne_pct" = "first_language_not_english_pct",

    # Enrollment totals
    "ajusted_total_enrol" = "adjusted_total_enrol",
    "ajusted_total_enrollment" = "adjusted_total_enrol",
    "total_enrollment" = "total_enrol"
  )

  # Apply mappings
  for (i in seq_along(col_names)) {
    if (col_names[i] %in% names(col_map)) {
      col_names[i] <- col_map[col_names[i]]
    }
  }

  col_names
}


#' Standardize grade level strings
#'
#' @param grade Vector of grade strings
#' @return Vector of standardized grade codes
#' @keywords internal
standardize_grade <- function(grade) {

  grade <- toupper(trimws(grade))

  grade_map <- c(
    "PK" = "PK",
    "K" = "K",
    "GR.1" = "01", "GR.2" = "02", "GR.3" = "03", "GR.4" = "04",
    "GR.5" = "05", "GR.6" = "06", "GR.7" = "07", "GR.8" = "08",
    "GR.9" = "09", "GR.10" = "10", "GR.11" = "11", "GR.12" = "12",
    "SPED_BEYOND_GRADE_12" = "SPED_BEYOND"
  )

  result <- grade_map[grade]

  # For any unmatched, return NA
  result[is.na(result)] <- NA_character_

  as.character(result)
}


#' Extract count from percentage and total
#'
#' @param pct_str Percentage string (e.g., "15.2%")
#' @param total Total enrollment number
#' @return Estimated count as integer
#' @keywords internal
extract_pct_to_count <- function(pct_str, total) {

  # Clean percentage string
  pct <- gsub("%", "", pct_str)
  pct <- safe_numeric(pct)

  # Calculate count
  count <- round(pct / 100 * total)

  as.integer(count)
}
