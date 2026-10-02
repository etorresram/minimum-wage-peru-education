# ==============================================================================
# 14_sdid.R
# Purpose: Synthetic difference-in-differences (Arkhangelsky et al. 2021) at the
#   department level. Treated units = high-bite departments (above-median
#   pre-reform fraction of private wage earners below the new floor); the
#   synthetic control re-weights low-bite departments to match the treated
#   group's pre-reform levels and trends. Outcomes are department x quarter
#   weighted means for LOW-EDUCATION workers, and the low-minus-high skill gap
#   (the gap version nets out department-wide shocks common to both groups).
#   The partially treated 2022Q2 is excluded; post = 2022Q3 onward.
#   Standard errors: jackknife of Arkhangelsky et al. (2021) (the placebo
#   variance is infeasible here: 12 treated vs 13 control units leaves no room
#   to resample placebo treatment assignments).
# Output: output/sdid_results.csv
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "."),
        "scripts", "R", "00_config.R"))
suppressMessages({library(synthdid)})
set.seed(20220501)

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
D  <- DT[in_window==1 & working_age==1 & !is.na(skill) & transition==0]

OUTS <- list(
  list(y="log_wage_hr", lab="Log hourly wage", flt=quote(wage_valid==1)),
  list(y="employed",    lab="Employment",      flt=quote(rep(TRUE,.N))),
  list(y="formal",      lab="Formal empl.",    flt=quote(employed==1 & public_sector==0)),
  list(y="self_emp",    lab="Self-employment", flt=quote(employed==1 & public_sector==0)))

run_sdid <- function(o, mode) {
  d <- D[eval(o$flt)]
  if (mode == "low_only") {
    cell <- d[low==1, .(y=weighted.mean(get(o$y), fac500a, na.rm=TRUE)),
              by=.(region, t_index, high_bite)]
  } else {  # skill gap: low mean minus high mean, per region x quarter
    cell <- d[, .(y=weighted.mean(get(o$y), fac500a, na.rm=TRUE)),
              by=.(region, t_index, high_bite, low)]
    cell <- dcast(cell, region + t_index + high_bite ~ low, value.var="y")
    setnames(cell, c("0","1"), c("y_high","y_low"))
    cell <- cell[!is.na(y_low) & !is.na(y_high)][, y := y_low - y_high]
  }
  # balanced panel required
  full <- cell[, .N, by=region][N == uniqueN(cell$t_index)]$region
  cell <- cell[region %in% full]
  cell[, treated := as.integer(high_bite==1 & t_index >= 7)]
  pm <- synthdid::panel.matrices(as.data.frame(cell[, .(region, t_index, y, treated)]),
                                 unit="region", time="t_index",
                                 outcome="y", treatment="treated")
  est <- synthdid::synthdid_estimate(pm$Y, pm$N0, pm$T0)
  se  <- tryCatch(sqrt(as.numeric(vcov(est, method="jackknife"))),
                  error=function(e) NA_real_)
  data.table(outcome=o$lab, mode=mode, n_regions=length(full),
             att=as.numeric(est), se=as.numeric(se),
             p=2*pnorm(-abs(as.numeric(est)/as.numeric(se))))
}

res <- rbindlist(lapply(OUTS, function(o)
  rbind(run_sdid(o, "low_only"), run_sdid(o, "skill_gap"))))
fwrite(res, file.path(DIR_OUT, "sdid_results.csv"))
cat("==== Synthetic DiD (high-bite vs synthetic low-bite departments) ====\n")
print(res[, .(outcome, mode, n_regions, att=round(att,4), se=round(se,4), p=round(p,4))])
cat("\nDone: 14_sdid.R\n")
