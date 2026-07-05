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
  "p207","p208a","p209","p203","p558c",
  # education
  "p301a",
  # labour-force status and job characteristics
  "ocu500","p507","p510","p511a","p512a","p510a1",
  # informality (INEI) where available
  "ocupinf","emplpsec",
  # pension affiliation primitives (for reconstruction)
  "p558a1","p558a2","p558a3","p558a4","p558a5",
  # hours and tenure in the main occupation
  "p513t","i513t","p520","i520","p513a1","p513a2",
  # income: p524a1 is PER PAY PERIOD (frequency in p523: 1 daily, 2 weekly,
  # 3 fortnightly, 4 monthly); p530a is monthly net profit (independents)
  "p523","p524a1","p530a",
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
# Reference month/year for income (income refers to the month BEFORE the
# interview; January interviews refer to December of the previous year).
DT[, mes_i := as.integer(mes)]
DT[is.na(mes_i), mes_i := (quarter-1L)*3L + 2L]           # fallback: mid-quarter
DT[, ref_month := ifelse(mes_i == 1L, 12L, mes_i - 1L)]
DT[, ref_year  := ifelse(mes_i == 1L, year - 1L, year)]
# Statutory MW in force in the income REFERENCE month (so May-2022 interviews,
# which report April incomes, are compared against the old S/930 floor).
DT[, mw := mw_value(ref_year, ref_month)]
# 2022Q2 is only partially treated: April interviews (and May interviews'
# April reference incomes) predate the 1-May-2022 reform.
DT[, transition := as.integer(t_index == reform_t)]

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
# Occupation and industry classifications (9999 = not classifiable -> NA).
DT[p505r4 == 9999, p505r4 := NA]
DT[p506r4 == 9999, p506r4 := NA]
# CNO-2015 "gran grupo" (1 digit) and 2-digit subgroup from the 4-digit code
DT[, occ1 := as.integer(p505r4 %/% 1000)]
DT[, occ2 := as.integer(p505r4 %/% 100)]
# CIIU Rev.4: 2-digit division (leading zeros matter: e.g. 0111 -> division 01)
DT[, ind_div := as.integer(substr(sprintf("%04d", as.integer(p506r4)), 1, 2))]
DT[is.na(p506r4), ind_div := NA_integer_]
# CIIU section (letter) from division ranges
DT[, ind_sec := cut(ind_div,
      breaks = c(0,4,9,34,35,40,44,48,54,57,63,67,68,76,83,84,85,89,93,96,98,99),
      labels = c("A","B","C","D","E","F","G","H","I","J","K",
                 "L","M","N","O","P","Q","R","S","T","U"))]
# Agriculture/forestry/fishing (divisions 01-03): covered by the separate
# agrarian labour regime (Ley 31110), not the general RMV.
DT[, agri := as.integer(ind_div %in% 1:3)]

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
# p507 category (VALIDATED against the dictionary and the data: category 5 is
# ~10-18% of workers = unpaid family workers; category 6 is ~1-2% = domestic):
#   1 employer, 2 own-account, 3 white-collar employee (empleado),
#   4 blue-collar (obrero), 5 UNPAID FAMILY WORKER (TFNR),
#   6 DOMESTIC WORKER (trabajador del hogar), 7 other
DT[, dependent    := as.integer(p507 %in% c(3,4))]        # private/public employees
DT[, self_emp     := as.integer(p507 == 2)]               # own-account
DT[, employer     := as.integer(p507 == 1)]
DT[, unpaid_fam   := as.integer(p507 == 5)]               # TFNR
DT[, domestic     := as.integer(p507 == 6)]               # trabajador del hogar
# MW-covered wage earners: employees AND domestic workers (Ley 31047 entitles
# domestic workers to the RMV since 2020); both answer the p523/p524a1 block.
DT[, wage_worker  := as.integer(p507 %in% c(3,4,6))]
DT[, public_sector := as.integer(p510 %in% c(1,2,3))]     # FFAA-PNP/public admin/public firm
# firm size buckets (p512a: 1 <=20, 2 21-50, 3 51-100, 4 101-500, 5 >500)
DT[, small_firm := as.integer(p512a <= 3)]                # <= 100 workers (MYPE range)
DT[, micro_firm := as.integer(p512a == 1)]                # <= 20 workers
# job tenure in the main occupation (years); new hire = under 12 months
DT[, tenure_yrs := fifelse(!is.na(p513a1), p513a1 + fifelse(is.na(p513a2), 0, p513a2)/12,
                           fifelse(!is.na(p513a2), p513a2/12, NA_real_))]
DT[, new_hire := as.integer(tenure_yrs < 1)]
# household head and ethnic self-identification (p558c: 1-4 indigenous groups)
DT[, hh_head := as.integer(p203 == 1)]
DT[, indigenous := fifelse(is.na(p558c), NA_integer_, as.integer(p558c %in% 1:4))]
# No formal contract among wage earners (p511a == 7 "sin contrato").
# February 2021 exception: the reduced telephone questionnaire applied in 15
# regions that month dropped the contract item (p511a missing for 51% of wage
# earners vs ~1% in every other month), so missing p511a in 2021m2 is coded NA
# rather than "no contract".
DT[, no_contract := fifelse(wage_worker == 1 & employed == 1,
                            as.integer(is.na(p511a) | p511a == 7), NA_integer_)]
DT[wage_worker == 1 & employed == 1 & is.na(p511a) &
   year == 2021 & mes_i == 2L, no_contract := NA_integer_]
# informal-employment decomposition (emplpsec, available 2021-2023):
#   1 = informal job in the informal sector, 2 = informal job in the formal sector
DT[, inf_insector  := fifelse(employed == 1 & !is.na(ocupinf),
                              as.integer(!is.na(emplpsec) & emplpsec == 1), NA_integer_)]
DT[, inf_outsector := fifelse(employed == 1 & !is.na(ocupinf),
                              as.integer(!is.na(emplpsec) & emplpsec == 2), NA_integer_)]

## ---- Hours -------------------------------------------------------------------
DT[, hours_main  := ifelse(is.na(p513t), i513t, p513t)]   # weekly hours, main occupation
DT[, hours_total := ifelse(is.na(p520),  i520,  p520)]    # usual weekly hours, all jobs
DT[hours_main  <= 0 | hours_main  > 112, hours_main  := NA]
DT[hours_total <= 0 | hours_total > 112, hours_total := NA]
DT[, fulltime := as.integer(hours_total >= 35)]
DT[, short_hours := as.integer(hours_total < 35)]

## ---- Labour income and wages -------------------------------------------------
# p524a1 is the payment PER PAY PERIOD; p523 gives the frequency. Convert to a
# monthly equivalent using the same factors implied by INEI's own annualized
# variable i524a1 (verified: median i524a1/12 / p524a1 by frequency is 25.0,
# 4.33, 2.02, 1.01): daily x25, weekly x52/12, fortnightly x2, monthly x1.
# 54% of low-education vs 15% of high-education employees are paid non-monthly,
# so skipping this conversion biases every wage comparison across skill groups.
PAY_MULT <- c(25, 52/12, 2, 1)
DT[, pay_freq := as.integer(p523)]
DT[, ylab_month := p524a1 * PAY_MULT[pay_freq]]
# Monthly labour income, main occupation (income reference month):
#   wage workers (employees + domestic) -> monthlyized p524a1 (gross pay);
#   employers / own-account -> p530a (net profit, already monthly);
#   unpaid family workers (p507==5) have no labour income by definition.
DT[, ylab_nom := fifelse(wage_worker == 1, ylab_month,
                  fifelse(p507 %in% c(1,2), p530a, NA_real_))]
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
# Pension items are marked with their OPTION CODE, not 1 (verified in the data:
# p558a1 is 0/1, p558a2 is 0/2, p558a3 is 0/3, p558a4 is 0/4, p558a5 is 0/5).
# Any value > 0 means the option was selected; p558a5 = "not affiliated".
DT[, has_pension := fifelse(
      (!is.na(p558a1) & p558a1 > 0) | (!is.na(p558a2) & p558a2 > 0) |
      (!is.na(p558a3) & p558a3 > 0) | (!is.na(p558a4) & p558a4 > 0), 1L,
      fifelse(!is.na(p558a5) & p558a5 > 0, 0L, NA_integer_))]
DT[, firm_registered := as.integer(p510a1 == 1)]          # 1 = registered in SUNAT
DT[is.na(firm_registered), firm_registered := 0L]
DT[, has_contract := as.integer(p511a %in% 1:6)]          # any formal contract (7 = none)
DT[is.na(has_contract), has_contract := 0L]

# Rule P (pension-only social-protection definition): informal if no pension.
DT[, informal_P := NA_integer_]
DT[employed == 1, informal_P := as.integer(has_pension == 0)]
DT[employed == 1 & unpaid_fam == 1, informal_P := 1L]

# Rule F (INEI-style, tuned to reproduce ocupinf):
#   wage employees / domestic workers: formal if affiliated to a pension OR
#     holding a formal contract; employers / own-account: formal if the unit
#     is registered. Unpaid family workers: always informal.
DT[, informal_F := NA_integer_]
DT[employed == 1 & wage_worker == 1,
   informal_F := fifelse(has_pension == 1 | has_contract == 1, 0L,
                  fifelse(has_pension == 0, 1L, NA_integer_))]
DT[employed == 1 & p507 %in% c(1,2),
   informal_F := as.integer(firm_registered == 0)]
DT[employed == 1 & unpaid_fam == 1, informal_F := 1L]
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
# Deflate at the income REFERENCE month (ref_year handles the December
# rollback for January interviews). CPI: Lima, Dec-2021 = 100 (BCRP PN38705PM;
# regenerated by scripts/R/data_prep_external.R).
cpi <- fread(file.path(DIR_PROC, "cpi_lima_dec2021.csv"))
DT <- merge(DT, cpi[, .(year, month, cpi)],
            by.x = c("ref_year","ref_month"), by.y = c("year","month"),
            all.x = TRUE, sort = FALSE)
stopifnot(DT[is.na(cpi), .N] == 0)
DT[, ylab_real := ylab_nom / (cpi/100)]                   # real monthly (Dic2021 soles)
DT[, wage_hr_nom  := ylab_nom  / (hours_main * 4.345)]     # nominal hourly wage
DT[, wage_hr_real := ylab_real / (hours_main * 4.345)]     # real hourly wage
# MW bite: monthly-equivalent pay below the statutory floor in force in the
# reference month; defined for MW-covered wage earners only.
DT[, below_mw := fifelse(wage_worker == 1 & !is.na(ylab_nom),
                         as.integer(ylab_nom < mw), NA_integer_)]

## ---- Canonical wage samples and winsorized log outcomes ----------------------
# Built ONCE here (not per estimation script) so every script uses identical
# thresholds and samples. Wage outcomes: private-sector MW-covered wage earners
# (employees + domestic workers); public-sector pay is set by separate scales.
DT[, wage_valid := as.integer(employed == 1 & wage_worker == 1 &
                              public_sector == 0 &
                              is.finite(wage_hr_real) & wage_hr_real > 0)]
DT[, earn_valid := as.integer(employed == 1 & wage_worker == 1 &
                              public_sector == 0 &
                              is.finite(ylab_real) & ylab_real > 0)]
DT[, log_wage_hr := NA_real_]
DT[, log_ylab    := NA_real_]
DT[wage_valid == 1, log_wage_hr := log(winsorize(wage_hr_real))]
DT[earn_valid == 1, log_ylab    := log(winsorize(ylab_real))]

## ---- Final flags and save ----------------------------------------------------
DT[, in_window := as.integer(year >= 2021 & year <= 2024)]  # main study window
setkey(DT, year, quarter, region)

saveRDS(DT, file.path(DIR_PROC, "enaho_pooled.rds"))
fwrite(DT[, .(year, quarter, t_index, event_k, post, transition, mw, skill, low,
              educ_code, age, female, urban, region, employed, unemployed, lfp,
              dependent, wage_worker, domestic, public_sector, self_emp, formal,
              informal, agri, ind_div, ind_sec, occ1, pay_freq, hours_total,
              fulltime, ylab_real, wage_hr_real, log_wage_hr, log_ylab, below_mw,
              wage_valid, earn_valid, fac500a, in_window)],
       file.path(DIR_PROC, "enaho_analysis.csv"))

cat("\nSaved: data/processed/enaho_pooled.rds and enaho_analysis.csv\n")
cat("Rows:", nrow(DT), " | window rows:", DT[in_window==1, .N], "\n")
cat("Build finished in", round(difftime(Sys.time(), t0, units="secs"),1), "sec\n")
sink()
