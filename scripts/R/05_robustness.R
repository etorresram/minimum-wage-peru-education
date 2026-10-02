# ==============================================================================
# 05_robustness.R
# Purpose: Robustness and inference checks for the headline DiD estimates.
#   A. Specification robustness (controls, sample, FE, education cutoff, window).
#   B. Inference robustness (region cluster, region x skill cluster, CR2
#      few-cluster correction, randomization inference).
#   C. Design robustness (triple difference with regional bite; continuous
#      Card-1992 exposure intensity).
#   D. Leave-one-region-out and leave-one-quarter-out stability.
#   E. In-time placebo reforms.
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "."),
        "scripts", "R", "00_config.R"))
source(file.path(PROJ_ROOT, "scripts", "R", "theme_paper.R"))
suppressMessages({library(fixest); library(clubSandwich); library(ggplot2)})
set.seed(20220501)

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
# D_all keeps the partially treated 2022Q2 transition quarter (for the
# "include transition" specification); the baseline D drops it, as in 03.
D_all <- DT[in_window==1 & working_age==1 & !is.na(skill)]
D_all[, did := low*post]
D_all[, ft_main := as.integer(hours_main>=35)]
D <- D_all[transition==0]
CTRL <- "age+age2+female+married+urban+years_educ"

OUTS <- list(
  list(y="log_wage_hr", lab="Log hourly wage", flt=quote(wage_valid==1)),
  list(y="employed",    lab="Employment",      flt=quote(rep(TRUE,.N))),
  list(y="formal",      lab="Formal empl.",    flt=quote(employed==1 & public_sector==0)),
  list(y="self_emp",    lab="Self-employment", flt=quote(employed==1 & public_sector==0)))

# helper: DiD (Low x Post) coefficient for a given data set / formula pieces
did_est <- function(dat, y, controls=CTRL, fe="t_index + region", clus=~region) {
  f <- as.formula(sprintf("%s ~ did + low + %s | %s", y,
                          ifelse(nchar(controls)>0, controls, "1"), fe))
  m <- feols(f, data=dat, weights=~fac500a, cluster=clus)
  ct <- coeftable(m)["did", ]
  list(m=m, est=ct[["Estimate"]], se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]], n=nobs(m))
}

## ======================= A. Specification robustness =========================
specs <- list(
  baseline   = function(o) did_est(D[eval(o$flt)], o$y),
  no_ctrl    = function(o) did_est(D[eval(o$flt)], o$y, controls=""),
  drop_covid = function(o) did_est(D[eval(o$flt) & t_index>=2], o$y),
  reg_trend  = function(o) did_est(D[eval(o$flt)], o$y, fe="t_index + region[t_index]"),
  prime_age  = function(o) did_est(D[eval(o$flt) & age>=25 & age<=55], o$y),
  alt_cutoff = function(o) {   # low <= sec. incomplete (<=5), high >= non-univ complete (>=8)
    d2 <- D[eval(o$flt) & educ_code %in% c(1:5,8:11)]
    d2[, low := as.integer(educ_code<=5)][, did := low*post]
    did_est(d2, o$y)
  },
  occ_ind_fe = function(o) did_est(D[eval(o$flt) & !is.na(occ1) & !is.na(ind_div)],
                                   o$y, fe="t_index + region + occ1 + ind_div"),
  cluster_rs = function(o) {
    d2 <- D[eval(o$flt)]; d2[, rs := paste(region, skill)]
    did_est(d2, o$y, clus=~rs)
  },
  # include the partially treated 2022Q2 transition quarter (baseline drops it)
  incl_trans = function(o) {
    d2 <- D_all[eval(o$flt)]
    did_est(d2, o$y)
  },
  # exclude agriculture (divisions 01-03: separate agrarian regime, Ley 31110);
  # only defined for job-conditional outcomes (industry unknown for non-workers)
  excl_agri  = function(o) {
    if (o$y == "employed") return(list(est=NA_real_, se=NA_real_, p=NA_real_, n=NA_integer_))
    did_est(D[eval(o$flt) & agri==0], o$y)
  },
  # group-specific linear trend: allows Low vs High to diverge linearly over the
  # whole window, so the DiD is identified from the deviation off that trend.
  # Conservative: with an immediate-and-persistent effect, part of the true
  # effect is absorbed by the trend, so this bounds the drift story from below.
  low_trend  = function(o) {
    d <- D[eval(o$flt)]
    f <- as.formula(sprintf("%s ~ did + low + low:t_index + %s | t_index + region",
                            o$y, CTRL))
    m <- feols(f, data=d, weights=~fac500a, cluster=~region)
    ct <- coeftable(m)["did", ]
    list(est=ct[["Estimate"]], se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]], n=nobs(m))
  },
  # add public-sector workers back into the job-conditional samples
  incl_public = function(o) {
    if (o$y == "employed") return(list(est=NA_real_, se=NA_real_, p=NA_real_, n=NA_integer_))
    f2 <- switch(o$y,
      log_wage_hr = quote(employed==1 & wage_worker==1 & is.finite(wage_hr_real) & wage_hr_real>0),
      formal      = quote(employed==1),
      self_emp    = quote(employed==1))
    d2 <- D[eval(f2)]
    if (o$y == "log_wage_hr") d2[, log_wage_hr := log(winsorize(wage_hr_real))]
    did_est(d2, o$y)
  }
)
specA <- rbindlist(lapply(OUTS, function(o) {
  rbindlist(lapply(names(specs), function(sp) {
    r <- specs[[sp]](o)
    data.table(outcome=o$lab, spec=sp, est=r$est, se=r$se, p=r$p, n=r$n)
  }))
}))
fwrite(specA, file.path(DIR_OUT, "rob_specifications.csv"))
cat("==== A. Specification robustness (Low x Post) ====\n")
print(dcast(specA, spec~outcome, value.var="est")[match(names(specs), spec)])

## ======================= B. Inference robustness =============================
# Few-cluster inference is applied to region x skill x post cell means
# (Bertrand, Duflo & Mullainathan 2004 collapse), where the CR2 small-sample
# correction of Pustejovsky & Tipton (2018) is both feasible and appropriate.
inf_tab <- rbindlist(lapply(OUTS, function(o) {
  d <- D[eval(o$flt)]
  base <- did_est(d, o$y)
  d[, rs := paste(region, skill)]
  rs <- did_est(d, o$y, clus=~rs)
  # collapse to region x skill x post
  cell <- d[, .(y=weighted.mean(get(o$y), fac500a, na.rm=TRUE), n=sum(fac500a)),
            by=.(region, low, post)]
  cell[, did := low*post]
  mc <- feols(y ~ did + low + post | region, cell, weights=~n)
  cr2 <- tryCatch({
    vc <- clubSandwich::vcovCR(mc, cluster=cell$region, type="CR2")
    ct <- clubSandwich::coef_test(mc, vcov=vc, coefs="did")
    list(est=coef(mc)[["did"]], se=ct$SE, p=ct$p_Satt)
  }, error=function(e) list(est=coef(mc)[["did"]], se=NA, p=NA))
  data.table(outcome=o$lab, est=base$est,
             se_region=base$se, p_region=base$p,
             se_regionskill=rs$se, p_regionskill=rs$p,
             est_collapse=cr2$est, se_CR2=cr2$se, p_CR2=cr2$p)
}))
fwrite(inf_tab, file.path(DIR_OUT, "rob_inference.csv"))
cat("\n==== B. Inference robustness (CR2 on BDM-collapsed cells) ====\n"); print(inf_tab)

## ======================= C. Design robustness ================================
# Triple difference: Low x Post x HighBite (region above-median MW bite)
ddd <- rbindlist(lapply(OUTS, function(o) {
  d <- D[eval(o$flt) & !is.na(high_bite)]
  m <- feols(as.formula(sprintf("%s ~ low*post*high_bite + %s | t_index + region", o$y, CTRL)),
             d, weights=~fac500a, cluster=~region)
  cn <- grep("low:post:high_bite", names(coef(m)), value=TRUE)
  ct <- coeftable(m)[cn, ]
  data.table(outcome=o$lab, est=ct[["Estimate"]], se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]])
}))
fwrite(ddd, file.path(DIR_OUT, "rob_triplediff.csv"))
cat("\n==== C1. Triple difference (Low x Post x HighBite) ====\n"); print(ddd)

# Continuous intensity (Card 1992): dependent employees, Post x standardized Kaitz
cont <- rbindlist(lapply(OUTS, function(o) {
  d <- D[eval(o$flt) & !is.na(exposure_z)]
  m <- feols(as.formula(sprintf("%s ~ post:exposure_z + %s | t_index + region", o$y, CTRL)),
             d, weights=~fac500a, cluster=~region)
  ct <- coeftable(m)["post:exposure_z", ]
  data.table(outcome=o$lab, est=ct[["Estimate"]], se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]])
}))
fwrite(cont, file.path(DIR_OUT, "rob_continuous.csv"))
cat("\n==== C2. Continuous exposure (Post x Kaitz_z) ====\n"); print(cont)

## ======================= D. Leave-one-out stability ==========================
# Full per-unit estimates are saved (rob_leaveoneout_detail.csv) for the
# appendix table/figure; the summary keeps the min-max ranges.
loo_detail <- rbindlist(lapply(OUTS, function(o) {
  d <- D[eval(o$flt)]
  regs <- sort(unique(d$region)); qs <- sort(unique(d$t_index))
  rbind(
    rbindlist(lapply(regs, function(r) { e <- did_est(d[region!=r], o$y)
      data.table(outcome=o$lab, drop_type="region", dropped=r,
                 est=e$est, se=e$se, p=e$p) })),
    rbindlist(lapply(qs, function(q) { e <- did_est(d[t_index!=q], o$y)
      data.table(outcome=o$lab, drop_type="quarter", dropped=as.character(q),
                 est=e$est, se=e$se, p=e$p) }))
  )
}))
fwrite(loo_detail, file.path(DIR_OUT, "rob_leaveoneout_detail.csv"))
full_est <- rbindlist(lapply(OUTS, function(o)
  data.table(outcome=o$lab, full=did_est(D[eval(o$flt)], o$y)$est)))
loo <- merge(full_est, loo_detail[, .(
    loro_min = min(est[drop_type=="region"]),  loro_max = max(est[drop_type=="region"]),
    loqo_min = min(est[drop_type=="quarter"]), loqo_max = max(est[drop_type=="quarter"])),
  by=outcome], by="outcome")
fwrite(loo, file.path(DIR_OUT, "rob_leaveoneout.csv"))
cat("\n==== D. Leave-one-out (region / quarter) ranges ====\n"); print(loo)

## ======================= E. Randomization inference ==========================
# IMPORTANT (labelling): this is Fisherian RI for the CONTINUOUS REGIONAL-
# EXPOSURE design (Post x Kaitz slope of section C2), NOT for the education-
# group Low x Post contrast -- with only two education groups a group-level
# permutation test of the main DiD is undefined. Tables and text must present
# it as design-based inference for the continuous specification. We collapse
# each outcome to region x quarter cell means and permute the 25 regional Kaitz
# values across departments (2000 draws), re-estimating the Post x exposure slope.
ri_outcomes <- c("employed","formal","self_emp","log_wage_hr")
region_expo <- unique(D[, .(region, exposure_z)])[order(region)]
RI <- 2000
ri_res <- rbindlist(lapply(ri_outcomes, function(y) {
  o <- OUTS[[which(sapply(OUTS,function(z) z$y)==y)]]
  d <- D[eval(o$flt) & !is.na(exposure_z)]
  cell <- d[, .(y=weighted.mean(get(y), fac500a, na.rm=TRUE), n=sum(fac500a),
                post=post[1]), by=.(region, t_index)]
  cell <- merge(cell, region_expo, by="region", sort=FALSE)
  fit <- function(dat) feols(y ~ post:exposure_z | region + t_index, dat,
                             weights=~n)$coefficients[["post:exposure_z"]]
  obs <- fit(cell)
  regs <- region_expo$region
  null <- numeric(RI)
  for (b in seq_len(RI)) {
    lut <- data.table(region=regs, exposure_z=sample(region_expo$exposure_z))
    c2 <- copy(cell); c2[, exposure_z := lut$exposure_z[match(region, lut$region)]]
    null[b] <- fit(c2)
  }
  data.table(outcome=o$lab, obs=obs, ri_p=mean(abs(null)>=abs(obs)))
}))
setnames(ri_res, "obs", "obs_exposure_slope")
fwrite(ri_res, file.path(DIR_OUT, "rob_randomization.csv"))
cat("\n==== E. Randomization inference: CONTINUOUS-EXPOSURE design",
    "(permute regional Kaitz, 2000 draws) ====\n")
print(ri_res)

## ================= E2. Wild cluster bootstrap: NOT FEASIBLE ==================
# The Cameron-Gelbach-Miller wild cluster bootstrap-t (fwildclusterboot) does
# not support weighted least squares, and all estimates here use ENAHO survey
# weights. Few-cluster inference is instead addressed by (i) the CR2/
# Satterthwaite correction on BDM-collapsed cells (section B) and (ii) the
# design-based randomization inference for the continuous-exposure design (E).
# The manuscript must NOT claim wild-bootstrap p-values.

## ======================= F. In-time placebo reforms ==========================
# Using only pre-reform data (t<=5, 2021Q1-2022Q1), assign a fake reform at each
# interior quarter and estimate the placebo DiD (should be ~0).
placebo <- rbindlist(lapply(OUTS, function(o) {
  rbindlist(lapply(2:4, function(pq) {
    d <- D[eval(o$flt) & t_index<=5]
    d[, post := as.integer(t_index>=pq)][, did := low*post]
    r <- did_est(d, o$y)
    data.table(outcome=o$lab, placebo_reform_t=pq, est=r$est, se=r$se, p=r$p)
  }))
}))
fwrite(placebo, file.path(DIR_OUT, "rob_placebo.csv"))
cat("\n==== F. In-time placebo reforms (pre-period only) ====\n"); print(placebo)
cat("\nDone: 05_robustness.R\n")
