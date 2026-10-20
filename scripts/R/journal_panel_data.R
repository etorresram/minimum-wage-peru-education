# Construcción del panel anual para el borrador de revista.
# Mismas definiciones y enlaces de 21_panel_transitions.R; no escribe resultados.
PANEL_DTA <- file.path(dirname(RAW_ENAHO), "Data", "ENAHO", "panel",
                       "978-Modulo1477", "enaho01a-2020-2024-500-panel.dta")
# RAW_ENAHO already points inside Data/ENAHO; resolve robustly:
if (!file.exists(PANEL_DTA)) {
  PANEL_DTA <- file.path(RAW_ENAHO, "panel", "978-Modulo1477",
                         "enaho01a-2020-2024-500-panel.dta")
}
if (!file.exists(PANEL_DTA)) {
  stop("No se encontró el Panel ENAHO 2020-2024. Defina MW_ENAHO_DIR ",
       "con la carpeta que contiene panel/978-Modulo1477/.")
}

YRS <- c("20","21","22","23","24")
per_year <- function(v) paste0(v, "_", YRS)
BASE_VARS <- c("mes","ubigeo","p301a","p207","p208a","p507","p510","p510a1",
               "p511a","p558a1","p558a2","p558a3","p558a4","p558a5",
               "ocu500","ocupinf","fac500a")
PAIRS <- data.table(t   = c("20","21","22","23"),
                    t1  = c("21","22","23","24"),
                    per = c("perpanel2021","perpanel2122","perpanel2223","perpanel2324"),
                    fac = c("facpanel2021","facpanel2122","facpanel2223","facpanel2324"))

want <- c(unlist(lapply(BASE_VARS, per_year)), PAIRS$per, PAIRS$fac)
cat("Reading", basename(PANEL_DTA), "(selected columns)...\n")
raw <- as.data.table(haven::read_dta(PANEL_DTA,
         col_select = tidyselect::any_of(want)))
# ubigeo is sometimes stored as character ("150101"); as.numeric handles both
raw <- raw[, lapply(.SD, function(x) suppressWarnings(as.numeric(haven::zap_labels(x))))]
cat("Loaded:", nrow(raw), "persons x", ncol(raw), "cols\n")

## ---- Per-year worker states ---------------------------------------------------
# state codes: 1 formal private job, 2 informal wage job, 3 self-employment
#              (own-account or employer, any formality), 4 other employed
#              (public sector, TFNR, domestic informal handled by rules below),
#              5 non-employed
year_state <- function(y) {
  g <- function(v) {
    cn <- paste0(v, "_", y)
    if (cn %in% names(raw)) raw[[cn]] else rep(NA_real_, nrow(raw))
  }
  emp   <- as.integer(g("ocu500") == 1)
  pub   <- as.integer(g("p510") %in% c(1,2,3))
  p507  <- g("p507")
  wagew <- as.integer(p507 %in% c(3,4,6))
  self  <- as.integer(p507 %in% c(1,2))          # employer or own-account
  tfnr  <- as.integer(p507 == 5)
  # informality: official ocupinf (1 informal / 2 formal) where present,
  # else INEI-style Rule F (as in 01_build_panel.R)
  pens <- fifelse(
    (!is.na(g("p558a1")) & g("p558a1") > 0) | (!is.na(g("p558a2")) & g("p558a2") > 0) |
    (!is.na(g("p558a3")) & g("p558a3") > 0) | (!is.na(g("p558a4")) & g("p558a4") > 0), 1L,
    fifelse(!is.na(g("p558a5")) & g("p558a5") > 0, 0L, NA_integer_))
  contr <- as.integer(g("p511a") %in% 1:6); contr[is.na(contr)] <- 0L
  freg  <- as.integer(g("p510a1") == 1);    freg[is.na(freg)]  <- 0L
  inf_F <- rep(NA_integer_, nrow(raw))
  i1 <- which(emp==1 & wagew==1)
  inf_F[i1] <- fifelse(pens[i1]==1 | contr[i1]==1, 0L,
                       fifelse(pens[i1]==0, 1L, NA_integer_))
  i2 <- which(emp==1 & self==1);  inf_F[i2] <- as.integer(freg[i2] == 0)
  i3 <- which(emp==1 & tfnr==1);  inf_F[i3] <- 1L
  i4 <- which(emp==1 & p507==7);  inf_F[i4] <- as.integer(pens[i4] == 0)
  oi <- g("ocupinf")
  informal <- fifelse(!is.na(oi) & oi %in% c(1,2), as.integer(oi == 1), inf_F)

  st <- rep(5L, nrow(raw))                        # non-employed
  st[which(emp==1)] <- 4L                         # other employed
  st[which(emp==1 & pub==0 & self==1)] <- 3L      # self-employment
  st[which(emp==1 & pub==0 & informal==1 & wagew==1)] <- 2L
  st[which(emp==1 & pub==0 & informal==0)] <- 1L  # formal private
  ub <- g("ubigeo")
  data.table(
    state = st, employed = emp, pub = pub,
    formal_priv = as.integer(st == 1L),
    informal_any = fifelse(emp==1, informal, NA_integer_),
    self_emp = as.integer(emp==1 & pub==0 & self==1),
    low  = fifelse(g("p301a") %in% 1:6, 1L,
             fifelse(g("p301a") %in% 7:11, 0L, NA_integer_)),
    age  = g("p208a"), female = as.integer(g("p207") == 2),
    region = sprintf("%02d", as.integer(ub) %/% 10000),
    mes = g("mes"), fac = g("fac500a"))
}
states <- lapply(setNames(YRS, YRS), year_state)

## ---- Stack pairs ---------------------------------------------------------------
mk_pair <- function(i) {
  p <- PAIRS[i]
  b <- states[[p$t]]; d <- states[[p$t1]]
  keep <- !is.na(raw[[p$per]]) & raw[[p$per]] == 1
  dt <- data.table(
    pair    = paste0("20", p$t, "-20", p$t1),
    w       = raw[[p$fac]][keep],
    low     = b$low[keep], age = b$age[keep], female = b$female[keep],
    region  = b$region[keep],
    base_state = b$state[keep], dest_state = d$state[keep],
    mes22   = if ("mes_22" %in% names(raw)) raw[["mes_22"]][keep] else NA_real_)
  # period classification relative to the 1-May-2022 reform
  if (p$t == "20") dt[, period := "PRE"]
  if (p$t == "21") dt[, period := fifelse(!is.na(mes22) & mes22 >= 5, "REFORM", "PRE")]
  if (p$t == "22") dt[, period := fifelse(!is.na(mes22) & mes22 <= 4, "REFORM", "POST")]
  if (p$t == "23") dt[, period := "POST"]
  dt
}
PP <- rbindlist(lapply(seq_len(nrow(PAIRS)), mk_pair))
PP <- PP[!is.na(low) & !is.na(w) & w > 0 & !is.na(base_state) & !is.na(dest_state) &
         !is.na(age) & age >= AGE_MIN & age <= AGE_MAX]
PP[, `:=`(age2 = age^2,
          reform = as.integer(period == "REFORM"),
          post   = as.integer(period == "POST"))]
cat("\nStacked pair-observations:", nrow(PP), "\n")
print(PP[, .N, by = .(pair, period)][order(pair, period)])
