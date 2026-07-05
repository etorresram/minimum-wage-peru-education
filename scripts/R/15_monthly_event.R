# ==============================================================================
# 15_monthly_event.R
# Purpose: Monthly event studies around 1 May 2022, exploiting the interview
#   month (ENAHO has continuous fieldwork). Employment-status outcomes are
#   timed by the INTERVIEW month; wage outcomes are timed by the income
#   REFERENCE month (the month before the interview), so treatment turns on
#   exactly at the reform for both. Event time runs -12..+12 months around the
#   reform with binned endpoints (<= -13 and >= +13); reference k = -1
#   (April 2022). Also: quarterly event study with a binned right tail
#   (k >= +8) as a robustness on endpoint handling.
# Output: output/monthly_event.csv, output/es_binned.csv,
#         figures/fig11_monthly_event.(pdf|png)
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
source(file.path(PROJ_ROOT, "scripts", "R", "theme_paper.R"))
suppressMessages({library(fixest); library(ggplot2)})

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
D  <- DT[in_window==1 & working_age==1 & !is.na(skill)]   # months handle 2022Q2 finely
CTRL <- "age+age2+female+married+urban+years_educ"
REF_M <- 17L   # May 2022 = (2022-2021)*12 + 5

D[, m_int := (year - 2021L)*12L + mes_i]                  # interview month index
D[, m_ref := (ref_year - 2021L)*12L + ref_month]          # income reference month index

OUTS <- list(
  list(y="employed",    lab="Employment",      flt=quote(rep(TRUE,.N)),      tvar="m_int"),
  list(y="formal",      lab="Formal empl.",    flt=quote(employed==1 & public_sector==0), tvar="m_int"),
  list(y="self_emp",    lab="Self-employment", flt=quote(employed==1 & public_sector==0), tvar="m_int"),
  list(y="log_wage_hr", lab="Log hourly wage", flt=quote(wage_valid==1),     tvar="m_ref"))

run_monthly <- function(o) {
  d <- D[eval(o$flt)]
  d[, k := get(o$tvar) - REF_M]
  d[, kb := pmin(pmax(k, -13L), 13L)]                     # bin tails at +/-13
  m <- feols(as.formula(sprintf(
        "%s ~ i(kb, low, ref=-1) + low + %s | kb + region", o$y, CTRL)),
        d, weights=~fac500a, cluster=~region)
  ct <- as.data.table(coeftable(m), keep.rownames="term")[grepl("^kb::", term)]
  ct[, k := as.integer(sub("kb::(-?\\d+):low", "\\1", term))]
  setnames(ct, c("Estimate","Std. Error"), c("est","se"))
  ct[, outcome := o$lab]
  ct[, .(outcome, k, est, se)]
}
me <- rbindlist(lapply(OUTS, run_monthly))
ref_rows <- unique(me[, .(outcome)])[, `:=`(k=-1L, est=0, se=0)]
me <- rbind(me, ref_rows)[order(outcome, k)]
fwrite(me, file.path(DIR_OUT, "monthly_event.csv"))
cat("Monthly event-study coefficients saved (", nrow(me), "rows ).\n")

# For DISPLAY, normalize each outcome so the pre-period average is zero (a
# single reference month is an arbitrary and potentially atypical anchor: with
# ref = April 2022, a local trough, the wage panel reads as uniformly positive).
# The CSV keeps the raw ref=-1 coefficients; the DiD estimates are unaffected.
mp <- me[abs(k) <= 13]
mp[, est_n := est - mean(est[k < 0 & k != -1]), by=outcome]
p11 <- ggplot(mp, aes(k, est_n)) +
  geom_hline(yintercept=0, colour="grey55") +
  geom_vline(xintercept=-0.5, colour="grey55", linetype=3) +
  geom_ribbon(aes(ymin=est_n-1.96*se, ymax=est_n+1.96*se), fill="#1b6ca8", alpha=0.15) +
  geom_line(colour="#1b6ca8", linewidth=0.45) + geom_point(colour="#1b6ca8", size=0.9) +
  facet_wrap(~outcome, scales="free_y") +
  scale_x_continuous(breaks=seq(-12, 12, 4)) +
  labs(x="Months since the reform (0 = May 2022); endpoints binned at +/-13",
       y="Low x month coefficient (pre-period average = 0)",
       title="Monthly event studies around the May-2022 reform",
       caption="Normalized so the pre-period average is zero. 95% CI clustered by department.") +
  theme_paper()
save_fig(p11, "fig11_monthly_event", w=7.6, h=5.4)

## ---- Quarterly event study with binned right tail (k >= 8) -------------------
D2 <- D[transition==0]
D2[, kq := t_index - 6L]
D2[, kqb := pmin(kq, 8L)]
esb <- rbindlist(lapply(OUTS, function(o) {
  d <- D2[eval(o$flt)]
  m <- feols(as.formula(sprintf(
        "%s ~ i(kqb, low, ref=-1) + low + %s | kqb + region", o$y, CTRL)),
        d, weights=~fac500a, cluster=~region)
  ct <- as.data.table(coeftable(m), keep.rownames="term")[grepl("^kqb::", term)]
  ct[, k := as.integer(sub("kqb::(-?\\d+):low", "\\1", term))]
  setnames(ct, c("Estimate","Std. Error"), c("est","se"))
  ct[, outcome := o$lab]
  ct[, .(outcome, k, est, se)]
}))
fwrite(esb, file.path(DIR_OUT, "es_binned.csv"))
cat("Quarterly binned-endpoint event study saved.\n")
cat("\nDone: 15_monthly_event.R\n")
