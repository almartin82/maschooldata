# maschooldata

<!-- badges: start -->
[![R-CMD-check](https://github.com/almartin82/maschooldata/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/almartin82/maschooldata/actions/workflows/R-CMD-check.yaml)
[![Python Tests](https://github.com/almartin82/maschooldata/actions/workflows/python-test.yaml/badge.svg)](https://github.com/almartin82/maschooldata/actions/workflows/python-test.yaml)
[![pkgdown](https://github.com/almartin82/maschooldata/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/almartin82/maschooldata/actions/workflows/pkgdown.yaml)
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

**[Documentation](https://almartin82.github.io/maschooldata/)** | **[Getting Started](https://almartin82.github.io/maschooldata/articles/quickstart.html)**

Fetch and analyze Massachusetts school enrollment data from the Department of Elementary and Secondary Education (DESE) in R or Python.

## What can you find with maschooldata?

**30+ years of enrollment data (1994-2025).** 920,000 students today. Over 400 districts. Here are ten stories hiding in the numbers:

---

### 1. Boston's slow decline

Boston Public Schools has lost over 20,000 students since its peak. Today it enrolls around 48,000.

```r
library(maschooldata)
library(dplyr)

enr <- fetch_enr_multi(c(2000, 2005, 2010, 2015, 2020, 2025))

enr %>%
  filter(is_district, district_id == "0035",
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

---

### 2. Gateway Cities under pressure

Springfield, Worcester, and Lowell are struggling with enrollment while demographics shift dramatically.

```r
gateway <- c("0281", "0365", "0145")  # Springfield, Worcester, Lowell

enr %>%
  filter(is_district, district_id %in% gateway,
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

---

### 3. Massachusetts is diversifying fast

The state has gone from 80% white to under 60% white in 25 years. Hispanic students now exceed 20%.

```r
enr <- fetch_enr_multi(c(2000, 2010, 2020, 2025))

enr %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(end_year, subgroup, n_students, pct)
```

---

### 4. The Cape and Islands are graying

Barnstable County (Cape Cod) and Nantucket have seen steep enrollment declines as families can't afford housing.

```r
enr_2025 <- fetch_enr(2025)

# Find Cape districts
enr_2025 %>%
  filter(is_district, grade_level == "TOTAL", subgroup == "total_enrollment",
         grepl("Barnstable|Chatham|Dennis|Falmouth|Mashpee|Orleans|Provincetown", district_name)) %>%
  select(district_name, n_students)
```

---

### 5. COVID crushed kindergarten

Kindergarten enrollment dropped 10% during the pandemic and hasn't recovered.

```r
enr <- fetch_enr_multi(2018:2025)

enr %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "06", "12")) %>%
  select(end_year, grade_level, n_students)
```

---

### 6. Charter schools serving 45,000+ students

Massachusetts charter enrollment has grown steadily, especially in urban areas.

```r
enr_2025 %>%
  filter(is_charter, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  summarize(
    total_charter = sum(n_students, na.rm = TRUE),
    n_schools = n()
  )
```

---

### 7. One in five students is low-income

The "economically disadvantaged" indicator replaced free/reduced lunch in 2015, showing persistent need.

```r
enr <- fetch_enr_multi(2015:2025)

enr %>%
  filter(is_state, subgroup == "econ_disadv", grade_level == "TOTAL") %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(end_year, n_students, pct)
```

---

### 8. English learners are concentrated in cities

Over 10% of students statewide are English learners, but in some districts it's 30%+.

```r
enr_2025 %>%
  filter(is_district, subgroup == "lep", grade_level == "TOTAL") %>%
  arrange(desc(pct)) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(district_name, n_students, pct) %>%
  head(10)
```

---

### 9. The suburban ring is holding steady

Newton, Lexington, and Wellesley maintain enrollment while urban cores decline.

```r
suburbs <- c("0195", "0139", "0325")  # Newton, Lexington, Wellesley

enr <- fetch_enr_multi(2015:2025)

enr %>%
  filter(is_district, district_id %in% suburbs,
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
```

---

### 10. Regional school districts dominate rural Massachusetts

Over 50 regional districts serve students from multiple towns, a uniquely Massachusetts approach.

```r
enr_2025 %>%
  filter(is_district, grepl("Regional", district_name),
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  select(district_name, n_students) %>%
  head(10)
```

---

## Installation

```r
# install.packages("remotes")
remotes::install_github("almartin82/maschooldata")
```

## Quick Start

### R

```r
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

```python
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

| Years | Source | Notes |
|-------|--------|-------|
| **1994-2025** | DESE Socrata API | 30+ years of consistent data |

Data is accessed via the Massachusetts Education-to-Career Research and Data Hub:
https://educationtocareer.data.mass.gov/d/t8td-gens

### What's included

- **Levels:** State, District (400+), School (1,800+)
- **Demographics:** White, Black, Hispanic, Asian, Native American, Pacific Islander (1998+), Multiracial (2003+)
- **Special populations:** Students with disabilities, English learners, Low income / Economically disadvantaged
- **Grade levels:** PK through 12, plus SPED beyond Grade 12

### Massachusetts-specific notes

- **District IDs:** 4-digit codes (e.g., 0035 = Boston)
- **Economic indicator changes:** Pre-2015 used "Low Income", 2015-2021 used "Economically Disadvantaged", 2022+ uses "Low Income" again
- **Charter schools:** Included with charter flag for filtering
- **Regional districts:** Many multi-town districts with "Regional" in name

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data in Python and R.

**All 50 state packages:** [github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (almartin@gmail.com)

## License

MIT
