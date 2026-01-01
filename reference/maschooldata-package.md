# maschooldata: Fetch and Process Massachusetts School Data

Downloads and processes school data from the Massachusetts Department of
Elementary and Secondary Education (DESE). Provides functions for
fetching enrollment data from SIMS (Student Information Management
System) and transforming it into tidy format for analysis.

## Main functions

- [`fetch_enr`](https://almartin82.github.io/maschooldata/reference/fetch_enr.md):

  Fetch enrollment data for a school year

- [`fetch_enr_multi`](https://almartin82.github.io/maschooldata/reference/fetch_enr_multi.md):

  Fetch enrollment data for multiple years

- [`tidy_enr`](https://almartin82.github.io/maschooldata/reference/tidy_enr.md):

  Transform wide data to tidy (long) format

- [`id_enr_aggs`](https://almartin82.github.io/maschooldata/reference/id_enr_aggs.md):

  Add aggregation level flags

- [`enr_grade_aggs`](https://almartin82.github.io/maschooldata/reference/enr_grade_aggs.md):

  Create grade-level aggregations

- [`get_available_years`](https://almartin82.github.io/maschooldata/reference/get_available_years.md):

  List available data years

## Cache functions

- [`cache_status`](https://almartin82.github.io/maschooldata/reference/cache_status.md):

  View cached data files

- [`clear_cache`](https://almartin82.github.io/maschooldata/reference/clear_cache.md):

  Remove cached data files

## ID System

Massachusetts uses a hierarchical ID system:

- District IDs: 4 digits (e.g., 0350 = Boston)

- School IDs: 8 digits (district ID + 4-digit school number, e.g.,
  03500010)

## Data Sources

Data is sourced from the Massachusetts DESE website:

- Enrollment Reports:
  <https://www.doe.mass.edu/infoservices/reports/enroll/>

- SIMS: <https://www.doe.mass.edu/InfoServices/data/sims/>

- School Profiles: <https://profiles.doe.mass.edu/>

## Data Availability

- Excel downloads: 2017-2024 (school years 2016-17 through 2023-24)

- Profiles system: 2000-2025 (enrollment by race/gender reports)

## See also

Useful links:

- <https://github.com/almartin82/maschooldata>

- Report bugs at <https://github.com/almartin82/maschooldata/issues>

## Author

**Maintainer**: Al Martin <almartin@example.com>
