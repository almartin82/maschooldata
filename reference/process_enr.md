# Process raw DESE enrollment data

Transforms raw DESE data into a standardized schema combining district
and school data.

## Usage

``` r
process_enr(raw_data, end_year)
```

## Arguments

- raw_data:

  List containing district_race, school_race, and special_pop data
  frames from get_raw_enr

- end_year:

  School year end

## Value

Processed data frame with standardized columns
