# ==============================================================================
# 22_state_dependence.R
# Purpose: A designed test of the state-dependence interpretation of the
#          2022-vs-2025 contrast. The entry-margin mechanism (Section 6.5 /
#          21_panel_transitions.R) implies that a rising floor bites where new
#          formal matches are being created. Two testable implications:
#          (1) PREMISE: the stock of marginal formal matches was larger on the
#              eve of the 2022 reform than on the eve of the 2025 reform.
#              Measured nationally among low-educated formal private wage
#              earners: the new-hire share (tenure < 12 months) and the share
#              of pay within the band that the incoming floor swept.
#          (2) DOSE-RESPONSE: the 2022 compositional effects should concentrate
#              in departments where pre-reform formal match creation was high,
#              conditional on the wage-bite (Kaitz) gradient; and the same
#              interaction should be dead around the 2025 reform.
# Design:  (1) weighted national means, pre-2022 (2021Q1-2022Q1) vs pre-2025
#              (2024Q1-Q4) windows.
#          (2) triple interaction Low x Post x NewHire_z at the department
#              level (new-hire share among formal private wage earners in the
#              pre-reform window, standardized across 25 departments), with
#              and without the parallel Low x Post x Kaitz_z control, estimated
#              separately for the 2022 window (2021-2024, excl. 2022Q2) and the
#              2025 window (2024-2025, excl. Jan-2025 wage refs as in 08).
# Output:  output/state_premise.csv, output/state_dose.csv
# ==============================================================================

source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
suppressMessages(library(fixest))

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
CTRL <- "age + age2 + female + married + urban + years_educ"

## ---- (1) National premise: marginal-match mass on the eve of each reform ------
# Formal private wage earners with valid monthly-equivalent pay.
FW <- DT[working_age==1 & !is.na(skill) & employed==1 & public_sector==0 &
         wage_worker==1 & formal==1 & !is.na(ylab_nom)]
FW[, pre22 := as.integer(t_index %in% 1:5)]     # 2021Q1-2022Q1
FW[, pre25 := as.integer(t_index %in% 13:16)]   # 2024Q1-2024Q4
premise <- rbindlist(lapply(list(
    list(win="pre-2022", flt=quote(pre22==1), old=930, new=1025),
    list(win="pre-2025", flt=quote(pre25==1), old=1025, new=1130)),
  function(w) {
    s <- FW[eval(w$flt) & low==1]
    sh <- function(x) weighted.mean(x, s$fac500a, na.rm=TRUE)
    data.table(window = w$win, n = nrow(s),
      newhire_share  = sh(as.numeric(s$new_hire==1)),
      at_old_floor   = sh(as.numeric(abs(s$ylab_nom - w$old) <= 0.025*w$old)),
      swept_band     = sh(as.numeric(s$ylab_nom >= w$old*0.975 & s$ylab_nom < w$new)),
      below_new      = sh(as.numeric(s$ylab_nom < w$new)))
  }))
fwrite(premise, file.path(DIR_OUT, "state_premise.csv"))
cat("==== (1) Marginal-match mass, low-educated FORMAL private wage earners ====\n")
cat("(new-hire = tenure < 12 months; swept band = pay in [old floor - 2.5%, new floor))\n")
print(premise[, .(window, n, newhire = round(newhire_share,3),
                  at_old_floor = round(at_old_floor,3),
                  swept_band = round(swept_band,3), below_new = round(below_new,3))])

## ---- Department-level match-creation state variable ----------------------------
mk_state <- function(tset) {
  s <- FW[t_index %in% tset & !is.na(new_hire)]
  st <- s[, .(newhire = weighted.mean(new_hire, fac500a, na.rm=TRUE), n=.N), by=region]
  st[, newhire_z := (newhire - mean(newhire)) / sd(newhire)]
  st
}
st22 <- mk_state(1:5);  setnames(st22, c("newhire","newhire_z"), c("nh22","nh22_z"))
st25 <- mk_state(13:16); setnames(st25, c("newhire","newhire_z"), c("nh25","nh25_z"))
cmp <- merge(st22[, .(region, nh22, nh22_z)], st25[, .(region, nh25, nh25_z)], by="region")
ck <- merge(cmp, unique(DT[!is.na(exposure_z), .(region, exposure_z)]), by="region")
cat("\nDept new-hire share: pre-2022 mean", round(mean(cmp$nh22),3),
    "sd", round(sd(cmp$nh22),3), "| pre-2025 mean", round(mean(cmp$nh25),3),
    "sd", round(sd(cmp$nh25),3),
    "| corr(nh22_z, kaitz_z):", round(ck[, cor(nh22_z, exposure_z)], 3),
    "| corr(nh22, nh25):", round(cmp[, cor(nh22, nh25)], 3), "\n")

## ---- (2) Dose-response in match creation, 2022 vs 2025 reform ------------------
D22 <- DT[in_window==1 & working_age==1 & !is.na(skill) & transition==0]
D22 <- merge(D22, st22[, .(region, nh_z = nh22_z)], by="region", all.x=TRUE, sort=FALSE)
D22[, pp := post]

D25 <- DT[t_index>=13 & working_age==1 & !is.na(skill)]
D25 <- merge(D25, st25[, .(region, nh_z = nh25_z)], by="region", all.x=TRUE, sort=FALSE)
D25[, pp := as.integer(t_index>=17)]
D25[, wage_ref_pre2025 := as.integer(year==2025 & mes_i==1)]

OUTS <- list(
  list(y="formal",   lab="Formal employment", flt=quote(employed==1 & public_sector==0)),
  list(y="self_emp", lab="Self-employment",   flt=quote(employed==1 & public_sector==0)),
  list(y="employed", lab="Employment",        flt=quote(rep(TRUE,.N))),
  list(y="log_wage_hr", lab="Log hourly wage",flt=quote(wage_valid==1)))

dose_fit <- function(dat, o, kaitz_ctl) {
  d <- dat[eval(o$flt) & !is.na(nh_z) & !is.na(exposure_z)]
  if (o$y=="log_wage_hr" && "wage_ref_pre2025" %in% names(d)) d <- d[wage_ref_pre2025==0]
  rhs <- "low*pp*nh_z"
  if (kaitz_ctl) rhs <- paste(rhs, "+ low*pp*exposure_z")
  m <- feols(as.formula(sprintf("%s ~ %s + %s | t_index + region", o$y, rhs, CTRL)),
             d, weights=~fac500a, cluster=~region)
  ct <- coeftable(m)
  cn <- grep("^low:pp:nh_z$|^low:pp:nh_z", rownames(ct), value=TRUE)[1]
  data.table(outcome=o$lab, kaitz_control=kaitz_ctl,
             est=ct[cn,"Estimate"], se=ct[cn,"Std. Error"], p=ct[cn,"Pr(>|t|)"],
             n=nobs(m))
}
dose <- rbindlist(lapply(OUTS, function(o) rbind(
  cbind(reform="2022", dose_fit(D22, o, FALSE)),
  cbind(reform="2022", dose_fit(D22, o, TRUE)),
  cbind(reform="2025", dose_fit(D25, o, FALSE)),
  cbind(reform="2025", dose_fit(D25, o, TRUE)))))
fwrite(dose, file.path(DIR_OUT, "state_dose.csv"))
cat("\n==== (2) Low x Post x NewHire_z (dept match-creation dose) ====\n")
print(dose[, .(reform, outcome, kaitz = ifelse(kaitz_control,"+Kaitz",""),
               est=round(est,4), se=round(se,4), p=round(p,4))][order(outcome, reform, kaitz)])

cat("\nDone: 22_state_dependence.R\n")
