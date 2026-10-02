# ==============================================================================
# 12_sector_occ.R
# Purpose: Sectoral and occupational falsification of the reallocation result.
#   (A) Sector contrast (CIIU Rev.4 divisions from p506r4): the education DiD
#       is estimated separately for workers in
#         - covered, high-bite sectors (manufacturing 10-33, construction 41-43,
#           trade 45-47, hotels & restaurants 55-56);
#         - agriculture (01-03), under the agrarian regime of Ley 31110. NOTE:
#           the agrarian daily remuneration is INDEXED to the RMV, so it rose
#           with the May-2022 reform -- agriculture is NOT a placebo group;
#           the split is a breadth/homogeneity check, and the RESULT (declines
#           of similar size everywhere, including agriculture) says the
#           reallocation is broad-based, consistent with an economy-wide floor.
#         - all other private non-agricultural sectors.
#   (B) Occupation dose-response (CNO-2015 2-digit from p505r4): pre-reform
#       occupation-level exposure (share of the occupation's private wage
#       earners paid below the new floor) interacted with Post, with occupation
#       FE. CAVEAT (stated in the paper): occupation is measured at the
#       interview, hence post-treatment for movers; this is descriptive
#       corroboration, not a primary design.
# Output: output/sector_did.csv, occ_doseresponse.csv
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "."),
        "scripts", "R", "00_config.R"))
suppressMessages(library(fixest))

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
D  <- DT[in_window==1 & working_age==1 & !is.na(skill) & transition==0]
D[, did := low*post]
CTRL <- "age+age2+female+married+urban+years_educ"
NEW_MW <- 1025

## ---- (A) Sector contrast ------------------------------------------------------
D[, sector_grp := fifelse(ind_div %in% 1:3, "Agriculture (agrarian regime)",
                   fifelse(ind_div %in% c(10:33, 41:43, 45:47, 55:56),
                           "Covered high-bite sectors",
                   fifelse(!is.na(ind_div), "Other private sectors", NA_character_)))]
# job-conditional outcomes only (sector is defined for the employed)
sec_outs <- list(
  list(y="formal",      lab="Formal empl.",    flt=quote(employed==1 & public_sector==0 & !is.na(sector_grp))),
  list(y="self_emp",    lab="Self-employment", flt=quote(employed==1 & public_sector==0 & !is.na(sector_grp))),
  list(y="log_wage_hr", lab="Log hourly wage", flt=quote(wage_valid==1 & !is.na(sector_grp))))
sec <- rbindlist(lapply(sec_outs, function(o) {
  rbindlist(lapply(unique(na.omit(D$sector_grp)), function(g) {
    d <- D[eval(o$flt) & sector_grp==g]
    if (nrow(d) < 1000) return(NULL)
    m <- tryCatch(feols(as.formula(sprintf("%s ~ did + low + %s | t_index + region", o$y, CTRL)),
               d, weights=~fac500a, cluster=~region), error=function(e) NULL)
    if (is.null(m)) return(NULL)
    ct <- coeftable(m)["did", ]
    data.table(outcome=o$lab, sector=g, est=ct[["Estimate"]],
               se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]], n=nobs(m))
  }))
}))
fwrite(sec, file.path(DIR_OUT, "sector_did.csv"))
cat("==== (A) Education DiD by sector coverage group ====\n"); print(sec)

## ---- (B) Occupation dose-response ---------------------------------------------
pre <- D[t_index<6 & employed==1 & wage_worker==1 & public_sector==0 &
         !is.na(ylab_nom) & !is.na(occ2)]
occ_expo <- pre[, .(occ_frac_below = weighted.mean(ylab_nom < NEW_MW, fac500a),
                    n_occ = .N), by=occ2][n_occ >= 100]
cat(sprintf("\nOccupations (2-digit) with n>=100: %d | exposure range: %.2f - %.2f\n",
            nrow(occ_expo), min(occ_expo$occ_frac_below), max(occ_expo$occ_frac_below)))
E <- merge(D[employed==1 & public_sector==0 & !is.na(occ2)],
           occ_expo, by="occ2")
occ_outs <- list(
  list(y="formal",      lab="Formal empl.",    flt=quote(rep(TRUE,.N))),
  list(y="self_emp",    lab="Self-employment", flt=quote(rep(TRUE,.N))),
  list(y="log_wage_hr", lab="Log hourly wage", flt=quote(wage_valid==1)),
  list(y="below_mw",    lab="Paid below MW",   flt=quote(wage_worker==1 & !is.na(below_mw))))
occ <- rbindlist(lapply(occ_outs, function(o) {
  d <- E[eval(o$flt)]
  m <- feols(as.formula(sprintf(
        "%s ~ post:occ_frac_below + %s | occ2 + t_index + region", o$y, CTRL)),
        d, weights=~fac500a, cluster=~region)
  ct <- coeftable(m)["post:occ_frac_below", ]
  me <- feols(as.formula(sprintf(
        "%s ~ i(t_index, occ_frac_below, ref=5) + %s | occ2 + t_index + region", o$y, CTRL)),
        d, weights=~fac500a, cluster=~region)
  prc <- grep("t_index::[1-4]:occ_frac_below", names(coef(me)), value=TRUE)
  w <- tryCatch(wald(me, keep=prc, print=FALSE), error=function(e) NULL)
  data.table(outcome=o$lab, est=ct[["Estimate"]], se=ct[["Std. Error"]],
             p=ct[["Pr(>|t|)"]], n=nobs(m),
             leads_p=if(!is.null(w)) w$p else NA)
}))
fwrite(occ, file.path(DIR_OUT, "occ_doseresponse.csv"))
cat("\n==== (B) Post x occupation exposure (occ FE + quarter FE + region FE) ====\n")
print(occ)
cat("\nDone: 12_sector_occ.R\n")
