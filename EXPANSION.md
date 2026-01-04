# Massachusetts School Data Expansion Research

**Last Updated:** 2026-01-04 **Theme Researched:** Graduation Rates

------------------------------------------------------------------------

## Data Sources Found

### Source 1: High School Graduation Rates (Primary - Recommended)

- **Dataset ID:** `n2xa-p822`
- **URL:**
  <https://educationtocareer.data.mass.gov/Assessment-and-Accountability/High-School-Graduation-Rates/n2xa-p822>
- **API Endpoint:**
  `https://educationtocareer.data.mass.gov/resource/n2xa-p822.json`
- **HTTP Status:** 200 OK (verified)
- **Format:** Socrata API (JSON/CSV)
- **Years Available:** 2006-2024 (19 years)
- **Access:** Direct API access, no authentication required
- **Last Modified:** 2025-05-02
- **Record Count:** ~411,000 total records

### Source 2: State and District High School Graduation Rates (DART)

- **Dataset ID:** `u57w-6nby`
- **URL:**
  <https://educationtocareer.data.mass.gov/Assessment-and-Accountability/State-and-District-High-School-Graduation-Rates/u57w-6nby>
- **API Endpoint:**
  `https://educationtocareer.data.mass.gov/resource/u57w-6nby.json`
- **HTTP Status:** 200 OK (verified)
- **Format:** Socrata API (JSON/CSV)
- **Years Available:** 2024 (likely multi-year, needs verification)
- **Access:** Direct API access, no authentication required
- **Last Modified:** 2025-10-28
- **Note:** This is a DART (District Analysis Review Tool) dataset with
  different structure

### Source 3: Dropout Report

- **Dataset ID:** `cmm7-ttbg`
- **URL:** <https://educationtocareer.data.mass.gov/w/cmm7-ttbg>
- **API Endpoint:**
  `https://educationtocareer.data.mass.gov/resource/cmm7-ttbg.json`
- **HTTP Status:** 200 OK (verified)
- **Format:** Socrata API (JSON/CSV)
- **Years Available:** 2008-2024 (17 years)
- **Access:** Direct API access, no authentication required
- **Last Modified:** 2025-05-02

------------------------------------------------------------------------

## Schema Analysis

### High School Graduation Rates (n2xa-p822) - RECOMMENDED

#### Column Names (Consistent Across All Years)

| API Field        | Description                                           | Type   |
|------------------|-------------------------------------------------------|--------|
| `sy`             | School year (end year)                                | text   |
| `dist_code`      | District code (8 digits, e.g., “00350000” for Boston) | text   |
| `dist_name`      | District name                                         | text   |
| `org_code`       | Organization code (8 digits)                          | text   |
| `org_name`       | Organization name                                     | text   |
| `org_type`       | “State”, “District”, or “School”                      | text   |
| `grad_rate_type` | Rate type (see below)                                 | text   |
| `stu_grp`        | Student group/subgroup                                | text   |
| `cohort_cnt`     | Cohort count                                          | number |
| `grad_pct`       | Graduation percentage (decimal, e.g., 0.884 = 88.4%)  | number |
| `in_sch_pct`     | Still in school percentage                            | number |
| `non_grad_pct`   | Non-graduate completers percentage                    | number |
| `ged_pct`        | GED/High school equivalency percentage                | number |
| `drpout_pct`     | Dropout percentage                                    | number |
| `exclud_pct`     | Permanently excluded percentage                       | number |

#### Graduation Rate Types

- `4-Year Graduation Rate`
- `4-Year Adjusted Cohort Graduation Rate`
- `5-Year Graduation Rate`
- `5-Year Adjusted Cohort Graduation Rate`

#### Student Groups (16 categories)

- All Students
- American Indian or Alaska Native
- Asian
- Black or African American
- English Learners
- Female
- Foster Care
- High Needs
- Hispanic or Latino
- Homeless
- Low Income
- Male
- Multi-Race, Not Hispanic or Latino
- Native Hawaiian or Other Pacific Islander
- Students with Disabilities
- White

#### Organization Types

- State (org_code = “00000000”)
- District (org_code = dist_code)
- School

### Schema Changes Noted

- Schema has been consistent across all available years (2006-2024)
- Percentages stored as decimals (0.884 = 88.4%)
- No column name changes detected

### ID System

- **State ID:** `00000000`
- **District ID:** 8 digits, first 4 are unique district identifier
  (e.g., `00350000` for Boston district code `0035`)
- **School ID:** 8 digits, first 4 are district, last 4 are school
  within district (e.g., `00350560` = Boston Latin School)
- Consistent with enrollment API ID format

### Known Data Issues

- Suppression: Data not reported for cohorts with fewer than 6 students
- Some alternative/special schools may have low graduation rates
  (expected for recovery schools)
- `exclud_pct` (permanently excluded) only appears in older years and is
  typically 0

### Dropout Report (cmm7-ttbg) - SUPPLEMENTARY

#### Column Names

| API Field           | Description                    | Type   |
|---------------------|--------------------------------|--------|
| `sy`                | School year                    | text   |
| `dist_code`         | District code                  | text   |
| `dist_name`         | District name                  | text   |
| `org_code`          | Organization code              | text   |
| `org_name`          | Organization name              | text   |
| `org_type`          | State/District/School          | text   |
| `stu_grp`           | Student group                  | text   |
| `enroll_cnt_all`    | Total enrollment (grades 9-12) | number |
| `drpout_cnt_all`    | Total dropout count            | number |
| `drpout_pct_all`    | Total dropout rate             | number |
| `drpout_pct_grd_09` | Grade 9 dropout rate           | number |
| `drpout_pct_grd_10` | Grade 10 dropout rate          | number |
| `drpout_pct_grd_11` | Grade 11 dropout rate          | number |
| `drpout_pct_grd_12` | Grade 12 dropout rate          | number |

------------------------------------------------------------------------

## Time Series Heuristics

### State-Level Graduation Rates

| Metric                 | Expected Range         | Notes                                         |
|------------------------|------------------------|-----------------------------------------------|
| 4-year graduation rate | 80% - 92%              | Has increased from ~81% (2006) to ~88% (2024) |
| Cohort size            | 70,000 - 80,000        | Slight decline over time                      |
| YoY rate change        | \< 3 percentage points | Large swings indicate data issue              |

### Major District Graduation Rates

| District    | 4-Year Rate (2024) | Cohort Size      |
|-------------|--------------------|------------------|
| State       | 88.4%              | 73,046           |
| Boston      | 79.7%              | 3,711            |
| Worcester   | varies by school   | multiple schools |
| Springfield | check data         |                  |

### Data Quality Expectations

- All percentages should sum to approximately 1.0 (100%)
- `grad_pct + in_sch_pct + non_grad_pct + ged_pct + drpout_pct + exclud_pct ≈ 1.0`
- No negative values
- Cohort count should be \>= 6 for all reported rows

------------------------------------------------------------------------

## Recommended Implementation

### Priority: HIGH

- Graduation data is widely requested for education research
- API is stable, well-documented, and consistent with existing
  enrollment API

### Complexity: MEDIUM

- Same Socrata API pattern as enrollment
- Schema is clean and consistent
- Multiple rate types and subgroups add complexity to tidy
  transformation

### Estimated Files to Create/Modify:

1.  `R/get_raw_graduation.R` - New file for API download
2.  `R/fetch_graduation.R` - New file with `fetch_grad()` function
3.  `R/tidy_graduation.R` - New file for tidy transformation
4.  `tests/testthat/test-graduation-live.R` - Live pipeline tests
5.  Update `R/maschooldata-package.R` with new functions
6.  Update NAMESPACE and DESCRIPTION

### Implementation Steps:

1.  **Create `get_raw_grad_api()`**
    - Similar to
      [`get_raw_enr_api()`](https://almartin82.github.io/maschooldata/reference/get_raw_enr_api.md)
      pattern
    - API endpoint:
      `https://educationtocareer.data.mass.gov/resource/n2xa-p822.json`
    - Filter by year with `?sy=YYYY`
    - Handle pagination (set high limit)
2.  **Create `process_grad_api()`**
    - Standardize column names
    - Convert percentages if needed
    - Map org_type to consistent levels
3.  **Create `tidy_grad()`**
    - Pivot graduation rate types to columns (4yr, 4yr_adj, 5yr,
      5yr_adj)
    - Keep subgroups in rows
    - Add aggregation level flags
4.  **Create `fetch_grad()`**
    - Main user-facing function
    - Parameters: `end_year`, `rate_type`, `tidy`, `use_cache`
    - Support filtering by rate type
5.  **Optional: Add dropout data**
    - Could be separate `fetch_dropout()` or combined
    - Dataset `cmm7-ttbg` has similar structure

------------------------------------------------------------------------

## Test Requirements

### Raw Data Fidelity Tests Needed

``` r
# Year 2024 verification
test_that("2024 state graduation rate matches API", {
  # Expected from API: 88.4% (0.884), cohort 73,046
  data <- fetch_grad(2024)
  state_4yr <- data |>
    filter(org_type == "State", stu_grp == "All Students",
           grad_rate_type == "4-Year Graduation Rate")
  expect_equal(state_4yr$grad_pct, 0.884)
  expect_equal(state_4yr$cohort_cnt, 73046)
})

# Year 2007 verification (earliest year)
test_that("2007 state graduation rate matches API", {
  # Expected: 80.9% (0.809), cohort 75,912
  data <- fetch_grad(2007)
  state_4yr <- data |>
    filter(org_type == "State", stu_grp == "All Students",
           grad_rate_type == "4-Year Graduation Rate")
  expect_equal(state_4yr$grad_pct, 0.809)
  expect_equal(state_4yr$cohort_cnt, 75912)
})

# Boston district verification
test_that("2024 Boston graduation rate matches API", {
  # Expected: 79.7% (0.797), cohort 3,711
  data <- fetch_grad(2024)
  boston <- data |>
    filter(dist_code == "00350000", org_type == "District",
           stu_grp == "All Students", grad_rate_type == "4-Year Graduation Rate")
  expect_equal(boston$grad_pct, 0.797)
  expect_equal(boston$cohort_cnt, 3711)
})
```

### Data Quality Checks

``` r
test_that("graduation percentages sum to approximately 1", {
  data <- fetch_grad(2024, tidy = FALSE)
  data <- data |>
    mutate(pct_sum = grad_pct + in_sch_pct + non_grad_pct +
                     ged_pct + drpout_pct + exclud_pct)
  expect_true(all(data$pct_sum > 0.98 & data$pct_sum < 1.02, na.rm = TRUE))
})

test_that("no negative percentages", {
  data <- fetch_grad(2024, tidy = FALSE)
  expect_true(all(data$grad_pct >= 0, na.rm = TRUE))
  expect_true(all(data$drpout_pct >= 0, na.rm = TRUE))
})

test_that("cohort counts are positive", {
  data <- fetch_grad(2024, tidy = FALSE)
  expect_true(all(data$cohort_cnt > 0, na.rm = TRUE))
})
```

### Live Pipeline Tests

``` r
test_that("graduation API returns HTTP 200", {
  skip_if_offline()
  response <- httr::HEAD(
    "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json",
    httr::timeout(30)
  )
  expect_equal(httr::status_code(response), 200)
})

test_that("graduation API returns valid JSON", {
  skip_if_offline()
  response <- httr::GET(
    "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$limit=5",
    httr::timeout(30)
  )
  content <- httr::content(response, as = "text")
  data <- jsonlite::fromJSON(content)
  expect_true(is.data.frame(data))
  expect_gt(nrow(data), 0)
})
```

------------------------------------------------------------------------

## Additional Notes

### Relationship to Enrollment Data

- Graduation data uses same ID system as enrollment
- District codes are first 4 digits of 8-digit code
- Can join graduation to enrollment using `dist_code` and `org_code`

### Subgroup Consistency with Enrollment

Both datasets share these subgroups: - Race/ethnicity categories (7
groups) - Gender (Male/Female) - English Learners - Students with
Disabilities - Low Income / Economically Disadvantaged - High Needs

Graduation-only subgroups: - Foster Care - Homeless

### API Rate Limits

- Socrata default limit is 1000 rows
- Use `$limit=50000` to get all data for a year
- Expected ~20,000-25,000 rows per year (all schools, all subgroups, all
  rate types)

### Cache Strategy

- Same caching approach as enrollment
- Cache by year and tidy/wide format
- Approximately 2-3 MB per year uncompressed

------------------------------------------------------------------------

## Decision Points for Implementation

1.  **Rate type handling:**
    - Option A: Include all 4 rate types in output (4yr, 4yr_adj, 5yr,
      5yr_adj)
    - Option B: Default to 4-year, parameter to select type
    - Recommendation: Option A for `tidy=FALSE`, pivot for `tidy=TRUE`
2.  **Dropout data integration:**
    - Option A: Separate `fetch_dropout()` function
    - Option B: Include dropout as part of graduation output
    - Recommendation: Option A, keep functions focused
3.  **Subgroup filtering:**
    - Option A: Always return all subgroups
    - Option B: Add `subgroup` parameter to filter
    - Recommendation: Option A, let users filter with dplyr
