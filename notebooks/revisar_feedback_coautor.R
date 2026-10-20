# Auditoría numérica independiente: lm() y matriz de covarianza agrupada manual.
# Ejecutar desde project/: Rscript notebooks/revisar_feedback_coautor.R
analysis_paths <- c('feedback_coautor.R', 'notebooks/feedback_coautor.R',
                    'project/notebooks/feedback_coautor.R')
analysis_script <- analysis_paths[file.exists(analysis_paths)][1]
if (is.na(analysis_script)) stop('Ejecute desde project/, notebooks/ o su carpeta superior.')
source(analysis_script)
checks <- list()
for (o in outcomes) {
  original <- d[eval(o$filter)]
  for (design in c('principal', 'local', 'salto')) {
    s <- copy(original)
    if (design == 'local') s <- s[educ_code %in% 6:7]
    if (design == 'salto') s <- s[abs(x) <= 3]
    rhs <- switch(design,
      principal='did + low + age + age2 + female + married + urban + years_educ',
      local='did + low + age + age2 + female + married + urban',
      salto='above + x + above:x + post:x + post:above:x + above:post + age + age2 + female + married + urban')
    f <- as.formula(paste(o$y, '~', rhs, '+ factor(t_index) + factor(region)'))
    # No usar la muestra ni la matriz transformada internamente por fixest.
    required <- all.vars(f)
    s <- s[complete.cases(s[, ..required])]
    fit <- lm(f, data=s, weights=fac500a, x=TRUE, y=TRUE)
    X <- fit$x
    stopifnot(fit$rank == ncol(X))
    bread <- summary(fit)$cov.unscaled
    scores <- rowsum(X * as.numeric(weights(fit) * residuals(fit)),
                     group=s$region, reorder=FALSE)
    G <- uniqueN(s$region)
    N <- nrow(s)
    # Misma corrección finita de fixest por defecto: FE de departamento
    # anidados en el cluster no se cuentan salvo la constante común.
    K <- fit$rank - (G - 1L)
    V <- bread %*% crossprod(scores) %*% bread * (G/(G-1)) * ((N-1)/(N-K))
    term <- if (design == 'salto') 'above:post' else 'did'
    m <- models[[paste(o$y, design, sep='_')]]
    b <- coef(fit)[term]
    se <- sqrt(V[term, term])
    pval <- 2*pt(-abs(b/se), df=G-1)
    ct <- coeftable(m)[term, ]
    checks[[length(checks)+1L]] <- data.table(
      outcome=o$y, design=design, n=N, clusters=G,
      diferencia_coef=abs(b-ct['Estimate']),
      diferencia_ee=abs(se-ct['Std. Error']),
      diferencia_p=abs(pval-ct['Pr(>|t|)']))
    stopifnot(N == nobs(m), K == degrees_freedom(m, 'k'),
              abs(b-ct['Estimate']) < 1e-9,
              abs(se-ct['Std. Error']) < 1e-9,
              abs(pval-ct['Pr(>|t|)']) < 1e-8)
  }
}
checks <- rbindlist(checks)
# Contrastar las filas principales con los resultados previos del paper.
old <- fread(file.path(root, 'output/main_did_coefs.csv'))
for (o in outcomes) {
  current <- res[resultado == o$label & grepl('principal', diseno)]
  prior <- old[outcome == o$y]
  stopifnot(current$n == prior$n, abs(current$coef-prior$att) < 1e-10,
            abs(current$ee-prior$se) < 1e-10, abs(current$p-prior$p) < 1e-10)
}
# Confirmar soporte, orientación de los signos e intervalos.
stopifnot(all(d$low == 1-d$above), all(d$transition == 0),
          all(d$year %in% 2021:2024), !any(d$years_educ == 12),
          all(res$li95 < res$coef & res$ls95 > res$coef),
          all(res$gl_t == 24))
fwrite(checks, file.path(out, 'feedback_coautor_revision.csv'))
cat('\nRevisión aprobada: nueve coeficientes, EE y valores p; réplica del paper.\n')
print(checks)
writeLines(c(capture.output(sessionInfo()),
             paste('MD5 base:', tools::md5sum(file.path(root, 'data/processed/enaho_pooled.rds')))),
           file.path(out, 'feedback_coautor_sesion.txt'))
