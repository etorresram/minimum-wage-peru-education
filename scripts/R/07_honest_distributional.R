# ==============================================================================
# 07_honest_distributional.R
# Purpose:
#   (1) HonestDiD (Rambachan & Roth 2023) sensitivity to violations of parallel
#       trends, using the event-study estimates (relative-magnitudes restriction).
#   (2) Distributional effects via RIF unconditional-quantile DiD
#       (Firpo, Fortin & Lemieux 2009) across wage deciles.
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
source(file.path(PROJ_ROOT, "scripts", "R", "theme_paper.R"))
suppressMessages({library(fixest); library(HonestDiD); library(ggplot2)})

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
# Drops the partially treated 2022Q2 transition quarter (as in 03); canonical
# winsorized wage outcomes come from 01_build_panel.R.
D  <- DT[in_window==1 & working_age==1 & !is.na(skill) & transition==0]
D[, did := low*post]
CTRL <- "age+age2+female+married+urban+years_educ"

## ============================ (1) HonestDiD ==================================
es_model <- function(y, flt) {
  s <- D[eval(flt)]
  feols(as.formula(sprintf("%s ~ i(t_index, low, ref=5) + low + %s | t_index + region", y, CTRL)),
        s, weights=~fac500a, cluster=~region)
}
honest_one <- function(y, flt, name) {
  m <- es_model(y, flt)
  b <- coef(m); V <- vcov(m)
  idx <- grep("^t_index::", names(b))
  # order is t=1,2,3,4,7,...,16 -> k=-5..-2 (pre, ref k=-1) then k=1..10 (post;
  # the partially treated 2022Q2, k=0, is excluded from the sample)
  bh <- b[idx]; Vh <- V[idx, idx]
  nPre <- 4L; nPost <- length(idx) - nPre
  # relative-magnitudes restriction; l_vec averages the post-period effects
  rm <- tryCatch(
    HonestDiD::createSensitivityResults_relativeMagnitudes(
      betahat=bh, sigma=Vh, numPrePeriods=nPre, numPostPeriods=nPost,
      Mbarvec=c(0,0.1,0.2,0.3,0.4,0.5,0.75,1), l_vec=rep(1/nPost, nPost)),
    error=function(e) { message("Honest RM failed for ", name, ": ", conditionMessage(e)); NULL })
  orig <- tryCatch(
    HonestDiD::constructOriginalCS(betahat=bh, sigma=Vh,
      numPrePeriods=nPre, numPostPeriods=nPost, l_vec=rep(1/nPost, nPost)),
    error=function(e) NULL)
  if (is.null(rm)) return(NULL)
  # extract clean numeric vectors (HonestDiD stores lb/ub as 1-column matrices)
  res <- data.table(outcome=name, kind="RM", Mbar=as.numeric(rm$Mbar),
                    lb=as.numeric(rm$lb), ub=as.numeric(rm$ub))
  if (!is.null(orig)) res <- rbind(
    data.table(outcome=name, kind="Original", Mbar=0,
               lb=as.numeric(orig$lb), ub=as.numeric(orig$ub)),
    res)
  res
}
honest <- rbindlist(list(
  honest_one("log_wage_hr", quote(wage_valid==1), "Log hourly wage"),
  honest_one("employed",    quote(rep(TRUE,.N)), "Employment"),
  honest_one("formal",      quote(employed==1 & public_sector==0), "Formal empl."),
  honest_one("self_emp",    quote(employed==1 & public_sector==0), "Self-employment")
), fill=TRUE)
fwrite(honest, file.path(DIR_OUT, "honestdid.csv"))
cat("==== HonestDiD relative-magnitudes sensitivity (first post period) ====\n")
print(honest[, .(outcome, Mbar, lb=round(lb,4), ub=round(ub,4))])

## Smoothness (Delta^SD) restriction: M = 0 allows exact LINEAR extrapolation of
## the pre-trend into the post period -- the principled "drift-adjusted" bound.
honest_sd_one <- function(y, flt, name) {
  m <- es_model(y, flt)
  b <- coef(m); V <- vcov(m)
  idx <- grep("^t_index::", names(b))
  bh <- b[idx]; Vh <- V[idx, idx]
  nPre <- 4L; nPost <- length(idx) - nPre
  sd <- tryCatch(
    HonestDiD::createSensitivityResults(
      betahat=bh, sigma=Vh, numPrePeriods=nPre, numPostPeriods=nPost,
      Mvec=c(0, 0.005, 0.01), l_vec=rep(1/nPost, nPost)),
    error=function(e) { message("Honest SD failed for ", name); NULL })
  if (is.null(sd)) return(NULL)
  data.table(outcome=name, M=as.numeric(sd$M),
             lb=as.numeric(sd$lb), ub=as.numeric(sd$ub))
}
honest_sd <- rbindlist(list(
  honest_sd_one("formal",   quote(employed==1 & public_sector==0), "Formal empl."),
  honest_sd_one("self_emp", quote(employed==1 & public_sector==0), "Self-employment"),
  honest_sd_one("log_wage_hr", quote(wage_valid==1), "Log hourly wage")
), fill=TRUE)
fwrite(honest_sd, file.path(DIR_OUT, "honestdid_sd.csv"))
cat("\n==== HonestDiD smoothness (SD) restriction; M=0 = linear extrapolation ====\n")
print(honest_sd)

# breakdown Mbar: largest Mbar for which the robust CI still excludes 0
bd <- honest[kind=="RM"][, .(breakdown = { s <- .SD[order(Mbar)];
          excl <- s$lb>0 | s$ub<0;
          if (any(excl)) max(s$Mbar[excl]) else NA_real_ }), by=outcome]
cat("\nBreakdown Mbar (largest relative-magnitude violation the result survives):\n")
print(bd)

# sensitivity plot for employment and formality
hp <- honest[outcome %in% c("Employment","Formal empl.")]
hp <- hp[kind=="Original" | Mbar %in% c(0,0.1,0.2,0.3,0.4,0.5,1)]
hp[, Mlab := ifelse(kind=="Original", "Original", paste0("Mbar=",Mbar))]
hp[, Mlab := factor(Mlab, levels=c("Original", paste0("Mbar=",c(0,0.1,0.2,0.3,0.4,0.5,1))))]
p7 <- ggplot(hp, aes(Mlab, ymin=lb, ymax=ub)) +
  geom_hline(yintercept=0, colour="grey55") +
  geom_errorbar(width=0.2, linewidth=0.6, colour="#1b6ca8") +
  facet_wrap(~outcome, scales="free_y") +
  labs(x="Restriction on post-period trend violation", y="Robust CI (average post-reform effect)",
       title="HonestDiD sensitivity to parallel-trends violations",
       caption="Relative-magnitudes restriction (Rambachan & Roth 2023). Mbar bounds post-period trend by Mbar times the largest pre-period violation.") +
  theme_paper() + theme(axis.text.x=element_text(angle=30, hjust=1))
save_fig(p7, "fig7_honestdid", w=7, h=4.2)

## ==================== (2) RIF unconditional-quantile DiD =====================
W <- D[wage_valid==1]
taus <- seq(0.1, 0.9, 0.1)
# weighted quantile without extra deps
wtd_quantile <- function(x, w, p) {
  o <- order(x); x <- x[o]; w <- w[o]; cw <- cumsum(w)/sum(w)
  approx(cw, x, xout=p, rule=2, ties="ordered")$y
}
# recentered influence function for the tau-quantile (Firpo-Fortin-Lemieux 2009)
# Bandwidth: weighted Silverman rule (base density() picks its bandwidth
# ignoring the weights, which triggered warnings and misestimated f(q)).
rif_quantile <- function(y, w, tau) {
  q <- wtd_quantile(y, w, tau)
  wm <- weighted.mean(y, w); wsd <- sqrt(weighted.mean((y-wm)^2, w))
  n_eff <- sum(w)^2 / sum(w^2)
  bw <- 0.9 * wsd * n_eff^(-1/5)
  fq <- density(y, weights=w/sum(w), bw=bw, n=512)
  fhat <- approx(fq$x, fq$y, xout=q, rule=2)$y
  q + (tau - as.numeric(y <= q)) / fhat
}
rifdt <- rbindlist(lapply(taus, function(tau) {
  W2 <- copy(W)
  W2[, rif := rif_quantile(log_wage_hr, fac500a, tau)]
  m <- feols(rif ~ did + low + age+age2+female+married+urban+years_educ | t_index + region,
             W2, weights=~fac500a, cluster=~region)
  ct <- coeftable(m)["did", ]
  data.table(tau=tau, est=ct[["Estimate"]], se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]])
}))
fwrite(rifdt, file.path(DIR_OUT, "rif_quantile.csv"))
cat("\n==== RIF unconditional-quantile DiD (log hourly wage) ====\n"); print(rifdt)

p8 <- ggplot(rifdt, aes(tau, est)) +
  geom_hline(yintercept=0, colour="grey55") +
  geom_ribbon(aes(ymin=est-1.96*se, ymax=est+1.96*se), fill="#1b6ca8", alpha=0.15) +
  geom_line(colour="#1b6ca8", linewidth=0.7) + geom_point(colour="#1b6ca8", size=1.6) +
  scale_x_continuous(breaks=taus) +
  labs(x="Quantile of the log real hourly wage", y="Low x Post DiD (RIF)",
       title="Distributional wage effects across the wage distribution",
       caption="Unconditional-quantile (RIF) regressions, Firpo-Fortin-Lemieux (2009). Bands: 95% CI clustered by department.") +
  theme_paper()
save_fig(p8, "fig8_rif_quantile")
cat("\nDone: 07_honest_distributional.R\n")
