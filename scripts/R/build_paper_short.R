# Reorganiza resultados existentes para la versión breve; no reestima modelos.
# Ejecutar desde project/: Rscript scripts/R/build_paper_short.R
suppressPackageStartupMessages({library(data.table); library(ggplot2)})
root <- Sys.getenv('MW_PROJ_ROOT', '.')
folder <- file.path(root,'paper/espanol_corta')
dir.create(file.path(folder,'tables'),recursive=TRUE,showWarnings=FALSE)
dir.create(file.path(folder,'figures'),recursive=TRUE,showWarnings=FALSE)
read_out <- function(f) fread(file.path(root,'output',f))
main <- read_out('main_did_coefs.csv')
pre <- read_out('pretrend_tests.csv')
regional <- read_out('rob_continuous.csv')
leads <- read_out('exposure_leads.csv')
val <- read_out('validation2025_did.csv')
ys <- c('log_wage_hr','formal','self_emp')
labs <- c('Salario horario (log)','Formalidad (pp)','Autoempleo (pp)')
old_labs <- c('Log hourly wage','Formal empl.','Self-employment')
fmt <- function(x,digits=3) formatC(x,format='f',digits=digits)
fp <- function(x) ifelse(x<.001,'$<0.001$',fmt(x))
num <- function(x) format(x,big.mark='\\,',scientific=FALSE,trim=TRUE)
row <- function(...) paste0(paste(c(...),collapse=' & '),' \\\\')
write_table <- function(name,caption,label,align,header,body,notes) {
 placement <- if(name == 'local') 'H' else '!htbp'
 lines <- c(paste0('\\begin{table}[',placement,']\\centering'),paste0('\\caption{',caption,'}\\label{',label,'}'),
 '\\begin{threeparttable}\\small', '\\setlength{\\tabcolsep}{4pt}',paste0('\\begin{tabular}{',align,'}'),
 '\\toprule',header,'\\midrule',body,'\\bottomrule','\\end{tabular}',
 '\\begin{tablenotes}\\footnotesize',paste0('\\item ',notes),'\\end{tablenotes}',
 '\\end{threeparttable}\\end{table}')
 writeLines(lines,file.path(folder,'tables',paste0(name,'.tex')))
}
rows <- c()
for (i in seq_along(ys)) {
 a<-main[outcome==ys[i]]; scale<-if(i==1)1 else 100
 lo<-(a$att-qt(.975,24)*a$se)*scale;hi<-(a$att+qt(.975,24)*a$se)*scale
 rows<-c(rows,row(labs[i],num(a$n),fmt(a$att*scale),paste0('[',fmt(lo),', ',fmt(hi),']'),fp(a$p),fp(pre[outcome==ys[i],pretrend_p])),
 row('','',paste0('(',fmt(a$se*scale),')'),'','',''))
}
write_table('main','Tres resultados centrales del contraste educativo','tab:short_main','lrrrrr',
 row('Resultado','$N$','DiD','IC 95\\%','$p$','$p$ previo'),rows,
 'Coeficiente de baja educación por período posterior de la ecuación~\\eqref{eq:short_did}. ENAHO 2021T1--2024T4, sin 2022T2. Salarios: asalariados privados con remuneración horaria válida. Formalidad y autoempleo: ocupados no públicos. Los indicadores binarios se expresan en puntos porcentuales (pp). Errores agrupados por departamento entre paréntesis; 25 grupos, ponderadores de encuesta. IC con distribución $t_{24}$. La última columna contrasta conjuntamente los coeficientes previos del estudio de eventos; no rechazar no demuestra tendencias paralelas.')
rows<-c()
for(i in seq_along(ys)){
 a<-regional[outcome==old_labs[i]];scale<-if(i==1)1 else 100
 rows<-c(rows,row(labs[i],fmt(a$est*scale),fmt(a$se*scale),fp(a$p),fp(leads[outcome==old_labs[i],leads_p])))
}
write_table('regional','Cambios asociados con la exposición regional previa','tab:short_regional','lrrrr',
 row('Resultado','Coeficiente','EE','$p$','$p$ previo'),rows,
 'Coeficiente de período posterior por índice de Kaitz estandarizado, ecuación~\\eqref{eq:short_regional}. Una unidad equivale a una desviación estándar entre los 25 departamentos. Misma ventana, muestras de resultados, controles individuales y ponderadores que en el Cuadro~\\ref{tab:short_main}. El modelo regional no incluye el indicador binario de educación baja. Errores agrupados por departamento. Los valores $p$ previos corresponden a adelantos de exposición regional. No se mezclan aquí con valores $p$ de modelos colapsados o permutados.')
rows<-c()
for(i in seq_along(ys)){
 a<-val[outcome==old_labs[i]];scale<-if(i==1)1 else 100
 rows<-c(rows,row(labs[i],num(a$n),fmt(a$att*scale),fmt(a$se*scale),fp(a$p)))
}
write_table('2025','Contraste educativo alrededor de la reforma de 2025','tab:short_2025','lrrrr',
 row('Resultado','$N$','DiD','EE','$p$'),rows,
 'Resultados existentes de la réplica para 2024--2025. El indicador posterior comienza en 2025T1. Ponderadores de encuesta y errores agrupados por departamento. Formalidad se reconstruye en ambos años. Las unidades son log puntos en salarios y puntos porcentuales en formalidad y autoempleo.')
# Selección equilibrada de variantes: incluye el resultado adverso de tendencias por grupo.
spec<-read_out('rob_specifications.csv');migration<-read_out('rob_migration.csv')
spec_keys<-c('baseline','no_ctrl','drop_covid','reg_trend','prime_age','alt_cutoff','occ_ind_fe','incl_trans','excl_agri','incl_public','low_trend')
spec_names<-c('Base','Sin controles','Excluye 2021T1','Tendencia por departamento','Edad de 25 a 55 años','Corte educativo alternativo','EF ocupación y rama','Incluye 2022T2','Excluye agricultura','Incluye sector público','Tendencia por grupo educativo')
rows<-c()
for(j in seq_along(spec_keys)){
 vals<-sapply(seq_along(ys),function(i){a<-spec[outcome==old_labs[i]&spec==spec_keys[j]];s<-if(i==1)1 else 100;paste0(fmt(a$est*s),' (',fmt(a$se*s),')')})
 rows<-c(rows,row(spec_names[j],vals))
}
vals<-sapply(seq_along(ys),function(i){a<-migration[outcome==old_labs[i]&spec=='region_x_quarter_fe'];s<-if(i==1)1 else 100;paste0(fmt(a$est*s),' (',fmt(a$se*s),')')})
rows<-c(rows,row('EF departamento por trimestre',vals))
write_table('specifications','Variantes de especificación de los tres resultados','tab:short_specs','lrrr',
 row('Variante','Salario (log)','Formalidad (pp)','Autoempleo (pp)'),rows,
 'Coeficientes DiD y errores agrupados por departamento entre paréntesis. Las variantes modifican una característica de la especificación base; los tamaños de muestra completos están en los archivos de replicación. El corte alternativo compara secundaria incompleta o menos con superior no universitaria completa o más. Ocupación y rama pueden ser variables posteriores al tratamiento. La tendencia por grupo se estima en toda la ventana y puede absorber tanto una deriva como parte de un cambio persistente; su resultado no valida ninguna de las dos explicaciones por sí solo.')
local<-fread(file.path(root,'notebooks/feedback_coautor_resultados.csv'))
rows<-c()
for(design in c('DiD local: 11 vs 13 años','Cambio del salto lineal en 12 años')) {
 rows<-c(rows,paste0('\\multicolumn{4}{l}{\\emph{',if(design== 'DiD local: 11 vs 13 años') 'Secundaria completa frente a superior no universitaria incompleta' else 'Cambio del salto lineal extrapolado en 12 años','}} \\\\'))
 for(i in seq_along(ys)){
 lbl<-c('Log salario real por hora','Empleo formal','Autoempleo')[i]
 a<-local[diseno==design&resultado==lbl];scale<-if(i==1)1 else 100
 rows<-c(rows,row(labs[i],fmt(a$coef*scale),paste0('[',fmt(a$li95*scale),', ',fmt(a$ls95*scale),']'),fp(a$p)))
 }
}
write_table('local','Contrastes exploratorios cerca del límite educativo','tab:short_local','lrrr',
 row('Resultado','Coeficiente','IC 95\\%','$p$'),rows,
 'Orientación baja menos alta educación. Primer panel: DiD en categorías de 11 y 13 años imputados (29\\,008 observaciones salariales y 64\\,143 de composición). Segundo: diferencia de saltos lineales con valores educativos 9, 11, 13 y 14 (51\\,072 y 117\\,450 observaciones). Pesos de encuesta, controles individuales y efectos fijos de departamento y trimestre. Errores agrupados en 25 departamentos. Estos ejercicios no identifican una RD causal; el límite no asigna la reforma.')
# Tres paneles de dinámica, a partir de coeficientes ya estimados.
es<-read_out('event_study_coefs.csv')[outcome%in%ys]
es[,scale:=ifelse(outcome=='log_wage_hr',1,100)]
es[,`:=`(effect=est*scale,lo=(est-qt(.975,24)*se)*scale,hi=(est+qt(.975,24)*se)*scale)]
es[,panel:=factor(outcome,levels=ys,labels=labs)]
p<-ggplot(es,aes(event_k,effect))+geom_hline(yintercept=0,color='grey50',linewidth=.35)+
 geom_vline(xintercept=0,linetype=2,color='#9c4545',linewidth=.45)+
 geom_errorbar(aes(ymin=lo,ymax=hi),width=.15,color='#355e7c',linewidth=.4)+
 geom_point(color='#183d57',size=1.4)+facet_wrap(~panel,ncol=1,scales='free_y')+
 scale_x_continuous(breaks=c(-5,-3,-1,1,3,5,7,9,10))+
 labs(x='Trimestres respecto de 2022T2',y='Diferencia relativa a 2022T1')+
 theme_bw(base_size=10)+theme(strip.background=element_rect(fill='grey95'),panel.grid.minor=element_blank(),
 strip.text=element_text(face='bold'),plot.margin=margin(6,9,6,6))
ggsave(file.path(folder,'figures/eventos_tres_resultados.pdf'),p,width=6.3,height=6.2)
ggsave(file.path(folder,'figures/eventos_tres_resultados.png'),p,width=6.3,height=6.2,dpi=160)
cat('Generadas cinco tablas y una figura de tres resultados desde los CSV existentes.\n')
