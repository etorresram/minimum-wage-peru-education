# Estimaciones solicitadas por el coautor. Ejecutar desde cualquier directorio:
# Rscript project/notebooks/feedback_coautor.R
suppressPackageStartupMessages({library(data.table); library(fixest); library(ggplot2)})
locate_root <- function() {
  scripts <- sub('^--file=', '', grep('^--file=', commandArgs(FALSE), value=TRUE))
  candidates <- c(Sys.getenv('MW_PROJ_ROOT'), getwd(), file.path(getwd(), 'project'),
                  dirname(getwd()), if (length(scripts)) dirname(dirname(scripts[1])))
  for (candidate in candidates[nzchar(candidates)]) {
    if (file.exists(file.path(candidate, 'data/processed/enaho_pooled.rds')))
      return(normalizePath(candidate))
  }
  stop('No se encontró enaho_pooled.rds. Defina MW_PROJ_ROOT con la ruta de project.')
}
root <- locate_root()
out <- file.path(root, 'notebooks')
d <- readRDS(file.path(root, 'data/processed/enaho_pooled.rds'))
d <- d[in_window == 1 & working_age == 1 & transition == 0 &
       educ_code %in% 1:11 & !is.na(region) & is.finite(fac500a) & fac500a > 0]
d[, did := low * post]
d[, above := as.integer(years_educ >= 13)]
d[, x := years_educ - 12]

outcomes <- list(
  list(y='log_wage_hr', label='Log salario real por hora', filter=quote(wage_valid == 1)),
  list(y='formal', label='Empleo formal', filter=quote(employed == 1 & public_sector == 0 & !is.na(formal))),
  list(y='self_emp', label='Autoempleo', filter=quote(employed == 1 & public_sector == 0 & !is.na(self_emp)))
)
controls <- 'age + age2 + female + married + urban'
extract <- function(m, term, label, design, sample) {
  ct <- coeftable(m)[term, ]
  ci <- confint(m, parm=term, level=.95)
  data.table(diseno=design, muestra=sample, resultado=label, n=nobs(m),
    gl_t=degrees_freedom(m, type='t'),
    coef=unname(ct['Estimate']), ee=unname(ct['Std. Error']),
    p=unname(ct['Pr(>|t|)']),
    li95=unname(ci[1, 1]), ls95=unname(ci[1, 2]))
}
rows <- list()
models <- list()
for (o in outcomes) {
  s <- d[eval(o$filter)]
  # Diseño principal del paper, misma muestra y controles (incluye años de educación).
  f <- as.formula(sprintf('%s ~ did + low + %s + years_educ | t_index + region', o$y, controls))
  m <- feols(f, data=s, weights=~fac500a, cluster=~region, notes=FALSE)
  models[[paste(o$y, 'principal', sep='_')]] <- m
  rows[[length(rows)+1L]] <- extract(m, 'did', o$label, 'DiD principal: baja vs alta educación', 'Códigos 1–11')

  # Contraste inmediato al umbral: secundaria completa (11 años) vs superior
  # incompleta (13 años). El coeficiente se expresa como baja menos alta.
  near <- s[educ_code %in% 6:7]
  m2 <- feols(as.formula(sprintf('%s ~ did + low + %s | t_index + region', o$y, controls)),
              data=near, weights=~fac500a, cluster=~region, notes=FALSE)
  models[[paste(o$y, 'local', sep='_')]] <- m2
  rows[[length(rows)+1L]] <- extract(m2, 'did', o$label, 'DiD local: 11 vs 13 años', 'Códigos 6 y 7')

  # Diferencia de saltos descriptiva con tendencia lineal a cada lado del umbral.
  # Con pocos puntos de soporte, el salto en x=0 es extrapolado y no es una RD causal.
  wide <- s[abs(x) <= 3]
  f3 <- as.formula(sprintf('%s ~ above + x + above:x + post:x + post:above:x + above:post + %s | t_index + region', o$y, controls))
  m3 <- feols(f3, data=wide, weights=~fac500a, cluster=~region, notes=FALSE)
  models[[paste(o$y, 'salto', sep='_')]] <- m3
  r <- extract(m3, 'above:post', o$label, 'Cambio del salto lineal en 12 años', '9, 11, 13 y 14 años')
  # Orientar los tres diseños como baja menos alta.
  r[, c('coef','li95','ls95') := .(-coef, -ls95, -li95)]
  rows[[length(rows)+1L]] <- r
}
res <- rbindlist(rows)
fwrite(res, file.path(out, 'feedback_coautor_resultados.csv'))

# Diagnóstico descriptivo de exposición: fracción de asalariados privados bajo
# la RMV antes de la reforma. No es un primer estadio de tratamiento ni una
# prueba formal de discontinuidad; bajo la RMV no equivale a estar afectado.
pre <- d[post == 0 & wage_valid == 1 & !is.na(below_mw)]
support <- pre[, .(n=.N, peso=sum(fac500a),
                   pct_bajo_rmv=weighted.mean(below_mw, fac500a),
                   salario_hora=weighted.mean(wage_hr_real, fac500a)),
               by=.(educ_code, years_educ)][order(years_educ, educ_code)]
fwrite(support, file.path(out, 'feedback_coautor_soporte.csv'))

# Medias por categoría y período, útiles para examinar la extrapolación local.
means <- rbindlist(lapply(outcomes, function(o) {
  s <- d[eval(o$filter)]
  z <- s[, .(n=.N, media=weighted.mean(get(o$y), fac500a)),
    by=.(educ_code, years_educ, post)]
  z[, resultado := o$label]
  z
}))
fwrite(means, file.path(out, 'feedback_coautor_medias.csv'))

set.seed(42)
p <- ggplot(support, aes(years_educ, pct_bajo_rmv)) +
  geom_point(aes(size=n), color='#275b82',
             position=position_jitter(width=0.05, height=0, seed=42)) +
  geom_vline(xintercept=12, linetype='dashed', color='#af473c') +
  scale_x_continuous(breaks=sort(unique(support$years_educ))) +
  scale_y_continuous(labels=function(x) sprintf('%.0f%%', 100*x)) +
  labs(x='Años de educación imputados a la categoría',
       y='Asalariados privados bajo la RMV (antes de mayo de 2022)',
       size='Observaciones',
       caption='No hay observaciones con 12 años; los años proceden de categorías educativas.') +
  theme_minimal(base_size=11)
ggsave(file.path(out, 'feedback_coautor_exposicion.png'), p, width=8, height=4.8, dpi=150)

cat('\nRESULTADOS (efectos: baja menos alta educación):\n')
print(res[, .(diseno, resultado, n, coef=round(coef,4), ee=round(ee,4), p=round(p,4),
               li95=round(li95,4), ls95=round(ls95,4))])
cat('\nSOPORTE PREVIO AL CAMBIO:\n')
print(support)
