# maschooldata

**[Documentation](https://almartin82.github.io/maschooldata/)** \|
**[Getting
Started](https://almartin82.github.io/maschooldata/articles/quickstart.html)**

Fetch and analyze Massachusetts school enrollment data from the
Department of Elementary and Secondary Education (DESE) in R or Python.

## What can you find with maschooldata?

**30+ years of enrollment data (1994-2025).** 920,000 students today.
Over 400 districts. Here are fifteen stories hiding in the numbers:

------------------------------------------------------------------------

### 1. Boston’s slow decline

Boston Public Schools has lost over 20,000 students since its peak.
Today it enrolls around 48,000.

``` r
library(maschooldata)
library(dplyr)

enr <- fetch_enr_multi(c(2000, 2005, 2010, 2015, 2020, 2025))

enr %>%
  filter(is_district, district_id == "0035",
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

![Boston
decline](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/boston-decline-1.png)

Boston decline

------------------------------------------------------------------------

### 2. Gateway Cities under pressure

Springfield, Worcester, and Lowell are struggling with enrollment while
demographics shift dramatically.

``` r
gateway <- c("0281", "0365", "0145")  # Springfield, Worcester, Lowell

enr %>%
  filter(is_district, district_id %in% gateway,
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

![Gateway
cities](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/gateway-cities-1.png)

Gateway cities

------------------------------------------------------------------------

### 3. Massachusetts is diversifying fast

The state has gone from 80% white to under 60% white in 25 years.
Hispanic students now exceed 20%.

``` r
enr <- fetch_enr_multi(c(2000, 2010, 2020, 2025))

enr %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(end_year, subgroup, n_students, pct)
```

![Demographic
shift](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/demographics-shift-1.png)

Demographic shift

------------------------------------------------------------------------

### 4. The Cape and Islands are graying

Barnstable County (Cape Cod) and Nantucket have seen steep enrollment
declines as families can’t afford housing.

``` r
enr_2025 <- fetch_enr(2025)

# Find Cape districts
enr_2025 %>%
  filter(is_district, grade_level == "TOTAL", subgroup == "total_enrollment",
         grepl("Barnstable|Chatham|Dennis|Falmouth|Mashpee|Orleans|Provincetown", district_name)) %>%
  select(district_name, n_students)
```

![Cape
decline](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/cape-decline-1.png)

Cape decline

------------------------------------------------------------------------

### 5. COVID crushed kindergarten

Kindergarten enrollment dropped 10% during the pandemic and hasn’t
recovered.

``` r
enr <- fetch_enr_multi(2018:2025)

enr %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "06", "12")) %>%
  select(end_year, grade_level, n_students)
```

![COVID
kindergarten](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/covid-kindergarten-1.png)

COVID kindergarten

------------------------------------------------------------------------

### 6. Charter schools serving 45,000+ students

Massachusetts charter enrollment has grown steadily, especially in urban
areas.

``` r
enr_2025 %>%
  filter(is_charter, is_campus, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  summarize(
    total_charter = sum(n_students, na.rm = TRUE),
    n_schools = n()
  )
```

![Charter
enrollment](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/charter-enrollment-1.png)

Charter enrollment

------------------------------------------------------------------------

### 7. One in five students is low-income

The “economically disadvantaged” indicator replaced free/reduced lunch
in 2015, showing persistent need.

``` r
enr <- fetch_enr_multi(2015:2025)

enr %>%
  filter(is_state, subgroup == "econ_disadv", grade_level == "TOTAL") %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(end_year, n_students, pct)
```

![Economic
disadvantage](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/econ-disadvantage-1.png)

Economic disadvantage

------------------------------------------------------------------------

### 8. English learners are concentrated in cities

Over 10% of students statewide are English learners, but in some
districts it’s 30%+.

``` r
enr_2025 %>%
  filter(is_district, subgroup == "lep", grade_level == "TOTAL") %>%
  arrange(desc(pct)) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(district_name, n_students, pct) %>%
  head(10)
```

![EL
concentration](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/el-concentration-1.png)

EL concentration

------------------------------------------------------------------------

### 9. The suburban ring is holding steady

Newton, Lexington, and Wellesley maintain enrollment while urban cores
decline.

``` r
suburbs <- c("0195", "0139", "0325")  # Newton, Lexington, Wellesley

enr <- fetch_enr_multi(2015:2025)

enr %>%
  filter(is_district, district_id %in% suburbs,
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

![Suburban
stability](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/suburban-stable-1.png)

Suburban stability

------------------------------------------------------------------------

### 10. Regional school districts dominate rural Massachusetts

Over 50 regional districts serve students from multiple towns, a
uniquely Massachusetts approach.

``` r
enr_2025 %>%
  filter(is_district, grepl("Regional", district_name),
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  select(district_name, n_students) %>%
  head(10)
```

![Regional
districts](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/regional-districts-1.png)

Regional districts

------------------------------------------------------------------------

### 11. Springfield’s demographic transformation

Springfield, the state’s third-largest district, has seen Hispanic
students become the majority over the past decade.

``` r
enr <- fetch_enr_multi(2016:2025)

enr %>%
  filter(is_district, district_id == "0281", grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(end_year, subgroup, pct)
```

![Springfield
demographics](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/springfield-demographics-1.png)

Springfield demographics

------------------------------------------------------------------------

### 12. Fall River and New Bedford: SouthCoast struggles

Two former mill cities with similar trajectories - persistent economic
challenges and declining enrollment.

``` r
southcoast <- c("0079", "0192")  # Fall River, New Bedford

enr %>%
  filter(is_district, district_id %in% southcoast,
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

![SouthCoast
cities](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/southcoast-cities-1.png)

SouthCoast cities

------------------------------------------------------------------------

### 13. Worcester suburbs are growing

While Worcester holds steady, its suburban ring - Shrewsbury,
Westborough, Grafton - shows consistent growth.

``` r
worcester_ring <- c("0270", "0330", "0097")  # Shrewsbury, Westborough, Grafton

enr %>%
  filter(is_district, district_id %in% worcester_ring,
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

![Worcester
suburbs](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/worcester-suburbs-1.png)

Worcester suburbs

------------------------------------------------------------------------

### 14. Western MA faces population decline

Pioneer Valley and Berkshire counties have seen persistent enrollment
declines as young families move east or out of state.

``` r
western <- c("0199", "0003", "0211", "0098")  # Northampton, Amherst, Pittsfield, Great Barrington

enr %>%
  filter(is_district, district_id %in% western,
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  group_by(end_year) %>%
  summarize(total = sum(n_students, na.rm = TRUE))
```

![Western MA
decline](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/western-ma-decline-1.png)

Western MA decline

------------------------------------------------------------------------

### 15. Special education rates vary widely by district

Some districts identify nearly 25% of students for special education
services, while others are under 15%.

``` r
enr_2025 %>%
  filter(is_district, subgroup == "sped", grade_level == "TOTAL") %>%
  arrange(desc(pct)) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(district_name, n_students, pct) %>%
  head(15)
```

![SPED
rates](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/sped-gender-1.png)

SPED rates

------------------------------------------------------------------------

## Installation

``` r
# install.packages("remotes")
remotes::install_github("almartin82/maschooldata")
```

## Quick Start

### R

``` r
library(maschooldata)
library(dplyr)

# Fetch one year
enr_2025 <- fetch_enr(2025)

# Fetch multiple years
enr_multi <- fetch_enr_multi(2020:2025)

# State totals
enr_2025 %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")

# District breakdown
enr_2025 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students))

# Boston demographics
enr_2025 %>%
  filter(district_id == "0035", grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) %>%
  select(subgroup, n_students, pct)
```

### Python

``` python
import pymaschooldata as ma

# Fetch 2025 data (2024-25 school year)
enr = ma.fetch_enr(2025)

# Statewide total
total = enr[(enr['is_state']) & (enr['grade_level'] == 'TOTAL') &
            (enr['subgroup'] == 'total_enrollment')]['n_students'].sum()
print(f"{total:,} students")
#> 920,000 students

# Get multiple years
enr_multi = ma.fetch_enr_multi([2020, 2021, 2022, 2023, 2024, 2025])

# Check available years
years = ma.get_available_years()
print(f"Data available: {years['min_year']}-{years['max_year']}")
#> Data available: 1994-2025
```

## Data availability

| Years         | Source           | Notes                        |
|---------------|------------------|------------------------------|
| **1994-2025** | DESE Socrata API | 30+ years of consistent data |

Data is accessed via the Massachusetts Education-to-Career Research and
Data Hub: <https://educationtocareer.data.mass.gov/d/t8td-gens>

### What’s included

- **Levels:** State, District (400+), School (1,800+)
- **Demographics:** White, Black, Hispanic, Asian, Native American,
  Pacific Islander (1998+), Multiracial (2003+)
- **Special populations:** Students with disabilities, English learners,
  Low income / Economically disadvantaged
- **Grade levels:** PK through 12, plus SPED beyond Grade 12

### Massachusetts-specific notes

- **District IDs:** 4-digit codes (e.g., 0035 = Boston)
- **Economic indicator changes:** Pre-2015 used “Low Income”, 2015-2021
  used “Economically Disadvantaged”, 2022+ uses “Low Income” again
- **Charter schools:** Included with charter flag for filtering
- **Regional districts:** Many multi-town districts with “Regional” in
  name

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data
in Python and R.

**All 50 state packages:**
[github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (<almartin@gmail.com>)

## License

MIT
