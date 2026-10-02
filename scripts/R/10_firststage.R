# ==============================================================================
# 10_firststage.R
# Purpose: First-stage / compliance evidence and selection bounds.
#   (A) Bunching at the wage floor among FORMAL private wage earners: does the
#       spike at the old minimum (930) migrate to the new minimum (1,025)?
#       (Cengiz et al. 2019; Engbom & Moser 2022; Jales 2018.)
#   (B) Compliance DiD: share paid below the NEW floor (fixed threshold 1,025)
#       among formal private wage earners, Low x Post and event study.
#   (C) Lee (2009)-style trimming bounds on the wage DiD, addressing selection
#       into the wage-earner sample induced by the compositional response.
#   (D) Minimum detectable effects (MDE) for the headline outcomes.
# Output: output/firststage_spikes.csv, firststage_compliance.csv,
#         lee_bounds.csv, mde.csv, figures/fig10_bunching.(pdf|png)
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "."),
        "scripts", "R", "00_config.R"))
source(file.path(PROJ_ROOT, "scripts", "R", "theme_paper.R"))
suppressMessages({library(fixest); library(ggplot2); library(matrixStats)})

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
D  <- DT[in_window==1 & working_age==1 & !is.na(skill) & transition==0]
D[, did := low*post]
CTRL <- "age+age2+female+married+urban+years_educ"
OLD_MW <- 930; NEW_MW <- 1025

# Formal private wage earners with valid monthly-equivalent pay
FW <- D[employed==1 & wage_worker==1 & public_sector==0 & formal==1 &
        !is.na(ylab_nom)]

## ============ (A) Bunching: spike shares at the old and new floors ===========
# Spike = share of formal wage earners within +/-2.5% of a floor.
spike_share <- function(d, floor) {
  d[, weighted.mean(abs(ylab_nom/floor - 1) <= 0.025, fac500a, na.rm=TRUE)]
}
# Symmetric 3-quarter windows away from the transition:
pre_w  <- FW[t_index %in% 3:5]    # 2021Q3 - 2022Q1
post_w <- FW[t_index %in% 7:9]    # 2022Q3 - 2023Q1
spikes <- data.table(
  window   = c("pre","pre","post","post"),
  floor    = c(OLD_MW, NEW_MW, OLD_MW, NEW_MW),
  share    = c(spike_share(pre_w, OLD_MW),  spike_share(pre_w, NEW_MW),
               spike_share(post_w, OLD_MW), spike_share(post_w, NEW_MW)),
  n        = c(nrow(pre_w), nrow(pre_w), nrow(post_w), nrow(post_w))
)
# restrict to low-skilled formal wage earners as well (the target group)
pre_l  <- pre_w[low==1]; post_l <- post_w[low==1]
spikes_low <- data.table(
  window = c("pre","pre","post","post"),
  floor  = c(OLD_MW, NEW_MW, OLD_MW, NEW_MW),
  share  = c(spike_share(pre_l, OLD_MW),  spike_share(pre_l, NEW_MW),
             spike_share(post_l, OLD_MW), spike_share(post_l, NEW_MW)),
  n      = c(nrow(pre_l), nrow(pre_l), nrow(post_l), nrow(post_l))
)
spikes[, sample := "All formal wage earners"]
spikes_low[, sample := "Low-skilled formal wage earners"]
spikes_all <- rbind(spikes, spikes_low)
fwrite(spikes_all, file.path(DIR_OUT, "firststage_spikes.csv"))
cat("==== (A) Spike shares (+/-2.5% of floor), formal private wage earners ====\n")
print(spikes_all)

# Bunching figure: histograms pre vs post for low-skilled formal wage earners
bd <- FW[low==1 & t_index %in% c(3:5, 7:9) & ylab_nom>0 & ylab_nom<3000]
bd[, period := factor(ifelse(t_index>=7, "Post (2022Q3-2023Q1)", "Pre (2021Q3-2022Q1)"),
                      levels=c("Pre (2021Q3-2022Q1)", "Post (2022Q3-2023Q1)"))]
p10 <- ggplot(bd, aes(ylab_nom, weight=fac500a)) +
  geom_histogram(binwidth=50, boundary=0, fill="#1b6ca8", colour="white",
                 linewidth=0.2) +
  geom_vline(xintercept=OLD_MW, colour="#1b6ca8", linetype=2) +
  geom_vline(xintercept=NEW_MW, colour="#c1272d", linetype=2) +
  facet_wrap(~period, ncol=1, scales="free_y") +
  labs(x="Nominal monthly-equivalent earnings (S/), 50-sol bins", y="Weighted frequency",
       title="Earnings distribution of low-skilled FORMAL wage earners",
       caption="Dashed lines: old (930, blue) and new (1,025, red) minimum wage. Formal private-sector wage earners only.") +
  theme_paper()
save_fig(p10, "fig10_bunching", w=7, h=5.4)

## ============ (B) Compliance DiD: below the NEW floor (fixed 1,025) ==========
D[, below_new := as.integer(ylab_nom < NEW_MW)]
comp_samples <- list(
  list(lab="Formal wage earners",   flt=quote(employed==1 & wage_worker==1 & public_sector==0 & formal==1 & !is.na(below_new))),
  list(lab="Informal wage earners", flt=quote(employed==1 & wage_worker==1 & public_sector==0 & formal==0 & !is.na(below_new))),
  list(lab="All wage earners",      flt=quote(employed==1 & wage_worker==1 & public_sector==0 & !is.na(below_new)))
)
comp <- rbindlist(lapply(comp_samples, function(s) {
  d <- D[eval(s$flt)]
  m <- feols(as.formula(sprintf("below_new ~ did + low + %s | t_index + region", CTRL)),
             d, weights=~fac500a, cluster=~region)
  ct <- coeftable(m)["did", ]
  # event-study joint pre-trend
  me <- feols(as.formula(sprintf("below_new ~ i(t_index, low, ref=5) + low + %s | t_index + region", CTRL)),
              d, weights=~fac500a, cluster=~region)
  pre <- grep("t_index::[1-4]:low", names(coef(me)), value=TRUE)
  w <- tryCatch(wald(me, keep=pre, print=FALSE), error=function(e) NULL)
  ymean <- d[t_index<6, weighted.mean(below_new, fac500a, na.rm=TRUE)]
  data.table(sample=s$lab, att=ct[["Estimate"]], se=ct[["Std. Error"]],
             p=ct[["Pr(>|t|)"]], n=nobs(m), pre_mean=ymean,
             pretrend_p=if(!is.null(w)) w$p else NA)
}))
fwrite(comp, file.path(DIR_OUT, "firststage_compliance.csv"))
cat("\n==== (B) Compliance DiD: paid below 1,025 (fixed threshold) ====\n")
print(comp)

## ============ (C) Lee-style trimming bounds on the wage DiD ==================
# Selection margin: probability of being in the wage-earner sample
# (wage_valid) among the working-age population. The DiD on this margin gives
# the differential selection induced by the reform.
msel <- feols(as.formula(sprintf("wage_valid ~ did + low + %s | t_index + region", CTRL)),
              D, weights=~fac500a, cluster=~region)
sel <- coeftable(msel)["did", ]
sel_did <- sel[["Estimate"]]
base_rate <- D[low==1 & post==1, weighted.mean(wage_valid, fac500a)]
trim_frac <- abs(sel_did) / base_rate
cat(sprintf("\n==== (C) Selection into the wage sample: DiD = %.4f (se %.4f), trim fraction = %.3f ====\n",
            sel_did, sel[["Std. Error"]], trim_frac))
# 2x2 weighted means of log wage with trimming of the low-post cell
wtd_q <- function(x, w, p) { o <- order(x); x<-x[o]; w<-w[o]
  approx(cumsum(w)/sum(w), x, xout=p, rule=2, ties="ordered")$y }
cellmean <- function(d) d[, weighted.mean(log_wage_hr, fac500a, na.rm=TRUE)]
Wg <- D[wage_valid==1 & is.finite(log_wage_hr)]
m_l0 <- cellmean(Wg[low==1 & post==0]); m_h0 <- cellmean(Wg[low==0 & post==0])
m_h1 <- cellmean(Wg[low==0 & post==1])
lp <- Wg[low==1 & post==1]
q_lo <- wtd_q(lp$log_wage_hr, lp$fac500a, trim_frac)
q_hi <- wtd_q(lp$log_wage_hr, lp$fac500a, 1-trim_frac)
m_l1_upper <- cellmean(lp[log_wage_hr >= q_lo])   # trim bottom -> upper bound
m_l1_lower <- cellmean(lp[log_wage_hr <= q_hi])   # trim top    -> lower bound
did_raw   <- (cellmean(lp) - m_l0) - (m_h1 - m_h0)
did_upper <- (m_l1_upper  - m_l0) - (m_h1 - m_h0)
did_lower <- (m_l1_lower  - m_l0) - (m_h1 - m_h0)
lee <- data.table(quantity=c("selection_did","trim_fraction","raw_2x2_did",
                             "lower_bound","upper_bound"),
                  value=c(sel_did, trim_frac, did_raw, did_lower, did_upper))
fwrite(lee, file.path(DIR_OUT, "lee_bounds.csv"))
cat("Lee-style bounds on the (unconditional 2x2) log-wage DiD:\n"); print(lee)

## ============ (D) Minimum detectable effects =================================
main <- fread(file.path(DIR_OUT, "main_did_coefs.csv"))
main[, mde_80 := 2.8 * se]
main[, mde_pct_of_mean := ifelse(!grepl("^log", outcome), 100*mde_80/ymean, NA)]
fwrite(main[, .(outcome, label, att, se, mde_80, ymean, mde_pct_of_mean)],
       file.path(DIR_OUT, "mde.csv"))
cat("\n==== (D) Minimum detectable effects (80% power, 5% size) ====\n")
print(main[, .(label, att=round(att,4), se=round(se,4), mde=round(mde_80,4))])
cat("\nDone: 10_firststage.R\n")
