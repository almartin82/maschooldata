# Tidy assessment data

Transforms processed assessment data to ensure consistent long format.
The Socrata API data is already in long format, so this function
primarily validates and ensures schema consistency.

## Usage

``` r
tidy_assessment(df)
```

## Arguments

- df:

  A processed assessment data frame from process_assessment()

## Value

A long data frame of tidied assessment data
