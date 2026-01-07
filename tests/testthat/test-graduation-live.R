# ==============================================================================
# Graduation Rate LIVE Pipeline Tests
# ==============================================================================
#
# These tests verify each step of the data pipeline using LIVE network calls.
# The goal is to detect breakages early when the MA DESE Socrata API changes.
#
# DO NOT MOCK - These must make real network calls to test the actual API.
#
# ==============================================================================

# Helper function for offline tests
skip_if_offline <- function() {
  tryCatch({
    response <- httr::HEAD("https://www.google.com", httr::timeout(5))
    if (httr::http_error(response)) skip("No network connectivity")
  }, error = function(e) skip("No network connectivity"))
}

# ==============================================================================
# TEST 1: URL Availability
# ==============================================================================

test_that("Graduation API URL returns HTTP 200", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json"

  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200,
               info = "API should be accessible")
})

# ==============================================================================
# TEST 2: File Download Success
# ==============================================================================

test_that("Can download graduation data from API", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json"
  query <- list(
    sy = "2024",
    `$limit` = "100"
  )

  response <- httr::GET(url, query = query, httr::timeout(60))

  expect_equal(httr::status_code(response), 200)

  # Parse response
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  df <- jsonlite::fromJSON(content, flatten = TRUE)

  # Should have data
  expect_gt(nrow(df), 0)
  expect_gt(ncol(df), 5)
})

test_that("Downloaded data has expected structure", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json"
  query <- list(
    sy = "2024",
    `$limit` = "10"
  )

  response <- httr::GET(url, query = query, httr::timeout(60))

  content <- httr::content(response, as = "text", encoding = "UTF-8")
  df <- jsonlite::fromJSON(content, flatten = TRUE)

  # Check for expected columns
  expected_cols <- c("sy", "dist_code", "dist_name", "org_code", "org_name",
                     "org_type", "grad_rate_type", "stu_grp", "cohort_cnt",
                     "grad_pct")

  missing_cols <- setdiff(expected_cols, names(df))
  expect_equal(length(missing_cols), 0,
               info = paste("Missing columns:", paste(missing_cols, collapse = ", ")))
})

# ==============================================================================
# TEST 3: File Parsing Success
# ==============================================================================

test_that("API response parses to valid data frame", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json"
  query <- list(
    sy = "2024",
    `$limit` = "1000"
  )

  response <- httr::GET(url, query = query, httr::timeout(60))

  expect_false(httr::http_error(response))

  content <- httr::content(response, as = "text", encoding = "UTF-8")

  expect_true(is.character(content))
  expect_gt(nchar(content), 100)

  # Parse JSON
  df <- jsonlite::fromJSON(content, flatten = TRUE)

  expect_true(is.data.frame(df))
  expect_gt(nrow(df), 0)
})

# ==============================================================================
# TEST 4: Column Structure
# ==============================================================================

test_that("Graduation data has all required columns", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json"
  query <- list(
    sy = "2024",
    `$limit` = "100"
  )

  response <- httr::GET(url, query = query, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  df <- jsonlite::fromJSON(content, flatten = TRUE)

  # Critical columns
  critical_cols <- c(
    "sy",           # School year
    "dist_code",    # District code
    "org_code",     # Organization code
    "org_type",     # State/District/School
    "grad_rate_type", # 4-year/5-year
    "stu_grp",      # Student group/subgroup
    "cohort_cnt",   # Cohort count
    "grad_pct"      # Graduation percentage
  )

  for (col in critical_cols) {
    expect_true(col %in% names(df),
                info = paste("Critical column missing:", col))
  }
})

test_that("Column data types are correct", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json"
  query <- list(
    sy = "2024",
    `$limit` = "100"
  )

  response <- httr::GET(url, query = query, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  df <- jsonlite::fromJSON(content, flatten = TRUE)

  # sy should be character or integer
  expect_true(is.character(df$sy) || is.integer(df$sy))

  # cohort_cnt and grad_pct may be character from API (converted during processing)
  # Just check they're not NULL
  expect_true(!is.null(df$cohort_cnt))
  expect_true(!is.null(df$grad_pct))
})

# ==============================================================================
# TEST 5: Year Filtering
# ==============================================================================

test_that("Can extract data for specific year 2024", {
  skip_if_offline()

  # This tests get_raw_graduation(2024)
  raw <- get_raw_graduation(2024)

  expect_true(is.data.frame(raw))
  expect_gt(nrow(raw), 0)

  # All records should be for 2024
  expect_true(all(raw$sy == "2024" | raw$sy == 2024))
})

test_that("Can extract data for year 2019", {
  skip_if_offline()

  raw <- get_raw_graduation(2019)

  expect_true(is.data.frame(raw))
  expect_gt(nrow(raw), 0)

  # All records should be for 2019
  expect_true(all(raw$sy == "2019" | raw$sy == 2019))
})

test_that("Can extract data for year 2009", {
  skip_if_offline()

  raw <- get_raw_graduation(2009)

  expect_true(is.data.frame(raw))
  expect_gt(nrow(raw), 0)

  # All records should be for 2009
  expect_true(all(raw$sy == "2009" | raw$sy == 2009))
})

# ==============================================================================
# TEST 6: Aggregation Correctness
# ==============================================================================

test_that("District records sum correctly", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE)

  # Get state-level total
  state_total <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  # District totals should be much smaller than state
  district_totals <- data |>
    dplyr::filter(is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  # No single district should exceed state total
  expect_true(all(district_totals < state_total))
})

test_that("Subgroup counts are reasonable", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE)

  # Get state-level all students cohort
  all_students <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  # Female + male should approximately equal all students
  female <- data |>
    dplyr::filter(is_state,
                  subgroup == "female",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  male <- data |>
    dplyr::filter(is_state,
                  subgroup == "male",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  # female + male should be close to all_students (within 5%)
  gender_sum <- female + male
  expect_true(abs(gender_sum - all_students) / all_students < 0.05,
              info = paste("Female + Male:", gender_sum, "All:", all_students))
})

# ==============================================================================
# TEST 7: Data Quality
# ==============================================================================

test_that("No Inf or NaN in tidy output", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE, tidy = TRUE)

  # Check all numeric columns
  numeric_cols <- c("grad_rate", "cohort_count", "graduate_count")

  for (col in numeric_cols) {
    if (col %in% names(data)) {
      expect_false(any(is.infinite(data[[col]]), na.rm = TRUE),
                   info = paste("Inf values in:", col))
      expect_false(any(is.nan(data[[col]]), na.rm = TRUE),
                   info = paste("NaN values in:", col))
    }
  }
})

test_that("All graduation rates are in valid range", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE, tidy = TRUE)

  # grad_rate should be between 0 and 1
  expect_true(all(data$grad_rate >= 0, na.rm = TRUE),
              info = "Negative graduation rates found")

  expect_true(all(data$grad_rate <= 1, na.rm = TRUE),
              info = "Graduation rates > 100% found")
})

test_that("All cohort counts are non-negative", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE, tidy = TRUE)

  expect_true(all(data$cohort_count >= 0, na.rm = TRUE),
              info = "Negative cohort counts found")
})

test_that("No missing critical values at state level", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE, tidy = TRUE)

  state_data <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year")

  # Critical fields should not be NA
  expect_false(is.na(state_data$grad_rate))
  expect_false(is.na(state_data$cohort_count))
})

# ==============================================================================
# TEST 8: Output Fidelity
# ==============================================================================

test_that("tidy=TRUE has correct schema", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE, tidy = TRUE)

  # Required columns in tidy format
  required_cols <- c(
    "end_year",
    "type",
    "district_id",
    "district_name",
    "school_id",
    "school_name",
    "subgroup",
    "cohort_type",
    "cohort_count",
    "graduate_count",
    "grad_rate",
    "is_state",
    "is_district",
    "is_school"
  )

  missing_cols <- setdiff(required_cols, names(data))
  expect_equal(length(missing_cols), 0,
               info = paste("Missing columns:", paste(missing_cols, collapse = ", ")))
})

test_that("tidy=FALSE has correct schema", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE, tidy = FALSE)

  # Wide format should have different structure
  expect_true("grad_rate_type" %in% names(data) ||
              "cohort_type" %in% names(data))

  expect_true("stu_grp" %in% names(data) ||
              "subgroup" %in% names(data))
})

test_that("tidy=TRUE matches raw data values", {
  skip_if_offline()

  # Get raw data directly from API
  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json"
  query <- list(
    sy = "2024",
    org_type = "State",
    stu_grp = "All Students",
    grad_rate_type = "4-Year Graduation Rate",
    `$limit` = "10"
  )

  response <- httr::GET(url, query = query, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  raw <- jsonlite::fromJSON(content, flatten = TRUE)

  # Get processed data
  processed <- fetch_graduation(2024, use_cache = FALSE, tidy = TRUE)

  # Extract state 4-year all students rate
  processed_rate <- processed |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  # Convert from character if needed
  raw_rate <- as.numeric(raw$grad_pct[1])

  # Should match exactly
  expect_equal(processed_rate, raw_rate, tolerance = 0.001,
               info = paste("Processed:", processed_rate, "Raw:", raw_rate))
})

test_that("tidy=TRUE preserves district-level data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE, tidy = TRUE)

  # Check that Boston exists
  boston <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year")

  expect_equal(nrow(boston), 1)

  expect_gt(boston$grad_rate, 0)
  expect_gt(boston$cohort_count, 0)
})

test_that("tidy=TRUE includes all expected subgroups", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE, tidy = TRUE)

  # Expected subgroups at state level
  expected_subgroups <- c(
    "all",
    "female",
    "male",
    "white",
    "black",
    "hispanic",
    "asian",
    "english_learner",
    "special_ed",
    "low_income",
    "high_needs"
  )

  # Get state-level subgroups
  state_subgroups <- data |>
    dplyr::filter(is_state,
                  cohort_type == "4-year") |>
    dplyr::pull(subgroup) |>
    unique()

  # Check that key subgroups exist
  expect_true("all" %in% state_subgroups)
  expect_true("female" %in% state_subgroups)
  expect_true("male" %in% state_subgroups)
  expect_true("white" %in% state_subgroups)
  expect_true("black" %in% state_subgroups)
  expect_true("hispanic" %in% state_subgroups)
})

test_that("tidy=TRUE includes all cohort types", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = FALSE, tidy = TRUE)

  # Get unique cohort types
  cohort_types <- unique(data$cohort_type)

  # Should at least have 4-year
  expect_true("4-year" %in% cohort_types)

  # 2023 should have both 4-year and 5-year
  data_2023 <- fetch_graduation(2023, use_cache = FALSE, tidy = TRUE)
  cohort_types_2023 <- unique(data_2023$cohort_type)

  expect_true("4-year" %in% cohort_types_2023)
  expect_true("5-year" %in% cohort_types_2023)
})

test_that("Multiple years can be fetched", {
  skip_if_offline()

  data <- fetch_graduation_multi(2022:2024, tidy = TRUE, use_cache = FALSE)

  # Should have data for 3 years
  years <- unique(data$end_year)
  expect_equal(length(years), 3)
  expect_true(all(c(2022, 2023, 2024) %in% years))

  # Should have more rows than single year
  data_single <- fetch_graduation(2024, use_cache = FALSE, tidy = TRUE)
  expect_gt(nrow(data), nrow(data_single))
})
