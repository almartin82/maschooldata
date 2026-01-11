# ==============================================================================
# Assessment Data Processing Functions
# ==============================================================================
#
# This file contains functions for processing raw assessment data from the
# Socrata API into a standardized schema.
#
# ==============================================================================

#' Process raw assessment data into standard schema
#'
#' Transforms raw Socrata API data into the standardized schema used by
#' the package.
#'
#' @param raw_data Data frame from get_raw_assessment()
#' @param end_year School year end
#' @return Processed data frame with standardized columns
#' @keywords internal
process_assessment <- function(raw_data, end_year) {

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
  test_grade <- safe_col(raw_data, "test_grade")
  subject_code <- safe_col(raw_data, "subject_code")
  stu_grp <- safe_col(raw_data, "stu_grp")

  # Achievement counts
  e_cnt <- safe_num(safe_col(raw_data, "e_cnt"))
  m_cnt <- safe_num(safe_col(raw_data, "m_cnt"))
  pm_cnt <- safe_num(safe_col(raw_data, "pm_cnt"))
  nm_cnt <- safe_num(safe_col(raw_data, "nm_cnt"))
  m_plus_e_cnt <- safe_num(safe_col(raw_data, "m_plus_e_cnt"))
  stu_cnt <- safe_num(safe_col(raw_data, "stu_cnt"))

  # Achievement percentages
  e_pct <- safe_num(safe_col(raw_data, "e_pct"))
  m_pct <- safe_num(safe_col(raw_data, "m_pct"))
  pm_pct <- safe_num(safe_col(raw_data, "pm_pct"))
  nm_pct <- safe_num(safe_col(raw_data, "nm_pct"))
  m_plus_e_pct <- safe_num(safe_col(raw_data, "m_plus_e_pct"))
  stu_part_pct <- safe_num(safe_col(raw_data, "stu_part_pct"))

  # Score and growth
  avg_scaled_score <- safe_num(safe_col(raw_data, "avg_scaled_score"))
  avg_sgp <- safe_num(safe_col(raw_data, "avg_sgp"))
  avg_sgp_incl <- safe_num(safe_col(raw_data, "avg_sgp_incl"))

  # Build processed data frame
  processed <- data.frame(
    end_year = end_year,

    # Type from org_type
    type = dplyr::case_when(
      org_type == "State" ~ "State",
      org_type == "Public School District" ~ "District",
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

    # Grade and subject
    grade = test_grade,
    subject = subject_code,

    # Subgroup (student group)
    subgroup = stu_grp,

    # Achievement counts (Meeting+Exceeding, Exceeding, Meeting, Partially Meeting, Not Meeting)
    meeting_exceeding_cnt = as.integer(m_plus_e_cnt),
    exceeding_cnt = as.integer(e_cnt),
    meeting_cnt = as.integer(m_cnt),
    partially_meeting_cnt = as.integer(pm_cnt),
    not_meeting_cnt = as.integer(nm_cnt),
    student_count = as.integer(stu_cnt),

    # Achievement percentages (decimal scale 0-1)
    meeting_exceeding_pct = m_plus_e_pct,
    exceeding_pct = e_pct,
    meeting_pct = m_pct,
    partially_meeting_pct = pm_pct,
    not_meeting_pct = nm_pct,

    # Participation rate
    participation_rate = stu_part_pct,

    # Scaled score
    scaled_score = avg_scaled_score,

    # Student Growth Percentile (SGP) - may be missing for some years/grades
    sgp = avg_sgp,
    sgp_n = avg_sgp_incl,

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
    processed$subgroup == "Former English Learners" ~ "former_english_learner",
    processed$subgroup == "English Learners and Former English Learners" ~ "english_learner_and_former",
    processed$subgroup == "Ever English Learners" ~ "ever_english_learner",
    processed$subgroup == "Students with Disabilities" ~ "special_ed",
    processed$subgroup == "Students without Disabilities" ~ "not_special_ed",
    processed$subgroup == "Economically Disadvantaged" ~ "econ_disadv",
    processed$subgroup == "Low Income" ~ "low_income",
    processed$subgroup == "Non-Low Income" ~ "not_low_income",
    processed$subgroup == "High Needs" ~ "high_needs",
    processed$subgroup == "Foster Care" ~ "foster_care",
    processed$subgroup == "Homeless" ~ "homeless",
    processed$subgroup == "Migrant" ~ "migrant",
    processed$subgroup == "Military" ~ "military",
    processed$subgroup == "Title I" ~ "title_i",
    processed$subgroup == "Non-Title I" ~ "not_title_i",
    is.na(processed$subgroup) ~ NA_character_,
    TRUE ~ tolower(gsub(" ", "_", processed$subgroup))
  )

  # Standardize subject names
  processed$subject <- dplyr::case_when(
    processed$subject == "ELA" ~ "ela",
    processed$subject == "MATH" ~ "math",
    processed$subject == "SCI" ~ "science",
    processed$subject == "BIO" ~ "biology",
    processed$subject == "PHY" ~ "physics",
    processed$subject == "CIV" ~ "civics",
    is.na(processed$subject) ~ NA_character_,
    TRUE ~ tolower(processed$subject)
  )

  # Add aggregation level flags
  processed$is_state <- processed$type == "State"
  processed$is_district <- processed$type == "District"
  processed$is_school <- processed$type == "School"

  # Add flag for aggregated grades (e.g., "ALL (03-08)")
  processed$is_aggregated <- processed$grade == "ALL (03-08)"

  processed
}
