# ==============================================================================
# 21_panel_transitions.R
# Purpose: Worker-level transitions across the May-2022 reform using the
#          ENAHO Panel 2020-2024 (INEI survey 978, module 1477 = employment,
#          file enaho01a-2020-2024-500-panel.dta; verified 2026-07-12).
#          This addresses the repeated-cross-section limitation of the main
#          design: with linked persons I can separate worker-level exits from
#          formality (the reallocation mechanism) from composition changes.
# Design:  Stack year pairs t -> t+1 (2020-21, 2021-22, 2022-23, 2023-24),
#          linked by perpanelYYZZ and weighted by facpanelYYZZ. Classify each
#          pair-observation by its position relative to the reform using the
#          2022 interview month (the reform takes effect 1 May 2022):
#            PRE    = 2020->21; 2021->22 with mes_22 in 1..4
#            REFORM = 2021->22 with mes_22 >= 5; 2022->23 with mes_22 in 1..4
#                     (base state measured before the reform, destination after)
#            POST   = 2022->23 with mes_22 >= 5; 2023->24
#          Among base-year FORMAL private workers, estimate the DiD
#            y = b1 (Low x REFORM) + b2 (Low x POST) + Low + pair FE + X + e
#          for destinations: still formal, informal job, self-employment,
#          non-employment. b1 is the differential change in the transition
#          rate of low-educated workers across the reform window relative to
#          normal-times transitions. Symmetric entry margin (base = informal)
#          is also estimated. SEs clustered by department of the base year.
# Definitions replicate 01_build_panel.R exactly: employed = ocu500==1;
#          public = p510 in 1..3; wage worker = p507 in {3,4,6}; informality =
#          official ocupinf (1 = informal, 2 = formal) where released, else the
#          INEI-style Rule F from pension / contract / firm registration
#          (pension items carry their option code, not 1).
# Output:  output/panel_transitions_matrix.csv  (weighted transition matrices)
#          output/panel_transitions_did.csv     (stacked DiD estimates)
#          output/panel_entry_did.csv           (informality -> formal entry)
# ==============================================================================

source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
suppressMessages({library(haven); library(fixest)})

PANEL_DTA <- file.path(dirname(RAW_ENAHO), "Data", "ENAHO", "panel",
                       "978-Modulo1477", "enaho01a-2020-2024-500-panel.dta")
# RAW_ENAHO already points inside Data/ENAHO; resolve robustly:
if (!file.exists(PANEL_DTA)) {
  PANEL_DTA <- file.path(RAW_ENAHO, "panel", "978-Modulo1477",
                         "enaho01a-2020-2024-500-panel.dta")
}
if (!file.exists(PANEL_DTA)) {
  message("21_panel_transitions.R SKIPPED: ENAHO Panel 2020-2024 file not found.\n",
          "  Expected at Data/ENAHO/panel/978-Modulo1477/ (see REPLICATION.md).")
  quit(save = "no", status = 0)
}

YRS <- c("20","21","22","23","24")
per_year <- function(v) paste0(v, "_", YRS)
BASE_VARS <- c("mes","ubigeo","p301a","p207","p208a","p507","p510","p510a1",
               "p511a","p558a1","p558a2","p558a3","p558a4","p558a5",
               "ocu500","ocupinf","fac500a")
PAIRS <- data.table(t   = c("20","21","22","23"),
                    t1  = c("21","22","23","24"),
                    per = c("perpanel2021","perpanel2122","perpanel2223","perpanel2324"),
                    fac = c("facpanel2021","facpanel2122","facpanel2223","facpanel2324"))

want <- c(unlist(lapply(BASE_VARS, per_year)), PAIRS$per, PAIRS$fac)
cat("Reading", basename(PANEL_DTA), "(selected columns)...\n")
raw <- as.data.table(haven::read_dta(PANEL_DTA,
         col_select = tidyselect::any_of(want)))
# ubigeo is sometimes stored as character ("150101"); as.numeric handles both
raw <- raw[, lapply(.SD, function(x) suppressWarnings(as.numeric(haven::zap_labels(x))))]
cat("Loaded:", nrow(raw), "persons x", ncol(raw), "cols\n")

## ---- Per-year worker states ---------------------------------------------------
# state codes: 1 formal private job, 2 informal wage job, 3 self-employment
#              (own-account or employer, any formality), 4 other employed
#              (public sector, TFNR, domestic informal handled by rules below),
#              5 non-employed
year_state <- function(y) {
  g <- function(v) {
    cn <- paste0(v, "_", y)
    if (cn %in% names(raw)) raw[[cn]] else rep(NA_real_, nrow(raw))
  }
  emp   <- as.integer(g("ocu500") == 1)
  pub   <- as.integer(g("p510") %in% c(1,2,3))
  p507  <- g("p507")
  wagew <- as.integer(p507 %in% c(3,4,6))
  self  <- as.integer(p507 %in% c(1,2))          # employer or own-account
  tfnr  <- as.integer(p507 == 5)
  # informality: official ocupinf (1 informal / 2 formal) where present,
  # else INEI-style Rule F (as in 01_build_panel.R)
  pens <- fifelse(
    (!is.na(g("p558a1")) & g("p558a1") > 0) | (!is.na(g("p558a2")) & g("p558a2") > 0) |
    (!is.na(g("p558a3")) & g("p558a3") > 0) | (!is.na(g("p558a4")) & g("p558a4") > 0), 1L,
    fifelse(!is.na(g("p558a5")) & g("p558a5") > 0, 0L, NA_integer_))
  contr <- as.integer(g("p511a") %in% 1:6); contr[is.na(contr)] <- 0L
  freg  <- as.integer(g("p510a1") == 1);    freg[is.na(freg)]  <- 0L
  inf_F <- rep(NA_integer_, nrow(raw))
  i1 <- which(emp==1 & wagew==1)
  inf_F[i1] <- fifelse(pens[i1]==1 | contr[i1]==1, 0L,
                       fifelse(pens[i1]==0, 1L, NA_integer_))
  i2 <- which(emp==1 & self==1);  inf_F[i2] <- as.integer(freg[i2] == 0)
  i3 <- which(emp==1 & tfnr==1);  inf_F[i3] <- 1L
  i4 <- which(emp==1 & p507==7);  inf_F[i4] <- as.integer(pens[i4] == 0)
  oi <- g("ocupinf")
  informal <- fifelse(!is.na(oi) & oi %in% c(1,2), as.integer(oi == 1), inf_F)

  st <- rep(5L, nrow(raw))                        # non-employed
  st[which(emp==1)] <- 4L                         # other employed
  st[which(emp==1 & pub==0 & self==1)] <- 3L      # self-employment
  st[which(emp==1 & pub==0 & informal==1 & wagew==1)] <- 2L
  st[which(emp==1 & pub==0 & informal==0)] <- 1L  # formal private
  ub <- g("ubigeo")
  data.table(
    state = st, employed = emp, pub = pub,
    formal_priv = as.integer(st == 1L),
    informal_any = fifelse(emp==1, informal, NA_integer_),
    self_emp = as.integer(emp==1 & pub==0 & self==1),
    low  = fifelse(g("p301a") %in% 1:6, 1L,
             fifelse(g("p301a") %in% 7:11, 0L, NA_integer_)),
    age  = g("p208a"), female = as.integer(g("p207") == 2),
    region = sprintf("%02d", as.integer(ub) %/% 10000),
    mes = g("mes"), fac = g("fac500a"))
}
states <- lapply(setNames(YRS, YRS), year_state)

## ---- Stack pairs ---------------------------------------------------------------
mk_pair <- function(i) {
  p <- PAIRS[i]
  b <- states[[p$t]]; d <- states[[p$t1]]
  keep <- !is.na(raw[[p$per]]) & raw[[p$per]] == 1
  dt <- data.table(
    pair    = paste0("20", p$t, "-20", p$t1),
    w       = raw[[p$fac]][keep],
    low     = b$low[keep], age = b$age[keep], female = b$female[keep],
    region  = b$region[keep],
    base_state = b$state[keep], dest_state = d$state[keep],
    mes22   = if ("mes_22" %in% names(raw)) raw[["mes_22"]][keep] else NA_real_)
  # period classification relative to the 1-May-2022 reform
  if (p$t == "20") dt[, period := "PRE"]
  if (p$t == "21") dt[, period := fifelse(!is.na(mes22) & mes22 >= 5, "REFORM", "PRE")]
  if (p$t == "22") dt[, period := fifelse(!is.na(mes22) & mes22 <= 4, "REFORM", "POST")]
  if (p$t == "23") dt[, period := "POST"]
  dt
}
PP <- rbindlist(lapply(seq_len(nrow(PAIRS)), mk_pair))
PP <- PP[!is.na(low) & !is.na(w) & w > 0 & !is.na(base_state) & !is.na(dest_state) &
         !is.na(age) & age >= AGE_MIN & age <= AGE_MAX]
PP[, `:=`(age2 = age^2,
          reform = as.integer(period == "REFORM"),
          post   = as.integer(period == "POST"))]
cat("\nStacked pair-observations:", nrow(PP), "\n")
print(PP[, .N, by = .(pair, period)][order(pair, period)])

## ---- (1) Weighted transition matrices, base = formal private -------------------
F0 <- PP[base_state == 1]
lab_state <- c("1"="still formal", "2"="informal wage job", "3"="self-employment",
               "4"="other employed", "5"="non-employed")
mat <- F0[, .(share = sum(w)), by = .(period, low, dest_state)]
mat[, share := share / sum(share), by = .(period, low)]
mat[, destination := lab_state[as.character(dest_state)]]
mat_w <- dcast(mat, period + destination ~ low, value.var = "share")
setnames(mat_w, c("0","1"), c("high_educ","low_educ"))
mat_w <- mat_w[order(factor(period, levels=c("PRE","REFORM","POST")), destination)]
fwrite(mat_w, file.path(DIR_OUT, "panel_transitions_matrix.csv"))
cat("\n==== Transition shares from FORMAL PRIVATE (base year), weighted ====\n")
print(mat_w[, .(period, destination, low = round(low_educ,3), high = round(high_educ,3))])

## ---- (2) Stacked DiD on transitions, base = formal private ---------------------
F0[, `:=`(y_stay = as.integer(dest_state == 1),
          y_inf  = as.integer(dest_state == 2),
          y_self = as.integer(dest_state == 3),
          y_none = as.integer(dest_state == 5))]
OUTS <- list(
  list(y="y_stay", lab="Still formal private"),
  list(y="y_inf",  lab="To informal wage job"),
  list(y="y_self", lab="To self-employment"),
  list(y="y_none", lab="To non-employment"))
did <- rbindlist(lapply(OUTS, function(o) {
  m <- feols(as.formula(sprintf(
        "%s ~ low:reform + low:post + low + age + age2 + female | pair + region", o$y)),
        F0, weights = ~w, cluster = ~region)
  ct <- coeftable(m)
  base_lo <- F0[low==1 & period=="PRE", weighted.mean(get(o$y), w)]
  data.table(outcome = o$lab, base_pre_low = base_lo,
             b_reform = ct["low:reform","Estimate"], se_reform = ct["low:reform","Std. Error"],
             p_reform = ct["low:reform","Pr(>|t|)"],
             b_post = ct["low:post","Estimate"], se_post = ct["low:post","Std. Error"],
             p_post = ct["low:post","Pr(>|t|)"], n = nobs(m))
}))
fwrite(did, file.path(DIR_OUT, "panel_transitions_did.csv"))
cat("\n==== Stacked DiD, base = formal private workers ====\n")
cat("(Low x REFORM = differential transition change across the reform window)\n")
print(did[, .(outcome, base=round(base_pre_low,3),
              reform=sprintf("%.4f (%.4f) p=%.3f", b_reform, se_reform, p_reform),
              post=sprintf("%.4f (%.4f) p=%.3f", b_post, se_post, p_post), n)])

## ---- (3) Entry margin: base = informal employed --------------------------------
I0 <- PP[base_state %in% c(2,3)]        # informal wage job or self-employment
I0[, y_formal := as.integer(dest_state == 1)]
ent <- feols(y_formal ~ low:reform + low:post + low + age + age2 + female | pair + region,
             I0, weights = ~w, cluster = ~region)
ct <- coeftable(ent)
ent_tab <- data.table(outcome = "Informal/self -> formal private",
  base_pre_low = I0[low==1 & period=="PRE", weighted.mean(y_formal, w)],
  b_reform = ct["low:reform","Estimate"], se_reform = ct["low:reform","Std. Error"],
  p_reform = ct["low:reform","Pr(>|t|)"],
  b_post = ct["low:post","Estimate"], se_post = ct["low:post","Std. Error"],
  p_post = ct["low:post","Pr(>|t|)"], n = nobs(ent))
fwrite(ent_tab, file.path(DIR_OUT, "panel_entry_did.csv"))
cat("\n==== Entry margin: base = informal employed ====\n")
print(ent_tab[, .(outcome, base=round(base_pre_low,3),
              reform=sprintf("%.4f (%.4f) p=%.3f", b_reform, se_reform, p_reform),
              post=sprintf("%.4f (%.4f) p=%.3f", b_post, se_post, p_post), n)])

## ---- (4) Robustness: fully-post second interview only for the REFORM pair ------
F0r <- F0[!(period=="REFORM" & pair=="2021-2022" & !is.na(mes22) & mes22==5)]
rob <- feols(y_stay ~ low:reform + low:post + low + age + age2 + female | pair + region,
             F0r, weights=~w, cluster=~region)
cat("\nRobustness (drop May-2022 interviews from REFORM pair), still formal:\n")
print(coeftable(rob)[c("low:reform","low:post"), , drop=FALSE])

cat("\nDone: 21_panel_transitions.R\n")
