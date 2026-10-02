# ==============================================================================
# 13_pretrend_extension.R
# Purpose: Pre-COVID parallel-trends extension. The main window opens in 2021,
#   inside the pandemic recovery, so the education contrast cannot be validated
#   in "normal times" there. This script uses the annual ENAHO employment
#   modules for 2018-2019 (INEI surveys 634 and 687, module 05, downloaded by
#   the replication package) to test whether low- and high-education workers
#   trended in parallel in the quiet pre-COVID window 2018Q3-2019Q4 (after the
#   April-2018 RMV increase, before any further reform).
#   Two tests per outcome: (i) joint significance of Low x quarter interactions
#   (ref 2019Q4); (ii) a placebo DiD with a fake reform at 2019Q1.
# Output: output/pretrend_precovid.csv
# ==============================================================================
source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "."),
        "scripts", "R", "00_config.R"))
suppressMessages(library(fixest))

EXT <- file.path(RAW_ENAHO, "ext")
files <- c(f2018 = file.path(EXT, "634", "634-Modulo05", "enaho01a-2018-500.dta"),
           f2019 = file.path(EXT, "687", "687-Modulo05", "enaho01a-2019-500.dta"))
stopifnot(all(file.exists(files)))

need <- c("mes","ubigeo","estrato","p207","p208a","p209","p301a","ocu500",
          "p507","p510","p523","p524a1","p530a","ocupinf","fac500a",
          "p513t","i513t","p511a")
read_ext <- function(f, yr) {
  avail <- names(haven::read_dta(f, n_max = 0))
  ycol <- grep("^a", avail, value = TRUE)[1]              # "aÑo" (encoding-safe)
  d <- as.data.table(haven::read_dta(f, col_select = all_of(c(ycol, intersect(need, avail)))))
  setnames(d, ycol, "year_chr")
  for (v in setdiff(names(d), "ubigeo")) set(d, j = v, value = as_num(d[[v]]))
  d[, ubigeo := as.character(haven::zap_labels(ubigeo))]
  d[, year := yr]
  d
}
DT <- rbindlist(list(read_ext(files["f2018"], 2018L), read_ext(files["f2019"], 2019L)),
                use.names = TRUE, fill = TRUE)
cat("Pooled 2018-19 rows:", nrow(DT), "\n")

## ---- Minimal construction, mirroring 01_build_panel.R -------------------------
DT[, quarter := (as.integer(mes) - 1L) %/% 3L + 1L]
DT[, tq := (year - 2018L) * 4L + quarter]                 # 2018Q1=1 .. 2019Q4=8
DT[, mes_i := as.integer(mes)]
DT[, ref_month := ifelse(mes_i == 1L, 12L, mes_i - 1L)]
DT[, ref_year  := ifelse(mes_i == 1L, year - 1L, year)]
DT[, age := p208a][, age2 := age^2]
DT[, female := as.integer(p207 == 2)]
DT[, married := as.integer(p209 %in% c(1,2))]
DT[, urban := as.integer(estrato <= 5)]
DT[, region := substr(ubigeo, 1, 2)]
DT[, working_age := as.integer(age >= AGE_MIN & age <= AGE_MAX)]
DT[, skill := fifelse(p301a %in% LOW_SKILL_CODES, "Low",
             fifelse(p301a %in% HIGH_SKILL_CODES, "High", NA_character_))]
DT[, low := as.integer(skill == "Low")]
DT[, years_educ := c(`1`=0,`2`=1,`3`=3,`4`=6,`5`=9,`6`=11,`7`=13,`8`=14,
                     `9`=14,`10`=16,`11`=18)[as.character(p301a)]]
DT[, employed := as.integer(ocu500 == 1)]
DT[, wage_worker := as.integer(p507 %in% c(3,4,6))]
DT[, self_emp := as.integer(p507 == 2)]
DT[, public_sector := as.integer(p510 %in% c(1,2,3))]
DT[, informal := fifelse(is.na(ocupinf), NA_integer_, as.integer(ocupinf == 1))]
DT[, formal := as.integer(informal == 0)]
PAY_MULT <- c(25, 52/12, 2, 1)
DT[, ylab_nom := fifelse(wage_worker == 1, p524a1 * PAY_MULT[as.integer(p523)],
                  fifelse(p507 %in% c(1,2), p530a, NA_real_))]
DT[ylab_nom <= 0, ylab_nom := NA]
DT[, hours_main := ifelse(is.na(p513t), i513t, p513t)]
DT[hours_main <= 0 | hours_main > 112, hours_main := NA]
cpi <- fread(file.path(DIR_PROC, "cpi_lima_dec2021.csv"))
DT <- merge(DT, cpi[, .(year, month, cpi)],
            by.x = c("ref_year","ref_month"), by.y = c("year","month"), all.x = TRUE)
DT[, wage_hr_real := (ylab_nom/(cpi/100)) / (hours_main * 4.345)]
DT[, wage_valid := as.integer(employed==1 & wage_worker==1 & public_sector==0 &
                              is.finite(wage_hr_real) & wage_hr_real > 0)]
DT[wage_valid == 1, log_wage_hr := log(winsorize(wage_hr_real))]

## ---- Quiet window: 2018Q3 - 2019Q4 (tq 3..8) ----------------------------------
D <- DT[tq >= 3 & tq <= 8 & working_age == 1 & !is.na(skill)]
CTRL <- "age+age2+female+married+urban+years_educ"
OUTS <- list(
  list(y="log_wage_hr", lab="Log hourly wage", flt=quote(wage_valid==1)),
  list(y="employed",    lab="Employment",      flt=quote(rep(TRUE,.N))),
  list(y="formal",      lab="Formal empl.",    flt=quote(employed==1 & public_sector==0)),
  list(y="self_emp",    lab="Self-employment", flt=quote(employed==1 & public_sector==0)))

res <- rbindlist(lapply(OUTS, function(o) {
  d <- D[eval(o$flt)]
  # (i) joint test of Low x quarter interactions, ref 2019Q4 (tq=8)
  me <- feols(as.formula(sprintf("%s ~ i(tq, low, ref=8) + low + %s | tq + region", o$y, CTRL)),
              d, weights=~fac500a, cluster=~region)
  ints <- grep("^tq::", names(coef(me)), value=TRUE)
  w <- tryCatch(wald(me, keep=ints, print=FALSE), error=function(e) NULL)
  # (ii) placebo DiD at 2019Q1 (tq>=5)
  d[, did := low * as.integer(tq >= 5)]
  mp <- feols(as.formula(sprintf("%s ~ did + low + %s | tq + region", o$y, CTRL)),
              d, weights=~fac500a, cluster=~region)
  ct <- coeftable(mp)["did", ]
  data.table(outcome=o$lab, n=nobs(mp),
             joint_parallel_p = if(!is.null(w)) w$p else NA,
             placebo_did = ct[["Estimate"]], placebo_se = ct[["Std. Error"]],
             placebo_p = ct[["Pr(>|t|)"]])
}))
fwrite(res, file.path(DIR_OUT, "pretrend_precovid.csv"))
cat("==== Pre-COVID (2018Q3-2019Q4) parallelism of the education contrast ====\n")
print(res)
cat("\nDone: 13_pretrend_extension.R\n")
