# ==============================================================================
# 04_descriptives_figures.R
# Purpose: Descriptive statistics table (by skill group), and the descriptive /
#          event-study publication figures.
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "."),
        "scripts", "R", "00_config.R"))
source(file.path(PROJ_ROOT, "scripts", "R", "theme_paper.R"))
suppressMessages({library(data.table); library(ggplot2); library(matrixStats)})

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
W  <- DT[in_window==1 & working_age==1 & !is.na(skill)]
W[, wage_hr_w := ifelse(wage_valid==1, winsorize(wage_hr_real), NA)]

## ============================ TABLE 1: descriptives ==========================
wm  <- function(x,w) weighted.mean(x,w,na.rm=TRUE)
vars <- list(
  c("age","Age"), c("female","Female"), c("urban","Urban"), c("married","Married"),
  c("years_educ","Years of education"), c("lfp","Labour force participation"),
  c("employed","Employed"), c("wage_worker","Wage employee (incl. domestic)"),
  c("self_emp","Self-employed"),
  c("formal","Formal (if employed)"), c("informal","Informal (if employed)"),
  c("hours_main","Weekly hours (if employed)"), c("wage_hr_w","Real hourly wage (S/)"),
  c("ylab_real","Real monthly earnings (S/)"), c("below_mw","Below MW (wage earners)"))
pre <- W[t_index < 6]  # pre-reform descriptives
mk_col <- function(d, v) {
  x <- d[[v]]
  if (v %in% c("formal","informal","hours_main","wage_hr_w","below_mw"))
    d2 <- d[employed==1] else d2 <- d
  if (v=="wage_hr_w") d2 <- d[wage_valid==1]
  if (v=="ylab_real") d2 <- d[employed==1]
  wm(d2[[v]], d2$fac500a)
}
tab1 <- rbindlist(lapply(vars, function(v) {
  data.table(Variable=v[2],
             Low  = mk_col(pre[low==1], v[1]),
             High = mk_col(pre[low==0], v[1]))
}))
tab1[, Difference := Low - High]
fwrite(tab1, file.path(DIR_OUT, "tab_descriptives.csv"))

# LaTeX
fmt <- function(x) sub("^-(0\\.0+)$", "\\1", formatC(x, format="f", digits=2, big.mark=","))
lt <- c("\\begin{tabular}{lccc}", "\\toprule",
        " & Low-skilled & High-skilled & Difference \\\\",
        " & ($\\le$ sec. complete) & ($\\ge$ higher) & \\\\", "\\midrule")
for (i in seq_len(nrow(tab1)))
  lt <- c(lt, sprintf("%s & %s & %s & %s \\\\", tab1$Variable[i],
          fmt(tab1$Low[i]), fmt(tab1$High[i]), fmt(tab1$Difference[i])))
np <- pre[, .(n=.N), by=low]
lt <- c(lt, "\\midrule",
        sprintf("Observations & %s & %s & \\\\",
                format(np[low==1]$n, big.mark=","), format(np[low==0]$n, big.mark=",")),
        "\\bottomrule", "\\end{tabular}")
writeLines(lt, file.path(DIR_TAB, "tab_descriptives.tex"))
cat("Table 1 (descriptives) written.\n")

## ==================== FIGURE 1: MW, real MW, and CPI =========================
cpi <- fread(file.path(DIR_PROC, "cpi_lima_dec2021.csv"))
cpi[, date := as.Date(sprintf("%d-%02d-01", year, month))]
cpi[, mw := mw_value(year, month)]
cpi[, mw_real := mw / (cpi/100)]
f1dat <- melt(cpi[, .(date, `Nominal MW`=mw, `Real MW (Dec-2021 S/)`=mw_real)],
              id.vars="date")
p1 <- ggplot(f1dat, aes(date, value, colour=variable, linetype=variable)) +
  geom_vline(xintercept=as.Date(c("2022-05-01","2025-01-01")), colour="grey60", linetype=3) +
  geom_line(linewidth=0.8) +
  annotate("text", x=as.Date("2022-05-01"), y=max(f1dat$value), label="  D.S. 003-2022-TR",
           hjust=0, size=3, colour="grey30") +
  scale_colour_manual(values=pal_two) +
  labs(x=NULL, y="Soles per month", colour=NULL, linetype=NULL,
       title="The Peruvian minimum wage, 2021-2025",
       caption="Vertical lines: reforms effective 1 May 2022 and 1 Jan 2025. Real series deflated by Lima CPI (Dec-2021=100).") +
  theme_paper()
save_fig(p1, "fig1_minimum_wage")

## ============ FIGURE 2: raw weighted trends by skill group ===================
qtrend <- function(sub, yv) {
  sub[, .(m=weighted.mean(get(yv), fac500a, na.rm=TRUE),
          n=.N), by=.(t_index, skill)][, `:=`(outcome=yv)]
}
emp <- W[employed==1]
depw <- W[wage_valid==1 & !is.na(wage_hr_w)]
trd <- rbindlist(list(
  qtrend(W, "employed"),
  qtrend(emp, "formal"),
  qtrend(emp, "self_emp"),
  depw[, .(m=weighted.mean(log(wage_hr_w), fac500a, na.rm=TRUE), n=.N,
           outcome="log_wage"), by=.(t_index, skill)]
))
lab_map <- c(employed="Employment rate", formal="Formal share (empl.)",
             self_emp="Self-employed share (empl.)", log_wage="Mean log real hourly wage")
trd[, outcome_lab := lab_map[outcome]]
trd[, date := as.Date("2021-01-01") + (t_index-1)*91]
p2 <- ggplot(trd, aes(date, m, colour=skill, shape=skill)) +
  geom_vline(xintercept=as.Date("2022-04-15"), colour="grey55", linetype=3) +
  geom_line(linewidth=0.6) + geom_point(size=1.3) +
  facet_wrap(~outcome_lab, scales="free_y") +
  scale_colour_manual(values=pal_skill) +
  labs(x=NULL, y=NULL, colour="Skill", shape="Skill",
       title="Raw outcome trends by skill group",
       caption="Weighted quarterly means. Dashed line: May-2022 reform.") +
  theme_paper()
save_fig(p2, "fig2_raw_trends", w=7.2, h=5)

## ============ FIGURE 3: regional minimum-wage bite (Kaitz) ====================
br <- fread(file.path(DIR_PROC, "bite_region.csv"))
dep_names <- c("01"="Amazonas","02"="Ancash","03"="Apurimac","04"="Arequipa",
  "05"="Ayacucho","06"="Cajamarca","07"="Callao","08"="Cusco","09"="Huancavelica",
  "10"="Huanuco","11"="Ica","12"="Junin","13"="La Libertad","14"="Lambayeque",
  "15"="Lima","16"="Loreto","17"="Madre de Dios","18"="Moquegua","19"="Pasco",
  "20"="Piura","21"="Puno","22"="San Martin","23"="Tacna","24"="Tumbes","25"="Ucayali")
br[, dep := dep_names[region]]
p3 <- ggplot(br, aes(reorder(dep, kaitz), kaitz, fill=factor(high_bite))) +
  geom_col(width=0.72) + coord_flip() +
  geom_hline(yintercept=1, colour="grey40", linetype=2) +
  scale_fill_manual(values=c("0"="#9ecae1","1"="#08519c"),
                    labels=c("0"="Low bite","1"="High bite")) +
  labs(x=NULL, y="Kaitz index (new MW / pre-reform median wage)", fill=NULL,
       title="Minimum-wage bite across departments (pre-reform)") +
  theme_paper()
save_fig(p3, "fig3_regional_bite", w=6.5, h=5.2)

## ============ FIGURE 4: wage distribution & bunching =========================
bd <- W[employed==1 & wage_worker==1 & public_sector==0 & ylab_nom>0 & ylab_nom<4000]
bd[, period := ifelse(post==1, "Post (2022Q2-2024Q4)", "Pre (2021Q1-2022Q1)")]
p4 <- ggplot(bd[skill=="Low"], aes(ylab_nom, weight=fac500a, colour=period)) +
  geom_vline(xintercept=c(930,1025), colour=c("#1b6ca8","#c1272d"), linetype=2) +
  geom_density(linewidth=0.8, adjust=0.6) +
  annotate("text", x=930, y=0, label="930", vjust=-0.5, hjust=1.1, size=3, colour="#1b6ca8") +
  annotate("text", x=1025, y=0, label="1025", vjust=-0.5, hjust=-0.1, size=3, colour="#c1272d") +
  scale_colour_manual(values=pal_two) +
  labs(x="Nominal monthly earnings (S/)", y="Density", colour=NULL,
       title="Earnings distribution of low-skilled wage employees",
       caption="Dashed lines: old (930) and new (1025) minimum wage. Weighted kernel densities.") +
  theme_paper()
save_fig(p4, "fig4_wage_distribution")

## ============ FIGURE 5: event-study plots ===================================
es <- fread(file.path(DIR_OUT, "event_study_coefs.csv"))
es_lab <- c(log_wage_hr="Log real hourly wage", employed="Employment (working age)",
            formal="Formal employment", self_emp="Self-employment",
            hours_main="Weekly hours", below_mw="Paid below MW",
            log_ylab="Log real monthly earnings")
es <- es[outcome %in% names(es_lab)]
es[, lab := factor(es_lab[outcome], levels=es_lab)]
es[, ymin := est-1.96*se][, ymax := est+1.96*se]
p5 <- ggplot(es, aes(event_k, est)) +
  geom_hline(yintercept=0, colour="grey55") +
  geom_vline(xintercept=-0.5, colour="grey55", linetype=3) +
  geom_ribbon(aes(ymin=ymin, ymax=ymax), fill="#1b6ca8", alpha=0.15) +
  geom_line(colour="#1b6ca8", linewidth=0.5) +
  geom_point(colour="#1b6ca8", size=1.1) +
  facet_wrap(~lab, scales="free_y") +
  scale_x_continuous(breaks=seq(-5,10,2)) +
  labs(x="Quarters since reform (0 = 2022Q2, partially treated, excluded)", y="Low x period coefficient",
       title="Event-study estimates: low- vs high-skilled workers",
       caption="Reference quarter 2022Q1 (k=-1). The partially treated 2022Q2 (k=0) is excluded. Bands: 95% CI, SE clustered by department.") +
  theme_paper()
save_fig(p5, "fig5_event_study", w=7.6, h=6)

cat("All descriptive and event-study figures written to figures/.\n")
