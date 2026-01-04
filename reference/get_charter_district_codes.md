# Get charter district codes

Returns a character vector of district codes for all charter school
districts in Massachusetts. Charter schools operate as their own
districts.

## Usage

``` r
get_charter_district_codes(use_cache = TRUE)
```

## Arguments

- use_cache:

  If TRUE (default), use cached data if available

## Value

Character vector of charter district codes

## Examples

``` r
if (FALSE) { # \dontrun{
charter_districts <- get_charter_district_codes()
} # }
```
