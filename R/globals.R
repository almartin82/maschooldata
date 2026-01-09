# ==============================================================================
# Global Variable Declarations for NSE
# ==============================================================================
#
# This file declares global variables used in non-standard evaluation (NSE)
# with dplyr to prevent R CMD CHECK notes about undefined variables.
#
# ==============================================================================

if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    # Column names used in tidy_enrollment.R
    "subgroup", "grade_level", "n_students",
    "type", "charter_flag",
    "org_code", "district_name", "county", "district_total",
    "black", "asian", "hispanic", "multiracial",
    "native_american", "pacific_islander", "white",
    "grade", "grade_std", "total",
    "district_id", "campus_id", "campus_name", "region",
    "row_total", "school", "school_name", "school_total"
  ))
}
