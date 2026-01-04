# Get school type lookup table from MassGIS

Downloads the MassGIS Schools shapefile and extracts a lookup table
mapping school codes (SCHID) to school types (TYPE).

## Usage

``` r
get_school_types(use_cache = TRUE)
```

## Arguments

- use_cache:

  If TRUE (default), use cached data if available

## Value

Data frame with columns: school_id, school_type, school_name
