# ==============================================================================
# 19_referee_checks.R
# Purpose: Two pre-submission robustness blocks addressing referee objections.
#   (A) UNCONDITIONAL compositional outcomes: private formal employment and
#       self-employment as shares of the WORKING-AGE POPULATION, not of the
#       employed. The conditional outcomes select on employment, which has a
#       differential pandemic-recovery pre-trend; the unconditional versions
#       are immune to that selection margin.
#   (B) Political-crisis robustness of the continuous regional-exposure design:
#       the Dec-2022/Mar-2023 protests concentrated in the southern sierra
#       (Apurimac 03, Arequipa 04, Ayacucho 05, Cusco 08, Madre de Dios 17,
#       Puno 21), which overlaps the high-Kaitz bloc. Re-estimate the
#       Post x Kaitz slope (i) excluding that bloc, (ii) restricting the post
#       window to 2022Q3-Q4 (before the Castillo ouster on 7 Dec 2022), and
#       (iii) both, each with department-clustered SEs and randomization
#       inference. Also re-estimate the education DiD on the early-post window.
# Output: output/referee_uncond.csv, output/referee_uncond_es.csv,
#         output/referee_regional_crisis.csv, output/referee_earlypost_did.csv
# ==============================================================================

source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "."),
        "scripts", "R", "00_config.R"))
suppressMessages(library(fixest))
set.seed(20260712)

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
D  <- DT[in_window == 1 & working_age == 1 & !is.na(skill) & transition == 0]
D[, did := low * post]

CTRL <- "age + age2 + female + married + urban + years_educ"

## Southern protest bloc (Defensoria del Pueblo epicenters, Dec 2022 - Mar 2023)
SOUTH_BLOC <- c("03","04","05","08","17","21")
## Early post window: 2022Q3 (t=7) and 2022Q4 (t=8), before the 7-Dec-2022
## Castillo ouster; pre window unchanged (t = 1..5).
EARLY_T <- 1:8

## ---- (A) Unconditional outcomes ----------------------------------------------
# Shares of the working-age population. A worker counts as private-formal only
# if employed, private, and formal; public-sector workers and the non-employed
# count as zero (the outcome is "holds a private formal job"), so the outcome
# is defined for every working-age individual and involves no conditioning on
# employment status.
D[, formal_u := fifelse(employed == 1 & public_sector == 0 & formal == 1, 1, 0)]
D[, self_u   := fifelse(employed == 1 & public_sector == 0 & self_emp == 1, 1, 0)]
# informal employment share (employed, private, informal) for completeness
D[, informal_u := fifelse(employed == 1 & public_sector == 0 & formal == 0, 1, 0)]

U_OUTS <- list(
  list(y = "formal_u",   lab = "Private formal employment / pop."),
  list(y = "self_u",     lab = "Self-employment / pop."),
  list(y = "informal_u", lab = "Private informal employment / pop.")
)

did_fit <- function(dat, y) {
  m <- feols(as.formula(sprintf("%s ~ did + low + %s | t_index + region", y, CTRL)),
             dat, weights = ~fac500a, cluster = ~region)
  ct <- coeftable(m)["did", ]
  list(est = ct[["Estimate"]], se = ct[["Std. Error"]], p = ct[["Pr(>|t|)"]],
       n = nobs(m))
}

es_fit <- function(dat, y) {
  m <- feols(as.formula(sprintf(
        "%s ~ i(t_index, low, ref=5) + low + %s | t_index + region", y, CTRL)),
        dat, weights = ~fac500a, cluster = ~region)
  pre <- grep("t_index::[1-4]:low", names(coef(m)), value = TRUE)
  w <- tryCatch(wald(m, keep = pre, print = FALSE), error = function(e) NULL)
  ct <- as.data.table(coeftable(m), keep.rownames = "term")
  ct <- ct[grepl("^t_index::", term)]
  ct[, t_index := as.integer(sub("t_index::(\\d+):low", "\\1", term))]
  ct[, event_k := t_index - 6]
  setnames(ct, c("Estimate", "Std. Error"), c("est", "se"))
  list(pre_p = if (!is.null(w)) w$p else NA_real_,
       coefs = ct[, .(t_index, event_k, est, se)])
}

cont_fit <- function(dat, y) {
  m <- feols(as.formula(sprintf("%s ~ post:exposure_z + %s | t_index + region", y, CTRL)),
             dat, weights = ~fac500a, cluster = ~region)
  ct <- coeftable(m)["post:exposure_z", ]
  list(est = ct[["Estimate"]], se = ct[["Std. Error"]], p = ct[["Pr(>|t|)"]])
}

# Randomization inference for the continuous design on region x quarter cells,
# permuting the regional Kaitz values across the INCLUDED departments.
ri_cont <- function(dat, y, draws = 1000) {
  cell <- dat[!is.na(exposure_z),
              .(y = weighted.mean(get(y), fac500a, na.rm = TRUE),
                n = sum(fac500a), post = post[1]), by = .(region, t_index)]
  expo <- unique(dat[!is.na(exposure_z), .(region, exposure_z)])[order(region)]
  cell <- merge(cell, expo, by = "region", sort = FALSE)
  fit <- function(cc) feols(y ~ post:exposure_z | region + t_index, cc,
                            weights = ~n)$coefficients[["post:exposure_z"]]
  obs <- fit(cell)
  null <- numeric(draws)
  for (b in seq_len(draws)) {
    lut <- data.table(region = expo$region, ez = sample(expo$exposure_z))
    c2 <- copy(cell)[, exposure_z := lut$ez[match(region, lut$region)]]
    null[b] <- fit(c2)
  }
  mean(abs(null) >= abs(obs))
}

cat("==================================================================\n")
cat("(A) UNCONDITIONAL outcomes (shares of working-age population)\n")
cat("==================================================================\n")
ua <- rbindlist(lapply(U_OUTS, function(o) {
  d  <- D  # full working-age sample, no employment conditioning
  dd <- did_fit(d, o$y)
  es <- es_fit(d, o$y)
  co <- cont_fit(d[!is.na(exposure_z)], o$y)
  ri <- ri_cont(d, o$y)
  ymean <- weighted.mean(d[[o$y]], d$fac500a)
  data.table(outcome = o$y, label = o$lab, ymean = ymean, n = dd$n,
             did_est = dd$est, did_se = dd$se, did_p = dd$p,
             pretrend_p = es$pre_p,
             cont_est = co$est, cont_se = co$se, cont_p = co$p, cont_ri_p = ri)
}))
fwrite(ua, file.path(DIR_OUT, "referee_uncond.csv"))
print(ua[, .(label, ymean = round(ymean, 3),
             did = sprintf("%.4f (%.4f) p=%.3f", did_est, did_se, did_p),
             pre_p = round(pretrend_p, 3),
             cont = sprintf("%.4f (%.4f) p=%.3f RIp=%.3f",
                            cont_est, cont_se, cont_p, cont_ri_p))])

# event-study coefficients for the unconditional outcomes (for plotting/appendix)
ues <- rbindlist(lapply(U_OUTS, function(o) {
  es <- es_fit(D, o$y)
  cbind(data.table(outcome = o$y, label = o$lab), es$coefs)
}))
fwrite(ues, file.path(DIR_OUT, "referee_uncond_es.csv"))

## ---- (B) Regional design vs the 2022-23 political crisis ---------------------
cat("\n==================================================================\n")
cat("(B) Continuous regional design: political-crisis robustness\n")
cat("    South bloc =", paste(SOUTH_BLOC, collapse = ","),
    "(Apurimac, Arequipa, Ayacucho, Cusco, Madre de Dios, Puno)\n")
cat("==================================================================\n")

B_OUTS <- list(
  list(y = "log_wage_hr", lab = "Log real hourly wage", flt = quote(wage_valid == 1)),
  list(y = "employed",    lab = "Employment",           flt = quote(rep(TRUE, .N))),
  list(y = "formal",      lab = "Formal empl. (cond.)", flt = quote(employed == 1 & public_sector == 0)),
  list(y = "self_emp",    lab = "Self-emp. (cond.)",    flt = quote(employed == 1 & public_sector == 0)),
  list(y = "formal_u",    lab = "Formal empl. / pop.",  flt = quote(rep(TRUE, .N))),
  list(y = "self_u",      lab = "Self-emp. / pop.",     flt = quote(rep(TRUE, .N)))
)

VARIANTS <- list(
  list(tag = "baseline",         keep = quote(rep(TRUE, .N))),
  list(tag = "excl_south_bloc",  keep = quote(!region %in% SOUTH_BLOC)),
  list(tag = "post_2022only",    keep = quote(t_index %in% EARLY_T)),
  list(tag = "excl_south_AND_2022only",
       keep = quote(!region %in% SOUTH_BLOC & t_index %in% EARLY_T))
)

bres <- rbindlist(lapply(B_OUTS, function(o) rbindlist(lapply(VARIANTS, function(v) {
  d <- D[eval(o$flt)][eval(v$keep)][!is.na(exposure_z)]
  co <- cont_fit(d, o$y)
  ri <- ri_cont(d, o$y)
  data.table(outcome = o$y, label = o$lab, variant = v$tag,
             n = nrow(d), n_regions = uniqueN(d$region),
             est = co$est, se = co$se, p = co$p, ri_p = ri)
}))))
fwrite(bres, file.path(DIR_OUT, "referee_regional_crisis.csv"))
print(bres[, .(label, variant, n_regions,
               est = round(est, 4), se = round(se, 4),
               p = round(p, 4), ri_p = round(ri_p, 3))])

## Education DiD on the early post window (2022Q3-Q4 only): the timing check.
cat("\n---- Education DiD, post restricted to 2022Q3-2022Q4 ----\n")
ep <- rbindlist(lapply(B_OUTS, function(o) {
  d <- D[eval(o$flt)][t_index %in% EARLY_T]
  dd <- did_fit(d, o$y)
  data.table(outcome = o$y, label = o$lab, n = dd$n,
             est = dd$est, se = dd$se, p = dd$p)
}))
fwrite(ep, file.path(DIR_OUT, "referee_earlypost_did.csv"))
print(ep[, .(label, n, est = round(est, 4), se = round(se, 4), p = round(p, 4))])

cat("\nDone: 19_referee_checks.R\n")
