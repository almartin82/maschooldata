# state-schooldata

## CRITICAL DATA SOURCE RULES

**NEVER use Urban Institute API, NCES CCD, or ANY federal data source** — the entire point of these packages is to provide STATE-LEVEL data directly from state DOEs. Federal sources aggregate/transform data differently and lose state-specific details. If a state DOE source is broken, FIX IT or find an alternative STATE source — do not fall back to federal data.

---

### CONCURRENT TASK LIMIT
- **Maximum 5 background tasks running simultaneously**
- When launching multiple agents (e.g., for mass audits), batch them in groups of 5
- Wait for the current batch to complete before launching the next batch

---

## Git Commits and PRs
- NEVER reference Claude, Claude Code, or AI assistance in commit messages
- NEVER reference Claude, Claude Code, or AI assistance in PR descriptions
- NEVER add Co-Authored-By lines mentioning Claude or Anthropic
- Keep commit messages focused on what changed, not how it was written

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

If CI fails, fix the issue and push - auto-merge triggers when checks pass.

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

---

## Fidelity Requirement

**tidy=TRUE MUST maintain fidelity to raw, unprocessed data:**
- Enrollment counts in tidy format must exactly match the wide format
- No rounding or transformation of counts during tidying
- Percentages are calculated fresh but counts are preserved
- State aggregates are sums of school-level data

---

## README Images from Vignettes (REQUIRED)

**NEVER use `man/figures/` or `generate_readme_figs.R` for README images.**

README images MUST come from pkgdown-generated vignette output so they auto-update on merge:

```markdown
![Chart name](https://almartin82.github.io/{package}/articles/{vignette}_files/figure-html/{chunk-name}-1.png)
```

**Why:** Vignette figures regenerate automatically when pkgdown builds. Manual `man/figures/` requires running a separate script and is easy to forget, causing stale/broken images.

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

- Wrong district/entity names (case sensitivity, typos)
- Text claims that contradict data
- Broken code that fails silently
- Missing data output
- Verified, accurate, reproducible examples

---

# maschooldata

## Data Source: Massachusetts Department of Education

**Enrollment Data:** Socrata API at educationtocareer.data.mass.gov
- Dataset: Enrollment by School (ID: 2b93-ctuo)
- Years Available: 2002-2025
- ID System: 8-digit codes (State=00000000, District=dist_code, School=org_code)

**Graduation Rate Data:** Socrata API at educationtocareer.data.mass.gov
- Dataset: High School Graduation Rates (ID: n2xa-p822)
- Years Available: 2006-2024 (19 years)
- Documentation: `/Users/almartin/Documents/state-schooldata/docs/MA-GRADUATION-RESEARCH.md`

## Graduation Rate Implementation

### Status
- [x] Stage 1: Research complete (2026-01-07)
- [ ] Stage 2: TDD - Write tests
- [ ] Stage 3: Implement functions
- [ ] Stage 4: Documentation and validation

### Schema
- **Years:** 2006-2024 (19 years)
- **Columns:** 15 (consistent across all years)
- **Graduation Types:** 4-Year Rate, 4-Year Adjusted Cohort, 5-Year Rate (2006-2022 only), 5-Year Adjusted Cohort (2006-2022 only)
- **Subgroups:** 16 categories (All Students, English Learners, High Needs, etc.)
- **ID Format:** 8-digit character codes (preserve leading zeros)

### Verified Test Values
- State 2024: 88.4% (0.884), cohort 73,046
- Boston 2024: 79.7% (0.797), cohort 3,711
- Boston Latin 2024: 98.7% (0.987), cohort 385

### API Query Examples
```r
# Get all 2024 data
url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024'&$limit=50000"

# Get state-level only
url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024' AND org_type='State'&$limit=50000"

# Get specific district
url <- "https://educationtocareer.data.mass.gov/resource/n2xa-p822.json?$where=sy='2024' AND dist_code='00350000'&$limit=50000"
```

### Implementation Notes
- Same pattern as enrollment (Socrata API)
- No new dependencies (httr, jsonlite, dplyr, tidyr)
- All values come as strings from JSON, need conversion
- Complexity: LOW (template exists from enrollment implementation)
