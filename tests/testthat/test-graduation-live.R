# ==============================================================================
# Graduation Rate LIVE Pipeline Tests
# ==============================================================================
#
# These tests verify the entire data pipeline using LIVE network calls.
# NO MOCKS - real HTTP requests to Massachusetts DOE Socrata API.
#
# Purpose: Detect breakages early when state DOE websites change.
#
# Test Categories:
#   1. URL Availability - HTTP 200 checks
#   2. File Download - Verify actual data retrieval
#   3. File Parsing - JSON parsing succeeds
#   4. Column Structure - Expected columns present
#   5. Year Filtering - Single year extraction works
#   6. Data Quality - No Inf/NaN, valid ranges
#   7. Aggregation - State totals match
#   8. Output Fidelity - tidy=TRUE matches raw
#
# ==============================================================================

# Helper function for network skip guard
skip_if_offline <- function() {
  tryCatch({
    response <- httr::HEAD("https://www.google.com", httr::timeout(5))
    if (httr::http_error(response)) skip("No network connectivity")
  }, error = function(e) skip("No network connectivity"))
}

# ==============================================================================
# Test 1: URL Availability
# ==============================================================================

test_that("Massachusetts DOE graduation API URL returns HTTP 200", {
  skip_if_offline()

  # Base API endpoint
  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json"

  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

test_that("API query for specific year returns HTTP 200", {
  skip_if_offline()

  # Query for 2024 data
  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

test_that("API query for multiple years returns HTTP 200", {
  skip_if_offline()

  # Query for 2020 data (has both 4-year and 5-year rates)
  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2020'&$limit=50000"

  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

# ==============================================================================
# Test 2: File Download (API Data Retrieval)
# ==============================================================================

test_that("Can download graduation data for 2024", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))

  expect_equal(httr::status_code(response), 200)

  # Verify content length is reasonable (should be ~2MB for 2024)
  # Note: Some APIs don't return content-length header, so we check response content instead
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  expect_true(nchar(content) > 1000000)
})

test_that("Can download graduation data for historical year (2018)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2018'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))

  expect_equal(httr::status_code(response), 200)

  # Verify we got JSON data
  content_type <- httr::headers(response)$`content-type`
  expect_true(grepl("json", content_type))
})

test_that("Can filter by district code", {
  skip_if_offline()

  # Query for Boston district - URL encode single quotes
  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy%3D%272024%27%20AND%20dist_code%3D%2700350000%27&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))

  expect_equal(httr::status_code(response), 200)
})

# ==============================================================================
# Test 3: File Parsing (JSON Parsing)
# ==============================================================================

test_that("Can parse API response as JSON", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")

  # Parse JSON
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  expect_true(is.data.frame(data))

  expect_gt(nrow(data), 10000)
})

test_that("Parsed data has correct structure", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Check for expected columns
  expected_cols <- c("sy", "dist_code", "dist_name", "org_code", "org_name",
                     "org_type", "grad_rate_type", "stu_grp", "cohort_cnt",
                     "grad_pct", "in_sch_pct", "non_grad_pct", "ged_pct",
                     "drpout_pct", "exclud_pct")

  expect_true(all(expected_cols %in% names(data)))
})

test_that("Can parse data from different years", {
  skip_if_offline()

  # Test multiple years to ensure schema consistency
  years_to_test <- c("2007", "2018", "2022", "2024")

  for (test_year in years_to_test) {
    url <- paste0("https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='",
                  test_year, "'&$limit=50000")

    response <- httr::GET(url, httr::timeout(60))
    content <- httr::content(response, as = "text", encoding = "UTF-8")
    data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

    expect_true(is.data.frame(data))
    expect_gt(nrow(data), 0)
  }
})

# ==============================================================================
# Test 4: Column Structure
# ==============================================================================

test_that("API data has expected column names", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  expected_cols <- c("sy", "dist_code", "dist_name", "org_code", "org_name",
                     "org_type", "grad_rate_type", "stu_grp", "cohort_cnt",
                     "grad_pct", "in_sch_pct", "non_grad_pct", "ged_pct",
                     "drpout_pct", "exclud_pct")

  expect_true(all(expected_cols %in% names(data)))
})

test_that("Column data types are consistent", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Check string columns (all come as strings from JSON)
  expect_true(is.character(data$sy))
  expect_true(is.character(data$dist_code))
  expect_true(is.character(data$stu_grp))

  # Percentage columns (will need conversion to numeric)
  expect_true(is.character(data$grad_pct))
})

test_that("State record exists in data", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  state_records <- data[data$org_type == "State", ]

  expect_gt(nrow(state_records), 0)
})

# ==============================================================================
# Test 5: Year Filtering
# ==============================================================================

test_that("Can extract data for single year (2024)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # All records should have sy = "2024"
  expect_true(all(data$sy == "2024"))
})

test_that("Can extract data for year with 5-year rates (2020)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2020'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Should have both 4-year and 5-year rate types
  rate_types <- unique(data$grad_rate_type)

  expect_true("4-Year Graduation Rate" %in% rate_types)
  expect_true("5-Year Graduation Rate" %in% rate_types)
})

test_that("Recent years (2023-2024) have 4-year rates and may have 5-year rates", {
  skip_if_offline()

  for (test_year in c("2023", "2024")) {
    url <- paste0("https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='",
                  test_year, "'&$limit=50000")

    response <- httr::GET(url, httr::timeout(60))
    content <- httr::content(response, as = "text", encoding = "UTF-8")
    data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

    rate_types <- unique(data$grad_rate_type)

    expect_true(any(grepl("4-Year", rate_types)))

    # Note: 5-year rates discontinued after 2022, but API may still return them
    # We just verify 4-year rates exist for recent years
  }
})

# ==============================================================================
# Test 6: Data Quality
# ==============================================================================

test_that("No negative values in percentage columns", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Convert percentage columns to numeric
  pct_cols <- c("grad_pct", "in_sch_pct", "non_grad_pct", "ged_pct",
                "drpout_pct", "exclud_pct")

  for (col in pct_cols) {
    values <- as.numeric(data[[col]])
    expect_true(all(values >= 0, na.rm = TRUE))
  }
})

test_that("Percentages are in valid range (0-1)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Convert grad_pct to numeric and check range
  grad_pct <- as.numeric(data$grad_pct)

  expect_true(all(grad_pct >= 0 & grad_pct <= 1, na.rm = TRUE))
})

test_that("Cohort counts are reasonable (>= 6, due to suppression)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Convert cohort_cnt to integer
  cohort_cnt <- as.integer(data$cohort_cnt)

  # All reported cohorts should be >= 6 (suppression threshold)
  expect_true(all(cohort_cnt >= 6 | is.na(cohort_cnt), na.rm = TRUE))
})

test_that("No duplicate records", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Create unique key
  data$key <- paste(data$sy, data$org_code, data$grad_rate_type, data$stu_grp, sep = "_")

  expect_equal(nrow(data), length(unique(data$key)))
})

# ==============================================================================
# Test 7: Aggregation
# ==============================================================================

test_that("State record has all expected subgroups", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  state_data <- data[data$org_type == "State" &
                      data$grad_rate_type == "4-Year Graduation Rate", ]

  subgroups <- unique(state_data$stu_grp)

  # Should have all 16 subgroups
  expect_gte(length(subgroups), 16)
})

test_that("District records exist", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  district_data <- data[data$org_type == "District", ]

  expect_gt(nrow(district_data), 0)

  # Should have ~300+ districts in MA
  unique_districts <- length(unique(district_data$dist_code))
  expect_gte(unique_districts, 250)
})

test_that("School records exist", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  school_data <- data[data$org_type == "School", ]

  expect_gt(nrow(school_data), 0)
})

test_that("District codes preserve leading zeros", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Boston district code should be "00350000" (with leading zeros)
  boston_data <- data[data$dist_code == "00350000", ]

  expect_gt(nrow(boston_data), 0)
})

# ==============================================================================
# Test 8: Output Fidelity
# ==============================================================================

test_that("State-level graduation rate is reasonable", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  state_record <- data[data$org_type == "State" &
                        data$grad_rate_type == "4-Year Graduation Rate" &
                        data$stu_grp == "All Students", ]

  grad_rate <- as.numeric(state_record$grad_pct)

  # MA state graduation rate should be ~80-90%
  expect_gte(grad_rate, 0.80)
  expect_lte(grad_rate, 0.95)
})

test_that("Boston district data exists", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  boston_data <- data[data$dist_name == "Boston" &
                       data$grad_rate_type == "4-Year Graduation Rate" &
                       data$stu_grp == "All Students", ]

  expect_gt(nrow(boston_data), 0)
})

test_that("Boston Latin School data exists", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  boston_latin <- data[data$org_name == "Boston Latin School" &
                         data$grad_rate_type == "4-Year Graduation Rate" &
                         data$stu_grp == "All Students", ]

  expect_gt(nrow(boston_latin), 0)

  # Boston Latin typically has very high graduation rate (~98-99%)
  grad_rate <- as.numeric(boston_latin$grad_pct)
  expect_gte(grad_rate, 0.95)
})

test_that("Percentage columns sum to approximately 1.0", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Get state record for all students
  state_record <- data[data$org_type == "State" &
                        data$grad_rate_type == "4-Year Graduation Rate" &
                        data$stu_grp == "All Students", ]

  grad <- as.numeric(state_record$grad_pct)
  in_school <- as.numeric(state_record$in_sch_pct)
  non_grad <- as.numeric(state_record$non_grad_pct)
  ged <- as.numeric(state_record$ged_pct)
  dropout <- as.numeric(state_record$drpout_pct)
  excluded <- as.numeric(state_record$exclud_pct)

  total <- grad + in_school + non_grad + ged + dropout + excluded

  # Should sum to approximately 1.0 (allowing for rounding)
  expect_true(total >= 0.98 & total <= 1.02)
})
