# ==============================================================================
# Raw Enrollment Data Download Functions
# ==============================================================================
#
# This file contains functions for downloading raw enrollment data from
# Massachusetts DESE (Department of Elementary and Secondary Education).
#
# Data comes from DESE's enrollment reports at:
# https://www.doe.mass.edu/infoservices/reports/enroll/
#
# Format eras:
# - 2017-2020: Files use mixed case naming (District-GradeRace.xlsx)
# - 2021-2024: Files use lowercase with hyphens (district-grade-race.xlsx)
#
# File types downloaded:
# - district-grade-race.xlsx: District enrollment by grade and race/ethnicity
# - school-grade-race.xlsx: School enrollment by grade and race/ethnicity
# - special-populations.xlsx: Special populations (SPED, EL, Low Income, etc.)
#
# ==============================================================================

#' Download raw enrollment data from DESE
#'
#' Downloads district and school enrollment data from DESE's enrollment reports.
#'
#' @param end_year School year end (2023-24 = 2024). Valid years: 2017-2024.
#' @return List with district and school data frames
#' @keywords internal
get_raw_enr <- function(end_year) {

  # Validate year
  if (end_year < 2017 || end_year > 2024) {
    stop("end_year must be between 2017 and 2024. ",
         "Run get_available_years() to see available years.")
  }

  message(paste("Downloading DESE enrollment data for", end_year, "..."))

  # Download district and school race/grade data
  message("  Downloading district data...")
  district_race <- download_enrollment_file(end_year, "district", "race")

  message("  Downloading school data...")
  school_race <- download_enrollment_file(end_year, "school", "race")

  # Download special populations data (district level only)
  message("  Downloading special populations data...")
  special_pop <- download_special_populations(end_year)

  # Add end_year column
  district_race$end_year <- end_year
  school_race$end_year <- end_year
  if (!is.null(special_pop)) {
    special_pop$end_year <- end_year
  }

  list(
    district_race = district_race,
    school_race = school_race,
    special_pop = special_pop
  )
}


#' Build URL for enrollment file download
#'
#' Constructs the URL for a specific enrollment file based on year and type.
#' Handles different naming conventions across years.
#'
#' @param end_year School year end
#' @param level "district" or "school"
#' @param type "race", "gender", or "grade"
#' @return URL string
#' @keywords internal
build_enrollment_url <- function(end_year, level, type) {

  base_url <- "https://www.doe.mass.edu/InfoServices/reports/enroll"

  # Determine file naming convention based on year
  # 2017-2020: Mixed case (District-GradeRace.xlsx)
  # 2021+: Lowercase with hyphens (district-grade-race.xlsx)

  if (end_year <= 2020) {
    # Older format: Mixed case, no hyphen between grade and race
    if (level == "district") {
      prefix <- "District"
    } else {
      prefix <- "School"
    }

    if (type == "race") {
      filename <- paste0(prefix, "-GradeRace.xlsx")
    } else if (type == "gender") {
      filename <- paste0(prefix, "-GradeGender.xlsx")
    } else {
      filename <- paste0(prefix, "-Grade.xlsx")
    }

    # 2020 uses different capitalization
    if (end_year == 2020) {
      filename <- tolower(filename)
    }

  } else {
    # Newer format: All lowercase with hyphens
    if (type == "race") {
      filename <- paste0(level, "-grade-race.xlsx")
    } else if (type == "gender") {
      filename <- paste0(level, "-grade-gender.xlsx")
    } else {
      filename <- paste0(level, "-grade.xlsx")
    }
  }

  paste0(base_url, "/", end_year, "/", filename)
}


#' Download a single enrollment file
#'
#' @param end_year School year end
#' @param level "district" or "school"
#' @param type "race", "gender", or "grade"
#' @return Data frame with enrollment data
#' @keywords internal
download_enrollment_file <- function(end_year, level, type) {

  url <- build_enrollment_url(end_year, level, type)

  # Create temp file for download
  tname <- tempfile(
    pattern = paste0("ma_", level, "_", type, "_"),
    tmpdir = tempdir(),
    fileext = ".xlsx"
  )

  # Download with error handling
  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(tname, overwrite = TRUE),
      httr::timeout(120)
    )

    if (httr::http_error(response)) {
      stop(paste("HTTP error:", httr::status_code(response), "for URL:", url))
    }

    # Check file size (very small files likely error pages)
    file_info <- file.info(tname)
    if (file_info$size < 1000) {
      stop(paste("Downloaded file too small, likely an error page for year", end_year))
    }

  }, error = function(e) {
    stop(paste("Failed to download", level, type, "data for year", end_year,
               "\nURL:", url,
               "\nError:", e$message))
  })

  # Read Excel file - skip header rows
  df <- readxl::read_excel(
    tname,
    skip = 4,  # Skip header/title rows
    col_types = "text"  # Read all as text for safe processing
  )

  # Clean up temp file
  unlink(tname)

  df
}


#' Build URL for special populations file
#'
#' @param end_year School year end
#' @return URL string
#' @keywords internal
build_special_pop_url <- function(end_year) {

  base_url <- "https://www.doe.mass.edu/InfoServices/reports/enroll"

  # Naming convention changes by year
  if (end_year <= 2020) {
    if (end_year == 2020) {
      filename <- "specpopulations.xlsx"
    } else {
      filename <- "SpecPopulations.xlsx"
    }
  } else {
    filename <- "special-populations.xlsx"
  }

  paste0(base_url, "/", end_year, "/", filename)
}


#' Download special populations data
#'
#' @param end_year School year end
#' @return Data frame with special populations data, or NULL if not available
#' @keywords internal
download_special_populations <- function(end_year) {

  url <- build_special_pop_url(end_year)

  # Create temp file for download
  tname <- tempfile(
    pattern = "ma_special_pop_",
    tmpdir = tempdir(),
    fileext = ".xlsx"
  )

  # Download with error handling
  tryCatch({
    response <- httr::GET(
      url,
      httr::write_disk(tname, overwrite = TRUE),
      httr::timeout(120)
    )

    if (httr::http_error(response)) {
      warning(paste("Special populations data not available for year", end_year))
      return(NULL)
    }

    # Check file size
    file_info <- file.info(tname)
    if (file_info$size < 1000) {
      warning(paste("Special populations file too small for year", end_year))
      return(NULL)
    }

  }, error = function(e) {
    warning(paste("Failed to download special populations for year", end_year,
                  "\nError:", e$message))
    return(NULL)
  })

  # Read Excel file - skip header rows
  df <- readxl::read_excel(
    tname,
    skip = 4,
    col_types = "text"
  )

  # Clean up temp file
  unlink(tname)

  df
}
