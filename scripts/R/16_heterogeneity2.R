# ==============================================================================
# 16_heterogeneity2.R
# Purpose: Mechanism-oriented margins and additional heterogeneity.
#   (A) New adjustment-margin outcomes (education DiD):
#       - no_contract: share of wage earners without a written contract;
#       - micro_firm:  share of private workers in micro units (<= 20 workers);
#       - new_hire:    share of wage earners with tenure under 12 months
#                      (the hiring margin: a floor should slow formal hiring);
#       - second-margin decomposition of informality (2021-2023 only, where
#         INEI's emplpsec exists): informal job in the informal sector vs
#         informal job in the FORMAL sector.
#   (B) Additional subgroups for the headline outcomes: household head vs
#       non-head, indigenous vs non-indigenous self-identification.
# Output: output/margins2.csv, heterogeneity2.csv
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "."),
        "scripts", "R", "00_config.R"))
suppressMessages(library(fixest))

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
D  <- DT[in_window==1 & working_age==1 & !is.na(skill) & transition==0]
D[, did := low*post]
CTRL <- "age+age2+female+married+urban+years_educ"

did_one <- function(d, y) {
  m <- feols(as.formula(sprintf("%s ~ did + low + %s | t_index + region", y, CTRL)),
             d, weights=~fac500a, cluster=~region)
  ct <- coeftable(m)["did", ]
  ymean <- d[t_index<6, weighted.mean(get(y), fac500a, na.rm=TRUE)]
  data.table(att=ct[["Estimate"]], se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]],
             n=nobs(m), pre_mean=ymean)
}

## ---- (A) Adjustment margins ---------------------------------------------------
margins <- list(
  list(y="no_contract", lab="No written contract (wage earners)",
       flt=quote(employed==1 & wage_worker==1 & public_sector==0 & !is.na(no_contract))),
  list(y="micro_firm",  lab="Micro firm, <=20 workers (employed)",
       flt=quote(employed==1 & public_sector==0 & !is.na(micro_firm))),
  list(y="new_hire",    lab="Tenure < 12 months (wage earners)",
       flt=quote(employed==1 & wage_worker==1 & public_sector==0 & !is.na(new_hire))),
  list(y="inf_insector",  lab="Informal job, informal sector (2021-23)",
       flt=quote(employed==1 & public_sector==0 & !is.na(inf_insector) & year<=2023)),
  list(y="inf_outsector", lab="Informal job, FORMAL sector (2021-23)",
       flt=quote(employed==1 & public_sector==0 & !is.na(inf_outsector) & year<=2023))
)
mg <- rbindlist(lapply(margins, function(o)
  cbind(data.table(margin=o$lab), did_one(D[eval(o$flt)], o$y))))
fwrite(mg, file.path(DIR_OUT, "margins2.csv"))
cat("==== (A) Adjustment margins (Low x Post) ====\n"); print(mg)

## ---- (B) Subgroups: household head, indigenous --------------------------------
outs <- list(c("employed","Employment","rep(TRUE,.N)"),
             c("formal","Formal empl.","employed==1 & public_sector==0"),
             c("self_emp","Self-employment","employed==1 & public_sector==0"),
             c("log_wage_hr","Log hourly wage","wage_valid==1"))
subs <- list(
  list(dim="Household role", lab="Head",         flt=quote(hh_head==1)),
  list(dim="Household role", lab="Non-head",     flt=quote(hh_head==0)),
  list(dim="Ethnicity",      lab="Indigenous",   flt=quote(indigenous==1)),
  list(dim="Ethnicity",      lab="Non-indigenous", flt=quote(indigenous==0))
)
h2 <- rbindlist(lapply(outs, function(o) {
  rbindlist(lapply(subs, function(g) {
    d <- D[eval(g$flt) & eval(str2lang(o[3]))]
    if (nrow(d) < 500) return(NULL)
    r <- tryCatch(did_one(d, o[1]), error=function(e) NULL)
    if (is.null(r)) return(NULL)
    cbind(data.table(outcome=o[2], dim=g$dim, group=g$lab), r)
  }))
}))
fwrite(h2, file.path(DIR_OUT, "heterogeneity2.csv"))
cat("\n==== (B) Subgroups: household role and ethnicity ====\n")
print(h2[, .(outcome, dim, group, att=round(att,4), se=round(se,4), p=round(p,3))])
cat("\nDone: 16_heterogeneity2.R\n")
