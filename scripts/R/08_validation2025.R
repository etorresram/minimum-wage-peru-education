# ==============================================================================
# 08_validation2025.R
# Purpose: Out-of-sample validation using the SECOND reform (D.S. 006-2024-TR,
#          S/1025 -> S/1130, effective 1 Jan 2025). Window 2024Q1-2025Q4, a
#          cleaner post-pandemic period. Same low- vs high-skilled DiD design.
#          Note: informality is reconstructed for both years here (ocupinf absent
#          in 2024-2025), so it is measured consistently within this window.
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
source(file.path(PROJ_ROOT, "scripts", "R", "theme_paper.R"))
suppressMessages({library(fixest); library(ggplot2)})

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
# window 2024Q1 (t=13) .. 2025Q4 (t=20); reform 2025Q1 (t=17)
V <- DT[t_index>=13 & working_age==1 & !is.na(skill)]
V[, post2 := as.integer(t_index>=17)]
V[, did := low*post2]
V[(employed==1 & dependent==1 & wage_hr_real>0), log_wage_hr := log(winsorize(wage_hr_real))]
CTRL <- "age+age2+female+married+urban+years_educ"

outs <- list(
  list(y="log_wage_hr", lab="Log hourly wage", flt=quote(employed==1 & dependent==1 & is.finite(log_wage_hr))),
  list(y="employed",    lab="Employment",      flt=quote(rep(TRUE,.N))),
  list(y="formal",      lab="Formal empl.",    flt=quote(employed==1)),
  list(y="self_emp",    lab="Self-employment", flt=quote(employed==1)))

did2025 <- rbindlist(lapply(outs, function(o) {
  s <- V[eval(o$flt)]
  m <- feols(as.formula(sprintf("%s ~ did + low + %s | t_index + region", o$y, CTRL)),
             s, weights=~fac500a, cluster=~region)
  ct <- coeftable(m)["did", ]
  data.table(outcome=o$lab, att=ct[["Estimate"]], se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]], n=nobs(m))
}))
fwrite(did2025, file.path(DIR_OUT, "validation2025_did.csv"))
cat("==== 2025 reform DiD (Low x Post, window 2024-2025) ====\n"); print(did2025)

# event study around 2025Q1 (ref = 2024Q4 = t16)
es2025 <- rbindlist(lapply(outs, function(o) {
  s <- V[eval(o$flt)]
  m <- feols(as.formula(sprintf("%s ~ i(t_index, low, ref=16) + low + %s | t_index + region", o$y, CTRL)),
             s, weights=~fac500a, cluster=~region)
  ct <- as.data.table(coeftable(m), keep.rownames="term")[grepl("^t_index::", term)]
  ct[, t_index := as.integer(sub("t_index::(\\d+):low","\\1",term))]
  ct[, event_k := t_index-17][, outcome := o$lab]
  setnames(ct, c("Estimate","Std. Error"), c("est","se"))
  ct[, .(outcome,event_k,est,se)]
}))
ref <- unique(es2025[,.(outcome)])[,`:=`(event_k=-1L,est=0,se=0)]
es2025 <- rbind(es2025, ref)[order(outcome,event_k)]
fwrite(es2025, file.path(DIR_OUT, "validation2025_es.csv"))

p9 <- ggplot(es2025, aes(event_k, est)) +
  geom_hline(yintercept=0, colour="grey55") + geom_vline(xintercept=-0.5, colour="grey55", linetype=3) +
  geom_ribbon(aes(ymin=est-1.96*se, ymax=est+1.96*se), fill="#c1272d", alpha=0.15) +
  geom_line(colour="#c1272d", linewidth=0.5) + geom_point(colour="#c1272d", size=1.1) +
  facet_wrap(~outcome, scales="free_y") +
  labs(x="Quarters since 2025 reform (0 = 2025Q1)", y="Low x period coefficient",
       title="Out-of-sample validation: the January-2025 minimum-wage reform",
       caption="Reference quarter 2024Q4. Bands: 95% CI clustered by department.") +
  theme_paper()
save_fig(p9, "fig9_validation2025", w=7, h=4.6)
cat("Done: 08_validation2025.R\n")
