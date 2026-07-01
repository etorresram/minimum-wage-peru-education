# ==============================================================================
# 01_build_panel.R
# Purpose: Harmonize the 20 ENAHO quarterly employment modules (2021Q1-2025Q4)
#          into a single analysis-ready repeated cross-section. Construct the
#          skill groups, labor-market outcomes, controls, and a consistent
#          informality indicator (validated against INEI's ocupinf where it
#          exists, 2021-2023), then attach the CPI deflator.
# Output:  data/processed/enaho_pooled.rds  (+ .csv codebook, validation log)
# ==============================================================================

source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))

sink(file.path(DIR_LOG, "01_build_panel.log"), split = TRUE)
t0 <- Sys.time()
cat("Build started:", format(t0), "\n")

## ---- Columns to import -------------------------------------------------------
wanted <- c(
  # identifiers / design
  "conglome","vivienda","hogar","codperso","ubigeo","dominio","estrato","mes",
  "mieperho","fac500a",
  # demographics
  "p207","p208a","p209",
  # education
  "p301a",
  # labour-force status and job characteristics
  "ocu500","p507","p510","p511a","p512a","p510a1",
  # informality (INEI) where available
  "ocupinf","emplpsec",
  # pension affiliation primitives (for reconstruction)
  "p558a1","p558a2","p558a3","p558a4","p558a5",
  # hours
  "p513t","i513t","p520","i520",
  # income (nominal, monthly, reference month)
  "p524a1","p530a",
  # income (INEI imputed-deflated-annualized; Jimenez 2023 construction)
  "i524a1","d529t","i530a","d536",
  # occupation / industry
  "p505r4","p506r4","p505","p506"
)

files <- sort(list.files(RAW_ENAHO, pattern = "^PER_T[1-4]\\d{4}\\.dta$",
                         full.names = TRUE))
stopifnot(length(files) == 20)

read_one <- function(f) {
  yr <- file_year(f); q <- file_quarter(f)
  avail <- names(haven::read_dta(f, n_max = 0))
  take  <- intersect(wanted, avail)
  d <- as.data.table(haven::read_dta(f, col_select = all_of(take)))
  # add any missing wanted columns as NA so rbind is consistent
  for (v in setdiff(wanted, names(d))) d[[v]] <- NA
  # coerce all imported vars to numeric (haven_labelled/strings -> numeric),
  # keeping ubigeo/conglome as character ids
  idchar <- c("conglome","vivienda","hogar","ubigeo")
  for (v in setdiff(names(d), idchar)) set(d, j = v, value = as_num(d[[v]]))
  for (v in idchar) set(d, j = v, value = as.character(haven::zap_labels(d[[v]])))
  d[, `:=`(year = yr, quarter = q)]
  d[, source_file := basename(f)]
  cat(sprintf("  %-16s rows=%6d cols_taken=%2d  (ocupinf %s)\n",
              basename(f), nrow(d), length(take),
              ifelse("ocupinf" %in% take, "yes", "NO")))
  d
}

cat("\nReading ENAHO quarterly files:\n")
DT <- rbindlist(lapply(files, read_one), use.names = TRUE, fill = TRUE)
cat("\nPooled raw rows:", nrow(DT), "\n")

## ---- Time indexing -----------------------------------------------------------
DT[, t_index := (year - 2021L) * 4L + quarter]          # 2021Q1 = 1 ... 2025Q4 = 20
DT[, yq := sprintf("%d Q%d", year, quarter)]
reform_t <- (REFORM_YEAR - 2021L) * 4L + REFORM_QUARTER  # 2022Q2 = 6
DT[, event_k := t_index - reform_t]                       # 0 at 2022Q2
DT[, post := as.integer(t_index >= reform_t)]             # 2022Q2 onward
# reference month for income (income refers to the previous month)
DT[, ref_month := ifelse(is.na(mes), (quarter-1)*3 + 2, pmax(1, mes - 1))]
DT[, mw := mw_value(year, ifelse(is.na(mes), (quarter-1)*3 + 2, mes))]

## ---- Demographics and controls ----------------------------------------------
DT[, age    := p208a]
DT[, age2   := age^2]
DT[, female := as.integer(p207 == 2)]
DT[, married := as.integer(p209 %in% c(1,2))]            # cohabiting or married
DT[, urban  := as.integer(estrato <= 5)]                 # INEI: strata 1-5 urban, 6-8 rural
DT[, region := substr(ubigeo, 1, 2)]                     # departamento (25 units)
DT[, hhsize := mieperho]
DT[, dominio_lab := factor(dominio, levels = 1:8,
      labels = c("Costa norte","Costa centro","Costa sur","Sierra norte",
                 "Sierra centro","Sierra sur","Selva","Lima Metropolitana"))]
# 1-digit occupation and industry (CNO-2015 / CIIU rev.4)
DT[, occ1 := floor(p505r4 / 100)]
DT[, ind1 := as.integer(substr(sprintf("%04d", ifelse(is.na(p506r4),0,p506r4)),1,1))]

## ---- Education / skill groups ------------------------------------------------
DT[, educ_code := p301a]
DT[, educ_lab  := EDU_LABELS[as.character(educ_code)]]
DT[, skill := NA_character_]
DT[educ_code %in% LOW_SKILL_CODES,  skill := "Low"]      # <= secondary complete
DT[educ_code %in% HIGH_SKILL_CODES, skill := "High"]     # >= higher education
DT[, low := as.integer(skill == "Low")]                  # treatment indicator
DT[, years_educ := c(`1`=0,`2`=1,`3`=3,`4`=6,`5`=9,`6`=11,`7`=13,`8`=14,
                     `9`=14,`10`=16,`11`=18)[as.character(educ_code)]]
DT[, exper := pmax(0, age - years_educ - 6)]             # potential experience (Mincer)
DT[, exper2 := exper^2]

## ---- Labour-force status -----------------------------------------------------
# ocu500: 1 employed, 2 unemployed (open), 3 unemployed (hidden), 4 not in LF
DT[, employed   := as.integer(ocu500 == 1)]
DT[, unemployed := as.integer(ocu500 == 2)]
DT[, lfp        := as.integer(ocu500 %in% c(1,2))]        # labour force = emp + open unemp
DT[, working_age := as.integer(age >= AGE_MIN & age <= AGE_MAX)]

## ---- Job characteristics (employed only) -------------------------------------
# p507 category: 1 employer, 2 own-account, 3 white-collar employee (empleado),
#   4 blue-collar (obrero), 5 domestic worker, 6 unpaid family worker, 7 other
DT[, dependent    := as.integer(p507 %in% c(3,4))]        # wage employees (MW-relevant)
DT[, self_emp     := as.integer(p507 == 2)]               # own-account
DT[, employer     := as.integer(p507 == 1)]
DT[, unpaid_fam   := as.integer(p507 == 6)]
DT[, domestic     := as.integer(p507 == 5)]
DT[, public_sector := as.integer(p510 %in% c(1,2))]       # armed forces/public admin/public firm
# firm size buckets (p512a: 1..? ascending size; small firm if <= few workers)
DT[, small_firm := as.integer(p512a <= 3)]                # small productive unit

## ---- Hours -------------------------------------------------------------------
DT[, hours_main  := ifelse(is.na(p513t), i513t, p513t)]   # weekly hours, main occupation
DT[, hours_total := ifelse(is.na(p520),  i520,  p520)]    # usual weekly hours, all jobs
DT[hours_main  <= 0 | hours_main  > 112, hours_main  := NA]
DT[hours_total <= 0 | hours_total > 112, hours_total := NA]
DT[, fulltime := as.integer(hours_total >= 35)]
DT[, short_hours := as.integer(hours_total < 35)]

## ---- Labour income and wages -------------------------------------------------
# Nominal monthly labour income, main occupation (reference month):
#   dependent -> p524a1 (gross pay incl. overtime); own-account -> p530a (net profit)
DT[, ylab_nom := fifelse(dependent == 1, p524a1,
                  fifelse(p507 %in% c(1,2,5), p530a, NA_real_))]
DT[ylab_nom <= 0, ylab_nom := NA]
# INEI imputed-deflated-annualized labour income (Jimenez 2023), monthly:
DT[, ylab_inei := rowSums(cbind(i524a1, d529t, i530a, d536), na.rm = TRUE) / 12]
DT[ylab_inei <= 0, ylab_inei := NA]

## ---- Informality reconstruction ---------------------------------------------
# INEI 'ocupinf' (0 formal, 1/2 informal) is absent in 2024-2025. We rebuild a
# consistent indicator from primitives available in every year and validate it
# against ocupinf in 2021-2023. Two candidate rules:
#  (P) pension-based: informal if not affiliated to any pension system (social
#      protection definition), TFNR always informal.
#  (F) INEI-style: employees informal if lacking pension coverage; employers /
#      own-account informal if the unit is unregistered (p510a1); TFNR informal.
DT[, has_pension := as.integer(p558a1==1 | p558a2==1 | p558a3==1 | p558a4==1)]
DT[is.na(has_pension), has_pension := 0L]
DT[, firm_registered := as.integer(p510a1 == 1)]          # 1 = registered in SUNAT
DT[is.na(firm_registered), firm_registered := 0L]
DT[, has_contract := as.integer(p511a %in% 1:6)]          # any formal contract (7 = none)

# Rule P (pension-only social-protection definition): informal if no pension.
DT[, informal_P := NA_integer_]
DT[employed == 1, informal_P := as.integer(has_pension == 0)]
DT[employed == 1 & p507 == 6, informal_P := 1L]           # unpaid family worker

# Rule F (INEI-style, tuned to reproduce ocupinf, 88% agreement on 2021-2023):
#   wage employees / domestic: formal if affiliated to a pension OR holds a
#     formal contract; employers / own-account: formal if the unit is registered.
#   Unpaid family workers: always informal.
DT[, informal_F := NA_integer_]
DT[employed == 1 & p507 %in% c(3,4,5),
   informal_F := as.integer(has_pension == 0 & has_contract == 0)]
DT[employed == 1 & p507 %in% c(1,2),
   informal_F := as.integer(firm_registered == 0)]
DT[employed == 1 & p507 == 6, informal_F := 1L]
DT[employed == 1 & p507 == 7,
   informal_F := as.integer(has_pension == 0)]

# INEI reference indicator. VALIDATED coding: ocupinf == 1 informal, == 2 formal
# (the embedded value labels are unreliable; emplpsec is missing exactly for the
#  ocupinf==2 group, confirming that group is the formal one).
DT[, informal_inei := ifelse(is.na(ocupinf), NA_integer_, as.integer(ocupinf == 1))]

## ---- Validate reconstruction against ocupinf (2021-2023) --------------------
val <- DT[employed == 1 & !is.na(informal_inei)]
agree <- function(a, b) mean(a == b, na.rm = TRUE)
cat("\n---- Informality reconstruction validation (employed, 2021-2023) ----\n")
cat(sprintf("N with ocupinf: %d\n", nrow(val)))
cat(sprintf("INEI informal rate            : %.3f\n", mean(val$informal_inei)))
cat(sprintf("Rule P (pension) informal rate: %.3f | agreement=%.3f\n",
            mean(val$informal_P), agree(val$informal_P, val$informal_inei)))
cat(sprintf("Rule F (INEI-style) rate      : %.3f | agreement=%.3f\n",
            mean(val$informal_F), agree(val$informal_F, val$informal_inei)))
cat("Confusion (Rule F vs INEI):\n")
print(table(ruleF = val$informal_F, inei = val$informal_inei))

# Primary informal indicator: use INEI ocupinf where present, else best rule.
# (best rule chosen at run time by agreement; default to F.)
best_rule <- if (agree(val$informal_F, val$informal_inei) >=
                 agree(val$informal_P, val$informal_inei)) "F" else "P"
cat("\nChosen reconstruction rule for 2024-2025:", best_rule, "\n")
DT[, informal := informal_inei]
if (best_rule == "F") {
  DT[is.na(informal) & employed == 1, informal := informal_F]
} else {
  DT[is.na(informal) & employed == 1, informal := informal_P]
}
DT[, formal := as.integer(informal == 0)]

## ---- CPI deflator and real wages --------------------------------------------
cpi <- fread(file.path(DIR_PROC, "cpi_lima_dec2021.csv"))
DT <- merge(DT, cpi[, .(year, month, cpi)],
            by.x = c("year","ref_month"), by.y = c("year","month"),
            all.x = TRUE, sort = FALSE)
DT[, ylab_real := ylab_nom / (cpi/100)]                   # real monthly (Dic2021 soles)
DT[, wage_hr_nom  := ylab_nom  / (hours_main * 4.345)]     # nominal hourly wage
DT[, wage_hr_real := ylab_real / (hours_main * 4.345)]     # real hourly wage
# minimum-wage bite / compliance
DT[, below_mw := as.integer(ylab_nom < mw)]                # monthly pay below statutory MW
DT[, log_wage_hr  := log(wage_hr_real)]
DT[, log_ylab     := log(ylab_real)]

## ---- Final flags and save ----------------------------------------------------
DT[, in_window := as.integer(year >= 2021 & year <= 2024)]  # main study window
setkey(DT, year, quarter, region)

saveRDS(DT, file.path(DIR_PROC, "enaho_pooled.rds"))
fwrite(DT[, .(year, quarter, t_index, event_k, post, mw, skill, low, educ_code,
              age, female, urban, region, employed, unemployed, lfp, dependent,
              self_emp, formal, informal, hours_total, fulltime, ylab_real,
              wage_hr_real, log_wage_hr, below_mw, fac500a, in_window)],
       file.path(DIR_PROC, "enaho_analysis.csv"))

cat("\nSaved: data/processed/enaho_pooled.rds and enaho_analysis.csv\n")
cat("Rows:", nrow(DT), " | window rows:", DT[in_window==1, .N], "\n")
cat("Build finished in", round(difftime(Sys.time(), t0, units="secs"),1), "sec\n")
sink()
