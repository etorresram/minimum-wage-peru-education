# ==============================================================================
# 03_main_estimation.R
# Purpose: Main causal estimates of the May-2022 minimum-wage reform, contrasting
#          low-skilled (treated, bound by the MW) and high-skilled (control)
#          workers in a repeated-cross-section difference-in-differences design.
#   (a) TWFE DiD (Low x Post) with region and year-quarter fixed effects.
#   (b) Dynamic event study (Low x quarter), reference 2022Q1.
#   (c) Doubly-robust DiD (Sant'Anna & Zhao 2020, repeated cross sections).
# Output: tables/tab_main_did.tex, output/main_did_coefs.csv,
#         event-study coefficient files for plotting, DR-DiD results.
# ==============================================================================

source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
suppressMessages({library(fixest); library(DRDID)})

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
# Main sample DROPS the partially treated transition quarter 2022Q2 (the reform
# took effect 1 May; April interviews and April reference incomes are untreated).
# The "include transition quarter" specification is reported in 05_robustness.R.
D  <- DT[in_window == 1 & working_age == 1 & !is.na(skill) & transition == 0]
D[, did := low * post]
D[, yqf := factor(t_index)]
D[, ft_main := as.integer(hours_main >= 35)]   # full-time based on main-job hours
# Wage outcomes (log_wage_hr, log_ylab) are winsorized ONCE in 01_build_panel.R
# on the canonical private wage-earner sample (wage_valid / earn_valid).

CTRL <- c("age","age2","female","married","urban","years_educ")
ctrl_fml <- paste(CTRL, collapse = " + ")

# statutory size of the reform (10.2 percent) for elasticity conversions
MW_PCT <- 1025/930 - 1

## ---- Outcome catalogue: name, label, sample filter ---------------------------
# Conditional (job-level) outcomes are restricted to the PRIVATE sector: public
# pay scales do not respond to the RMV. Employment/LFP are unconditional.
outcomes <- list(
  list(y="log_wage_hr", lab="Log real hourly wage",   flt=quote(wage_valid==1)),
  list(y="log_ylab",    lab="Log real monthly earnings",flt=quote(earn_valid==1)),
  list(y="employed",    lab="Employed (working age)",  flt=quote(rep(TRUE,.N))),
  list(y="lfp",         lab="Labour force participation",flt=quote(rep(TRUE,.N))),
  list(y="formal",      lab="Formal employment",       flt=quote(employed==1 & public_sector==0)),
  list(y="hours_main",  lab="Weekly hours (main job)",  flt=quote(employed==1 & public_sector==0 & !is.na(hours_main))),
  list(y="ft_main",     lab="Full-time (>=35h)",        flt=quote(employed==1 & public_sector==0 & !is.na(hours_main))),
  list(y="self_emp",    lab="Self-employed",           flt=quote(employed==1 & public_sector==0)),
  list(y="below_mw",    lab="Paid below the MW",       flt=quote(employed==1 & wage_worker==1 & public_sector==0 & !is.na(below_mw)))
)

## ---- (a) TWFE DiD -----------------------------------------------------------
run_twfe <- function(o) {
  s <- D[eval(o$flt)]
  f <- as.formula(sprintf("%s ~ did + low + %s | t_index + region", o$y, ctrl_fml))
  m <- feols(f, data = s, weights = ~fac500a, cluster = ~region)
  ct <- coeftable(m)["did", ]
  ymean <- weighted.mean(s[[o$y]], s$fac500a, na.rm=TRUE)
  data.table(outcome=o$y, label=o$lab, n=nobs(m), ymean=ymean,
             att=ct[["Estimate"]], se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]])
}
main_tab <- rbindlist(lapply(outcomes, run_twfe))
main_tab[, pct_effect := ifelse(grepl("^log", outcome), 100*(exp(att)-1), NA)]
# Elasticities w.r.t. the 10.2% statutory MW increase:
#   log outcomes: att / %ΔMW ; level outcomes: (att / baseline mean) / %ΔMW
main_tab[, elasticity := ifelse(grepl("^log", outcome),
                                att / MW_PCT, (att / ymean) / MW_PCT)]
fwrite(main_tab, file.path(DIR_OUT, "main_did_coefs.csv"))
cat("==== (a) TWFE DiD: Low x Post ====\n"); print(main_tab[, .(label,n,ymean=round(ymean,3),
     att=round(att,4), se=round(se,4), p=round(p,4), pct=round(pct_effect,2),
     elast=round(elasticity,2))])

## ---- (b) Event study --------------------------------------------------------
# i(t_index, low, ref=5): low x quarter interactions, omitted quarter = 2022Q1
run_event <- function(o) {
  s <- D[eval(o$flt)]
  f <- as.formula(sprintf("%s ~ i(t_index, low, ref=5) + low + %s | t_index + region",
                          o$y, ctrl_fml))
  m <- feols(f, data = s, weights = ~fac500a, cluster = ~region)
  ct <- as.data.table(coeftable(m), keep.rownames="term")
  ct <- ct[grepl("^t_index::", term)]
  ct[, t_index := as.integer(sub("t_index::(\\d+):low","\\1", term))]
  ct[, event_k := t_index - 6]
  ct[, outcome := o$y]; ct[, label := o$lab]
  setnames(ct, c("Estimate","Std. Error"), c("est","se"))
  ct[, .(outcome,label,t_index,event_k,est,se)]
}
es_outcomes <- outcomes[sapply(outcomes, function(o) o$y %in%
                 c("log_wage_hr","log_ylab","employed","formal","hours_main","self_emp","below_mw"))]
es_tab <- rbindlist(lapply(es_outcomes, run_event))

## joint pre-trend Wald test (H0: all pre-reform Low x quarter interactions = 0)
pretrend_test <- function(o) {
  s <- D[eval(o$flt)]
  f <- as.formula(sprintf("%s ~ i(t_index, low, ref=5) + low + %s | t_index + region",
                          o$y, ctrl_fml))
  m <- feols(f, data=s, weights=~fac500a, cluster=~region)
  pre <- grep("t_index::[1-4]:low", names(coef(m)), value=TRUE)
  w <- tryCatch(wald(m, keep=pre, print=FALSE), error=function(e) NULL)
  data.table(outcome=o$y, label=o$lab,
             pretrend_F=if(!is.null(w)) w$stat else NA,
             pretrend_p=if(!is.null(w)) w$p else NA)
}
pretrends <- rbindlist(lapply(es_outcomes, pretrend_test))
fwrite(pretrends, file.path(DIR_OUT, "pretrend_tests.csv"))
cat("\n---- Joint pre-trend tests (H0: pre-reform interactions = 0) ----\n")
print(pretrends[, .(label, F=round(pretrend_F,2), p=round(pretrend_p,3))])
# add the omitted reference point (event_k = -1, t_index 5) at 0
ref_rows <- unique(es_tab[, .(outcome,label)])[, `:=`(t_index=5L,event_k=-1L,est=0,se=0)]
es_tab <- rbind(es_tab, ref_rows)[order(outcome, t_index)]
fwrite(es_tab, file.path(DIR_OUT, "event_study_coefs.csv"))
cat("\n==== (b) Event study saved (", nrow(es_tab), "coefs ) ====\n")

## ---- (c) Doubly-robust DiD (Sant'Anna-Zhao, repeated cross sections) --------
# Pre (t<6) vs post (t>6); the 2022Q2 transition quarter is already excluded
# from D. Standard errors are CLUSTERED BY DEPARTMENT using the estimator's
# influence function (the package default assumes independent observations,
# which is not comparable to the region-clustered TWFE column).
run_drdid <- function(o) {
  s <- D[eval(o$flt)]
  s <- s[, .(y=get(o$y), post=as.numeric(t_index>6), D=low, region,
             age,age2,female,married,urban,years_educ, w=fac500a)]
  s <- s[complete.cases(s)]
  cov <- as.matrix(s[, .(one=1,age,age2,female,married,urban,years_educ)])
  out <- tryCatch(DRDID::drdid_rc(y=s$y, post=s$post, D=s$D, covariates=cov,
                                  i.weights=s$w, inffunc=TRUE),
                  error=function(e) NULL)
  if (is.null(out)) return(data.table(outcome=o$y,label=o$lab,att=NA,se=NA,se_iid=NA,p=NA))
  # cluster-robust SE from the influence function: Var = sum_g (sum_i psi_i)^2 / n^2
  psi <- as.numeric(out$att.inf.func)
  gsum <- tapply(psi, s$region, sum)
  se_cl <- sqrt(sum(gsum^2)) / length(psi)
  data.table(outcome=o$y, label=o$lab, att=out$ATT, se=se_cl, se_iid=out$se,
             p=2*pnorm(-abs(out$ATT/se_cl)))
}
dr_tab <- rbindlist(lapply(outcomes, run_drdid))
fwrite(dr_tab, file.path(DIR_OUT, "drdid_coefs.csv"))
cat("\n==== (c) Doubly-robust DiD (Sant'Anna-Zhao) ====\n")
print(dr_tab[, .(label, att=round(att,4), se=round(se,4), p=round(p,4))])

## ---- Save an estimation object for HonestDiD (log wage event study) ---------
s <- D[wage_valid==1]
m_es_wage <- feols(log_wage_hr ~ i(t_index, low, ref=5) + low + age+age2+female+married+urban+years_educ |
                   t_index + region, data=s, weights=~fac500a, cluster=~region)
saveRDS(m_es_wage, file.path(DIR_OUT, "es_wage_model.rds"))
cat("\nSaved event-study wage model for HonestDiD sensitivity.\n")
cat("Done: 03_main_estimation.R\n")
