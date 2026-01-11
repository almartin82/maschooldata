# Process raw assessment data into standard schema

Transforms raw Socrata API data into the standardized schema used by the
package.

## Usage

``` r
process_assessment(raw_data, end_year)
```

## Arguments

- raw_data:

  Data frame from get_raw_assessment()

- end_year:

  School year end

## Value

Processed data frame with standardized columns
