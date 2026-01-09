### CONCURRENT TASK LIMIT
- **Maximum 5 background tasks running simultaneously**
- When launching multiple agents (e.g., for mass audits), batch them in groups of 5
- Wait for the current batch to complete before launching the next batch

---

## CRITICAL DATA SOURCE RULES

**NEVER use Urban Institute API, NCES CCD, or ANY federal data source** — the entire point of these packages is to provide STATE-LEVEL data directly from state DOEs. Federal sources aggregate/transform data differently and lose state-specific details. If a state DOE source is broken, FIX IT or find an alternative STATE source — do not fall back to federal data.

---

# Claude Code Instructions

### GIT COMMIT POLICY
- Commits are allowed
- NO Claude Code attribution, NO Co-Authored-By trailers, NO emojis
- Write normal commit messages as if a human wrote them

---

## Local Testing Before PRs (REQUIRED)

**PRs will not be merged until CI passes.** Run these checks locally BEFORE opening a PR:

### CI Checks That Must Pass

| Check | Local Command | What It Tests |
|-------|---------------|---------------|
| R-CMD-check | `devtools::check()` | Package builds, tests pass, no errors/warnings |
| Python tests | `pytest tests/test_pymaschooldata.py -v` | Python wrapper works correctly |
| pkgdown | `pkgdown::build_site()` | Documentation and vignettes render |

### Quick Commands

```r
# R package check (required)
devtools::check()

# Python tests (required)
system("pip install -e ./pymaschooldata && pytest tests/test_pymaschooldata.py -v")

# pkgdown build (required)
pkgdown::build_site()
```

### Pre-PR Checklist

Before opening a PR, verify:
- [ ] `devtools::check()` — 0 errors, 0 warnings
- [ ] `pytest tests/test_pymaschooldata.py` — all tests pass
- [ ] `pkgdown::build_site()` — builds without errors
- [ ] Vignettes render (no `eval=FALSE` hacks)

---

## LIVE Pipeline Testing

This package includes `tests/testthat/test-pipeline-live.R` with LIVE network tests.

### Test Categories:
1. URL Availability - HTTP 200 checks
2. File Download - Verify actual file (not HTML error)
3. File Parsing - readxl/readr succeeds
4. Column Structure - Expected columns exist
5. get_raw_enr() - Raw data function works
6. Data Quality - No Inf/NaN, non-negative counts
7. Aggregation - State total > 0
8. Output Fidelity - tidy=TRUE matches raw

### Running Tests:
```r
devtools::test(filter = "pipeline-live")
```

See `state-schooldata/CLAUDE.md` for complete testing framework documentation.

---

## Git Workflow (REQUIRED)

### Feature Branch + PR + Auto-Merge Policy

**NEVER push directly to main.** All changes must go through PRs with auto-merge:

```bash
# 1. Create feature branch
git checkout -b fix/description-of-change

# 2. Make changes, commit
git add -A
git commit -m "Fix: description of change"

# 3. Push and create PR with auto-merge
git push -u origin fix/description-of-change
gh pr create --title "Fix: description" --body "Description of changes"
gh pr merge --auto --squash

# 4. Clean up stale branches after PR merges
git checkout main && git pull && git fetch --prune origin
```

### Branch Cleanup (REQUIRED)

**Clean up stale branches every time you touch this package:**

```bash
# Delete local branches merged to main
git branch --merged main | grep -v main | xargs -r git branch -d

# Prune remote tracking branches
git fetch --prune origin
```

### Auto-Merge Requirements

PRs auto-merge when ALL CI checks pass:
- R-CMD-check (0 errors, 0 warnings)
- Python tests (if py{st}schooldata exists)
- pkgdown build (vignettes must render)

If CI fails, fix the issue and push - auto-merge will trigger when checks pass.

---

## README Images from Vignettes (REQUIRED)

**NEVER use `man/figures/` or `generate_readme_figs.R` for README images.**

README images MUST come from pkgdown-generated vignette output so they auto-update on merge:

```markdown
![Chart name](https://almartin82.github.io/{package}/articles/{vignette}_files/figure-html/{chunk-name}-1.png)
```

Example for maschooldata:
```markdown
![Charter enrollment](https://almartin82.github.io/maschooldata/articles/enrollment-trends_files/figure-html/charter-enrollment-1.png)
```

**Why:** Vignette figures regenerate automatically when pkgdown builds. Manual `man/figures/` requires running a separate script and is easy to forget, causing stale/broken images.

---

## Graduation Rate Data (Stage 1 Research Complete)

### Data Source: Socrata API
- **Dataset:** High School Graduation Rates (ID: n2xa-p822)
- **API Endpoint:** `https://educationtocareer.data.mass.gov/resource/n2xa-p822.json`
- **Years Available:** 2006-2024 (19 years)
- **HTTP Status:** 200 OK (verified 2026-01-07)
- **Documentation:** See `/Users/almartin/Documents/state-schooldata/docs/MA-GRADUATION-RESEARCH.md`

### Schema Details

**Column Names (consistent across all 19 years):**
- `sy` - School year end (e.g., "2024")
- `dist_code` - District code (8 digits, e.g., "00350000")
- `dist_name` - District name
- `org_code` - Organization code (8 digits)
- `org_name` - Organization name
- `org_type` - "State", "District", or "School"
- `grad_rate_type` - "4-Year Graduation Rate", "4-Year Adjusted Cohort", "5-Year Graduation Rate", "5-Year Adjusted Cohort"
- `stu_grp` - Student subgroup (16 categories)
- `cohort_cnt` - Cohort count
- `grad_pct` - Graduation percentage (decimal, e.g., 0.884 = 88.4%)
- `in_sch_pct` - Still in school percentage
- `non_grad_pct` - Non-graduate completers percentage
- `ged_pct` - GED percentage
- `drpout_pct` - Dropout percentage
- `exclud_pct` - Permanently excluded percentage

**Total Columns:** 15
**Schema Changes:** NONE - identical schema across all 19 years

### Graduation Rate Types

1. **4-Year Graduation Rate** (2006-2024) - Standard rate
2. **4-Year Adjusted Cohort Graduation Rate** (2006-2024) - Federal standard
3. **5-Year Graduation Rate** (2006-2022 only) - Discontinued after 2022
4. **5-Year Adjusted Cohort Graduation Rate** (2006-2022 only) - Discontinued after 2022

### Student Subgroups (16 categories)

All Students, American Indian or Alaska Native, Asian, Black or African American, English Learners, Female, Foster Care, High Needs, Hispanic or Latino, Homeless, Low Income, Male, Multi-Race Not Hispanic or Latino, Native Hawaiian or Other Pacific Islander, Students with Disabilities, White

### ID System

- **State:** `00000000`
- **District:** 8 digits (e.g., Boston = "00350000")
- **School:** 8 digits, composite of district + school (e.g., Boston Latin = "00350560")
- **All IDs must be character type** to preserve leading zeros

### Verified Data Values (for Tests)

**State-Level 4-Year Graduation Rates:**
- 2007: 80.9% (0.809), cohort 75,912
- 2018: 87.9% (0.879), cohort 74,641
- 2024: 88.4% (0.884), cohort 73,046

**Boston District (dist_code=00350000):**
- 2007: 57.9% (0.579), cohort 4,940
- 2024: 79.7% (0.797), cohort 3,711

**Boston Latin School (org_code=00350560):**
- 2024: 98.7% (0.987), cohort 385

### Implementation Status

- [x] Stage 1: Research complete (2026-01-07)
- [ ] Stage 2: TDD - Write tests (next step)
- [ ] Stage 3: Implement functions
- [ ] Stage 4: Documentation and validation

### Implementation Notes

- **Same pattern as enrollment:** Both use Socrata API at educationtocareer.data.mass.gov
- **No new dependencies:** Use existing httr, jsonlite, dplyr, tidyr
- **Data types:** All values come as strings from JSON, need conversion
- **Quality:** Excellent - no nulls, proper schema, consistent formatting
- **Complexity:** LOW - template exists from enrollment implementation

### Query Examples

```r
# Get all 2024 data
url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

# Get state-level only
url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024' AND org_type='State'&$limit=50000"

# Get specific district
url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024' AND dist_code='00350000'&$limit=50000"
```

### Full Research Documentation

See `/Users/almartin/Documents/state-schooldata/docs/MA-GRADUATION-RESEARCH.md` for complete research details including:
- Downloaded sample data for 5 years
- Cross-year comparison
- Data quality analysis
- Test values for fidelity tests
- API access patterns
- Tidy transformation schema

---

## README and Vignette Code Matching (REQUIRED)

**CRITICAL RULE (as of 2026-01-08):** ALL code blocks in the README MUST match code in a vignette EXACTLY (1:1 correspondence).

### Why This Matters

The Idaho fix revealed critical bugs when README code didn't match vignettes:
- Wrong district names (lowercase vs ALL CAPS)
- Text claims that contradicted actual data  
- Missing data output in examples

### README Story Structure (REQUIRED)

Every story/section in the README MUST follow this structure:

1. **Claim**: A factual statement about the data
2. **Explication**: Brief explanation of why this matters
3. **Code**: R code that fetches and analyzes the data (MUST exist in a vignette)
4. **Code Output**: Data table/print statement showing actual values (REQUIRED)
5. **Visualization**: Chart from vignette (auto-generated from pkgdown)

### Enforcement

The `state-deploy` skill verifies this before deployment:
- Extracts all README code blocks
- Searches vignettes for EXACT matches
- Fails deployment if code not found in vignettes
- Randomly audits packages for claim accuracy

### What This Prevents

- ❌ Wrong district/entity names (case sensitivity, typos)
- ❌ Text claims that contradict data
- ❌ Broken code that fails silently
- ❌ Missing data output
- ✅ Verified, accurate, reproducible examples

### Example

```markdown
### 1. State enrollment grew 28% since 2002

State added 68,000 students from 2002 to 2026, bucking national trends.

```r
library(arschooldata)
library(dplyr)

enr <- fetch_enr_multi(2002:2026)

enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students) %>%
  filter(end_year %in% c(2002, 2026)) %>%
  mutate(change = n_students - lag(n_students),
         pct_change = round((n_students / lag(n_students) - 1) * 100, 1))
# Prints: 2002=XXX, 2026=YYY, change=ZZZ, pct=PP.P%
```

![Chart](https://almartin82.github.io/arschooldata/articles/...)
```


---

## README and Vignette Code Matching (REQUIRED)

**CRITICAL RULE (as of 2026-01-08):** ALL code blocks in the README MUST match code in a vignette EXACTLY (1:1 correspondence).

### Why This Matters

The Idaho fix revealed critical bugs when README code didn't match vignettes:
- Wrong district names (lowercase vs ALL CAPS)
- Text claims that contradicted actual data  
- Missing data output in examples

### README Story Structure (REQUIRED)

Every story/section in the README MUST follow this structure:

1. **Claim**: A factual statement about the data
2. **Explication**: Brief explanation of why this matters
3. **Code**: R code that fetches and analyzes the data (MUST exist in a vignette)
4. **Code Output**: Data table/print statement showing actual values (REQUIRED)
5. **Visualization**: Chart from vignette (auto-generated from pkgdown)

### Enforcement

The `state-deploy` skill verifies this before deployment:
- Extracts all README code blocks
- Searches vignettes for EXACT matches
- Fails deployment if code not found in vignettes
- Randomly audits packages for claim accuracy

### What This Prevents

- ❌ Wrong district/entity names (case sensitivity, typos)
- ❌ Text claims that contradict data
- ❌ Broken code that fails silently
- ❌ Missing data output
- ✅ Verified, accurate, reproducible examples

### Example

```markdown
### 1. State enrollment grew 28% since 2002

State added 68,000 students from 2002 to 2026, bucking national trends.

```r
library(idschooldata)
library(dplyr)

enr <- fetch_enr_multi(2002:2026)

enr %>%
  filter(is_state, subgroup == "total_enrollment", grade_level == "TOTAL") %>%
  select(end_year, n_students) %>%
  filter(end_year %in% c(2002, 2026)) %>%
  mutate(change = n_students - lag(n_students),
         pct_change = round((n_students / lag(n_students) - 1) * 100, 1))
# Prints: 2002=XXX, 2026=YYY, change=ZZZ, pct=PP.P%
```

![Chart](https://almartin82.github.io/idschooldata/articles/...)
```

