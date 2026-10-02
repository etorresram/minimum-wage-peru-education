# ==============================================================================
# 17_pretest_power.R
# Purpose: Power of the pre-trends test (Roth 2022, AER: Insights), using the
#   'pretrends' package. For each headline event study, compute the slope of a
#   LINEAR violation of parallel trends against which the conventional
#   pre-test would only have 50% and 80% power, and the bias in the average
#   post-period effect that such an undetected violation would imply. This
#   quantifies how much confounding could hide behind a "passed" pre-test.
# Output: output/pretest_power.csv
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "."),
        "scripts", "R", "00_config.R"))
suppressMessages({library(fixest); library(pretrends)})

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
D  <- DT[in_window==1 & working_age==1 & !is.na(skill) & transition==0]
CTRL <- "age+age2+female+married+urban+years_educ"

OUTS <- list(
  list(y="log_wage_hr", lab="Log hourly wage", flt=quote(wage_valid==1)),
  list(y="employed",    lab="Employment",      flt=quote(rep(TRUE,.N))),
  list(y="formal",      lab="Formal empl.",    flt=quote(employed==1 & public_sector==0)),
  list(y="self_emp",    lab="Self-employment", flt=quote(employed==1 & public_sector==0)))

res <- rbindlist(lapply(OUTS, function(o) {
  d <- D[eval(o$flt)]
  m <- feols(as.formula(sprintf(
        "%s ~ i(t_index, low, ref=5) + low + %s | t_index + region", o$y, CTRL)),
        d, weights=~fac500a, cluster=~region)
  idx <- grep("^t_index::", names(coef(m)))
  b <- coef(m)[idx]; V <- vcov(m)[idx, idx]
  tvec <- as.integer(sub("t_index::(\\d+):low", "\\1", names(b))) - 6L  # event time
  # slopes detectable with 50% / 80% power
  s50 <- tryCatch(pretrends::slope_for_power(sigma=V, targetPower=0.50,
                    tVec=tvec, referencePeriod=-1), error=function(e) NA_real_)
  s80 <- tryCatch(pretrends::slope_for_power(sigma=V, targetPower=0.80,
                    tVec=tvec, referencePeriod=-1), error=function(e) NA_real_)
  # bias of the average post effect under an undetected linear trend of slope s:
  # post periods run k=1..10, mean(k)=5.5, so bias = s * (mean(k) - (-1)) = 6.5 s
  post_k <- tvec[tvec >= 0]
  bias50 <- s50 * (mean(post_k) - (-1))
  bias80 <- s80 * (mean(post_k) - (-1))
  data.table(outcome=o$lab, slope_power50=s50, slope_power80=s80,
             implied_bias_power50=bias50, implied_bias_power80=bias80)
}))
main <- fread(file.path(DIR_OUT, "main_did_coefs.csv"))
map <- c("Log hourly wage"="log_wage_hr","Employment"="employed",
         "Formal empl."="formal","Self-employment"="self_emp")
res[, att := main$att[match(map[outcome], main$outcome)]]
res[, bias50_over_att := implied_bias_power50 / att]
fwrite(res, file.path(DIR_OUT, "pretest_power.csv"))
cat("==== Pre-test power against linear violations (Roth 2022) ====\n")
print(res[, .(outcome, slope50=round(slope_power50,4), slope80=round(slope_power80,4),
              bias50=round(implied_bias_power50,4), att=round(att,4),
              ratio=round(bias50_over_att,2))])
cat("\nDone: 17_pretest_power.R\n")
