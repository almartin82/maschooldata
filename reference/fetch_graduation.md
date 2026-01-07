# Fetch Massachusetts graduation rate data

Downloads and processes graduation rate data from the Massachusetts
Department of Elementary and Secondary Education (DESE) via their
Socrata API (educationtocareer.data.mass.gov).

## Usage

``` r
fetch_graduation(end_year, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_year:

  A school year. Year is the end of the academic year - eg 2023-24
  school year is year '2024'. Valid values are 2006-2024.

- tidy:

  If TRUE (default), returns data in long (tidy) format with subgroup
  column. If FALSE, returns wide format.

- use_cache:

  If TRUE (default), uses locally cached data when available. Set to
  FALSE to force re-download from DESE.

## Value

Data frame with graduation rate data. Wide format includes columns for
district_id, school_id, names, subgroup, cohort_type, cohort_count,
graduate_count, and grad_rate. Tidy format is the same (API data is
already in long format).

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 2024 graduation data (2023-24 school year)
grad_2024 <- fetch_graduation(2024)

# Get historical data from 2010
grad_2010 <- fetch_graduation(2010)

# Get wide format (already wide from API)
grad_wide <- fetch_graduation(2024, tidy = FALSE)

# Force fresh download (ignore cache)
grad_fresh <- fetch_graduation(2024, use_cache = FALSE)

# Filter to Boston Public Schools
boston <- grad_2024 |>
  dplyr::filter(district_id == "0035")

# Compare 4-year and 5-year rates
rates <- grad_2024 |>
  dplyr::filter(is_state, subgroup == "all") |>
  dplyr::select(cohort_type, grad_rate, cohort_count)
} # }
```
