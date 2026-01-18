# maschooldata

**[Documentation](https://almartin82.github.io/maschooldata/)** \|
**[Getting
Started](https://almartin82.github.io/maschooldata/articles/enrollment-trends.html)**

Fetch and analyze Massachusetts school enrollment and graduation data
from the Department of Elementary and Secondary Education (DESE) in R or
Python.

## Why maschooldata?

Massachusetts publishes detailed school data through their
[Education-to-Career Research and Data
Hub](https://educationtocareer.data.mass.gov/), but working with Socrata
APIs and understanding data structures takes time. This package gives
you a clean, consistent interface to 30+ years of enrollment data and 19
years of graduation rates - all with a single function call.

Part of the [njschooldata](https://github.com/almartin82/njschooldata)
family of state education data packages, providing consistent interfaces
for accessing state DOE data across all 50 states.

## What can you find with maschooldata?

**30+ years of enrollment data (1994-2024).** 915,000 students today.
Over 400 districts. Here are eighteen stories hiding in the numbers:

------------------------------------------------------------------------

### 1. Boston’s slow decline

Boston Public Schools has lost over 17,000 students since 2000. Today it
enrolls around 46,000.

``` r
library(maschooldata)
library(dplyr)

enr <- fetch_enr_multi(c(2000, 2005, 2010, 2015, 2020, 2024), use_cache = TRUE)

enr %>%
  filter(is_district, district_id == "0035",
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
#>   end_year district_name n_students
#> 1     2000        Boston      62950
#> 2     2005        Boston      57742
#> 3     2010        Boston      55371
#> 4     2015        Boston      54312
#> 5     2020        Boston      50480
#> 6     2024        Boston      45742
```

![Boston
decline](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/boston-decline-1.png)

Boston decline

------------------------------------------------------------------------

### 2. Gateway Cities under pressure

Springfield, Worcester, and Lowell - Massachusetts’ “Gateway Cities” -
have seen different enrollment trajectories.

``` r
gateway <- c("0281", "0348", "0160")  # Springfield, Worcester, Lowell

enr %>%
  filter(is_district, district_id %in% gateway,
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
#>    end_year district_name n_students
#> 1      2000        Lowell      14239
#> 2      2000   Springfield      25918
#> 3      2000     Worcester      24625
#> 4      2005        Lowell      14051
#> 5      2005   Springfield      25975
#> 6      2005     Worcester      24085
#> 7      2010        Lowell      13897
#> 8      2010   Springfield      25141
#> 9      2010     Worcester      23837
#> 10     2015        Lowell      14185
#> 11     2015   Springfield      25645
#> 12     2015     Worcester      24756
#> 13     2020        Lowell      14256
#> 14     2020   Springfield      25007
#> 15     2020     Worcester      24693
#> 16     2024        Lowell      14274
#> 17     2024   Springfield      23693
#> 18     2024     Worcester      24350
```

![Gateway
cities](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/gateway-cities-1.png)

Gateway cities

------------------------------------------------------------------------

### 3. Massachusetts is diversifying fast

The state has gone from over 70% white to under 55% white in 25 years.
Hispanic students now exceed 25%.

``` r
enr <- fetch_enr_multi(c(2000, 2010, 2020, 2024), use_cache = TRUE)

enr %>%
  filter(is_state, grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(end_year, subgroup, n_students, pct)
#>    end_year  subgroup n_students  pct
#> 1      2000     asian      40287  4.2
#> 2      2000     black      79406  8.2
#> 3      2000  hispanic      98181 10.2
#> 4      2000     white    711046 73.7
#> 5      2010     asian      50691  5.3
#> 6      2010     black      81458  8.5
#> 7      2010  hispanic    139606 14.6
#> 8      2010     white    628251 65.6
#> 9      2020     asian      63424  6.8
#> 10     2020     black      84120  9.1
#> 11     2020  hispanic    210668 22.7
#> 12     2020     white    508665 54.8
#> 13     2024     asian      67707  7.4
#> 14     2024     black      87836  9.6
#> 15     2024  hispanic    229655 25.1
#> 16     2024     white    484928 53.0
```

![Demographic
shift](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/demographics-shift-1.png)

Demographic shift

------------------------------------------------------------------------

### 4. The Cape and Islands are graying

Barnstable County (Cape Cod) and the Islands have seen steep enrollment
declines as families can’t afford housing.

``` r
enr_2024 <- fetch_enr(2024, use_cache = TRUE)

# Find Cape districts
enr_2024 %>%
  filter(is_district, grade_level == "TOTAL", subgroup == "total_enrollment",
         grepl("Barnstable|Chatham|Dennis|Falmouth|Mashpee|Orleans|Provincetown", district_name)) %>%
  select(district_name, n_students)
#>         district_name n_students
#> 1          Barnstable       4026
#> 2             Chatham        347
#> 3 Dennis-Yarmouth Reg       2609
#> 4            Falmouth       2700
#> 5             Mashpee       1425
#> 6          Nauset Reg       1445
#> 7       Provincetown         113
```

![Cape
decline](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/cape-decline-1.png)

Cape decline

------------------------------------------------------------------------

### 5. COVID crushed kindergarten

Kindergarten enrollment dropped significantly during the pandemic and
hasn’t fully recovered.

``` r
enr <- fetch_enr_multi(2018:2024, use_cache = TRUE)

enr %>%
  filter(is_state, subgroup == "total_enrollment",
         grade_level %in% c("K", "01", "06", "12")) %>%
  select(end_year, grade_level, n_students)
#>    end_year grade_level n_students
#> 1      2018           K      68958
#> 2      2018          01      71026
#> 3      2018          06      68706
#> 4      2018          12      67800
#> 5      2019           K      68197
#> 6      2019          01      70048
#> 7      2019          06      69143
#> 8      2019          12      68169
#> 9      2020           K      60689
#> 10     2020          01      67709
#> 11     2020          06      69068
#> 12     2020          12      67912
#> 13     2021           K      57994
#> 14     2021          01      62527
#> 15     2021          06      67892
#> 16     2021          12      69126
#> 17     2022           K      62215
#> 18     2022          01      60813
#> 19     2022          06      67584
#> 20     2022          12      70110
#> 21     2023           K      62050
#> 22     2023          01      63702
#> 23     2023          06      66584
#> 24     2023          12      72239
#> 25     2024           K      61846
#> 26     2024          01      64297
#> 27     2024          06      66913
#> 28     2024          12      68770
```

![COVID
kindergarten](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/covid-kindergarten-1.png)

COVID kindergarten

------------------------------------------------------------------------

### 6. Charter schools serving 45,000+ students

Massachusetts charter enrollment has grown steadily, especially in urban
areas.

``` r
enr_2024 %>%
  filter(is_charter, is_campus, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  summarize(
    total_charter = sum(n_students, na.rm = TRUE),
    n_schools = n()
  )
#>   total_charter n_schools
#> 1         45742        75
```

![Charter
enrollment](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/charter-enrollment-1.png)

Charter enrollment

------------------------------------------------------------------------

### 7. Over 40% of students are low-income

The “economically disadvantaged” indicator shows persistent need across
the state.

``` r
enr <- fetch_enr_multi(2015:2024, use_cache = TRUE)

enr %>%
  filter(is_state, subgroup == "econ_disadv", grade_level == "TOTAL") %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(end_year, n_students, pct)
#>   end_year n_students  pct
#> 1     2015     300814 31.5
#> 2     2016     307055 32.1
#> 3     2017     305117 32.0
#> 4     2018     305915 32.1
#> 5     2019     311478 32.6
#> 6     2020     340403 36.7
#> 7     2021     381612 42.0
#> 8     2022     384044 41.8
#> 9     2023     391248 42.0
#> 10    2024     385697 42.2
```

![Economic
disadvantage](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/econ-disadvantage-1.png)

Economic disadvantage

------------------------------------------------------------------------

### 8. English learners are concentrated in cities

Over 13% of students statewide are English learners, but in some
districts it’s 30%+.

``` r
enr_2024 %>%
  filter(is_district, subgroup == "lep", grade_level == "TOTAL") %>%
  arrange(desc(pct)) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(district_name, n_students, pct) %>%
  head(10)
#>                                              district_name n_students  pct
#> 1                                                  Chelsea       4403 53.7
#> 2                                                  Lawrence       7929 51.9
#> 3                         Lowell Community Charter Public         317 38.8
#> 4                                                   Revere       3125 38.1
#> 5                                               Framingham       3126 33.4
#> 6                                                    Salem       1418 32.4
#> 7                                                Somerville       1483 31.7
#> 8                                                 Brockton       4716 30.5
#> 9                                                   Malden       1884 30.5
#> 10 Pioneer Valley Chinese Immersion Charter (District)        284 30.0
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

enr <- fetch_enr_multi(2015:2024, use_cache = TRUE)

enr %>%
  filter(is_district, district_id %in% suburbs,
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, district_name, n_students)
#>    end_year district_name n_students
#> 1      2015     Lexington       7026
#> 2      2015        Newton      12805
#> 3      2015     Wellesley       4903
#> 4      2016     Lexington       7180
#> 5      2016        Newton      12941
#> 6      2016     Wellesley       4878
#> 7      2017     Lexington       7310
#> 8      2017        Newton      12862
#> 9      2017     Wellesley       4817
#> 10     2018     Lexington       7346
#> 11     2018        Newton      12748
#> 12     2018     Wellesley       4808
#> 13     2019     Lexington       7363
#> 14     2019        Newton      12704
#> 15     2019     Wellesley       4746
#> 16     2020     Lexington       7258
#> 17     2020        Newton      12395
#> 18     2020     Wellesley       4582
#> 19     2021     Lexington       7032
#> 20     2021        Newton      11941
#> 21     2021     Wellesley       4467
#> 22     2022     Lexington       6868
#> 23     2022        Newton      11854
#> 24     2022     Wellesley       4457
#> 25     2023     Lexington       6906
#> 26     2023        Newton      12086
#> 27     2023     Wellesley       4476
#> 28     2024     Lexington       6879
#> 29     2024        Newton      12131
#> 30     2024     Wellesley       4457
```

![Suburban
stability](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/suburban-stable-1.png)

Suburban stability

------------------------------------------------------------------------

### 10. Regional school districts dominate rural Massachusetts

Over 50 regional districts serve students from multiple towns, a
uniquely Massachusetts approach.

``` r
enr_2024 %>%
  filter(is_district, grepl("Regional", district_name),
         subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students)) %>%
  select(district_name, n_students) %>%
  head(10)
#>                                            district_name n_students
#> 1       Southeastern Regional Vocational Technical              1586
#> 2                     Greater New Bedford Regional Voc Tech    1568
#> 3  Southern Worcester County Regional Vocational             1193
#> 4                     Silver Lake Regional School District    2689
#> 5                                      Nashoba Regional     3350
#> 6                        Assabet Valley Regional Voc Tech    1054
#> 7                     Shawsheen Valley Regional Voc Tech    1355
#> 8                                  Pentucket Regional     2890
#> 9                                   Masconomet Regional     2256
#> 10                          King Philip Regional          2937
```

![Regional
districts](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/regional-districts-1.png)

Regional districts

------------------------------------------------------------------------

### 11. Springfield’s demographic transformation

Springfield, the state’s third-largest district, has seen Hispanic
students become the majority over the past decade.

``` r
enr <- fetch_enr_multi(2016:2024, use_cache = TRUE)

enr %>%
  filter(is_district, district_id == "0281", grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(end_year, subgroup, pct)
#>    end_year  subgroup  pct
#> 1      2016     asian  2.6
#> 2      2016     black 21.8
#> 3      2016  hispanic 64.9
#> 4      2016     white  8.7
#> 5      2017     asian  2.8
#> 6      2017     black 21.2
#> 7      2017  hispanic 65.6
#> 8      2017     white  8.4
#> 9      2018     asian  2.8
#> 10     2018     black 20.9
#> 11     2018  hispanic 66.5
#> 12     2018     white  7.6
#> 13     2019     asian  2.8
#> 14     2019     black 20.2
#> 15     2019  hispanic 67.5
#> 16     2019     white  7.3
#> 17     2020     asian  2.9
#> 18     2020     black 18.9
#> 19     2020  hispanic 69.4
#> 20     2020     white  6.6
#> 21     2021     asian  2.7
#> 22     2021     black 18.5
#> 23     2021  hispanic 70.7
#> 24     2021     white  5.9
#> 25     2022     asian  2.8
#> 26     2022     black 18.3
#> 27     2022  hispanic 71.1
#> 28     2022     white  5.5
#> 29     2023     asian  3.0
#> 30     2023     black 17.9
#> 31     2023  hispanic 71.3
#> 32     2023     white  5.4
#> 33     2024     asian  3.1
#> 34     2024     black 17.7
#> 35     2024  hispanic 71.5
#> 36     2024     white  5.3
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
#>   end_year district_name n_students
#> 1     2016    Fall River      10090
#> 2     2016   New Bedford      12735
#> 3     2017    Fall River      10086
#> 4     2017   New Bedford      12696
#> 5     2018    Fall River       9973
#> 6     2018   New Bedford      12605
#> 7     2019    Fall River       9839
#> 8     2019   New Bedford      12506
#> 9     2020    Fall River       9673
#> 10    2020   New Bedford      12209
#> 11    2021    Fall River       9386
#> 12    2021   New Bedford      11844
#> 13    2022    Fall River       9282
#> 14    2022   New Bedford      11785
#> 15    2023    Fall River       9225
#> 16    2023   New Bedford      11752
#> 17    2024    Fall River       9152
#> 18    2024   New Bedford      11671
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
#>   end_year district_name n_students
#> 1     2016       Grafton       2929
#> 2     2016    Shrewsbury       6008
#> 3     2016   Westborough       2571
#> 4     2017       Grafton       2972
#> 5     2017    Shrewsbury       6097
#> 6     2017   Westborough       2548
#> 7     2018       Grafton       3024
#> 8     2018    Shrewsbury       6052
#> 9     2018   Westborough       2528
#> 10    2019       Grafton       3063
#> 11    2019    Shrewsbury       6104
#> 12    2019   Westborough       2540
#> 13    2020       Grafton       3037
#> 14    2020    Shrewsbury       6061
#> 15    2020   Westborough       2528
#> 16    2021       Grafton       2928
#> 17    2021    Shrewsbury       5885
#> 18    2021   Westborough       2439
#> 19    2022       Grafton       2926
#> 20    2022    Shrewsbury       5817
#> 21    2022   Westborough       2448
#> 22    2023       Grafton       2944
#> 23    2023    Shrewsbury       5777
#> 24    2023   Westborough       2479
#> 25    2024       Grafton       2965
#> 26    2024    Shrewsbury       5652
#> 27    2024   Westborough       2476
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
#> # A tibble: 9 x 2
#>   end_year total
#>      <dbl> <dbl>
#> 1     2016  8411
#> 2     2017  8358
#> 3     2018  8262
#> 4     2019  8144
#> 5     2020  7962
#> 6     2021  7620
#> 7     2022  7500
#> 8     2023  7445
#> 9     2024  7413
```

![Western MA
decline](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/western-ma-decline-1.png)

Western MA decline

------------------------------------------------------------------------

### 15. Special education rates vary widely by district

Some districts identify nearly 25% of students for special education
services, while others are under 15%.

``` r
enr_2024 %>%
  filter(is_district, subgroup == "sped", grade_level == "TOTAL") %>%
  arrange(desc(pct)) %>%
  mutate(pct = round(pct * 100, 1)) %>%
  select(district_name, n_students, pct) %>%
  head(15)
#>                                     district_name n_students  pct
#> 1                         Lowell Middlesex Academy       106 100.0
#> 2                   Phoenix Academy Springfield         159 100.0
#> 3                            Springfield Intl Charter     416 28.1
#> 4                                Greenfield          1088 27.3
#> 5                            North Adams            546 26.0
#> 6                                  Orange             268 25.7
#> 7                                 Athol-Royalston      557 24.8
#> 8                                 Ware              461 24.5
#> 9              Gill-Montague Regional               383 24.5
#> 10             Gateway Regional School District     342 24.2
#> 11                                    Palmer        576 23.6
#> 12                                 Southbridge      479 23.4
#> 13                                     Ayer         498 23.3
#> 14                          Mohawk Trail Regional     372 23.3
#> 15                                   Somerset       649 22.9
```

![SPED
rates](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/sped-gender-1.png)

SPED rates

------------------------------------------------------------------------

### 16. Four-year graduation rates improving statewide

Massachusetts’ 4-year graduation rate has climbed from 80% in 2006 to
88% in 2024, with persistent gaps by race and income.

``` r
library(maschooldata)
library(dplyr)

grad <- fetch_graduation_multi(2006:2024, use_cache = TRUE)

grad %>%
  filter(is_state, subgroup == "all", cohort_type == "4-year") %>%
  select(end_year, grad_rate, cohort_count) %>%
  mutate(rate_pct = round(grad_rate * 100, 1))
#>    end_year grad_rate cohort_count rate_pct
#> 1      2006     0.799        74380     79.9
#> 2      2007     0.809        75912     80.9
#> 3      2008     0.816        75086     81.6
#> 4      2009     0.816        74574     81.6
#> 5      2010     0.827        75107     82.7
#> 6      2011     0.834        75193     83.4
#> 7      2012     0.847        73483     84.7
#> 8      2013     0.854        72704     85.4
#> 9      2014     0.860        71999     86.0
#> 10     2015     0.869        71700     86.9
#> 11     2016     0.877        73120     87.7
#> 12     2017     0.879        74174     87.9
#> 13     2018     0.879        74641     87.9
#> 14     2019     0.882        73813     88.2
#> 15     2020     0.890        72779     89.0
#> 16     2021     0.897        72024     89.7
#> 17     2022     0.895        70954     89.5
#> 18     2023     0.891        72152     89.1
#> 19     2024     0.884        73046     88.4
```

![Graduation
trend](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/graduation-trend-1.png)

Graduation trend

------------------------------------------------------------------------

### 17. Urban-suburban graduation gaps persist

Boston (80%) trails Newton (95%) by 15 percentage points, reflecting
opportunity gaps across the state.

``` r
grad_2024 <- fetch_graduation(2024, use_cache = TRUE)

grad_2024 %>%
  filter(is_district,
         district_name %in% c("Boston", "Springfield", "Worcester", "Newton"),
         subgroup == "all",
         cohort_type == "4-year") %>%
  select(district_name, grad_rate, cohort_count) %>%
  mutate(rate_pct = round(grad_rate * 100, 1))
#>   district_name grad_rate cohort_count rate_pct
#> 1        Boston     0.797         3711     79.7
#> 2        Newton     0.954          963     95.4
#> 3   Springfield     0.786         1841     78.6
#> 4     Worcester     0.860         1990     86.0
```

![Urban-suburban
graduation](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/urban-suburban-grad-1.png)

Urban-suburban graduation

------------------------------------------------------------------------

### 18. Special populations face graduation challenges

English learners (67%) and students with disabilities (75%) graduate at
lower rates than peers.

``` r
grad_2024 %>%
  filter(is_state,
         subgroup %in% c("english_learner", "special_ed", "low_income"),
         cohort_type == "4-year") %>%
  select(subgroup, grad_rate, cohort_count) %>%
  mutate(rate_pct = round(grad_rate * 100, 1))
#>          subgroup grad_rate cohort_count rate_pct
#> 1      special_ed     0.754        15039     75.4
#> 2      low_income     0.816        39276     81.6
#> 3 english_learner     0.667         7194     66.7
```

![Special population
graduation](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/special-pop-grad-1.png)

Special population graduation

------------------------------------------------------------------------

## Installation

### R

``` r
# install.packages("remotes")
remotes::install_github("almartin82/maschooldata")
```

``` r
library(maschooldata)
library(dplyr)

# Fetch one year
enr_2024 <- fetch_enr(2024)

# Fetch multiple years
enr_multi <- fetch_enr_multi(2020:2024)

# State totals
enr_2024 %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL")

# District breakdown
enr_2024 %>%
  filter(is_district, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  arrange(desc(n_students))

# Boston demographics
enr_2024 %>%
  filter(district_id == "0035", grade_level == "TOTAL",
         subgroup %in% c("white", "black", "hispanic", "asian")) %>%
  select(subgroup, n_students, pct)
```

### Python

``` python
import pymaschooldata as ma

# Fetch 2024 data (2023-24 school year)
enr = ma.fetch_enr(2024)

# Statewide total
total = enr[(enr['is_state']) & (enr['grade_level'] == 'TOTAL') &
            (enr['subgroup'] == 'total_enrollment')]['n_students'].sum()
print(f"{total:,} students")
#> 914,959 students

# Get multiple years
enr_multi = ma.fetch_enr_multi([2020, 2021, 2022, 2023, 2024])

# Check available years
years = ma.get_available_years()
print(f"Data available: {years['min_year']}-{years['max_year']}")
#> Data available: 1994-2024

# Fetch graduation rates
grad = ma.fetch_graduation(2024)

# State graduation rate
state_rate = grad[(grad['is_state']) & (grad['subgroup'] == 'all') &
                  (grad['cohort_type'] == '4-year')]['grad_rate'].values[0]
print(f"State graduation rate: {state_rate * 100:.1f}%")
#> State graduation rate: 88.4%

# Get multiple years of graduation data
grad_multi = ma.fetch_graduation_multi([2020, 2021, 2022, 2023, 2024])
```

## Data availability

| Data Type            | Years     | Source           | Notes                               |
|----------------------|-----------|------------------|-------------------------------------|
| **Enrollment**       | 1994-2024 | DESE Socrata API | 30+ years of consistent data        |
| **Graduation rates** | 2006-2024 | DESE Socrata API | 4-year and 5-year rates by subgroup |

Data is accessed via the Massachusetts Education-to-Career Research and
Data Hub: - Enrollment:
<https://educationtocareer.data.mass.gov/d/t8td-gens> - Graduation:
<https://educationtocareer.data.mass.gov/d/n2xa-p822>

### What’s included

#### Enrollment data

- **Levels:** State, District (400+), School (1,800+)
- **Demographics:** White, Black, Hispanic, Asian, Native American,
  Pacific Islander (1998+), Multiracial (2003+)
- **Special populations:** Students with disabilities, English learners,
  Low income / Economically disadvantaged
- **Grade levels:** PK through 12, plus SPED beyond Grade 12

#### Graduation rate data

- **Levels:** State, District, School
- **Cohort types:** 4-year, 5-year graduation rates
- **Subgroups:** All students, race/ethnicity, gender, English learners,
  special education, low income, high needs
- **Outcomes:** Graduation rate, cohort count, still in school, GED,
  dropout, non-graduate completers

### Data Notes

**Data source:** [Massachusetts Department of Elementary and Secondary
Education (DESE)](https://www.doe.mass.edu/)

**Suppression rules:** Small counts may be suppressed to protect student
privacy.

**Economic indicator changes:** - Pre-2015: “Low Income” (free/reduced
lunch) - 2015-2021: “Economically Disadvantaged” (new definition) -
2022+: “Low Income” (reverted terminology)

**Census Day:** Data reflects October 1 enrollment counts.

**Charter schools:** Included with charter flag for filtering.
District-level charter totals use special district codes.

**Regional districts:** Many multi-town districts exist with “Regional”
in name, especially for vocational-technical schools.

### Massachusetts-specific notes

- **District IDs:** 4-digit codes (e.g., 0035 = Boston)
- **School IDs:** 8-digit codes (district + school)

## Part of the State Schooldata Project

A simple, consistent interface for accessing state-published school data
in Python and R.

**All 50 state packages:**
[github.com/almartin82](https://github.com/almartin82?tab=repositories&q=schooldata)

## Author

[Andy Martin](https://github.com/almartin82) (<almartin@gmail.com>)

## License

MIT
