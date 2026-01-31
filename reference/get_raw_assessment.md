# Download raw assessment data from DESE Socrata API

Downloads MCAS assessment data from the Massachusetts
Education-to-Career Research and Data Hub (Socrata) API. Uses pagination
to fetch all records since the API has a 100,000 row limit per request.

## Usage

``` r
get_raw_assessment(end_year)
```

## Arguments

- end_year:

  School year end (2024-25 = 2025). Valid years: 2017-2019, 2021-2025.

## Value

Data frame with assessment data including district and school records
