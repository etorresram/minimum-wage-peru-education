# ==============================================================================
# data_prep_external.R
# Purpose: Generate the two external inputs used by the pipeline, with full
#          provenance, so the replication package is self-contained.
#   (1) data/processed/cpi_lima_dec2021.csv
#       Lima Metropolitana CPI, base Dec-2021 = 100. Source: BCRP statistical
#       API, series PN38705PM ("Indice de precios Lima Metropolitana,
#       indice Dic.2021 = 100", primary source INEI). Coverage 2018m01-2025m12
#       (2018-19 supports the pre-COVID parallel-trends extension; December of
#       each prior year is required because incomes reported in January
#       interviews refer to the previous month).
#   (2) data/processed/minimum_wage_series.csv
#       Statutory monthly minimum wage (RMV), from the verified schedule in
#       00_config.R (D.S. 003-2022-TR; D.S. 006-2024-TR), cross-checked against
#       BCRP series PN02124PM (source MTPE).
# Requires internet access; if the BCRP API is unreachable the script stops
# without overwriting the committed files.
# ==============================================================================

source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
suppressMessages(library(jsonlite))

## ---- (1) CPI, Lima Metropolitana, base Dec-2021 = 100 ------------------------
url <- paste0("https://estadisticas.bcrp.gob.pe/estadisticas/series/api/",
              "PN38705PM/json/2018-01/2025-12")
resp <- tryCatch(jsonlite::fromJSON(url), error = function(e) NULL)
if (is.null(resp) || length(resp$periods) == 0)
  stop("BCRP API unreachable; keeping the committed CSVs unchanged.")

meses <- c(Ene=1,Feb=2,Mar=3,Abr=4,May=5,Jun=6,Jul=7,Ago=8,Set=9,Sep=9,Oct=10,Nov=11,Dic=12)
per <- resp$periods
cpi <- data.table(
  month = as.integer(meses[sub("\\..*", "", per$name)]),
  year  = as.integer(sub(".*\\.", "", per$name)),
  cpi   = as.numeric(unlist(per$values))
)
stopifnot(!anyNA(cpi))
# sanity: base month must be 100
stopifnot(abs(cpi[year==2021 & month==12, cpi] - 100) < 1e-6)
cpi[, quarter := (month - 1L) %/% 3L + 1L]
setcolorder(cpi, c("year","month","quarter","cpi"))
setorder(cpi, year, month)
fwrite(cpi, file.path(DIR_PROC, "cpi_lima_dec2021.csv"))
cat(sprintf("cpi_lima_dec2021.csv written: %d months, %d-%02d to %d-%02d\n",
            nrow(cpi), cpi$year[1], cpi$month[1],
            cpi$year[.N], cpi[.N, month]))

## ---- (2) Statutory minimum wage series ---------------------------------------
mw <- CJ(year = 2021:2025, month = 1:12)
mw[, date := as.Date(sprintf("%d-%02d-01", year, month))]
mw[, rmv_soles := mw_value(year, month)]
mw[, quarter := (month - 1L) %/% 3L + 1L]
setcolorder(mw, c("date","rmv_soles","year","month","quarter"))
fwrite(mw, file.path(DIR_PROC, "minimum_wage_series.csv"))
cat("minimum_wage_series.csv written:", nrow(mw), "months\n")
