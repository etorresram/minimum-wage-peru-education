# ==============================================================================
# 20_protest_control.R
# Purpose: Direct control for the Dec-2022/Mar-2023 political-crisis protests
#          in the continuous regional-exposure design.
# Data:    PCM-SGSD monthly conflict reports ("Reporte de Conflictos Sociales",
#          gob.pe collection 11518), tables "Maximo numero de personas
#          movilizadas por region" for January and February 2023, the peak
#          months of the national crisis monitoring (the December-2022 report
#          predates that table). Values transcribed to
#          Data/conflictos/protest_intensity.csv; source PDFs kept alongside.
# Measure: protest_z = z-score of per-capita peak mobilization, where peak
#          mobilization = max of the January and February 2023 monthly maxima
#          and the denominator is the department's working-age population
#          (4 x mean quarterly sum of fac500a, since each ENAHO quarter expands
#          to about one fourth of the population).
# Specs:   Post x Kaitz slope with (i) Post x protest_z control and
#          (ii) Crisis x protest_z control (crisis = 2023Q1 onward), each with
#          department-clustered SEs and randomization inference on the Kaitz
#          slope holding the protest control fixed.
# Output:  output/referee_protest_control.csv
# ==============================================================================

source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
suppressMessages(library(fixest))
set.seed(20260712)

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
D  <- DT[in_window == 1 & working_age == 1 & !is.na(skill) & transition == 0]
CTRL <- "age + age2 + female + married + urban + years_educ"

## ---- Protest intensity measure ------------------------------------------------
pi_raw <- fread(file.path(dirname(RAW_ENAHO), "conflictos", "protest_intensity.csv"),
                colClasses = list(character = "region"))
pi_raw[, mob_peak := pmax(mob_jan2023, mob_feb2023)]
# working-age population by department (4 quarters x mean quarterly expansion)
pop <- D[t_index <= 5, .(pop_wa = 4 * sum(fac500a) / uniqueN(t_index)), by = region]
pi_raw <- merge(pi_raw, pop, by = "region")
pi_raw[, mob_pc := mob_peak / pop_wa]
pi_raw[, protest_z := (mob_pc - mean(mob_pc)) / sd(mob_pc)]

expo <- unique(D[!is.na(exposure_z), .(region, exposure_z)])
chk <- merge(pi_raw, expo, by = "region")
cat("Correlation(exposure_z, protest_z) across 25 departments:",
    round(cor(chk$exposure_z, chk$protest_z), 3), "\n")
print(chk[order(-protest_z),
          .(dep_name, mob_peak, mob_pc = round(mob_pc, 4),
            protest_z = round(protest_z, 2), kaitz_z = round(exposure_z, 2))])

D <- merge(D, pi_raw[, .(region, protest_z)], by = "region", all.x = TRUE, sort = FALSE)
D[, crisis := as.integer(t_index >= 9)]   # 2023Q1 onward

## ---- Outcomes ------------------------------------------------------------------
D[, formal_u := fifelse(employed == 1 & public_sector == 0 & formal == 1, 1, 0)]
OUTS <- list(
  list(y = "log_wage_hr", lab = "Log real hourly wage", flt = quote(wage_valid == 1)),
  list(y = "employed",    lab = "Employment",           flt = quote(rep(TRUE, .N))),
  list(y = "formal",      lab = "Formal empl. (cond.)", flt = quote(employed == 1 & public_sector == 0)),
  list(y = "self_emp",    lab = "Self-emp. (cond.)",    flt = quote(employed == 1 & public_sector == 0)),
  list(y = "formal_u",    lab = "Formal empl. / pop.",  flt = quote(rep(TRUE, .N)))
)

SPECS <- list(
  list(tag = "no_control",       rhs = "post:exposure_z"),
  list(tag = "post_x_protest",   rhs = "post:exposure_z + post:protest_z"),
  list(tag = "crisis_x_protest", rhs = "post:exposure_z + crisis:protest_z")
)

## Randomization inference on the Kaitz slope, protest control held at its true
## assignment (only the exposure labels are permuted).
ri_cont_ctl <- function(dat, y, rhs, draws = 1000) {
  cell <- dat[!is.na(exposure_z),
              .(y = weighted.mean(get(y), fac500a, na.rm = TRUE), n = sum(fac500a),
                post = post[1], crisis = crisis[1]), by = .(region, t_index)]
  lut0 <- unique(dat[!is.na(exposure_z), .(region, exposure_z, protest_z)])[order(region)]
  cell <- merge(cell, lut0, by = "region", sort = FALSE)
  f <- as.formula(sprintf("y ~ %s | region + t_index", rhs))
  fit <- function(cc) feols(f, cc, weights = ~n)$coefficients[["post:exposure_z"]]
  obs <- fit(cell)
  null <- numeric(draws)
  for (b in seq_len(draws)) {
    lut <- data.table(region = lut0$region, ez = sample(lut0$exposure_z))
    c2 <- copy(cell)[, exposure_z := lut$ez[match(region, lut$region)]]
    null[b] <- fit(c2)
  }
  mean(abs(null) >= abs(obs))
}

res <- rbindlist(lapply(OUTS, function(o) rbindlist(lapply(SPECS, function(sp) {
  d <- D[eval(o$flt)][!is.na(exposure_z) & !is.na(protest_z)]
  f <- as.formula(sprintf("%s ~ %s + %s | t_index + region", o$y, sp$rhs, CTRL))
  m <- feols(f, d, weights = ~fac500a, cluster = ~region)
  ct  <- coeftable(m)
  kz  <- ct["post:exposure_z", ]
  pr  <- grep(":protest_z", rownames(ct), value = TRUE)
  prc <- if (length(pr)) ct[pr[1], ] else NULL
  ri  <- ri_cont_ctl(d, o$y, sp$rhs)
  data.table(outcome = o$y, label = o$lab, spec = sp$tag,
             kaitz_est = kz[["Estimate"]], kaitz_se = kz[["Std. Error"]],
             kaitz_p = kz[["Pr(>|t|)"]], kaitz_ri_p = ri,
             protest_est = if (!is.null(prc)) prc[["Estimate"]] else NA_real_,
             protest_se  = if (!is.null(prc)) prc[["Std. Error"]] else NA_real_,
             protest_p   = if (!is.null(prc)) prc[["Pr(>|t|)"]] else NA_real_)
}))))
fwrite(res, file.path(DIR_OUT, "referee_protest_control.csv"))
cat("\n==== Continuous Kaitz design with protest-intensity control ====\n")
print(res[, .(label, spec,
              kaitz = sprintf("%.4f (%.4f) p=%.3f RIp=%.3f",
                              kaitz_est, kaitz_se, kaitz_p, kaitz_ri_p),
              protest = ifelse(is.na(protest_est), "",
                sprintf("%.4f (%.4f) p=%.3f", protest_est, protest_se, protest_p)))])
cat("\nDone: 20_protest_control.R\n")
