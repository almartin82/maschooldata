# ==============================================================================
# School Type Classification from MassGIS
# ==============================================================================
#
# This file provides functions to identify school types (charter, vocational,
# etc.) using the authoritative MassGIS Schools data layer.
#
# Data source: MassGIS Schools (Pre-K through High School)
# URL: https://www.mass.gov/info-details/massgis-data-massachusetts-schools-pre-k-through-high-school
#
# The TYPE field contains:
#   CHA = Charter
#   ELE = Public Elementary
#   MID = Public Middle
#   SEC = Public Secondary
#   VOC = Vocational/Technical/Agricultural
#   PRI = Private
#   SPE = Special Education (Approved)
#   SPU = Special Education (Unapproved)
#   OTH = Other
#
# ==============================================================================

#' MassGIS Schools shapefile URL
#' @keywords internal
MASSGIS_SCHOOLS_URL <- "https://s3.us-east-1.amazonaws.com/download.massgis.digital.mass.gov/shapefiles/state/schools.zip"

#' Get school type lookup table from MassGIS
#'
#' Downloads the MassGIS Schools shapefile and extracts a lookup table
#' mapping school codes (SCHID) to school types (TYPE).
#'
#' @param use_cache If TRUE (default), use cached data if available
#' @return Data frame with columns: school_id, school_type, school_name
#' @keywords internal
get_school_types <- function(use_cache = TRUE) {


  # Check for cached data


  cache_file <- file.path(tempdir(), "ma_school_types.rds")


  if (use_cache && file.exists(cache_file)) {
    cache_time <- file.info(cache_file)$mtime
    # Cache valid for 30 days
    if (difftime(Sys.time(), cache_time, units = "days") < 30) {
      return(readRDS(cache_file))
    }

  }


  # Download and extract shapefile

  temp_zip <- tempfile(fileext = ".zip")

  temp_dir <- tempfile()


  tryCatch({
    message("Downloading MassGIS Schools data...")
    utils::download.file(MASSGIS_SCHOOLS_URL, temp_zip, mode = "wb", quiet = TRUE)

    utils::unzip(temp_zip, exdir = temp_dir)

    # Find the DBF file (contains attribute data)
    dbf_file <- list.files(temp_dir, pattern = "\\.dbf$",
                           recursive = TRUE, full.names = TRUE)[1]

    if (is.na(dbf_file) || !file.exists(dbf_file)) {
      stop("Could not find DBF file in MassGIS Schools download")
    }

    # Read DBF file using foreign package
    schools <- foreign::read.dbf(dbf_file, as.is = TRUE)

    # Extract relevant columns
    school_types <- data.frame(
      school_id = schools$SCHID,
      school_type = schools$TYPE,
      school_name = schools$NAME,
      district_code = schools$DIST_CODE,
      stringsAsFactors = FALSE
    )

    # Cache the result
    saveRDS(school_types, cache_file)

    return(school_types)

  }, error = function(e) {
    warning("Failed to download MassGIS Schools data: ", e$message,
            "\nCharter school identification will not be available.")
    return(NULL)
  }, finally = {
    # Clean up temp files
    unlink(temp_zip)
    unlink(temp_dir, recursive = TRUE)
  })
}

#' Get charter school codes
#'
#' Returns a character vector of school codes (8-digit SCHID) for all
#' charter schools in Massachusetts.
#'
#' @param use_cache If TRUE (default), use cached data if available
#' @return Character vector of charter school codes
#' @export
#' @examples
#' \dontrun{
#' charter_codes <- get_charter_codes()
#' length(charter_codes)  # ~72 charter schools
#' }
get_charter_codes <- function(use_cache = TRUE) {
  school_types <- get_school_types(use_cache = use_cache)

  if (is.null(school_types)) {
    return(character(0))
  }

  school_types$school_id[school_types$school_type == "CHA"]
}

#' Get charter district codes
#'
#' Returns a character vector of district codes for all charter school
#' districts in Massachusetts. Charter schools operate as their own districts.
#'
#' @param use_cache If TRUE (default), use cached data if available
#' @return Character vector of charter district codes
#' @export
#' @examples
#' \dontrun{
#' charter_districts <- get_charter_district_codes()
#' }
get_charter_district_codes <- function(use_cache = TRUE) {
  school_types <- get_school_types(use_cache = use_cache)

  if (is.null(school_types)) {
    return(character(0))
  }

  charter_schools <- school_types[school_types$school_type == "CHA", ]

  # For schools with missing district_code, derive from school_id

  # District code = first 4 digits + "0000" (e.g., 35190205 -> 35190000)
  district_codes <- ifelse(
    is.na(charter_schools$district_code) | charter_schools$district_code == "",
    paste0(substr(charter_schools$school_id, 1, 4), "0000"),
    charter_schools$district_code
  )

  unique(district_codes)
}

#' Check if a school or district is a charter
#'
#' @param org_code Character vector of organization codes (8-digit)
#' @param use_cache If TRUE (default), use cached data if available
#' @return Logical vector indicating charter status
#' @keywords internal
is_charter_org <- function(org_code, use_cache = TRUE) {
  charter_codes <- get_charter_codes(use_cache = use_cache)
  charter_districts <- get_charter_district_codes(use_cache = use_cache)


  # Match both school codes and district codes
  org_code %in% c(charter_codes, charter_districts)
}
