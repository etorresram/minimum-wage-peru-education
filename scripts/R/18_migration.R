# ==============================================================================
# 18_migration.R
# Purpose: Robustness to the Venezuelan immigration wave. The large inflow
#   (about 1.5 million people, concentrated in 2018-2019 and in Lima and the
#   urban coast) competes with low-education natives in informal urban labor
#   markets, so it is a candidate confounder for the education contrast.
#   Three checks:
#   (a) department x quarter fixed effects: absorbs ANY local shock common to
#       both education groups within a department-quarter, including migrant
#       inflows and regularization waves; identification is within-cell.
#   (b) excluding Lima and Callao, which host the large majority of the
#       Venezuelan population;
#   (c) excluding the eight departments with the largest Venezuelan presence
#       (Lima, Callao, La Libertad, Arequipa, Lambayeque, Piura, Ica, Tumbes).
#   Note the spatial logic: migrants concentrate in LOW-bite departments
#   (Lima and the coast), so a migration confound would generate effects
#   concentrated in low-bite areas, the opposite of the observed dose-response.
# Output: output/rob_migration.csv
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
suppressMessages(library(fixest))

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
D  <- DT[in_window==1 & working_age==1 & !is.na(skill) & transition==0]
D[, did := low*post]
CTRL <- "age+age2+female+married+urban+years_educ"

MIG_TOP2 <- c("15","07")
MIG_TOP8 <- c("15","07","13","04","14","20","11","24")

OUTS <- list(
  list(y="log_wage_hr", lab="Log hourly wage", flt=quote(wage_valid==1)),
  list(y="employed",    lab="Employment",      flt=quote(rep(TRUE,.N))),
  list(y="formal",      lab="Formal empl.",    flt=quote(employed==1 & public_sector==0)),
  list(y="self_emp",    lab="Self-employment", flt=quote(employed==1 & public_sector==0)))

run <- function(o, spec, fe="t_index + region", drop=NULL) {
  d <- D[eval(o$flt)]
  if (!is.null(drop)) d <- d[!region %in% drop]
  m <- feols(as.formula(sprintf("%s ~ did + low + %s | %s", o$y, CTRL, fe)),
             d, weights=~fac500a, cluster=~region)
  ct <- coeftable(m)["did", ]
  data.table(outcome=o$lab, spec=spec, est=ct[["Estimate"]],
             se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]], n=nobs(m))
}

res <- rbindlist(lapply(OUTS, function(o) rbind(
  run(o, "baseline"),
  run(o, "region_x_quarter_fe", fe="region^t_index"),
  run(o, "excl_lima_callao",  drop=MIG_TOP2),
  run(o, "excl_top8_migration", drop=MIG_TOP8)
)))
fwrite(res, file.path(DIR_OUT, "rob_migration.csv"))
cat("==== Robustness to the Venezuelan immigration wave ====\n")
print(res[, .(outcome, spec, est=round(est,4), se=round(se,4), p=round(p,4), n)])
cat("\nDone: 18_migration.R\n")
