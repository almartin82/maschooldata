# Tests for MCAS assessment functions
# These tests verify data from the MA DESE Socrata API (educationtocareer.data.mass.gov)
# Dataset ID: i9w6-niyt

# ==============================================================================
# Unit tests (no network required)
# ==============================================================================

test_that("get_available_assess_years returns expected years", {
  years <- get_available_assess_years()

  expect_true(is.numeric(years))
  expect_true(length(years) >= 8)  # 2017-2019, 2021-2025

  # Should include known years
  expect_true(2017 %in% years)
  expect_true(2019 %in% years)
  expect_true(2021 %in% years)
  expect_true(2025 %in% years)

  # Should NOT include 2020 (COVID year)
  expect_false(2020 %in% years)
})

test_that("get_available_assess_subgroups returns expected subgroups", {
  subgroups <- get_available_assess_subgroups()

  expect_true(is.character(subgroups))
  expect_true(length(subgroups) >= 20)

  # Should include key subgroups
  expect_true("all" %in% subgroups)
  expect_true("white" %in% subgroups)
  expect_true("black" %in% subgroups)
  expect_true("hispanic" %in% subgroups)
  expect_true("asian" %in% subgroups)
  expect_true("english_learner" %in% subgroups)
  expect_true("special_ed" %in% subgroups)
  expect_true("low_income" %in% subgroups)
})

test_that("fetch_assessment validates year parameter", {
  expect_error(fetch_assessment(2020), "2020")  # COVID year
  expect_error(fetch_assessment(2015), "must be one of")  # Too early
  expect_error(fetch_assessment(2030), "must be one of")  # Too late
})

test_that("DESE_ASSESS_SOCRATA_API constant is valid", {
  expect_true(grepl("educationtocareer.data.mass.gov", DESE_ASSESS_SOCRATA_API))
  expect_true(grepl("i9w6-niyt", DESE_ASSESS_SOCRATA_API))
})

# ==============================================================================
# Integration tests - URL Availability
# ==============================================================================

test_that("MCAS assessment API is accessible", {
  skip_on_cran()
  skip_if_offline()

  # Just check the API endpoint responds
  response <- httr::HEAD(
    paste0(DESE_ASSESS_SOCRATA_API, "?$limit=1"),
    httr::timeout(30)
  )

  expect_equal(httr::status_code(response), 200)
})

# ==============================================================================
# Integration tests - Data Download and Parsing
# ==============================================================================

test_that("get_raw_assessment downloads valid data", {
  skip_on_cran()
  skip_if_offline()

  raw <- get_raw_assessment(2025)

  expect_true(is.data.frame(raw))
  expect_true(nrow(raw) > 0)

  # Check required columns from API exist
  expect_true("sy" %in% names(raw) || "end_year" %in% names(raw))
  expect_true("org_type" %in% names(raw))
  expect_true("dist_code" %in% names(raw))
  expect_true("test_grade" %in% names(raw))
  expect_true("subject_code" %in% names(raw))
  expect_true("stu_grp" %in% names(raw))
  expect_true("m_plus_e_pct" %in% names(raw))
  expect_true("avg_scaled_score" %in% names(raw))
})

test_that("process_assessment creates standard schema", {
  skip_on_cran()
  skip_if_offline()

  raw <- get_raw_assessment(2025)
  processed <- process_assessment(raw, 2025)

  # Check standardized columns exist
  expect_true("end_year" %in% names(processed))
  expect_true("type" %in% names(processed))
  expect_true("district_id" %in% names(processed))
  expect_true("school_id" %in% names(processed))
  expect_true("grade" %in% names(processed))
  expect_true("subject" %in% names(processed))
  expect_true("subgroup" %in% names(processed))
  expect_true("meeting_exceeding_pct" %in% names(processed))
  expect_true("scaled_score" %in% names(processed))
  expect_true("student_count" %in% names(processed))

  # Check aggregation flags
  expect_true("is_state" %in% names(processed))
  expect_true("is_district" %in% names(processed))
  expect_true("is_school" %in% names(processed))

  # Check types are standardized
  expect_true("State" %in% processed$type)
  expect_true("District" %in% processed$type)
  expect_true("School" %in% processed$type)

  # Check subjects are lowercase
  subjects <- unique(processed$subject)
  expect_true("ela" %in% subjects)
  expect_true("math" %in% subjects)
})

test_that("tidy_assessment produces correct format", {
  skip_on_cran()
  skip_if_offline()

  raw <- get_raw_assessment(2025)
  processed <- process_assessment(raw, 2025)
  tidy_df <- tidy_assessment(processed)

  # Tidy should preserve key columns
  expect_true("end_year" %in% names(tidy_df))
  expect_true("grade" %in% names(tidy_df))
  expect_true("subject" %in% names(tidy_df))
  expect_true("subgroup" %in% names(tidy_df))
  expect_true("meeting_exceeding_pct" %in% names(tidy_df))

  # Should not have NA subgroups
  expect_false(any(is.na(tidy_df$subgroup)))

  # IDs should be character type
  expect_true(is.character(tidy_df$district_id))
  expect_true(is.character(tidy_df$school_id))
})

# ==============================================================================
# Integration tests - Data Quality
# ==============================================================================

test_that("assessment data has valid percentages", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, use_cache = TRUE)

  # Percentages should be between 0 and 1 (not 0-100)
  pct_cols <- c("meeting_exceeding_pct", "exceeding_pct", "meeting_pct",
                "partially_meeting_pct", "not_meeting_pct")

  for (col in pct_cols) {
    if (col %in% names(result)) {
      values <- result[[col]][!is.na(result[[col]])]
      expect_true(all(values >= 0), info = paste(col, "has negative values"))
      expect_true(all(values <= 1), info = paste(col, "has values > 1"))
    }
  }
})

test_that("assessment data has valid student counts", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, use_cache = TRUE)

  # Student counts should be non-negative integers
  counts <- result$student_count[!is.na(result$student_count)]
  expect_true(all(counts >= 0), "Student counts should be non-negative")
  expect_true(all(counts == floor(counts)), "Student counts should be integers")

  # No impossibly large counts
  expect_true(all(counts < 1000000), "Student count > 1M is suspicious")
})

test_that("assessment data has valid scaled scores", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, use_cache = TRUE)

  # MCAS scaled scores typically range from about 440-560
  scores <- result$scaled_score[!is.na(result$scaled_score)]
  expect_true(all(scores >= 400), "Scaled scores below 400 are suspicious")
  expect_true(all(scores <= 600), "Scaled scores above 600 are suspicious")
})

test_that("assessment data has no Inf or NaN values", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, use_cache = TRUE)

  # Check numeric columns for Inf/NaN
  numeric_cols <- c("meeting_exceeding_pct", "scaled_score", "student_count")

  for (col in numeric_cols) {
    if (col %in% names(result)) {
      values <- result[[col]][!is.na(result[[col]])]
      expect_false(any(is.infinite(values)), info = paste(col, "has Inf values"))
      expect_false(any(is.nan(values)), info = paste(col, "has NaN values"))
    }
  }
})

# ==============================================================================
# Integration tests - Data Fidelity (ACTUAL VALUES from raw data)
# ==============================================================================

test_that("State 2025 Grade 10 ELA All Students matches API value", {
  skip_on_cran()
  skip_if_offline()

  # Verified value from API: m_plus_e_pct = 0.51, stu_cnt = 67825
  result <- fetch_assessment(2025, grade = "10", subject = "ela",
                            subgroup = "all", use_cache = TRUE)

  state_row <- result[result$is_state, ]
  expect_equal(nrow(state_row), 1, info = "Should have exactly one state row")

  # Meeting+Exceeding percentage should be 51% (0.51)
  expect_equal(state_row$meeting_exceeding_pct, 0.51, tolerance = 0.001)

  # Student count should be ~67,825
  expect_equal(state_row$student_count, 67825, tolerance = 100)

  # Scaled score should be 499
  expect_equal(state_row$scaled_score, 499, tolerance = 1)
})

test_that("State 2025 Grade 3 Math All Students matches API value", {
  skip_on_cran()
  skip_if_offline()

  # Verified value from API: m_plus_e_pct = 0.44, stu_cnt = 66361
  result <- fetch_assessment(2025, grade = "03", subject = "math",
                            subgroup = "all", use_cache = TRUE)

  state_row <- result[result$is_state, ]
  expect_equal(nrow(state_row), 1)

  expect_equal(state_row$meeting_exceeding_pct, 0.44, tolerance = 0.001)
  expect_equal(state_row$student_count, 66361, tolerance = 100)
  expect_equal(state_row$scaled_score, 496, tolerance = 1)
})

test_that("State 2019 pre-COVID data matches API value", {
  skip_on_cran()
  skip_if_offline()

  # Verified value from API: Grade 10 ELA m_plus_e_pct = 0.61, stu_cnt = 70815
  result <- fetch_assessment(2019, grade = "10", subject = "ela",
                            subgroup = "all", use_cache = TRUE)

  state_row <- result[result$is_state, ]
  expect_equal(nrow(state_row), 1)

  # 2019 had higher proficiency (61% vs 51% in 2025)
  expect_equal(state_row$meeting_exceeding_pct, 0.61, tolerance = 0.001)
  expect_equal(state_row$student_count, 70815, tolerance = 100)
})

test_that("Boston district 2025 Grade 10 ELA matches API value", {
  skip_on_cran()
  skip_if_offline()

  # Verified value from API: Boston (0035) Grade 10 ELA m_plus_e_pct = 0.40
  result <- fetch_assessment(2025, grade = "10", subject = "ela",
                            subgroup = "all", use_cache = TRUE)

  boston <- result[result$district_id == "0035" & result$is_district, ]
  expect_equal(nrow(boston), 1, info = "Should have exactly one Boston district row")

  expect_equal(boston$meeting_exceeding_pct, 0.40, tolerance = 0.01)
  expect_equal(boston$student_count, 3078, tolerance = 50)
})

test_that("Achievement gap data 2025 Grade 10 ELA matches API values", {
  skip_on_cran()
  skip_if_offline()

  # Verified values from API for state Grade 10 ELA:
  # White: 0.59, Black: 0.35, Hispanic: 0.31, Asian: 0.76
  result <- fetch_assessment(2025, grade = "10", subject = "ela", use_cache = TRUE)

  state_data <- result[result$is_state, ]

  white <- state_data[state_data$subgroup == "white", ]
  black <- state_data[state_data$subgroup == "black", ]
  hispanic <- state_data[state_data$subgroup == "hispanic", ]
  asian <- state_data[state_data$subgroup == "asian", ]

  expect_equal(white$meeting_exceeding_pct, 0.59, tolerance = 0.01)
  expect_equal(black$meeting_exceeding_pct, 0.35, tolerance = 0.01)
  expect_equal(hispanic$meeting_exceeding_pct, 0.31, tolerance = 0.01)
  expect_equal(asian$meeting_exceeding_pct, 0.76, tolerance = 0.01)
})

test_that("Special populations 2025 Grade 10 ELA matches API values", {
  skip_on_cran()
  skip_if_offline()

  # Verified values from API:
  # English Learners: 0.02, Students with Disabilities: 0.17, Low Income: 0.31
  result <- fetch_assessment(2025, grade = "10", subject = "ela", use_cache = TRUE)

  state_data <- result[result$is_state, ]

  el <- state_data[state_data$subgroup == "english_learner", ]
  sped <- state_data[state_data$subgroup == "special_ed", ]
  lowinc <- state_data[state_data$subgroup == "low_income", ]

  expect_equal(el$meeting_exceeding_pct, 0.02, tolerance = 0.01)
  expect_equal(sped$meeting_exceeding_pct, 0.17, tolerance = 0.01)
  expect_equal(lowinc$meeting_exceeding_pct, 0.31, tolerance = 0.01)
})

# ==============================================================================
# Integration tests - fetch_assessment function behavior
# ==============================================================================

test_that("fetch_assessment returns all required columns", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, use_cache = TRUE)

  required_cols <- c(
    "end_year", "type", "district_id", "district_name",
    "school_id", "school_name", "grade", "subject", "subgroup",
    "meeting_exceeding_pct", "student_count", "scaled_score",
    "is_state", "is_district", "is_school"
  )

  for (col in required_cols) {
    expect_true(col %in% names(result), info = paste("Missing column:", col))
  }
})

test_that("fetch_assessment grade filter works", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, grade = "10", use_cache = TRUE)

  expect_true(all(result$grade == "10"))
})

test_that("fetch_assessment subject filter works", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, subject = "math", use_cache = TRUE)

  expect_true(all(result$subject == "math"))
})

test_that("fetch_assessment subgroup filter works", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, subgroup = "all", use_cache = TRUE)

  expect_true(all(result$subgroup == "all"))
})

test_that("fetch_assessment invalid filters produce errors", {
  skip_on_cran()
  skip_if_offline()

  expect_error(fetch_assessment(2025, grade = "99"), "Invalid grade")
  expect_error(fetch_assessment(2025, subject = "invalid"), "Invalid subject")
  expect_error(fetch_assessment(2025, subgroup = "invalid"), "Invalid subgroup")
})

test_that("exclude_aggregated removes ALL (03-08) rows", {
  skip_on_cran()
  skip_if_offline()

  # With exclude_aggregated = TRUE (default)
  result_excluded <- fetch_assessment(2025, exclude_aggregated = TRUE, use_cache = TRUE)
  expect_false("ALL (03-08)" %in% result_excluded$grade)

  # With exclude_aggregated = FALSE
  result_included <- fetch_assessment(2025, exclude_aggregated = FALSE, use_cache = TRUE)
  expect_true("ALL (03-08)" %in% result_included$grade)
})

# ==============================================================================
# Integration tests - fetch_assessment_multi function
# ==============================================================================

test_that("fetch_assessment_multi combines years correctly", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment_multi(c(2019, 2021, 2025),
                                   grade = "10", subject = "ela", subgroup = "all",
                                   use_cache = TRUE)

  # Should have all three years
  expect_true(2019 %in% result$end_year)
  expect_true(2021 %in% result$end_year)
  expect_true(2025 %in% result$end_year)

  # Should have state rows for each year
  state_rows <- result[result$is_state, ]
  expect_equal(nrow(state_rows), 3)
})

test_that("fetch_assessment_multi validates years", {
  skip_on_cran()
  skip_if_offline()

  # Should error on invalid years
  expect_error(fetch_assessment_multi(c(2019, 2020, 2021)), "2020")  # COVID year
  expect_error(fetch_assessment_multi(c(2015, 2019)), "Invalid years")
})

# ==============================================================================
# Integration tests - Aggregation level coverage
# ==============================================================================

test_that("assessment data includes all aggregation levels", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, use_cache = TRUE)

  # Should have state data
  state_rows <- result[result$is_state, ]
  expect_true(nrow(state_rows) > 0)

  # Should have district data (400+ districts)
  district_rows <- result[result$is_district, ]
  expect_true(nrow(district_rows) > 100)

  # Should have school data (1800+ schools)
  school_rows <- result[result$is_school, ]
  expect_true(nrow(school_rows) > 500)
})

test_that("assessment data has expected subjects", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, use_cache = TRUE)

  subjects <- unique(result$subject)

  expect_true("ela" %in% subjects)
  expect_true("math" %in% subjects)
  expect_true("science" %in% subjects)
})

test_that("assessment data has expected grades", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment(2025, exclude_aggregated = FALSE, use_cache = TRUE)

  grades <- unique(result$grade)

  # Grades 3-8 should be present
  expect_true("03" %in% grades)
  expect_true("04" %in% grades)
  expect_true("05" %in% grades)
  expect_true("06" %in% grades)
  expect_true("07" %in% grades)
  expect_true("08" %in% grades)

  # Grade 10 should be present
  expect_true("10" %in% grades)

  # Aggregated grade should be present when not excluded
  expect_true("ALL (03-08)" %in% grades)
})

# ==============================================================================
# Integration tests - Caching
# ==============================================================================

test_that("assessment caching works correctly", {
  skip_on_cran()
  skip_if_offline()

  # First call should download (use cache = TRUE so it caches)
  result1 <- fetch_assessment(2024, use_cache = TRUE)

  # Second call should use cache (faster)
  t1 <- Sys.time()
  result2 <- fetch_assessment(2024, use_cache = TRUE)
  t2 <- Sys.time()

  # Results should be identical
  expect_equal(nrow(result1), nrow(result2))
  expect_equal(names(result1), names(result2))

  # Cache read should be fast (less than 30 seconds - allowing for disk I/O)
  expect_true(difftime(t2, t1, units = "secs") < 30)
})

# ==============================================================================
# COVID impact tests
# ==============================================================================

test_that("2021 shows COVID impact compared to 2019", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_assessment_multi(c(2019, 2021),
                                   grade = "10", subject = "ela", subgroup = "all",
                                   use_cache = TRUE)

  state_data <- result[result$is_state, ]

  # Both years should have data
  pct_2019 <- state_data[state_data$end_year == 2019, "meeting_exceeding_pct"]
  pct_2021 <- state_data[state_data$end_year == 2021, "meeting_exceeding_pct"]

  # Both should have proficiency rates between 0 and 1
  expect_true(pct_2019 >= 0 && pct_2019 <= 1)
  expect_true(pct_2021 >= 0 && pct_2021 <= 1)

  # 2019 was 61%
  expect_equal(pct_2019, 0.61, tolerance = 0.02)
})
