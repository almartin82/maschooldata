# Fetch graduation rate data for multiple years

Downloads and combines graduation rate data for multiple school years.

## Usage

``` r
fetch_graduation_multi(end_years, tidy = TRUE, use_cache = TRUE)
```

## Arguments

- end_years:

  Vector of school year ends (e.g., c(2020, 2021, 2022))

- tidy:

  If TRUE (default), returns data in long (tidy) format.

- use_cache:

  If TRUE (default), uses locally cached data when available.

## Value

Combined data frame with graduation rate data for all requested years

## Examples

``` r
if (FALSE) { # \dontrun{
# Get 5 years of data
grad_multi <- fetch_graduation_multi(2020:2024)

# Track graduation rate trends
grad_multi |>
  dplyr::filter(is_state, subgroup == "all", cohort_type == "4-year") |>
  dplyr::select(end_year, grad_rate, cohort_count)

# Compare Boston and Springfield over time
grad_multi |>
  dplyr::filter(district_id %in% c("0035", "0281"),
               subgroup == "all",
               cohort_type == "4-year") |>
  dplyr::select(end_year, district_name, grad_rate)
} # }
```
