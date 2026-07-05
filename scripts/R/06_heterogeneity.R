# ==============================================================================
# 06_heterogeneity.R
# Purpose: Heterogeneous effects of the reform. Within each subgroup we estimate
#          the low- vs high-skilled DiD (Low x Post) for the headline outcomes.
# Output:  output/heterogeneity.csv, figures/fig6_heterogeneity.(pdf|png)
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
source(file.path(PROJ_ROOT, "scripts", "R", "theme_paper.R"))
suppressMessages({library(fixest); library(ggplot2)})

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
# Baseline sample: drops the partially treated 2022Q2 transition quarter (as in
# 03); wage outcomes use the canonical winsorized logs built in 01_build_panel.R.
D  <- DT[in_window==1 & working_age==1 & !is.na(skill) & transition==0]
D[, did := low*post]
D[, agegrp := fifelse(age<=25,"Youth (14-25)", fifelse(age<=45,"Prime (26-45)","Older (46-65)"))]
CTRL <- "age+age2+female+married+urban+years_educ"

did_sub <- function(dat, y, flt) {
  s <- dat[eval(flt)]
  if (nrow(s)<500 || uniqueN(s$did)<2) return(NULL)
  m <- tryCatch(feols(as.formula(sprintf("%s ~ did + low + %s | t_index + region", y, CTRL)),
             s, weights=~fac500a, cluster=~region), error=function(e) NULL)
  if (is.null(m) || !("did" %in% names(coef(m)))) return(NULL)
  ct <- coeftable(m)["did", ]
  data.table(est=ct[["Estimate"]], se=ct[["Std. Error"]], p=ct[["Pr(>|t|)"]], n=nobs(m))
}

outs <- list(c("employed","Employment", "rep(TRUE,.N)"),
             c("formal","Formal empl.","employed==1 & public_sector==0"),
             c("self_emp","Self-employment","employed==1 & public_sector==0"),
             c("log_wage_hr","Log hourly wage","wage_valid==1"))

subgroups <- list(
  list(dim="Overall",   lab="All",           flt=quote(rep(TRUE,.N))),
  list(dim="Gender",    lab="Men",           flt=quote(female==0)),
  list(dim="Gender",    lab="Women",         flt=quote(female==1)),
  list(dim="Age",       lab="Youth (14-25)", flt=quote(agegrp=="Youth (14-25)")),
  list(dim="Age",       lab="Prime (26-45)", flt=quote(agegrp=="Prime (26-45)")),
  list(dim="Age",       lab="Older (46-65)", flt=quote(agegrp=="Older (46-65)")),
  list(dim="Area",      lab="Urban",         flt=quote(urban==1)),
  list(dim="Area",      lab="Rural",         flt=quote(urban==0)),
  list(dim="MW bite",   lab="High-bite reg.",flt=quote(high_bite==1)),
  list(dim="MW bite",   lab="Low-bite reg.", flt=quote(high_bite==0))
)

het <- rbindlist(lapply(outs, function(o) {
  rbindlist(lapply(subgroups, function(g) {
    # combine outer subgroup filter with the outcome's own sample filter
    flt <- bquote(.(g$flt) & .(str2lang(o[3])))
    r <- did_sub(D, o[1], flt)
    if (is.null(r)) return(NULL)
    cbind(data.table(outcome=o[2], dim=g$dim, group=g$lab), r)
  }))
}))
fwrite(het, file.path(DIR_OUT, "heterogeneity.csv"))
cat("Heterogeneity estimates:\n"); print(het[, .(outcome,dim,group,est=round(est,4),se=round(se,4),p=round(p,3))])

## coefficient plot
het[, group := factor(group, levels=rev(unique(sapply(subgroups,function(g) g$lab))))]
het[, outcome := factor(outcome, levels=sapply(outs,function(o) o[2]))]
p6 <- ggplot(het, aes(est, group, colour=dim)) +
  geom_vline(xintercept=0, colour="grey55") +
  geom_errorbarh(aes(xmin=est-1.96*se, xmax=est+1.96*se), height=0.25, linewidth=0.5) +
  geom_point(size=1.7) +
  facet_wrap(~outcome, scales="free_x", nrow=1) +
  scale_colour_brewer(palette="Dark2") +
  labs(x="Low x Post DiD estimate", y=NULL, colour=NULL,
       title="Heterogeneous effects of the May-2022 minimum-wage reform",
       caption="Each point: low- vs high-skilled DiD within the subgroup. Bars: 95% CI, SE clustered by department.") +
  theme_paper() + theme(legend.position="none")
save_fig(p6, "fig6_heterogeneity", w=9, h=5)
cat("Saved fig6_heterogeneity.\n")
