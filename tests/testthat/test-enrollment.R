# Tests for enrollment functions
# Note: Most tests are marked as skip_on_cran since they require network access

test_that("safe_numeric handles various inputs", {
  # Normal numbers
  expect_equal(safe_numeric("100"), 100)
  expect_equal(safe_numeric("1,234"), 1234)

  # Suppressed values
  expect_true(is.na(safe_numeric("*")))
  expect_true(is.na(safe_numeric("***")))
  expect_true(is.na(safe_numeric("<5")))
  expect_true(is.na(safe_numeric("<10")))
  expect_true(is.na(safe_numeric("")))

  # Whitespace handling
  expect_equal(safe_numeric("  100  "), 100)
})

test_that("get_available_years returns valid range", {
  years <- get_available_years()
  expect_true(is.numeric(years))
  expect_true(length(years) > 0)
  expect_true(min(years) >= 1994)  # Historical data starts at 1994
  expect_true(max(years) <= 2030)  # Allow for future years
})

test_that("fetch_enr validates year parameter", {
  expect_error(fetch_enr(1990), "end_year must be between")
  expect_error(fetch_enr(2030), "end_year must be between")
})

test_that("DESE_SOCRATA_API constant is valid", {
  # The package now uses the Socrata API
  expect_true(grepl("educationtocareer.data.mass.gov", DESE_SOCRATA_API))
  expect_true(grepl("t8td-gens", DESE_SOCRATA_API))
})

test_that("standardize_grade handles Massachusetts grade formats", {
  expect_equal(standardize_grade("PK"), "PK")
  expect_equal(standardize_grade("K"), "K")
  expect_equal(standardize_grade("Gr.1"), "01")
  expect_equal(standardize_grade("Gr.12"), "12")
  expect_equal(standardize_grade("SPED_Beyond_Grade_12"), "SPED_BEYOND")
})

test_that("get_cache_dir returns valid path", {
  cache_dir <- get_cache_dir()
  expect_true(is.character(cache_dir))
  expect_true(grepl("maschooldata", cache_dir))
})

test_that("cache functions work correctly", {
  # Test cache path generation
  path <- get_cache_path(2024, "tidy")
  expect_true(grepl("enr_tidy_2024.rds", path))

  # Test cache_exists returns FALSE for non-existent cache
  expect_false(cache_exists(9999, "tidy"))
})

# Integration tests (require network access)
test_that("fetch_enr downloads and processes data", {
  skip_on_cran()
  skip_if_offline()

  # Use 2024 as it's the most recent

  result <- fetch_enr(2024, tidy = FALSE, use_cache = FALSE)

  # Check structure
  expect_true(is.data.frame(result))
  expect_true("district_id" %in% names(result))
  expect_true("campus_id" %in% names(result))
  expect_true("row_total" %in% names(result))
  expect_true("type" %in% names(result))

  # Check we have all levels
  expect_true("State" %in% result$type)
  expect_true("District" %in% result$type)
  expect_true("Campus" %in% result$type)

  # Check ID formats (Massachusetts uses 4-digit district, 8-digit school)
  districts <- result[result$type == "District" & !is.na(result$district_id), ]
  expect_true(nrow(districts) > 0)
  expect_true(all(nchar(districts$district_id) == 4))

  campuses <- result[result$type == "Campus" & !is.na(result$campus_id), ]
  expect_true(nrow(campuses) > 0)
  expect_true(all(nchar(campuses$campus_id) == 8))

  # Check demographics exist
  expect_true("white" %in% names(result))
  expect_true("black" %in% names(result))
  expect_true("hispanic" %in% names(result))
  expect_true("asian" %in% names(result))
})

test_that("tidy_enr produces correct long format", {
  skip_on_cran()
  skip_if_offline()

  # Get wide data
  wide <- fetch_enr(2024, tidy = FALSE, use_cache = TRUE)

  # Tidy it
  tidy_result <- tidy_enr(wide)

  # Check structure
  expect_true("grade_level" %in% names(tidy_result))
  expect_true("subgroup" %in% names(tidy_result))
  expect_true("n_students" %in% names(tidy_result))
  expect_true("pct" %in% names(tidy_result))

  # Check subgroups include expected values
  subgroups <- unique(tidy_result$subgroup)
  expect_true("total_enrollment" %in% subgroups)
  expect_true("hispanic" %in% subgroups)
  expect_true("white" %in% subgroups)
})

test_that("id_enr_aggs adds correct flags", {
  skip_on_cran()
  skip_if_offline()

  # Get tidy data with aggregation flags
  result <- fetch_enr(2024, tidy = TRUE, use_cache = TRUE)

  # Check flags exist
  expect_true("is_state" %in% names(result))
  expect_true("is_district" %in% names(result))
  expect_true("is_campus" %in% names(result))
  expect_true("is_charter" %in% names(result))

  # Check flags are boolean
  expect_true(is.logical(result$is_state))
  expect_true(is.logical(result$is_district))
  expect_true(is.logical(result$is_campus))
  expect_true(is.logical(result$is_charter))

  # Check mutual exclusivity (each row is only one type)
  type_sums <- result$is_state + result$is_district + result$is_campus
  expect_true(all(type_sums == 1))
})

test_that("fetch_enr_multi combines years correctly", {
  skip_on_cran()
  skip_if_offline()

  # Fetch two years
  result <- fetch_enr_multi(c(2023, 2024), tidy = TRUE, use_cache = TRUE)

  # Check we have both years
  expect_true(2023 %in% result$end_year)
  expect_true(2024 %in% result$end_year)

  # Check state totals exist for both years
  state_totals <- result %>%
    dplyr::filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")
  expect_equal(nrow(state_totals), 2)
})

test_that("historical data (2000) works via API", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2000, tidy = FALSE, use_cache = FALSE)

  expect_true(is.data.frame(result))
  expect_true("State" %in% result$type)
  expect_true("District" %in% result$type)
  expect_true(nrow(result) > 0)
})

test_that("most recent year (2024) works via API", {
  skip_on_cran()
  skip_if_offline()

  result <- fetch_enr(2024, tidy = FALSE, use_cache = FALSE)

  expect_true(is.data.frame(result))
  expect_true("State" %in% result$type)
  expect_true("District" %in% result$type)
  expect_true(nrow(result) > 0)

  # Check 2024 has the expected state total (should be around 915,000)
  state_row <- result[result$type == "State", ]
  expect_true(nrow(state_row) == 1)
  expect_true(state_row$row_total > 800000)
  expect_true(state_row$row_total < 1000000)
})
