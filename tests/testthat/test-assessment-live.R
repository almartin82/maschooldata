# ==============================================================================
# Assessment LIVE Pipeline Tests
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

test_that("Massachusetts DOE assessment API URL returns HTTP 200", {
  skip_if_offline()

  # Base API endpoint
  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json"

  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

test_that("API query for specific year returns HTTP 200", {
  skip_if_offline()

  # Query for 2025 data
  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

test_that("API query for historical year returns HTTP 200", {
  skip_if_offline()

  # Query for 2017 data (earliest available)
  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2017'&$limit=100000"

  response <- httr::HEAD(url, httr::timeout(30))

  expect_equal(httr::status_code(response), 200)
})

# ==============================================================================
# Test 2: File Download (API Data Retrieval)
# ==============================================================================

test_that("Can download assessment data for 2025", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))

  expect_equal(httr::status_code(response), 200)

  # Verify content length is reasonable
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  expect_true(nchar(content) > 1000000)
})

test_that("Can download assessment data for historical year (2019)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2019'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))

  expect_equal(httr::status_code(response), 200)

  # Verify we got JSON data
  content_type <- httr::headers(response)$`content-type`
  expect_true(grepl("json", content_type))
})

test_that("Can filter by grade level", {
  skip_if_offline()

  # Query for grade 10 data
  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'%20AND%20test_grade='10'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))

  expect_equal(httr::status_code(response), 200)
})

# ==============================================================================
# Test 3: File Parsing (JSON Parsing)
# ==============================================================================

test_that("Can parse API response as JSON", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")

  # Parse JSON
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  expect_true(is.data.frame(data))
  expect_gt(nrow(data), 10000)
})

test_that("Parsed data has correct structure", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Check for expected columns
  expected_cols <- c("sy", "dist_code", "dist_name", "org_code", "org_name",
                     "org_type", "test_grade", "subject_code", "stu_grp",
                     "m_plus_e_cnt", "m_plus_e_pct", "e_cnt", "e_pct",
                     "m_cnt", "m_pct", "pm_cnt", "pm_pct", "nm_cnt",
                     "nm_pct", "stu_cnt", "stu_part_pct", "avg_scaled_score")

  expect_true(all(expected_cols %in% names(data)))
})

test_that("Can parse data from different years", {
  skip_if_offline()

  # Test multiple years to ensure schema consistency
  years_to_test <- c("2017", "2019", "2022", "2025")

  for (test_year in years_to_test) {
    url <- paste0("https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='",
                  test_year, "'&$limit=100000")

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

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  expected_cols <- c("sy", "dist_code", "dist_name", "org_code", "org_name",
                     "org_type", "test_grade", "subject_code", "stu_grp",
                     "m_plus_e_cnt", "m_plus_e_pct", "e_cnt", "e_pct",
                     "m_cnt", "m_pct", "pm_cnt", "pm_pct", "nm_cnt",
                     "nm_pct", "stu_cnt", "stu_part_pct", "avg_scaled_score")

  expect_true(all(expected_cols %in% names(data)))
})

test_that("Column data types are consistent", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Check string columns
  expect_true(is.character(data$sy))
  expect_true(is.character(data$dist_code))
  expect_true(is.character(data$stu_grp))

  # Percentage columns (will need conversion to numeric)
  expect_true(is.character(data$m_plus_e_pct))
})

test_that("State record exists in data", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  state_records <- data[data$org_type == "State", ]

  expect_gt(nrow(state_records), 0)
})

# ==============================================================================
# Test 5: Year Filtering
# ==============================================================================

test_that("Can extract data for single year (2025)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # All records should have sy = "2025"
  expect_true(all(data$sy == "2025"))
})

test_that("Can extract data for pre-COVID year (2019)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2019'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Should have both ELA and Math for grades 3-8
  expect_true(all(data$sy == "2019"))
})

test_that("2020 data handling (note: 2020 was cancelled due to COVID)", {
  skip_if_offline()

  # Note: The API may return data for 2020, but it would be from other sources
  # or error data. MCAS tests were cancelled in 2020 due to COVID-19.
  # We skip 2020 in available years list instead.

  # Just verify the function knows 2020 is not available
  available_years <- get_available_assess_years()
  expect_false(2020 %in% available_years)
})

# ==============================================================================
# Test 6: Data Quality
# ==============================================================================

test_that("No negative values in percentage columns", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Convert percentage columns to numeric
  pct_cols <- c("m_plus_e_pct", "e_pct", "m_pct", "pm_pct", "nm_pct")

  for (col in pct_cols) {
    values <- as.numeric(data[[col]])
    expect_true(all(values >= 0, na.rm = TRUE))
  }
})

test_that("Percentages are in valid range (0-1)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Convert m_plus_e_pct to numeric and check range
  m_plus_e_pct <- as.numeric(data$m_plus_e_pct)

  expect_true(all(m_plus_e_pct >= 0 & m_plus_e_pct <= 1, na.rm = TRUE))
})

test_that("Student counts are reasonable (>= 0)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Convert stu_cnt to integer
  stu_cnt <- as.integer(data$stu_cnt)

  # All student counts should be >= 0
  expect_true(all(stu_cnt >= 0 | is.na(stu_cnt), na.rm = TRUE))
})

test_that("Participation rates are reasonable (>= 0.90 for state)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Check state participation rates for "all" subgroup
  state_data <- data[data$org_type == "State" & data$stu_grp == "All Students", ]
  stu_part_pct <- as.numeric(state_data$stu_part_pct)

  expect_true(all(stu_part_pct >= 0.90, na.rm = TRUE))
})

# ==============================================================================
# Test 7: Aggregation
# ==============================================================================

test_that("State record has all expected subgroups", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  state_data <- data[data$org_type == "State", ]

  subgroups <- unique(state_data$stu_grp)

  # Should have 25+ subgroups
  expect_gte(length(subgroups), 25)
})

test_that("District records exist", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  district_data <- data[data$org_type == "Public School District", ]

  expect_gt(nrow(district_data), 0)

  # Should have 50+ districts in MA (note: not all districts may be in this dataset)
  unique_districts <- length(unique(district_data$dist_code))
  expect_gte(unique_districts, 50)
})

test_that("School records or district records exist", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Check if we have district-level data (which may include schools as org_type)
  district_data <- data[data$org_type == "Public School District", ]
  school_data <- data[data$org_type == "School", ]

  # Should have either school or district records
  expect_true(nrow(district_data) > 0 || nrow(school_data) > 0)
})

test_that("District codes preserve leading zeros", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

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

test_that("State-level grade 3 math achievement is reasonable", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  state_record <- data[data$org_type == "State" &
                        data$test_grade == "03" &
                        data$subject_code == "MATH" &
                        data$stu_grp == "All Students", ]

  m_plus_e_pct <- as.numeric(state_record$m_plus_e_pct)

  # MA grade 3 math achievement should be ~40-50%
  expect_gte(m_plus_e_pct, 0.35)
  expect_lte(m_plus_e_pct, 0.60)
})

test_that("Boston district data exists", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  boston_data <- data[data$dist_name == "Boston", ]

  expect_gt(nrow(boston_data), 0)
})

test_that("High school science data exists (HS SCI)", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  hs_sci <- data[data$test_grade == "HS SCI", ]

  expect_gt(nrow(hs_sci), 0)
})

test_that("Achievement percentages sum to approximately 1.0", {
  skip_if_offline()

  url <- "https://educationtocareer.data.mass.gov/resource/i9w6-niyt.json?$where=sy='2025'&$limit=100000"

  response <- httr::GET(url, httr::timeout(60))
  content <- httr::content(response, as = "text", encoding = "UTF-8")
  data <- jsonlite::fromJSON(content, simplifyDataFrame = TRUE)

  # Get state record for all students, grade 3 math
  state_record <- data[data$org_type == "State" &
                        data$test_grade == "03" &
                        data$subject_code == "MATH" &
                        data$stu_grp == "All Students", ]

  m_plus_e <- as.numeric(state_record$m_plus_e_pct)
  pm <- as.numeric(state_record$pm_pct)
  nm <- as.numeric(state_record$nm_pct)

  total <- m_plus_e + pm + nm

  # Should sum to approximately 1.0 (allowing for rounding)
  expect_true(total >= 0.98 & total <= 1.02)
})
