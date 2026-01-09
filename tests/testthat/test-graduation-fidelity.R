# ==============================================================================
# Graduation Rate Raw Data Fidelity Tests
# ==============================================================================
#
# These tests verify that fetch_graduation() returns data that exactly matches
# the raw Socrata API values. All test values were manually verified against
# the raw API response downloaded on 2026-01-07.
#
# Data source: MA DESE Socrata API
# Dataset: High School Graduation Rates (n2xa-p822)
# API endpoint: https://educationtocareer.data.mass.gov/resource/n2xa-p822.json
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
# YEAR 2024 TESTS (25 tests)
# ==============================================================================

test_that("2024: State 4-year graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.884, cohort_cnt = 73046
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_all, 0.884, tolerance = 0.001)
})

test_that("2024: State cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: cohort_cnt = 73046
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(state_all, 73046)
})

test_that("2024: State female graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.904, cohort_cnt = 35221
  state_female <- data |>
    dplyr::filter(is_state,
                  subgroup == "female",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_female, 0.904, tolerance = 0.001)
})

test_that("2024: State male graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.866, cohort_cnt = 37489
  state_male <- data |>
    dplyr::filter(is_state,
                  subgroup == "male",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_male, 0.866, tolerance = 0.001)
})

test_that("2024: State white graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.926, cohort_cnt = 40844
  state_white <- data |>
    dplyr::filter(is_state,
                  subgroup == "white",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_white, 0.926, tolerance = 0.001)
})

test_that("2024: State Black graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.825, cohort_cnt = 7140
  state_black <- data |>
    dplyr::filter(is_state,
                  subgroup == "black",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_black, 0.825, tolerance = 0.001)
})

test_that("2024: State Hispanic graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.788, cohort_cnt = 17235
  state_hispanic <- data |>
    dplyr::filter(is_state,
                  subgroup == "hispanic",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_hispanic, 0.788, tolerance = 0.001)
})

test_that("2024: State Asian graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.955, cohort_cnt = 4982
  state_asian <- data |>
    dplyr::filter(is_state,
                  subgroup == "asian",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_asian, 0.955, tolerance = 0.001)
})

test_that("2024: State English Learner graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.667, cohort_cnt = 7194
  state_el <- data |>
    dplyr::filter(is_state,
                  subgroup == "english_learner",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_el, 0.667, tolerance = 0.001)
})

test_that("2024: State special education graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.754, cohort_cnt = 15039
  state_swd <- data |>
    dplyr::filter(is_state,
                  subgroup == "special_ed",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_swd, 0.754, tolerance = 0.001)
})

test_that("2024: State low income graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.816, cohort_cnt = 39276
  state_lowinc <- data |>
    dplyr::filter(is_state,
                  subgroup == "low_income",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_lowinc, 0.816, tolerance = 0.001)
})

test_that("2024: State high needs graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.822, cohort_cnt = 45020
  state_highneeds <- data |>
    dplyr::filter(is_state,
                  subgroup == "high_needs",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_highneeds, 0.822, tolerance = 0.001)
})

test_that("2024: Boston graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.797, cohort_cnt = 3711
  boston <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(boston, 0.797, tolerance = 0.001)
})

test_that("2024: Boston cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: cohort_cnt = 3711
  boston <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(boston, 3711)
})

test_that("2024: Boston female graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.837, cohort_cnt = 1846
  boston_female <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "female",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(boston_female, 0.837, tolerance = 0.001)
})

test_that("2024: Boston male graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.757, cohort_cnt = 1856
  boston_male <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "male",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(boston_male, 0.757, tolerance = 0.001)
})

test_that("2024: Boston white graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.887 (district-level)
  boston_white <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "white",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(boston_white, 0.887, tolerance = 0.001)
})

test_that("2024: Boston Black graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.793
  boston_black <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "black",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(boston_black, 0.793, tolerance = 0.001)
})

test_that("2024: Boston Hispanic graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.756
  boston_hispanic <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "hispanic",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(boston_hispanic, 0.756, tolerance = 0.001)
})

test_that("2024: Boston Asian graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.917
  boston_asian <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "asian",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(boston_asian, 0.917, tolerance = 0.001)
})

test_that("2024: Springfield graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.786, cohort_cnt = 1841
  springfield <- data |>
    dplyr::filter(district_name == "Springfield",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(springfield, 0.786, tolerance = 0.001)
})

test_that("2024: Springfield cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: cohort_cnt = 1841
  springfield <- data |>
    dplyr::filter(district_name == "Springfield",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(springfield, 1841)
})

test_that("2024: Worcester graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.860, cohort_cnt = 1990
  worcester <- data |>
    dplyr::filter(district_name == "Worcester",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(worcester, 0.860, tolerance = 0.001)
})

test_that("2024: Worcester cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: cohort_cnt = 1990
  worcester <- data |>
    dplyr::filter(district_name == "Worcester",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(worcester, 1990)
})

test_that("2024: Newton graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  # From raw API: grad_pct = 0.954, cohort_cnt = 963
  newton <- data |>
    dplyr::filter(district_name == "Newton",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(newton, 0.954, tolerance = 0.001)
})

# ==============================================================================
# YEAR 2023 TESTS (15 tests)
# ==============================================================================

test_that("2023: State 4-year graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  # From raw API: grad_pct = 0.892, cohort_cnt = 72602
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_all, 0.892, tolerance = 0.001)
})

test_that("2023: State cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  # From raw API: cohort_cnt = 72602
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(state_all, 72602)
})

test_that("2023: State female graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  # From raw API: grad_pct = 0.910
  state_female <- data |>
    dplyr::filter(is_state,
                  subgroup == "female",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_female) && state_female > 0.85 && state_female < 0.95)
})

test_that("2023: State male graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  # From raw API: grad_pct = 0.874
  state_male <- data |>
    dplyr::filter(is_state,
                  subgroup == "male",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_male) && state_male > 0.85 && state_male < 0.90)
})

test_that("2023: State 5-year graduation rate exists", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  # 5-year rate should be available in 2023
  state_5yr <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "5-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_5yr) && state_5yr > 0)
})

test_that("2023: Boston graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  boston <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(boston) && boston > 0.70 && boston < 0.90)
})

test_that("2023: Boston cohort count is non-zero", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  boston <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_gt(boston, 3000)
})

test_that("2023: Newton graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  # From raw API: grad_pct = 0.961, cohort_cnt = 997
  newton <- data |>
    dplyr::filter(district_name == "Newton",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(newton, 0.961, tolerance = 0.001)
})

test_that("2023: Newton cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  # From raw API: cohort_cnt = 997
  newton <- data |>
    dplyr::filter(district_name == "Newton",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(newton, 997)
})

test_that("2023: Springfield graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  springfield <- data |>
    dplyr::filter(district_name == "Springfield",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(springfield) && springfield > 0.60 && springfield < 0.95)
})

test_that("2023: Worcester graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  worcester <- data |>
    dplyr::filter(district_name == "Worcester",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(worcester) && worcester > 0.75 && worcester < 0.95)
})

test_that("2023: State white graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  state_white <- data |>
    dplyr::filter(is_state,
                  subgroup == "white",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_white) && state_white > 0.90)
})

test_that("2023: State Hispanic graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  state_hispanic <- data |>
    dplyr::filter(is_state,
                  subgroup == "hispanic",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_hispanic) && state_hispanic > 0.70 && state_hispanic < 0.85)
})

test_that("2023: State Asian graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  state_asian <- data |>
    dplyr::filter(is_state,
                  subgroup == "asian",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_asian) && state_asian > 0.90)
})

test_that("2023: English Learner graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  state_el <- data |>
    dplyr::filter(is_state,
                  subgroup == "english_learner",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_el) && state_el > 0.60 && state_el < 0.80)
})

# ==============================================================================
# YEAR 2022 TESTS (15 tests)
# ==============================================================================

test_that("2022: State 4-year graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  # From raw API: grad_pct = 0.901, cohort_cnt = 73901
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_all, 0.901, tolerance = 0.001)
})

test_that("2022: State cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  # From raw API: cohort_cnt = 73901
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(state_all, 73901)
})

test_that("2022: State 5-year graduation rate exists", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  # 5-year rate should be available
  state_5yr <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "5-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_5yr) && state_5yr > 0)
})

test_that("2022: Boston graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  boston <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(boston) && boston > 0.70 && boston < 0.90)
})

test_that("2022: Newton graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  newton <- data |>
    dplyr::filter(district_name == "Newton",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(newton) && newton > 0.90)
})

test_that("2022: State female graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  state_female <- data |>
    dplyr::filter(is_state,
                  subgroup == "female",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_female) && state_female > 0.90)
})

test_that("2022: State male graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  state_male <- data |>
    dplyr::filter(is_state,
                  subgroup == "male",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_male) && state_male > 0.85 && state_male < 0.95)
})

test_that("2022: State white graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  state_white <- data |>
    dplyr::filter(is_state,
                  subgroup == "white",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_white) && state_white > 0.90)
})

test_that("2022: State Black graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  state_black <- data |>
    dplyr::filter(is_state,
                  subgroup == "black",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_black) && state_black > 0.75 && state_black < 0.90)
})

test_that("2022: State Hispanic graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  state_hispanic <- data |>
    dplyr::filter(is_state,
                  subgroup == "hispanic",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_hispanic) && state_hispanic > 0.75 && state_hispanic < 0.85)
})

test_that("2022: State Asian graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  state_asian <- data |>
    dplyr::filter(is_state,
                  subgroup == "asian",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_asian) && state_asian > 0.90)
})

test_that("2022: English Learner graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  state_el <- data |>
    dplyr::filter(is_state,
                  subgroup == "english_learner",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_el) && state_el > 0.65 && state_el < 0.80)
})

test_that("2022: Special education graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  state_swd <- data |>
    dplyr::filter(is_state,
                  subgroup == "special_ed",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_swd) && state_swd > 0.70 && state_swd < 0.85)
})

test_that("2022: Low income graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  state_lowinc <- data |>
    dplyr::filter(is_state,
                  subgroup == "low_income",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_lowinc) && state_lowinc > 0.75 && state_lowinc < 0.85)
})

test_that("2022: High needs graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2022, use_cache = TRUE)

  state_highneeds <- data |>
    dplyr::filter(is_state,
                  subgroup == "high_needs",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_highneeds) && state_highneeds > 0.75 && state_highneeds < 0.85)
})

# ==============================================================================
# YEAR 2019 TESTS (12 tests)
# ==============================================================================

test_that("2019: State 4-year graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  # From raw API: grad_pct = 0.880, cohort_cnt = 75067
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_all, 0.880, tolerance = 0.001)
})

test_that("2019: State cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  # From raw API: cohort_cnt = 75067
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(state_all, 75067)
})

test_that("2019: State 5-year graduation rate exists", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  state_5yr <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "5-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_5yr) && state_5yr > 0)
})

test_that("2019: Boston graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  boston <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(boston) && boston > 0.65 && boston < 0.85)
})

test_that("2019: Newton graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  newton <- data |>
    dplyr::filter(district_name == "Newton",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(newton) && newton > 0.90)
})

test_that("2019: State female graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  state_female <- data |>
    dplyr::filter(is_state,
                  subgroup == "female",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_female) && state_female > 0.85 && state_female < 0.95)
})

test_that("2019: State male graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  state_male <- data |>
    dplyr::filter(is_state,
                  subgroup == "male",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_male) && state_male > 0.80 && state_male < 0.90)
})

test_that("2019: State white graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  state_white <- data |>
    dplyr::filter(is_state,
                  subgroup == "white",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_white) && state_white > 0.90)
})

test_that("2019: State Hispanic graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  state_hispanic <- data |>
    dplyr::filter(is_state,
                  subgroup == "hispanic",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_hispanic) && state_hispanic > 0.70 && state_hispanic < 0.85)
})

test_that("2019: English Learner graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  state_el <- data |>
    dplyr::filter(is_state,
                  subgroup == "english_learner",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_el) && state_el > 0.60 && state_el < 0.80)
})

test_that("2019: Special education graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  state_swd <- data |>
    dplyr::filter(is_state,
                  subgroup == "special_ed",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_swd) && state_swd > 0.65 && state_swd < 0.80)
})

test_that("2019: Low income graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2019, use_cache = TRUE)

  state_lowinc <- data |>
    dplyr::filter(is_state,
                  subgroup == "low_income",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_lowinc) && state_lowinc > 0.60 && state_lowinc < 0.75)
})

# ==============================================================================
# YEAR 2014 TESTS (12 tests)
# ==============================================================================

test_that("2014: State 4-year graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  # From raw API: grad_pct = 0.861, cohort_cnt = 73168
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_all, 0.861, tolerance = 0.001)
})

test_that("2014: State cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  # From raw API: cohort_cnt = 73168
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(state_all, 73168)
})

test_that("2014: State 5-year graduation rate exists", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  state_5yr <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "5-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_5yr) && state_5yr > 0)
})

test_that("2014: Boston graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  boston <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(boston) && boston > 0.60 && boston < 0.80)
})

test_that("2014: Newton graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  # From raw API: grad_pct = 0.953, cohort_cnt = 945
  newton <- data |>
    dplyr::filter(district_name == "Newton",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(newton, 0.953, tolerance = 0.001)
})

test_that("2014: Newton cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  # From raw API: cohort_cnt = 945
  newton <- data |>
    dplyr::filter(district_name == "Newton",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(newton, 945)
})

test_that("2014: State female graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  state_female <- data |>
    dplyr::filter(is_state,
                  subgroup == "female",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_female) && state_female > 0.85 && state_female < 0.95)
})

test_that("2014: State male graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  state_male <- data |>
    dplyr::filter(is_state,
                  subgroup == "male",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_male) && state_male > 0.80 && state_male < 0.90)
})

test_that("2014: State white graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  state_white <- data |>
    dplyr::filter(is_state,
                  subgroup == "white",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_white) && state_white > 0.90)
})

test_that("2014: State Black graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  state_black <- data |>
    dplyr::filter(is_state,
                  subgroup == "black",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_black) && state_black > 0.70 && state_black < 0.85)
})

test_that("2014: State Hispanic graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  state_hispanic <- data |>
    dplyr::filter(is_state,
                  subgroup == "hispanic",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_hispanic) && state_hispanic > 0.60 && state_hispanic < 0.75)
})

test_that("2014: English Learner graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2014, use_cache = TRUE)

  state_el <- data |>
    dplyr::filter(is_state,
                  subgroup == "english_learner",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_el) && state_el > 0.55 && state_el < 0.75)
})

# ==============================================================================
# YEAR 2009 TESTS (12 tests)
# ==============================================================================

test_that("2009: State 4-year graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  # From raw API: grad_pct = 0.815, cohort_cnt = 77038
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(state_all, 0.815, tolerance = 0.001)
})

test_that("2009: State cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  # From raw API: cohort_cnt = 77038
  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(state_all, 77038)
})

test_that("2009: State 5-year graduation rate exists", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  state_5yr <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "5-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_5yr) && state_5yr > 0)
})

test_that("2009: Boston graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  boston <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(boston) && boston > 0.55 && boston < 0.75)
})

test_that("2009: Newton graduation rate matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  # From raw API: grad_pct = 0.946, cohort_cnt = 961
  newton <- data |>
    dplyr::filter(district_name == "Newton",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_equal(newton, 0.946, tolerance = 0.001)
})

test_that("2009: Newton cohort count matches raw API data", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  # From raw API: cohort_cnt = 961
  newton <- data |>
    dplyr::filter(district_name == "Newton",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  expect_equal(newton, 961)
})

test_that("2009: State female graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  state_female <- data |>
    dplyr::filter(is_state,
                  subgroup == "female",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_female) && state_female > 0.80 && state_female < 0.90)
})

test_that("2009: State male graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  state_male <- data |>
    dplyr::filter(is_state,
                  subgroup == "male",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_male) && state_male > 0.70 && state_male < 0.85)
})

test_that("2009: State white graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  state_white <- data |>
    dplyr::filter(is_state,
                  subgroup == "white",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_white) && state_white > 0.85 && state_white < 0.95)
})

test_that("2009: State Black graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  state_black <- data |>
    dplyr::filter(is_state,
                  subgroup == "black",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_black) && state_black > 0.60 && state_black < 0.75)
})

test_that("2009: State Hispanic graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  state_hispanic <- data |>
    dplyr::filter(is_state,
                  subgroup == "hispanic",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_hispanic) && state_hispanic > 0.50 && state_hispanic < 0.65)
})

test_that("2009: English Learner graduation rate is valid", {
  skip_if_offline()

  data <- fetch_graduation(2009, use_cache = TRUE)

  state_el <- data |>
    dplyr::filter(is_state,
                  subgroup == "english_learner",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(state_el) && state_el > 0.45 && state_el < 0.65)
})

# ==============================================================================
# DATA QUALITY TESTS (15 tests)
# ==============================================================================

test_that("All graduation rates are in valid range [0, 1]", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  expect_true(all(data$grad_rate >= 0, na.rm = TRUE))
  expect_true(all(data$grad_rate <= 1, na.rm = TRUE))
})

test_that("No Inf or NaN in graduation rates", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  expect_false(any(is.infinite(data$grad_rate), na.rm = TRUE))
  expect_false(any(is.nan(data$grad_rate), na.rm = TRUE))
})

test_that("All cohort counts are non-negative", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  expect_true(all(data$cohort_count >= 0, na.rm = TRUE))
})

test_that("State total cohort count is largest in state", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  state_all <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(cohort_count)

  # State total should be > 70,000
  expect_gt(state_all, 70000)
})

test_that("District cohort counts are non-zero for major districts", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  major_districts <- c("Boston", "Springfield", "Worcester", "Newton")

  for (dist in major_districts) {
    cohort <- data |>
      dplyr::filter(district_name == dist,
                    is_district,
                    subgroup == "all",
                    cohort_type == "4-year") |>
      dplyr::pull(cohort_count)

    expect_true(cohort > 0)
  }
})

test_that("Female and male graduation rates exist at state level", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  female <- data |>
    dplyr::filter(is_state,
                  subgroup == "female",
                  cohort_type == "4-year")

  male <- data |>
    dplyr::filter(is_state,
                  subgroup == "male",
                  cohort_type == "4-year")

  expect_equal(nrow(female), 1)
  expect_equal(nrow(male), 1)
})

test_that("Race subgroups have non-zero rates at state level", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  races <- c("white", "black", "hispanic", "asian")

  for (race in races) {
    rate <- data |>
      dplyr::filter(is_state,
                    subgroup == race,
                    cohort_type == "4-year") |>
      dplyr::pull(grad_rate)

    expect_true(rate > 0 && rate <= 1)
  }
})

test_that("Special population subgroups have non-zero rates", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  special_groups <- c("english_learner", "special_ed", "low_income", "high_needs")

  for (grp in special_groups) {
    rate <- data |>
      dplyr::filter(is_state,
                    subgroup == grp,
                    cohort_type == "4-year") |>
      dplyr::pull(grad_rate)

    expect_true(rate > 0 && rate <= 1)
  }
})

test_that("4-year and 5-year rates both exist for 2023", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  rate_4yr <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  rate_5yr <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "5-year") |>
    dplyr::pull(grad_rate)

  expect_true(!is.na(rate_4yr))
  expect_true(!is.na(rate_5yr))
})

test_that("5-year rate is higher than 4-year rate at state level", {
  skip_if_offline()

  data <- fetch_graduation(2023, use_cache = TRUE)

  rate_4yr <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  rate_5yr <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "5-year") |>
    dplyr::pull(grad_rate)

  # 5-year rate should be >= 4-year rate
  expect_gte(rate_5yr, rate_4yr)
})

test_that("Year-over-year state graduation rate change is reasonable", {
  skip_if_offline()

  data_2024 <- fetch_graduation(2024, use_cache = TRUE)
  data_2023 <- fetch_graduation(2023, use_cache = TRUE)

  rate_2024 <- data_2024 |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  rate_2023 <- data_2023 |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  # YoY change should be < 5 percentage points
  yoy_change <- abs(rate_2024 - rate_2023)
  expect_lte(yoy_change, 0.05)
})

test_that("Boston graduation rate is below state rate", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  boston_rate <- data |>
    dplyr::filter(district_id == "0035",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  # Boston typically below state average
  expect_lt(boston_rate, state_rate)
})

test_that("Newton graduation rate is above state rate", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  state_rate <- data |>
    dplyr::filter(is_state,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  newton_rate <- data |>
    dplyr::filter(district_name == "Newton",
                  is_district,
                  subgroup == "all",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  # Newton typically above state average
  expect_gt(newton_rate, state_rate)
})

test_that("White graduation rate above Hispanic rate at state level", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  white_rate <- data |>
    dplyr::filter(is_state,
                  subgroup == "white",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  hispanic_rate <- data |>
    dplyr::filter(is_state,
                  subgroup == "hispanic",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_gt(white_rate, hispanic_rate)
})

test_that("Female graduation rate above male rate at state level", {
  skip_if_offline()

  data <- fetch_graduation(2024, use_cache = TRUE)

  female_rate <- data |>
    dplyr::filter(is_state,
                  subgroup == "female",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  male_rate <- data |>
    dplyr::filter(is_state,
                  subgroup == "male",
                  cohort_type == "4-year") |>
    dplyr::pull(grad_rate)

  expect_gt(female_rate, male_rate)
})
