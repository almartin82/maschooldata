#' maschooldata: Fetch and Process Massachusetts School Data
#'
#' Downloads and processes school data from the Massachusetts Department of
#' Elementary and Secondary Education (DESE). Provides functions for fetching
#' enrollment data from SIMS (Student Information Management System) and
#' transforming it into tidy format for analysis.
#'
#' @section Main functions:
#' \describe{
#'   \item{\code{\link{fetch_enr}}}{Fetch enrollment data for a school year}
#'   \item{\code{\link{fetch_enr_multi}}}{Fetch enrollment data for multiple years}
#'   \item{\code{\link{tidy_enr}}}{Transform wide data to tidy (long) format}
#'   \item{\code{\link{id_enr_aggs}}}{Add aggregation level flags}
#'   \item{\code{\link{enr_grade_aggs}}}{Create grade-level aggregations}
#'   \item{\code{\link{get_available_years}}}{List available data years}
#' }
#'
#' @section Cache functions:
#' \describe{
#'   \item{\code{\link{cache_status}}}{View cached data files}
#'   \item{\code{\link{clear_cache}}}{Remove cached data files}
#' }
#'
#' @section ID System:
#' Massachusetts uses a hierarchical ID system:
#' \itemize{
#'   \item District IDs: 4 digits (e.g., 0350 = Boston)
#'   \item School IDs: 8 digits (district ID + 4-digit school number, e.g., 03500010)
#' }
#'
#' @section Data Sources:
#' Data is sourced from the Massachusetts DESE website:
#' \itemize{
#'   \item Enrollment Reports: \url{https://www.doe.mass.edu/infoservices/reports/enroll/}
#'   \item SIMS: \url{https://www.doe.mass.edu/InfoServices/data/sims/}
#'   \item School Profiles: \url{https://profiles.doe.mass.edu/}
#' }
#'
#' @section Data Availability:
#' \itemize{
#'   \item Excel downloads: 2017-2024 (school years 2016-17 through 2023-24)
#'   \item Profiles system: 2000-2025 (enrollment by race/gender reports)
#' }
#'
#' @docType package
#' @name maschooldata-package
#' @aliases maschooldata
#' @keywords internal
"_PACKAGE"

#' Pipe operator
#'
#' See \code{magrittr::\link[magrittr:pipe]{\%>\%}} for details.
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom dplyr %>%
#' @usage lhs \%>\% rhs
#' @param lhs A value or the magrittr placeholder.
#' @param rhs A function call using the magrittr semantics.
#' @return The result of calling `rhs(lhs)`.
NULL
