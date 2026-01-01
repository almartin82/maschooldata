# Build URL for enrollment file download

Constructs the URL for a specific enrollment file based on year and
type. Handles different naming conventions across years.

## Usage

``` r
build_enrollment_url(end_year, level, type)
```

## Arguments

- end_year:

  School year end

- level:

  "district" or "school"

- type:

  "race", "gender", or "grade"

## Value

URL string
