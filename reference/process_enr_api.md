# Process API data into standard schema

Transforms raw Socrata API data into the standardized schema used by the
package, matching the format produced by the Excel-based processing.

## Usage

``` r
process_enr_api(api_data, end_year)
```

## Arguments

- api_data:

  Data frame from get_raw_enr_api

- end_year:

  School year end

## Value

Processed data frame with standardized columns
