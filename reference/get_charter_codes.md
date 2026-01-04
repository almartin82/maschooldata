# Get charter school codes

Returns a character vector of school codes (8-digit SCHID) for all
charter schools in Massachusetts.

## Usage

``` r
get_charter_codes(use_cache = TRUE)
```

## Arguments

- use_cache:

  If TRUE (default), use cached data if available

## Value

Character vector of charter school codes

## Examples

``` r
if (FALSE) { # \dontrun{
charter_codes <- get_charter_codes()
length(charter_codes)  # ~72 charter schools
} # }
```
