# ==============================================================================
# 11_exposure_cells.R
# Purpose: Granular exposure designs and exposure-leads diagnostics.
#   (A) Leads test for the REGIONAL continuous-exposure design (exposure_z):
#       joint test that pre-reform quarter x exposure interactions are zero.
#       This is the design-based analogue of the pre-trend test and the key
#       diagnostic for the paper's corroborating design.
#   (B) Cell-level fraction-affected design (Card 1992; Clemens & Wither 2019):
#       exposure = pre-reform share of a department x skill x age cell's private
#       wage earners paid (i) between the old and new floors (frac_aff) or
#       (ii) below the new floor (frac_below). REPORTED AS A TRANSPARENCY
#       EXERCISE: both variants fail their leads diagnostics in this window --
#       fine-grained exposure is confounded with the cells' pandemic-recovery
#       trajectories (the between-floors variant even flips signs, because
#       cells with mass between the floors are the semi-formal cells that
#       recovered fastest). The regional design in (A) does not suffer this.
# Output: output/exposure_leads.csv, exposure_cells.csv, exposure_cell_did.csv,
#         exposure_cell_ri.csv
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
suppressMessages(library(fixest))
set.seed(20220501)

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
D  <- DT[in_window==1 & working_age==1 & !is.na(skill) & transition==0]
D[, agegrp := fifelse(age<=25, "Y", fifelse(age<=45, "P", "O"))]
D[, cell := paste(region, skill, agegrp, sep="_")]
CTRL <- "age+age2+female+married+urban+years_educ"
OLD_MW <- 930; NEW_MW <- 1025

OUTS <- list(
  list(y="log_wage_hr", lab="Log hourly wage", flt=quote(wage_valid==1)),
  list(y="employed",    lab="Employment",      flt=quote(rep(TRUE,.N))),
  list(y="formal",      lab="Formal empl.",    flt=quote(employed==1 & public_sector==0)),
  list(y="self_emp",    lab="Self-employment", flt=quote(employed==1 & public_sector==0)))

## ---- (A) Leads test for the regional continuous-exposure design --------------
leads <- rbindlist(lapply(OUTS, function(o) {
  d <- D[eval(o$flt) & !is.na(exposure_z)]
  me <- feols(as.formula(sprintf(
        "%s ~ i(t_index, exposure_z, ref=5) + %s | region + t_index", o$y, CTRL)),
        d, weights=~fac500a, cluster=~region)
  prc <- grep("t_index::[1-4]:exposure_z", names(coef(me)), value=TRUE)
  w <- tryCatch(wald(me, keep=prc, print=FALSE), error=function(e) NULL)
  data.table(design="regional_kaitz", outcome=o$lab,
             leads_p=if(!is.null(w)) w$p else NA)
}))
fwrite(leads, file.path(DIR_OUT, "exposure_leads.csv"))
cat("==== (A) Exposure-leads joint tests, regional Kaitz design ====\n")
print(leads)

## ---- (B) Cell-level fraction-affected design ---------------------------------
pre <- D[t_index<6 & employed==1 & wage_worker==1 & public_sector==0 &
         !is.na(ylab_nom)]
cells <- pre[, .(
    frac_aff   = weighted.mean(ylab_nom >= OLD_MW & ylab_nom < NEW_MW, fac500a),
    frac_below = weighted.mean(ylab_nom < NEW_MW, fac500a),
    n_wage     = .N), by=cell]
cat(sprintf("\nCells: %d | median wage earners per cell: %d | cells with n<30: %d\n",
            nrow(cells), as.integer(median(cells$n_wage)), sum(cells$n_wage<30)))
fwrite(cells, file.path(DIR_OUT, "exposure_cells.csv"))

D <- merge(D, cells, by="cell", all.x=TRUE)
D <- D[!is.na(frac_below) & n_wage >= 30]

run_cell <- function(o, expo) {
  d <- D[eval(o$flt)]
  m <- feols(as.formula(sprintf("%s ~ post:%s + %s | cell + t_index", o$y, expo, CTRL)),
             d, weights=~fac500a, cluster=~region)
  ct <- coeftable(m)[sprintf("post:%s", expo), ]
  me <- feols(as.formula(sprintf("%s ~ i(t_index, %s, ref=5) + %s | cell + t_index",
                                 o$y, expo, CTRL)),
              d, weights=~fac500a, cluster=~region)
  prc <- grep(sprintf("t_index::[1-4]:%s", expo), names(coef(me)), value=TRUE)
  w <- tryCatch(wald(me, keep=prc, print=FALSE), error=function(e) NULL)
  data.table(exposure=expo, outcome=o$lab, est=ct[["Estimate"]],
             se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]], n=nobs(m),
             leads_p=if(!is.null(w)) w$p else NA)
}
cell_res <- rbindlist(lapply(OUTS, function(o)
  rbind(run_cell(o, "frac_below"), run_cell(o, "frac_aff"))))
fwrite(cell_res, file.path(DIR_OUT, "exposure_cell_did.csv"))
cat("\n==== (B) Cell-level Post x exposure (cell FE + quarter FE) ====\n")
print(cell_res)

## RI for the frac_below variant (cell-level permutation, 2000 draws)
RI <- 2000
cell_expo <- unique(D[, .(cell, frac_below)])
ri <- rbindlist(lapply(OUTS, function(o) {
  d <- D[eval(o$flt)]
  cq <- d[, .(y=weighted.mean(get(o$y), fac500a, na.rm=TRUE), n=sum(fac500a),
              post=post[1]), by=.(cell, t_index)]
  cq <- merge(cq, cell_expo, by="cell", sort=FALSE)
  fit <- function(dat) tryCatch(
    feols(y ~ post:frac_below | cell + t_index, dat, weights=~n)$
      coefficients[["post:frac_below"]], error=function(e) NA_real_)
  obs <- fit(cq)
  null <- numeric(RI)
  for (b in seq_len(RI)) {
    lut <- data.table(cell=cell_expo$cell, fb=sample(cell_expo$frac_below))
    c2 <- copy(cq); c2[, frac_below := lut$fb[match(cell, lut$cell)]]
    null[b] <- fit(c2)
  }
  data.table(outcome=o$lab, obs_slope=obs,
             ri_p=mean(abs(null)>=abs(obs), na.rm=TRUE))
}))
fwrite(ri, file.path(DIR_OUT, "exposure_cell_ri.csv"))
cat("\n==== RI: permute frac_below across cells (2000 draws) ====\n")
print(ri)
cat("\nDone: 11_exposure_cells.R\n")
