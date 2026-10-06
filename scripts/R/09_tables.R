# ==============================================================================
# 09_tables.R  --  Build publication LaTeX tables (booktabs) from output CSVs.
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "."),
        "scripts", "R", "00_config.R"))

star <- function(p) ifelse(is.na(p),"",ifelse(p<0.01,"***",ifelse(p<0.05,"**",ifelse(p<0.1,"*",""))))
f3 <- function(x) formatC(x, format="f", digits=3)          # 3 decimals for all estimates
cell <- function(est,se,p) {                                 # estimate with stars (no empty ^{})
  s <- star(p); sprintf("%s%s", f3(est), if (nzchar(s)) paste0("$^{",s,"}$") else "")
}
secell <- function(se) sprintf("(%s)", f3(se))
# canonical, uniform outcome labels used across every table
LAB <- c("Log hourly wage"="Log real hourly wage", "Log real hourly wage"="Log real hourly wage",
         "Formal empl."="Formal employment", "Formal employment"="Formal employment",
         "Employment"="Employment", "Self-employment"="Self-employment",
         "Log real monthly earnings"="Log real monthly earnings",
         "Labour force part."="Labour force participation",
         "Weekly hours"="Weekly hours", "Paid below MW"="Paid below the MW")
canon <- function(x) ifelse(x %in% names(LAB), LAB[x], x)
# shared significance-stars legend and clustering/weights note fragments
STARS <- "$^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."
SE_NOTE <- "Standard errors clustered by department in parentheses; all estimates are weighted by ENAHO survey weights."

wrap <- function(body, caption, label, notes, colspec, header, small=FALSE, colsep=NULL) {
  c("\\begin{table}[!tbp]\\centering",
    sprintf("\\caption{%s}\\label{%s}", caption, label),
    "\\begin{threeparttable}",
    if (small) "\\footnotesize" else NULL,
    if (!is.null(colsep)) sprintf("\\setlength{\\tabcolsep}{%s}", colsep) else NULL,
    sprintf("\\begin{tabular}{%s}", colspec), "\\toprule",
    header, "\\midrule", body, "\\bottomrule", "\\end{tabular}",
    "\\begin{tablenotes}\\footnotesize", notes, "\\end{tablenotes}",
    "\\end{threeparttable}\\end{table}")
}

## ---- Table: descriptives (wrap existing tabular) ----------------------------
desc_body <- readLines(file.path(DIR_TAB, "tab_descriptives.tex"))
# strip the tabular wrapper lines to reuse rows
di <- which(grepl("\\\\toprule", desc_body))[1]; dj <- which(grepl("\\\\bottomrule", desc_body))[1]
desc_rows <- desc_body[(di+1):(dj-1)]
descw <- c("\\begin{table}[!tbp]\\centering",
  "\\caption{Descriptive statistics by skill group, pre-reform period}\\label{tab:desc}",
  "\\begin{threeparttable}", "\\begin{tabular}{lccc}", "\\toprule", desc_rows, "\\bottomrule",
  "\\end{tabular}", "\\begin{tablenotes}\\footnotesize",
  "\\item Notes: Weighted means using ENAHO survey weights, working-age individuals (14--65) in the pre-reform quarters (2021Q1--2022Q1). Low-skilled: education at most complete secondary (\\texttt{p301a}$\\le$6). High-skilled: any tertiary education (\\texttt{p301a}$\\ge$7). Wage-earner variables (hourly wage, below MW) are conditional on being a private-sector wage earner (employees and domestic workers, monthly-equivalent earnings); hours and formality are conditional on employment. Observation counts are unweighted. The below-MW row uses the statutory floor in force in the income reference month (930 soles throughout the pre-reform window); the exposure shares relative to the NEW floor (57 vs.\\ 40 percent) discussed in the text use 1{,}025 soles.",
  "\\end{tablenotes}", "\\end{threeparttable}\\end{table}")
writeLines(descw, file.path(DIR_TAB, "tab_descriptives_wrapped.tex"))

## ---- Table: main DiD results ------------------------------------------------
main <- fread(file.path(DIR_OUT, "main_did_coefs.csv"))
dr   <- fread(file.path(DIR_OUT, "drdid_coefs.csv"))
pt   <- fread(file.path(DIR_OUT, "pretrend_tests.csv"))
ord  <- c("log_wage_hr","log_ylab","employed","lfp","formal","self_emp","hours_main","below_mw")
labs <- c(log_wage_hr="Log real hourly wage", log_ylab="Log real monthly earnings",
          employed="Employment", lfp="Labour force participation", formal="Formal employment",
          self_emp="Self-employment", hours_main="Weekly hours", below_mw="Paid below the MW")
rows <- c()
for (o in ord) {
  m <- main[outcome==o]; d <- dr[outcome==o]; p <- pt[outcome==o]
  ptp <- if(nrow(p)) p$pretrend_p[1] else NA
  el  <- if (!is.null(m$elasticity)) m$elasticity else NA
  rows <- c(rows,
    sprintf("%s & %s & %s & %s & %s \\\\", labs[o], cell(m$att,m$se,m$p),
            cell(d$att,d$se,d$p), ifelse(is.na(ptp),"--",f3(ptp)),
            ifelse(is.na(el),"--",formatC(el, format="f", digits=2))),
    sprintf(" & %s & %s & & \\\\", secell(m$se), secell(d$se)),
    sprintf(" & \\multicolumn{2}{c}{\\footnotesize $N=%s$, $\\bar{y}=%s$} & & \\\\",
            format(m$n,big.mark=","), f3(m$ymean)))
}
tab_main <- wrap(rows,
  "Difference-in-differences estimates of the 2022 minimum-wage reform",
  "tab:main", c(
  "\\item Notes: Each row is a separate regression on ENAHO 2021Q1--2024Q4, excluding the partially treated transition quarter 2022Q2. Column (1) reports the two-way fixed-effects DiD coefficient on $\\mathrm{Low}\\times\\mathrm{Post}$ from equation~\\eqref{eq:twfe}, with department and quarter fixed effects and controls (age, age squared, sex, urban, marital status, years of education). Column (2) reports the doubly robust DiD estimator of \\citet{santanna_zhao_2020} collapsing to pre/post; its standard errors are clustered by department using the estimator's influence function. Column (3) is the $p$-value of a joint test that the pre-reform event-study interactions are zero. Column (4) converts the column-(1) estimate into an elasticity with respect to the 10.2 percent minimum-wage increase (for level outcomes, relative to the baseline mean $\\bar{y}$). Wage outcomes are for private-sector wage earners (employees and domestic workers, monthly-equivalent earnings); formality, hours, and self-employment are for private-sector workers. Standard errors clustered by department (25 clusters) in parentheses; all estimates are weighted by ENAHO survey weights. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lcccc",
  "Outcome & (1) TWFE DiD & (2) Doubly robust & (3) Pre-trend $p$ & (4) Elasticity \\\\",
  small=TRUE, colsep="4pt")
writeLines(tab_main, file.path(DIR_TAB, "tab_main_did.tex"))

## ---- Table: specification robustness ----------------------------------------
sp <- fread(file.path(DIR_OUT, "rob_specifications.csv"))
sp_ord <- c(baseline="Baseline", no_ctrl="No controls", drop_covid="Drop 2021Q1 (pandemic)",
            reg_trend="Department linear trends", prime_age="Prime age (25--55)",
            alt_cutoff="Alternative education cutoff", occ_ind_fe="Occupation \\& industry FE",
            cluster_rs="Cluster dept.$\\times$skill",
            low_trend="Low-skilled group linear trend",
            incl_trans="Include transition quarter (2022Q2)",
            excl_agri="Exclude agriculture (agrarian regime)",
            incl_public="Include public-sector workers")
oc <- c("Log hourly wage","Employment","Formal empl.","Self-employment")
fmtN <- function(n) ifelse(is.na(n), "--", format(n, big.mark=","))
rows <- sapply(names(sp_ord), function(s) {
  vals <- sapply(oc, function(o){ r <- sp[spec==s & outcome==o]
    if(nrow(r) && !is.na(r$est)) cell(r$est,r$se,r$p) else "--" })
  ses  <- sapply(oc, function(o){ r <- sp[spec==s & outcome==o]
    if(nrow(r) && !is.na(r$est)) secell(r$se) else "" })
  ns   <- sapply(oc, function(o){ r <- sp[spec==s & outcome==o]
    if(nrow(r)) sprintf("\\footnotesize[%s]", fmtN(r$n)) else "" })
  c(sprintf("%s & %s \\\\", sp_ord[s], paste(vals, collapse=" & ")),
    sprintf(" & %s \\\\", paste(ses, collapse=" & ")),
    sprintf(" & %s \\\\", paste(ns, collapse=" & ")))
})
tab_sp <- wrap(as.vector(rows),
  "Specification robustness of the DiD estimates",
  "tab:robspec", c("\\item Notes: Each cell is the $\\mathrm{Low}\\times\\mathrm{Post}$ DiD coefficient (standard error clustered by department below; sample size in brackets) for the outcome in the column heading, under the specification in the row; all estimates are weighted by ENAHO survey weights, and Log hourly wage denotes the log real hourly wage. The baseline is equation~\\eqref{eq:twfe}, which excludes the partially treated 2022Q2. The alternative education cutoff defines low-skilled as at most incomplete secondary and high-skilled as at least complete non-university tertiary, dropping the boundary categories. The agriculture exclusion and the public-sector inclusion apply to job-conditional outcomes only (industry and sector are undefined for non-workers). $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lcccc",
  paste0("Specification & ", paste(oc, collapse=" & "), " \\\\"),
  small=TRUE, colsep="4pt")
writeLines(tab_sp, file.path(DIR_TAB, "tab_robustness.tex"))

## ---- Table: inference and design robustness ---------------------------------
inf <- fread(file.path(DIR_OUT, "rob_inference.csv"))
ri  <- fread(file.path(DIR_OUT, "rob_randomization.csv"))
cont<- fread(file.path(DIR_OUT, "rob_continuous.csv"))
ddd <- fread(file.path(DIR_OUT, "rob_triplediff.csv"))
v25 <- fread(file.path(DIR_OUT, "validation2025_did.csv"))
pv <- function(p) ifelse(is.na(p),"--",f3(p))
rows <- c()
for (o in oc) {
  a <- inf[outcome==o]; r <- ri[outcome==o]; cc <- cont[outcome==o]; vv <- v25[outcome==o]
  rip <- if(nrow(r)) r$ri_p[1] else NA
  rows <- c(rows,
    sprintf("%s & %s & %s & %s & %s & %s & %s \\\\", o,
      pv(a$p_region), pv(a$p_regionskill), pv(a$p_CR2), pv(rip),
      cell(cc$est,cc$se,cc$p), cell(vv$att,vv$se,vv$p)),
    sprintf(" & & & & & %s & %s \\\\", secell(cc$se), secell(vv$se)))
}
tab_inf <- wrap(rows,
  "Inference robustness, design robustness, and out-of-sample validation",
  "tab:inference", c("\\item Notes: Columns (1)--(3) report $p$-values for the baseline $\\mathrm{Low}\\times\\mathrm{Post}$ effect under, respectively, department clustering (25 clusters), department$\\times$skill clustering (50 clusters), and the CR2 small-sample correction \\citep{pustejovsky_tipton_2018} applied to department-level collapsed cells. Column (4) reports the randomization-inference $p$-value for the CONTINUOUS-exposure design of column (5), not for the two-group $\\mathrm{Low}\\times\\mathrm{Post}$ contrast, obtained by permuting the 25 regional Kaitz indices across departments (2{,}000 draws). Column (5) reports the continuous-exposure estimate, the coefficient on $\\mathrm{Post}\\times$(standardized department Kaitz index), with department-clustered standard errors in parentheses. Column (6) reports the $\\mathrm{Low}\\times\\mathrm{Post}$ DiD estimate for the January-2025 reform (window 2024--2025), with department-clustered standard errors in parentheses. Log hourly wage denotes the log real hourly wage; all estimates are weighted by ENAHO survey weights. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lcccccc",
  "Outcome & (1) Dept. & (2) Dept.$\\times$sk. & (3) CR2 & (4) RI (cont.) & (5) Continuous & (6) 2025 \\\\",
  small=TRUE, colsep="3.5pt")
writeLines(tab_inf, file.path(DIR_TAB, "tab_inference.tex"))

## ---- Appendix table: triple difference --------------------------------------
rows <- c()
for (o in oc) {
  dd <- ddd[outcome==o]
  rows <- c(rows, sprintf("%s & %s \\\\", o, cell(dd$est,dd$se,dd$p)),
            sprintf(" & %s \\\\", secell(dd$se)))
}
tab_ddd <- wrap(rows,
  "Triple-difference estimates: $\\mathrm{Low}\\times\\mathrm{Post}\\times\\mathrm{HighBite}$",
  "tab:ddd", c("\\item Notes: Coefficient on the triple interaction $\\mathrm{Low}\\times\\mathrm{Post}\\times\\mathrm{HighBite}$, where HighBite indicates departments with an above-median pre-reform fraction of private wage earners paid below the new minimum wage. Department and quarter fixed effects, controls as in the baseline; standard errors clustered by department (25 clusters); ENAHO survey weights. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lc", "Outcome & DDD estimate \\\\")
writeLines(tab_ddd, file.path(DIR_TAB, "tab_triplediff.tex"))

## ---- Appendix table: leave-one-out ranges ------------------------------------
loo <- fread(file.path(DIR_OUT, "rob_leaveoneout.csv"))
rows <- c()
for (o in oc) {
  l <- loo[outcome==o]
  rows <- c(rows, sprintf("%s & %s & [%s, %s] & [%s, %s] \\\\", o, f3(l$full),
    f3(l$loro_min), f3(l$loro_max), f3(l$loqo_min), f3(l$loqo_max)))
}
tab_loo <- wrap(rows,
  "Leave-one-out stability of the baseline DiD estimates",
  "tab:loo", c("\\item Notes: Ranges of the $\\mathrm{Low}\\times\\mathrm{Post}$ coefficient when re-estimating the baseline dropping one department at a time (25 estimates) or one quarter at a time (15 estimates). Full per-unit estimates are in the replication output (\\texttt{rob\\_leaveoneout\\_detail.csv})."),
  "lccc", "Outcome & Full sample & Drop-one-department range & Drop-one-quarter range \\\\")
writeLines(tab_loo, file.path(DIR_TAB, "tab_leaveoneout.tex"))

## ---- Appendix table: in-time placebo reforms -------------------------------
pl <- fread(file.path(DIR_OUT, "rob_placebo.csv"))
qlab <- c(`2`="2021Q2", `3`="2021Q3", `4`="2021Q4")
prows <- sapply(unique(pl$outcome), function(o) {
  vals <- sapply(c(2,3,4), function(q){ r <- pl[outcome==o & placebo_reform_t==q]; cell(r$est,r$se,r$p) })
  ses  <- sapply(c(2,3,4), function(q){ r <- pl[outcome==o & placebo_reform_t==q]; secell(r$se) })
  c(sprintf("%s & %s \\\\", canon(o), paste(vals, collapse=" & ")),
    sprintf(" & %s \\\\", paste(ses, collapse=" & ")))
})
plb <- c("\\begin{tabular}{lccc}", "\\toprule",
         "Outcome & Placebo 2021Q2 & Placebo 2021Q3 & Placebo 2021Q4 \\\\", "\\midrule",
         as.vector(prows), "\\bottomrule", "\\end{tabular}")
writeLines(plb, file.path(DIR_TAB, "tab_placebo_body.tex"))

## ---- Table: first stage (spike migration + compliance DiD) ------------------
sk <- fread(file.path(DIR_OUT, "firststage_spikes.csv"))
cm <- fread(file.path(DIR_OUT, "firststage_compliance.csv"))
rows <- c("\\multicolumn{4}{l}{\\emph{Panel A: share of formal wage earners within $\\pm$2.5\\% of each floor}}\\\\")
for (smp in unique(sk$sample)) {
  s <- sk[sample==smp]
  rows <- c(rows, sprintf("%s & & & \\\\", smp),
    sprintf("\\quad At the old floor (930) & %s & %s & \\\\",
            f3(s[window=="pre" & floor==930, share]), f3(s[window=="post" & floor==930, share])),
    sprintf("\\quad At the new floor (1{,}025) & %s & %s & \\\\",
            f3(s[window=="pre" & floor==1025, share]), f3(s[window=="post" & floor==1025, share])))
}
rows <- c(rows, "\\midrule",
  "\\multicolumn{4}{l}{\\emph{Panel B: DiD on the share paid below 1{,}025 (fixed threshold)}}\\\\",
  " & DiD & (s.e.) & Pre-trend $p$ \\\\ \\midrule")
for (i in seq_len(nrow(cm))) {
  rows <- c(rows, sprintf("%s & %s & %s & %s \\\\", cm$sample[i],
    cell(cm$att[i], cm$se[i], cm$p[i]), secell(cm$se[i]), f3(cm$pretrend_p[i])))
}
tab_fs <- wrap(rows,
  "First stage: spike migration and compliance at the wage floor",
  "tab:firststage", c("\\item Notes: Panel A reports the weighted share of formal private wage earners (monthly-equivalent pay) within $\\pm$2.5 percent of each statutory floor, in symmetric three-quarter windows before (2021Q3--2022Q1) and after (2022Q3--2023Q1) the reform. Panel B reports $\\mathrm{Low}\\times\\mathrm{Post}$ DiD estimates for an indicator of monthly-equivalent pay below 1{,}025 soles (threshold held fixed in all periods), by formality status, with department-clustered standard errors and the joint pre-trend $p$-value in the last column. ENAHO survey weights throughout. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lccc",
  "  & Pre window & Post window & \\\\", small=TRUE)
writeLines(tab_fs, file.path(DIR_TAB, "tab_firststage.tex"))

## ---- Appendix table: granular exposure designs -------------------------------
el <- fread(file.path(DIR_OUT, "exposure_leads.csv"))
cd <- fread(file.path(DIR_OUT, "exposure_cell_did.csv"))
rows <- c()
for (i in seq_len(nrow(el)))
  rows <- c(rows, sprintf("%s & \\multicolumn{4}{c}{leads $p$ = %s} \\\\",
                          el$outcome[i], f3(el$leads_p[i])))
rows <- c(rows, "\\midrule",
  "\\multicolumn{5}{l}{\\emph{Panel B: cell-level fraction-affected designs (transparency exercise)}}\\\\",
  "Outcome & Exposure & Estimate & (s.e.) & Leads $p$ \\\\ \\midrule")
for (i in seq_len(nrow(cd)))
  rows <- c(rows, sprintf("%s & %s & %s & %s & %s \\\\", cd$outcome[i],
    gsub("_","\\\\_",cd$exposure[i]), cell(cd$est[i],cd$se[i],cd$p[i]),
    secell(cd$se[i]), f3(cd$leads_p[i])))
tab_ec <- wrap(rows,
  "Exposure designs: diagnostics and cell-level estimates",
  "tab:expocells", c("\\item Notes: Panel A: joint tests that the pre-reform quarter$\\times$exposure interactions are zero in the regional continuous-exposure design (standardized department Kaitz). Panel B: coefficients on $\\mathrm{Post}\\times$exposure from cell-level fraction-affected designs (department$\\times$skill$\\times$age cells; frac\\_below = pre-reform share of the cell's private wage earners paid below 1{,}025; frac\\_aff = share paid between 930 and 1{,}025), with cell and quarter fixed effects and department-clustered standard errors. Both cell-level variants fail their leads diagnostics (fine-grained exposure is confounded with the cells' pandemic-recovery trajectories), which is why the regional design is the preferred corroboration. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lcccc",
  "\\multicolumn{5}{l}{\\emph{Panel A: regional Kaitz design, exposure-leads joint tests}}\\\\", small=TRUE)
writeLines(tab_ec, file.path(DIR_TAB, "tab_exposure.tex"))

## ---- Appendix table: sector and occupation -----------------------------------
sec <- fread(file.path(DIR_OUT, "sector_did.csv"))
oc2 <- fread(file.path(DIR_OUT, "occ_doseresponse.csv"))
rows <- c()
for (o in unique(sec$outcome)) {
  g <- function(s) { r <- sec[outcome==o & sector==s]
    if (nrow(r)) cell(r$est,r$se,r$p) else "--" }
  gs <- function(s) { r <- sec[outcome==o & sector==s]
    if (nrow(r)) secell(r$se) else "" }
  rows <- c(rows,
    sprintf("%s & %s & %s & %s \\\\", o, g("Covered high-bite sectors"),
            g("Agriculture (agrarian regime)"), g("Other private sectors")),
    sprintf(" & %s & %s & %s \\\\", gs("Covered high-bite sectors"),
            gs("Agriculture (agrarian regime)"), gs("Other private sectors")))
}
rows <- c(rows, "\\midrule",
  "\\multicolumn{4}{l}{\\emph{Panel B: occupation-exposure dose response ($\\mathrm{Post}\\times$ occupation share below 1{,}025)}}\\\\",
  "Outcome & Estimate & (s.e.) & Leads $p$ \\\\ \\midrule")
for (i in seq_len(nrow(oc2)))
  rows <- c(rows, sprintf("%s & %s & %s & %s \\\\", oc2$outcome[i],
    cell(oc2$est[i],oc2$se[i],oc2$p[i]), secell(oc2$se[i]), f3(oc2$leads_p[i])))
tab_so <- wrap(rows,
  "Sectoral breadth and occupational dose response of the reallocation",
  "tab:sectorocc", c("\\item Notes: Panel A: $\\mathrm{Low}\\times\\mathrm{Post}$ DiD within sector groups defined from CIIU Rev.4 divisions (covered high-bite: manufacturing 10--33, construction 41--43, trade 45--47, hotels and restaurants 55--56; agriculture: divisions 01--03, under the agrarian regime of Ley 31110, whose daily remuneration is indexed to the RMV and therefore rose with the reform). Panel B: coefficient on $\\mathrm{Post}\\times$(pre-reform share of the 2-digit occupation's private wage earners paid below 1{,}025), with occupation, quarter, and department fixed effects; occupation is measured at the interview and is therefore post-treatment for movers, so Panel B is descriptive corroboration rather than a primary design. Department-clustered standard errors; ENAHO survey weights. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lccc",
  c("\\multicolumn{4}{l}{\\emph{Panel A: education DiD by sector group}}\\\\",
    "Outcome & Covered high-bite & Agriculture & Other private \\\\"), small=TRUE)
writeLines(tab_so, file.path(DIR_TAB, "tab_sector_occ.tex"))

## ---- Appendix table: Lee bounds and MDE ---------------------------------------
lb <- fread(file.path(DIR_OUT, "lee_bounds.csv"))
md <- fread(file.path(DIR_OUT, "mde.csv"))
gv <- function(q) f3(lb[quantity==q, value])
rows <- c(
  sprintf("Selection DiD (wage-sample inclusion) & %s & \\\\", gv("selection_did")),
  sprintf("Trimming fraction & %s & \\\\", gv("trim_fraction")),
  sprintf("Untrimmed DiD & %s & \\\\", gv("raw_2x2_did")),
  sprintf("Bounds & [%s, %s] & \\\\", gv("lower_bound"), gv("upper_bound")),
  "\\midrule",
  "\\multicolumn{3}{l}{\\emph{Panel B: minimum detectable effects (80\\% power, 5\\% size)}}\\\\",
  "Outcome & Estimate & MDE \\\\ \\midrule")
for (i in seq_len(nrow(md)))
  rows <- c(rows, sprintf("%s & %s & %s \\\\", md$label[i], f3(md$att[i]), f3(md$mde_80[i])))
tab_lm <- wrap(rows,
  "Selection bounds and statistical power",
  "tab:leemde", c("\\item Notes: Panel A: bounds on the unconditional 2$\\times$2 log hourly wage DiD following the trimming logic of \\citet{lee_2009}: the reform reduced the probability that a low-education worker appears in the wage-earner sample (selection DiD), so the low$\\times$post cell is trimmed from above and below by the implied fraction of its baseline rate. Panel B: minimum detectable effect $=2.8\\times$ the department-clustered standard error of the baseline DiD."),
  "lcc",
  "\\multicolumn{3}{l}{\\emph{Panel A: Lee-type trimming bounds, unconditional 2$\\times$2 log-wage DiD}}\\\\", small=TRUE)
writeLines(tab_lm, file.path(DIR_TAB, "tab_lee_mde.tex"))

## ---- Appendix table: SDID and pre-test power ---------------------------------
sd2 <- fread(file.path(DIR_OUT, "sdid_results.csv"))
pp <- fread(file.path(DIR_OUT, "pretest_power.csv"))
rows <- c()
for (o in unique(sd2$outcome)) {
  a <- sd2[outcome==o & mode=="low_only"]; b <- sd2[outcome==o & mode=="skill_gap"]
  rows <- c(rows,
    sprintf("%s & %s & %s & \\\\", o, cell(a$att,a$se,a$p), cell(b$att,b$se,b$p)),
    sprintf(" & %s & %s & \\\\", secell(a$se), secell(b$se)))
}
rows <- c(rows, "\\midrule",
  "\\multicolumn{4}{l}{\\emph{Panel B: power of the pre-trends test against linear violations \\citep{roth_2022_pretest}}}\\\\",
  "Outcome & Slope at 50\\% power & Implied bias (avg.\\ post) & Bias / estimate \\\\ \\midrule")
for (i in seq_len(nrow(pp)))
  rows <- c(rows, sprintf("%s & %s & %s & %s \\\\", pp$outcome[i],
    f3(pp$slope_power50[i]), f3(pp$implied_bias_power50[i]),
    formatC(pp$bias50_over_att[i], format="f", digits=2)))
tab_sp3 <- wrap(rows,
  "Synthetic DiD and the power of the pre-trends test",
  "tab:sdidpower", c("\\item Notes: Panel A: synthetic DiD estimates \\citep{arkhangelsky_2021_sdid} on department$\\times$quarter cells, treating above-median-bite departments as treated from 2022Q3; column (1) uses low-education outcome means, column (2) the low-minus-high skill gap; jackknife standard errors in parentheses (the placebo variance is infeasible with 12 treated and 13 control units). Panel B: slope of a linear violation of parallel trends against which the conventional pre-test has only 50 percent power \\citep{roth_2022_pretest}, the bias such an undetected violation would induce in the average post-period effect, and its ratio to the estimated effect. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lccc",
  c("\\multicolumn{4}{l}{\\emph{Panel A: synthetic difference-in-differences (high-bite vs synthetic low-bite departments)}}\\\\",
    "Outcome & Low-education means & Skill gap & \\\\"), small=TRUE)
writeLines(tab_sp3, file.path(DIR_TAB, "tab_sdid_power.tex"))

## ---- Appendix table: adjustment margins and new subgroups --------------------
mg <- fread(file.path(DIR_OUT, "margins2.csv"))
h2 <- fread(file.path(DIR_OUT, "heterogeneity2.csv"))
rows <- c()
for (i in seq_len(nrow(mg)))
  rows <- c(rows, sprintf("%s & %s & %s & %s \\\\", mg$margin[i],
    cell(mg$att[i],mg$se[i],mg$p[i]), secell(mg$se[i]), f3(mg$pre_mean[i])))
rows <- c(rows, "\\midrule",
  "\\multicolumn{4}{l}{\\emph{Panel B: subgroups by household role and ethnic self-identification}}\\\\",
  "Outcome & Group & Estimate & (s.e.) \\\\ \\midrule")
for (i in seq_len(nrow(h2)))
  rows <- c(rows, sprintf("%s & %s & %s & %s \\\\", h2$outcome[i], h2$group[i],
    cell(h2$att[i],h2$se[i],h2$p[i]), secell(h2$se[i])))
tab_mg <- wrap(rows,
  "Adjustment margins and additional subgroups",
  "tab:margins", c("\\item Notes: Panel A: $\\mathrm{Low}\\times\\mathrm{Post}$ DiD estimates for mechanism-oriented outcomes: the share of private wage earners without a written contract (\\texttt{p511a}), the share of private workers in micro units of at most 20 workers (\\texttt{p512a}), the share of wage earners with under 12 months of tenure (\\texttt{p513a1/2}), and the decomposition of informal employment into informal-sector and formal-sector informal jobs (INEI \\texttt{emplpsec}, available 2021--2023). Panel B: baseline DiD within subgroups defined by household headship (\\texttt{p203}) and indigenous self-identification (\\texttt{p558c}). Department-clustered standard errors; ENAHO survey weights. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lccc",
  c("\\multicolumn{4}{l}{\\emph{Panel A: adjustment margins ($\\mathrm{Low}\\times\\mathrm{Post}$)}}\\\\",
    "Margin & Estimate & (s.e.) & Pre-reform mean \\\\"), small=TRUE)
writeLines(tab_mg, file.path(DIR_TAB, "tab_margins.tex"))

## ---- Appendix table: Venezuelan migration robustness --------------------------
mig <- fread(file.path(DIR_OUT, "rob_migration.csv"))
mig_lab <- c(baseline="Baseline", region_x_quarter_fe="Department$\\times$quarter FE",
             excl_lima_callao="Excluding Lima and Callao",
             excl_top8_migration="Excluding top-8 migrant-hosting departments")
oc4 <- c("Log hourly wage","Employment","Formal empl.","Self-employment")
rows <- c()
for (sp in names(mig_lab)) {
  vals <- sapply(oc4, function(o){ r <- mig[spec==sp & outcome==o]; cell(r$est,r$se,r$p) })
  ses  <- sapply(oc4, function(o){ r <- mig[spec==sp & outcome==o]; secell(r$se) })
  rows <- c(rows, sprintf("%s & %s \\\\", mig_lab[sp], paste(vals, collapse=" & ")),
            sprintf(" & %s \\\\", paste(ses, collapse=" & ")))
}
tab_mig <- wrap(rows,
  "Robustness to the Venezuelan immigration wave",
  "tab:migration", c("\\item Notes: $\\mathrm{Low}\\times\\mathrm{Post}$ DiD estimates under specifications that address the Venezuelan immigration inflow. Department$\\times$quarter fixed effects absorb any local shock common to both education groups within a department-quarter, including migrant arrivals and regularization waves. The top-8 exclusion drops Lima, Callao, La Libertad, Arequipa, Lambayeque, Piura, Ica, and Tumbes, the departments hosting the large majority of the Venezuelan population. Department-clustered standard errors; ENAHO survey weights. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lcccc",
  paste0("Specification & ", paste(oc4, collapse=" & "), " \\\\"), small=TRUE, colsep="4pt")
writeLines(tab_mig, file.path(DIR_TAB, "tab_migration.tex"))

## ---- Table: political-crisis robustness of the regional design ---------------
pc <- fread(file.path(DIR_OUT, "referee_protest_control.csv"))
rc <- fread(file.path(DIR_OUT, "referee_regional_crisis.csv"))
oc_cr <- data.table(
  y   = c("log_wage_hr","employed","formal","self_emp"),
  lab = c("Log hourly wage","Employment","Formal empl.","Self-employment"))
crisis_cols <- function(y) {
  a <- pc[outcome==y & spec=="no_control"]
  b <- pc[outcome==y & spec=="post_x_protest"]
  d <- pc[outcome==y & spec=="crisis_x_protest"]
  e <- rc[outcome==y & variant=="excl_south_bloc"]
  f <- rc[outcome==y & variant=="post_2022only"]
  g <- rc[outcome==y & variant=="excl_south_AND_2022only"]
  list(est = c(cell(a$kaitz_est,a$kaitz_se,a$kaitz_p), cell(b$kaitz_est,b$kaitz_se,b$kaitz_p),
               cell(d$kaitz_est,d$kaitz_se,d$kaitz_p), cell(e$est,e$se,e$p),
               cell(f$est,f$se,f$p), cell(g$est,g$se,g$p)),
       se  = c(secell(a$kaitz_se), secell(b$kaitz_se), secell(d$kaitz_se),
               secell(e$se), secell(f$se), secell(g$se)),
       rip = sprintf("[%s]", f3(c(a$kaitz_ri_p, b$kaitz_ri_p, d$kaitz_ri_p,
                                  e$ri_p, f$ri_p, g$ri_p))))
}
rows <- c()
for (i in seq_len(nrow(oc_cr))) {
  cc <- crisis_cols(oc_cr$y[i])
  rows <- c(rows,
    sprintf("%s & %s \\\\", oc_cr$lab[i], paste(cc$est, collapse=" & ")),
    sprintf(" & %s \\\\", paste(cc$se,  collapse=" & ")),
    sprintf(" & %s \\\\", paste(cc$rip, collapse=" & ")))
}
tab_cr <- wrap(rows,
  "The 2022--23 political crisis and the continuous regional-exposure design",
  "tab:crisis", c("\\item Notes: Each cell reports the coefficient on $\\mathrm{Post}\\times$(standardized department Kaitz index) from the continuous-exposure design, with department-clustered standard errors in parentheses and the randomization-inference $p$-value (permuting the Kaitz indices across the included departments, 1{,}000 draws, protest control held at its true assignment) in brackets. Column (1) is the baseline of Table~\\ref{tab:inference}, column (5). Columns (2) and (3) add the standardized per-capita peak protest mobilization interacted with the post indicator and with an indicator for 2023Q1 onward, respectively; protest intensity is the January--February 2023 maximum number of persons mobilized in each department, from the monthly conflict reports of the Presidencia del Consejo de Ministros, divided by the department's working-age population. Column (4) excludes the six southern departments at the center of the December-2022--March-2023 protests (Apur\\'imac, Arequipa, Ayacucho, Cusco, Madre de Dios, Puno). Column (5) restricts the post-reform window to 2022Q3--Q4, before the ouster of President Castillo on 7 December 2022, and column (6) combines both restrictions. All estimates weighted by ENAHO survey weights. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lcccccc",
  c("& (1) Baseline & (2) +Post$\\times$ & (3) +2023$\\times$ & (4) Excl.\\ south & (5) Post = & (6) (4)+(5) \\\\",
    "Outcome & & protest & protest & bloc & 2022 only & \\\\"), small=TRUE, colsep="3pt")
writeLines(tab_cr, file.path(DIR_TAB, "tab_crisis.tex"))

## ---- Appendix table: unconditional compositional outcomes ---------------------
un <- fread(file.path(DIR_OUT, "referee_uncond.csv"))
un_lab <- c(formal_u="Private formal employment", self_u="Self-employment",
            informal_u="Private informal employment")
rows <- c()
for (y in names(un_lab)) {
  r <- un[outcome==y]
  rows <- c(rows, sprintf("%s & %s & %s & %s & %s & %s \\\\",
    un_lab[y], f3(r$ymean), cell(r$did_est,r$did_se,r$did_p), f3(r$pretrend_p),
    cell(r$cont_est,r$cont_se,r$cont_p), f3(r$cont_ri_p)),
    sprintf(" & & %s & & %s & \\\\", secell(r$did_se), secell(r$cont_se)))
}
tab_un <- wrap(rows,
  "Unconditional compositional outcomes (shares of the working-age population)",
  "tab:uncond", c("\\item Notes: Outcomes are defined for every working-age individual: an individual counts as (private) formally employed only if employed, in the private sector, and formal, and analogously for self-employment and private informal employment; the non-employed and public-sector workers count as zeros. Column (2) reports the baseline $\\mathrm{Low}\\times\\mathrm{Post}$ education DiD with department-clustered standard errors; column (3) the joint $p$-value of the pre-reform event-study interactions; column (4) the coefficient on $\\mathrm{Post}\\times$(standardized department Kaitz index) from the continuous regional-exposure design; column (5) its randomization-inference $p$-value (permuting the Kaitz indices across departments, 1{,}000 draws). Because these outcomes embed the employment margin, the education-DiD versions inherit its differential pandemic-recovery pre-trend and are reported for transparency rather than leaned on; the regional-design estimates do not depend on the education contrast. All estimates weighted by ENAHO survey weights. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lccccc",
  c("& Pre-reform & Education DiD & Pre-trend & Kaitz slope & RI \\\\",
    "Outcome & mean & (Low$\\times$Post) & $p$ & (Post$\\times z$) & $p$ \\\\"), small=TRUE, colsep="4pt")
writeLines(tab_un, file.path(DIR_TAB, "tab_uncond.tex"))

## ---- Table: worker-level transitions (ENAHO Panel 2020-2024) -------------------
tr_mat <- tryCatch(fread(file.path(DIR_OUT, "panel_transitions_matrix.csv")),
                   error = function(e) NULL)
if (!is.null(tr_mat)) {
  tr_did <- fread(file.path(DIR_OUT, "panel_transitions_did.csv"))
  tr_ent <- fread(file.path(DIR_OUT, "panel_entry_did.csv"))
  per_lab <- c(PRE="Pre-reform pairs", REFORM="Reform-window pairs", POST="Post-reform pairs")
  dest_ord <- c("still formal","informal wage job","self-employment",
                "other employed","non-employed")
  rows <- c()
  for (p in c("PRE","REFORM","POST")) {
    rows <- c(rows, sprintf("\\multicolumn{4}{l}{%s}\\\\", per_lab[p]))
    for (d in dest_ord) {
      r <- tr_mat[period==p & destination==d]
      rows <- c(rows, sprintf("\\quad %s & %s & %s & %s \\\\",
        paste(toupper(substr(d,1,1)), substr(d,2,nchar(d)), sep=""),
        f3(r$low_educ), f3(r$high_educ), f3(r$low_educ - r$high_educ)))
    }
  }
  rows <- c(rows, "\\midrule",
    "\\multicolumn{4}{l}{\\emph{Panel B: stacked transition DiD (Low $\\times$ period, pair and department FE)}}\\\\",
    " & Low$\\times$Reform & Low$\\times$Post & Pre-reform mean (low) \\\\ \\midrule")
  for (i in seq_len(nrow(tr_did))) {
    r <- tr_did[i]
    rows <- c(rows, sprintf("%s & %s & %s & %s \\\\", r$outcome,
      cell(r$b_reform, r$se_reform, r$p_reform), cell(r$b_post, r$se_post, r$p_post),
      f3(r$base_pre_low)),
      sprintf(" & %s & %s & \\\\", secell(r$se_reform), secell(r$se_post)))
  }
  r <- tr_ent[1]
  rows <- c(rows, sprintf("%s & %s & %s & %s \\\\", "Informal $\\to$ formal (entry)",
    cell(r$b_reform, r$se_reform, r$p_reform), cell(r$b_post, r$se_post, r$p_post),
    f3(r$base_pre_low)),
    sprintf(" & %s & %s & \\\\", secell(r$se_reform), secell(r$se_post)))
  tab_tr <- wrap(rows,
    "Worker-level transitions across the reform (ENAHO Panel 2020--2024)",
    "tab:transitions", sprintf("\\item Notes: Linked persons from the ENAHO Panel 2020--2024 (INEI survey 978), year pairs $t\\to t{+}1$ for $t=2020,\\dots,2023$, panel weights \\texttt{facpanel}. Pair-observations are classified relative to the 1-May-2022 reform using the 2022 interview month: pre-reform (2020--21; 2021--22 interviewed January--April 2022), reform-window (2021--22 interviewed from May 2022; 2022--23 interviewed January--April 2022, whose base state predates the reform), and post-reform (2022--23 interviewed from May 2022; 2023--24). Panel A reports weighted destination shares of workers holding a formal private job in the base year (%s pair-observations). Panel B reports coefficients from stacked regressions of each transition indicator on Low$\\times$Reform, Low$\\times$Post, and Low, with pair and department fixed effects and age, age squared, and sex as controls; the entry row conditions on informal employment (wage or self-employment) in the base year (%s observations). Employment states replicate the main text definitions; informality uses the official indicator where released and the reconstruction elsewhere. Standard errors clustered by base-year department in parentheses. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$.", format(tr_did$n[1], big.mark=","), format(tr_ent$n[1], big.mark=",")),
    "lccc",
    c("\\multicolumn{4}{l}{\\emph{Panel A: destination shares of base-year formal private workers}}\\\\",
      " & Low-educated & High-educated & Low $-$ High \\\\"), small=TRUE, colsep="5pt")
  writeLines(tab_tr, file.path(DIR_TAB, "tab_transitions.tex"))
} else {
  message("panel_transitions_matrix.csv not found; tab_transitions not built.")
}

cat("All LaTeX tables written to tables/.\n")

## ---- Spanish versions (tables/es/) for paper_espanol.tex ------------------------
source(file.path(PROJ_ROOT, "scripts", "R", "i18n_es.R"))
translate_tables_es()
cat("Spanish tables written to tables/es/.\n")
