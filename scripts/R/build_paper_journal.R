# Borrador para revista: descriptivos y transiciones en R.
# Ejecutar desde project/: Rscript scripts/R/build_paper_journal.R
suppressPackageStartupMessages({
  library(data.table); library(fixest); library(haven); library(matrixStats)
})
PROJ_ROOT <- normalizePath(Sys.getenv('MW_PROJ_ROOT', '.'))
source(file.path(PROJ_ROOT, 'scripts/R/00_config.R'))
dest <- file.path(PROJ_ROOT, 'paper/espanol_revista')
previous_output <- Sys.getenv('MW_PAPER_OUTPUT', unset=NA_character_)
Sys.setenv(MW_PAPER_OUTPUT=dest)
source(file.path(PROJ_ROOT,'scripts/R/build_paper_short.R'), local=new.env())
if(is.na(previous_output)) Sys.unsetenv('MW_PAPER_OUTPUT') else
  Sys.setenv(MW_PAPER_OUTPUT=previous_output)
# Presentation adjustments for a manuscript, without changing estimates.
regional_path <- file.path(dest,'tables/regional.tex')
regional_text <- readLines(regional_path)
regional_text <- gsub(' No se mezclan aquí con valores $p$ de modelos colapsados o permutados.',
                     '',regional_text,fixed=TRUE)
writeLines(regional_text,regional_path)
val_path <- file.path(dest,'tables/2025.tex')
writeLines(gsub('Resultados existentes de la réplica para 2024--2025.',
                'ENAHO 2024--2025.',readLines(val_path),fixed=TRUE),val_path)
dir.create(file.path(dest, 'tables'), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path(dest, 'results'), recursive=TRUE, showWarnings=FALSE)
fmt <- function(x, digits=2) formatC(x, format='f', digits=digits)
row <- function(...) paste0(paste(c(...), collapse=' & '), ' \\\\')
table_out <- function(name, title, label, cols, header, body, note) {
  writeLines(c('\\begin{table}[!htbp]\\centering',
    paste0('\\caption{', title, '}\\label{', label, '}'),
    '\\begin{threeparttable}\\small',
    '\\setlength{\\tabcolsep}{5pt}',
    paste0('\\begin{tabular}{', cols, '}'), '\\toprule', header,
    '\\midrule', body, '\\bottomrule', '\\end{tabular}',
    '\\begin{tablenotes}\\footnotesize', paste0('\\item ',note),
    '\\end{tablenotes}\\end{threeparttable}\\end{table}'),
    file.path(dest, 'tables', paste0(name, '.tex')))
}

# Descriptivos con los mismos filtros generales que la notebook auditada.
d <- readRDS(file.path(DIR_PROC, 'enaho_pooled.rds'))
d <- d[in_window==1 & working_age==1 & transition==0 &
         educ_code %in% 1:11 & !is.na(region) & is.finite(fac500a) & fac500a>0]
pre <- d[post==0]
definitions <- list(
  list(id='n_all', label='Observaciones: población de 14--65 años',
       sample=quote(TRUE), expr=quote(.N), digits=0),
  list(id='age', label='Edad (años)', sample=quote(TRUE),
       expr=quote(weighted.mean(age,fac500a)), digits=1),
  list(id='urban', label='Zona urbana (\\%)', sample=quote(TRUE),
       expr=quote(100*weighted.mean(urban,fac500a)), digits=1),
  list(id='n_wage', label='Observaciones: muestra salarial',
       sample=quote(wage_valid==1), expr=quote(.N), digits=0),
  list(id='wage_median', label='Mediana salarial mensual nominal (S/)',
       sample=quote(wage_valid==1), expr=quote(weightedMedian(ylab_nom,fac500a)), digits=0),
  list(id='wage_hour', label='Salario real por hora, media (S/)',
       sample=quote(wage_valid==1), expr=quote(weighted.mean(wage_hr_real,fac500a)), digits=2),
  list(id='below_old', label='Salario mensual inferior a S/930 (\\%)',
       sample=quote(wage_valid==1), expr=quote(100*weighted.mean(ylab_nom<930,fac500a)), digits=1),
  list(id='below_new', label='Salario mensual inferior a S/1025 (\\%)',
       sample=quote(wage_valid==1), expr=quote(100*weighted.mean(ylab_nom<1025,fac500a)), digits=1),
  list(id='between', label='Salario mensual en [S/930, S/1025) (\\%)',
       sample=quote(wage_valid==1), expr=quote(100*weighted.mean(ylab_nom>=930 & ylab_nom<1025,fac500a)), digits=1),
  list(id='n_comp', label='Observaciones: muestra de composición',
       sample=quote(employed==1 & public_sector==0 & !is.na(formal) & !is.na(self_emp)),
       expr=quote(.N), digits=0),
  list(id='formal', label='Empleo formal (\\%)',
       sample=quote(employed==1 & public_sector==0 & !is.na(formal)),
       expr=quote(100*weighted.mean(formal,fac500a)), digits=1),
  list(id='self', label='Cuenta propia (\\%)',
       sample=quote(employed==1 & public_sector==0 & !is.na(self_emp)),
       expr=quote(100*weighted.mean(self_emp,fac500a)), digits=1)
)
desc <- rbindlist(lapply(definitions, function(a) {
  s <- if(identical(a$sample, quote(TRUE))) pre else pre[eval(a$sample)]
  z <- s[, .(value=eval(a$expr)), by=low]
  z[, `:=`(variable=a$id, label=a$label, digits=a$digits)]
  z
}))
fwrite(desc, file.path(dest, 'results/descriptivos_previos.csv'))
body <- vapply(definitions, function(a) {
  x <- desc[variable==a$id]
  row(a$label, fmt(x[low==1,value],a$digits), fmt(x[low==0,value],a$digits))
}, character(1))
table_out('descriptivos', 'Grupos educativos y exposición antes de la reforma',
  'tab:journal_desc', 'lrr', row('Indicador','Baja educación','Alta educación'),body,
  'ENAHO 2021T1--2022T1, edades 14--65. Medias, proporciones y mediana ponderadas por fac500a; observaciones sin ponderar. Muestra salarial: asalariados privados con salario horario válido, incluidos trabajadores del hogar. Muestra de composición: ocupados no públicos. Los porcentajes bajo cada piso usan remuneración mensual equivalente nominal y no certifican incumplimiento legal: no se restringe a jornada completa. La franja entre pisos mide ubicación salarial previa, no asignación efectiva al tratamiento.')

# Reconstruye los mismos pares anuales del análisis existente.
source(file.path(PROJ_ROOT, 'scripts/R/journal_panel_data.R'))
samples <- list(
  entrada=PP[base_state %in% c(2,3)],
  permanencia=PP[base_state==1]
)
estimates <- list()
audit <- list()
for(nm in names(samples)) {
  s <- copy(samples[[nm]])
  s[, y:=as.integer(dest_state==1)]
  for(variant in c('restringido','ventanas_comunes')) {
    # Pair FE do not absorb period indicators: 2021-22 and 2022-23 each
    # contain two periods. Include their main effects in the preferred model.
    rhs <- if(variant=='ventanas_comunes') 'low * (reform + post)' else 'low + low:reform + low:post'
    f <- as.formula(paste0('y ~ ',rhs,' + age + age2 + female | pair + region'))
    m <- feols(f, data=s, weights=~w, cluster=~region, notes=FALSE)
    ct <- coeftable(m)
    if(variant=='ventanas_comunes') {
      # Independent weighted least squares + department-cluster covariance.
      f_lm <- as.formula(paste0('y ~ ',rhs,
        ' + age + age2 + female + factor(pair) + factor(region)'))
      vars <- all.vars(f_lm)
      s_lm <- s[complete.cases(s[, ..vars])]
      fit <- lm(f_lm,data=s_lm,weights=w,x=TRUE)
      X <- fit$x
      stopifnot(fit$rank==ncol(X))
      G <- uniqueN(s_lm$region); N <- nrow(s_lm)
      K <- fit$rank-(G-1L)
      bread <- summary(fit)$cov.unscaled
      scores <- rowsum(X*as.numeric(weights(fit)*residuals(fit)),
                       group=s_lm$region,reorder=FALSE)
      V <- bread %*% crossprod(scores) %*% bread * G/(G-1) * (N-1)/(N-K)
      stopifnot(N==nobs(m),K==degrees_freedom(m,'k'))
      for(term in c('low:reform','low:post')) {
        b <- coef(fit)[term]; se <- sqrt(V[term,term])
        pv <- 2*pt(-abs(b/se),df=G-1)
        delta <- c(abs(b-ct[term,1]),abs(se-ct[term,2]),abs(pv-ct[term,4]))
        stopifnot(delta[1]<1e-9,delta[2]<1e-9,delta[3]<1e-8)
        audit[[length(audit)+1L]] <- data.table(resultado=nm,termino=term,
          diferencia_coef=delta[1],diferencia_se=delta[2],diferencia_p=delta[3])
      }
    }
    for(window in c('reform','post')) {
      term <- paste0('low:',window)
      ci <- confint(m,parm=term)
      estimates[[length(estimates)+1L]] <- data.table(
        resultado=nm, especificacion=variant, ventana=window, n=nobs(m),
        base_pre_low=s[low==1 & period=='PRE',weighted.mean(y,w)],
        coef=ct[term,1], se=ct[term,2], p=ct[term,4],
        li=ci[1,1], ls=ci[1,2], gl=degrees_freedom(m,type='t'))
    }
  }
}
panel <- rbindlist(estimates)
# Verify the reused construction against both previously published results.
old_entry <- fread(file.path(DIR_OUT,'panel_entry_did.csv'))
old_stay <- fread(file.path(DIR_OUT,'panel_transitions_did.csv'))[outcome=='Still formal private']
for(nm in names(samples)) {
  old <- if(nm=='entrada') old_entry else old_stay
  for(window in c('reform','post')) {
    a <- panel[resultado==nm & especificacion=='restringido' & ventana==window]
    stopifnot(a$n==old$n, abs(a$coef-old[[paste0('b_',window)]])<1e-9,
              abs(a$se-old[[paste0('se_',window)]])<1e-9)
  }
}
fwrite(panel,file.path(dest,'results/transiciones.csv'))
fwrite(rbindlist(audit),file.path(dest,'results/auditoria_transiciones.csv'))
body <- c()
for(nm in names(samples)) {
  x <- panel[resultado==nm & especificacion=='ventanas_comunes']
  body <- c(body,paste0('\\multicolumn{5}{l}{\\emph{',
    if(nm=='entrada') 'Entrada a empleo privado formal' else 'Permanencia en empleo privado formal',
    '}} \\\\'))
  for(window in c('reform','post')) {
    a <- x[ventana==window]
    body <- c(body,row(if(window=='reform') 'Cruza la reforma' else 'Posterior a la reforma',
      fmt(100*a$coef),paste0('[',fmt(100*a$li),', ',fmt(100*a$ls),']'),
      fmt(a$p,3),fmt(a$n,0)))
  }
}
table_out('transiciones','Entrada y permanencia en la formalidad en el panel anual',
  'tab:journal_panel','lrrrr',row('Ventana','DiD (pp)','IC 95\\%','$p$','$N$'),body,
  'ENAHO Panel 2020--2024. Coeficientes de baja educación por ventana de la ecuación~\\eqref{eq:journal_panel}; referencia: pares previos. Entrada: origen asalariado informal o independiente no clasificado como formal; permanencia: origen privado formal. Factores de expansión del panel, controles del año inicial, efectos fijos de par de años y departamento e indicadores comunes de ventana. IC con errores agrupados por departamento. N cuenta pares-persona, no individuos únicos. Tasas previas de baja educación: 4.51\\% de entrada y 62.64\\% de permanencia.')
writeLines(sub('[[:space:]]+$','',capture.output(sessionInfo())),
           file.path(dest,'results/sesion_R.txt'))
print(desc[,.(variable,low,value)])
print(panel)
