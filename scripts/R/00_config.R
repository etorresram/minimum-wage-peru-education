# ==============================================================================
# 00_config.R
# Project: Minimum wages and workers by education level in Peru (ENAHO 2021-2025)
# Purpose: Central configuration, paths, constants, and helper functions.
# Author: replication package
# ==============================================================================
# This script is sourced by every other script. It defines paths, the verified
# minimum-wage schedule, the education-to-skill mapping, and small helpers.
# ------------------------------------------------------------------------------

suppressMessages({
  library(haven)
  library(data.table)
})

## ---- Paths -------------------------------------------------------------------
# Root is inferred so the package runs from any machine.
if (!exists("PROJ_ROOT")) {
  PROJ_ROOT <- normalizePath(file.path(dirname(sys.frame(1)$ofile %||% "."), "..", ".."),
                             mustWork = FALSE)
}
# Fallback: allow explicit override via environment variable.
if (!dir.exists(file.path(PROJ_ROOT, "scripts"))) {
  PROJ_ROOT <- Sys.getenv("MW_PROJ_ROOT",
                          ".")
}
RAW_ENAHO   <- Sys.getenv("MW_ENAHO_DIR",
                          file.path(PROJ_ROOT, "..", "Data", "ENAHO"))
DIR_PROC    <- file.path(PROJ_ROOT, "data", "processed")
DIR_INT     <- file.path(PROJ_ROOT, "data", "interim")
DIR_FIG     <- file.path(PROJ_ROOT, "figures")
DIR_TAB     <- file.path(PROJ_ROOT, "tables")
DIR_OUT     <- file.path(PROJ_ROOT, "output")
DIR_LOG     <- file.path(PROJ_ROOT, "logs")
for (d in c(DIR_PROC, DIR_INT, DIR_FIG, DIR_TAB, DIR_OUT, DIR_LOG)) {
  if (!dir.exists(d)) dir.create(d, recursive = TRUE, showWarnings = FALSE)
}

## ---- Verified minimum-wage schedule -----------------------------------------
# Source: D.S. 003-2022-TR (eff. 2022-05-01, S/930 -> S/1025) and
#         D.S. 006-2024-TR (eff. 2025-01-01, S/1025 -> S/1130).
# Verified against BCRP series PN02124PM (Remuneracion Minima Vital, MTPE).
mw_value <- function(year, month) {
  d <- as.Date(sprintf("%04d-%02d-01", year, month))
  data.table::fifelse(d < as.Date("2022-05-01"), 930,
    data.table::fifelse(d < as.Date("2025-01-01"), 1025, 1130))
}
REFORM_DATE    <- as.Date("2022-05-01")   # first reform inside the study window
REFORM_YEAR    <- 2022
REFORM_QUARTER <- 2                        # 2022Q2 is the first (partially) treated quarter
REF_EVENT_Q    <- "2022Q1"                 # omitted event-study reference quarter

## ---- Education (p301a) -> skill mapping --------------------------------------
# p301a coding VALIDATED against the data (weighted shares, ENAHO 2021):
#  1 No education | 2 Initial | 3 Primary incomplete | 4 Primary complete
#  5 Secondary incomplete | 6 Secondary complete
#  7 Higher non-univ. incomplete | 8 Higher non-univ. complete
#  9 University incomplete | 10 University complete | 11 Postgraduate
#  12 Special education (excluded, not orderable) | missing (excluded)
# Treatment (low-skilled): p301a in 1..6 ; Control (high-skilled): p301a in 7..11
EDU_LABELS <- c("1"="No education","2"="Initial","3"="Primary incomplete",
                "4"="Primary complete","5"="Secondary incomplete","6"="Secondary complete",
                "7"="Higher non-univ. incomplete","8"="Higher non-univ. complete",
                "9"="University incomplete","10"="University complete","11"="Postgraduate",
                "12"="Special education")
LOW_SKILL_CODES  <- 1:6
HIGH_SKILL_CODES <- 7:11

## ---- Sample restrictions -----------------------------------------------------
AGE_MIN <- 14L    # legal working age in Peru
AGE_MAX <- 65L    # standard upper bound for the working-age population
HOURS_MIN_WEEK <- 1     # minimum weekly hours to be counted as employed with hours
WAGE_WINSOR <- c(0.005, 0.995)  # trimming/winsorizing quantiles for wage outcomes

## ---- Small helpers -----------------------------------------------------------
`%||%` <- function(a, b) if (is.null(a)) b else a

# Robust numeric coercion for haven_labelled columns (some are stored as strings)
as_num <- function(x) {
  if (is.null(x)) return(NA_real_)
  x <- haven::zap_labels(x)
  if (is.character(x)) return(suppressWarnings(as.numeric(x)))
  as.numeric(x)
}

# Parse quarter from an ENAHO trimestral filename such as PER_T32024.dta -> 3
file_quarter <- function(f) as.integer(sub(".*PER_T([1-4]).*", "\\1", basename(f)))
file_year    <- function(f) as.integer(sub(".*PER_T[1-4](\\d{4}).*", "\\1", basename(f)))

# Winsorize a numeric vector at given probs (weighted-agnostic)
winsorize <- function(x, p = WAGE_WINSOR) {
  qs <- quantile(x, probs = p, na.rm = TRUE, type = 7)
  pmin(pmax(x, qs[1]), qs[2])
}

message("00_config.R loaded. PROJ_ROOT = ", PROJ_ROOT)
