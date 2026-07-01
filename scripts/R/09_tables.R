# ==============================================================================
# 09_tables.R  --  Build publication LaTeX tables (booktabs) from output CSVs.
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))

star <- function(p) ifelse(is.na(p),"",ifelse(p<0.01,"***",ifelse(p<0.05,"**",ifelse(p<0.1,"*",""))))
f3 <- function(x) formatC(x, format="f", digits=3)
cell <- function(est,se,p) sprintf("%s$^{%s}$", f3(est), star(p))  # estimate with stars
secell <- function(se) sprintf("(%s)", f3(se))

wrap <- function(body, caption, label, notes, colspec, header, small=FALSE) {
  c("\\begin{table}[H]\\centering",
    sprintf("\\caption{%s}\\label{%s}", caption, label),
    "\\begin{threeparttable}",
    if (small) "\\footnotesize" else NULL,
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
descw <- c("\\begin{table}[H]\\centering",
  "\\caption{Descriptive statistics by skill group, pre-reform period}\\label{tab:desc}",
  "\\begin{threeparttable}", "\\begin{tabular}{lccc}", "\\toprule", desc_rows, "\\bottomrule",
  "\\end{tabular}", "\\begin{tablenotes}\\footnotesize",
  "\\item Notes: Weighted means using ENAHO survey weights, working-age individuals (14--65) in the pre-reform quarters (2021Q1--2022Q1). Low-skilled: education at most complete secondary (\\texttt{p301a}$\\le$6). High-skilled: any tertiary education (\\texttt{p301a}$\\ge$7). Wage and hours variables are conditional on employment; the hourly wage is further conditional on being a dependent employee.",
  "\\end{tablenotes}", "\\end{threeparttable}\\end{table}")
writeLines(descw, file.path(DIR_TAB, "tab_descriptives_wrapped.tex"))

## ---- Table: main DiD results ------------------------------------------------
main <- fread(file.path(DIR_OUT, "main_did_coefs.csv"))
dr   <- fread(file.path(DIR_OUT, "drdid_coefs.csv"))
pt   <- fread(file.path(DIR_OUT, "pretrend_tests.csv"))
ord  <- c("log_wage_hr","log_ylab","employed","lfp","formal","self_emp","hours_main","below_mw")
labs <- c(log_wage_hr="Log real hourly wage", log_ylab="Log real monthly earnings",
          employed="Employment", lfp="Labour force part.", formal="Formal employment",
          self_emp="Self-employment", hours_main="Weekly hours", below_mw="Paid below MW")
rows <- c()
for (o in ord) {
  m <- main[outcome==o]; d <- dr[outcome==o]; p <- pt[outcome==o]
  ptp <- if(nrow(p)) p$pretrend_p[1] else NA
  rows <- c(rows,
    sprintf("%s & %s & %s & %s \\\\", labs[o], cell(m$att,m$se,m$p),
            cell(d$att,d$se,d$p), ifelse(is.na(ptp),"--",f3(ptp))),
    sprintf(" & %s & %s & \\\\", secell(m$se), secell(d$se)),
    sprintf(" & \\multicolumn{2}{c}{\\footnotesize $N=%s$, $\\bar{y}=%s$} & \\\\",
            format(m$n,big.mark=","), f3(m$ymean)))
}
tab_main <- wrap(rows,
  "Difference-in-differences estimates of the 2022 minimum-wage reform",
  "tab:main", c(
  "\\item Notes: Each row is a separate regression. Column (1) reports the two-way fixed-effects DiD coefficient on $\\mathrm{Low}\\times\\mathrm{Post}$ from equation~\\eqref{eq:twfe}, with department and quarter fixed effects and controls (age, age squared, sex, urban, marital status, years of education). Column (2) reports the doubly robust DiD estimator of \\citet{santanna_zhao_2020} collapsing to pre/post and dropping the transition quarter. Column (3) is the $p$-value of a joint test that the pre-reform event-study interactions are zero. Standard errors clustered by department in parentheses. Survey weights used throughout. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lccc",
  "Outcome & (1) TWFE DiD & (2) Doubly robust & (3) Pre-trend $p$ \\\\")
writeLines(tab_main, file.path(DIR_TAB, "tab_main_did.tex"))

## ---- Table: specification robustness ----------------------------------------
sp <- fread(file.path(DIR_OUT, "rob_specifications.csv"))
sp_ord <- c(baseline="Baseline", no_ctrl="No controls", drop_covid="Drop 2021Q1 (pandemic)",
            reg_trend="Department linear trends", prime_age="Prime age (25--55)",
            alt_cutoff="Alternative education cutoff", occ_ind_fe="Occupation \\& industry FE",
            cluster_rs="Cluster dept.$\\times$skill")
oc <- c("Log hourly wage","Employment","Formal empl.","Self-employment")
rows <- sapply(names(sp_ord), function(s) {
  vals <- sapply(oc, function(o){ r <- sp[spec==s & outcome==o]; if(nrow(r)) cell(r$est,r$se,r$p) else "" })
  ses  <- sapply(oc, function(o){ r <- sp[spec==s & outcome==o]; if(nrow(r)) secell(r$se) else "" })
  c(sprintf("%s & %s \\\\", sp_ord[s], paste(vals, collapse=" & ")),
    sprintf(" & %s \\\\", paste(ses, collapse=" & ")))
})
tab_sp <- wrap(as.vector(rows),
  "Specification robustness of the DiD estimates",
  "tab:robspec", c("\\item Notes: Each cell is the $\\mathrm{Low}\\times\\mathrm{Post}$ DiD coefficient (standard error clustered by department below) for the outcome in the column heading, under the specification in the row. The baseline is equation~\\eqref{eq:twfe}. The alternative education cutoff defines low-skilled as at most incomplete secondary and high-skilled as at least complete non-university tertiary, dropping the boundary categories. $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lcccc",
  paste0("Specification & ", paste(oc, collapse=" & "), " \\\\"))
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
  a <- inf[outcome==o]; r <- ri[outcome==o]; cc <- cont[outcome==o]; dd <- ddd[outcome==o]; vv <- v25[outcome==o]
  rip <- if(nrow(r)) r$ri_p[1] else NA
  rows <- c(rows, sprintf("%s & %s & %s & %s & %s & %s & %s \\\\", o,
    pv(a$p_region), pv(a$p_regionskill), pv(a$p_CR2), pv(rip),
    cell(cc$est,cc$se,cc$p), cell(vv$att,vv$se,vv$p)))
}
tab_inf <- wrap(rows,
  "Inference robustness, design robustness, and out-of-sample validation",
  "tab:inference", c("\\item Notes: Columns (1)--(4) report $p$-values for the baseline $\\mathrm{Low}\\times\\mathrm{Post}$ effect under, respectively, department clustering, department$\\times$skill clustering, the CR2 small-sample correction \\citep{pustejovsky_tipton_2018} applied to department-level collapsed cells, and randomization inference permuting the regional bite across departments (2{,}000 draws). Column (5) reports the continuous-exposure estimate, the coefficient on $\\mathrm{Post}\\times$(standardized department Kaitz index). Column (6) reports the DiD estimate for the January-2025 reform (window 2024--2025). $^{*}p<0.1$, $^{**}p<0.05$, $^{***}p<0.01$."),
  "lcccccc",
  "Outcome & (1) Dept. & (2) Dept.$\\times$skill & (3) CR2 & (4) RI & (5) Continuous & (6) 2025 reform \\\\",
  small=TRUE)
writeLines(tab_inf, file.path(DIR_TAB, "tab_inference.tex"))

## ---- Appendix table: in-time placebo reforms -------------------------------
pl <- fread(file.path(DIR_OUT, "rob_placebo.csv"))
qlab <- c(`2`="2021Q2", `3`="2021Q3", `4`="2021Q4")
prows <- sapply(unique(pl$outcome), function(o) {
  vals <- sapply(c(2,3,4), function(q){ r <- pl[outcome==o & placebo_reform_t==q]; cell(r$est,r$se,r$p) })
  sprintf("%s & %s \\\\", o, paste(vals, collapse=" & "))
})
plb <- c("\\begin{tabular}{lccc}", "\\toprule",
         "Outcome & Placebo 2021Q2 & Placebo 2021Q3 & Placebo 2021Q4 \\\\", "\\midrule",
         as.vector(prows), "\\bottomrule", "\\end{tabular}")
writeLines(plb, file.path(DIR_TAB, "tab_placebo_body.tex"))

cat("All LaTeX tables written to tables/.\n")
