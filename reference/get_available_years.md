# Get available years for Massachusetts enrollment data

Returns the range of school years for which enrollment data is available
from the DESE Socrata API. Data is available from 1994-2025.

## Usage

``` r
get_available_years()
```

## Value

Integer vector of available school years (end year)

## Details

Note: Years 1992-1993 exist in the API but have very limited data (only
special populations). Full enrollment data starts in 1994.

## Examples

``` r
get_available_years()
#>  [1] 1994 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008
#> [16] 2009 2010 2011 2012 2013 2014 2015 2016 2017 2018 2019 2020 2021 2022 2023
#> [31] 2024 2025
# Returns: 1994, 1995, ..., 2024, 2025
```
