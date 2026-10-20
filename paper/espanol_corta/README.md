# Versión breve del paper

Documento independiente: `paper_espanol_corto.pdf`. La versión extensa se conserva en `paper/espanol/paper_espanol.pdf`.

## Cambios editoriales

- El argumento se concentra en salario horario, formalidad y autoempleo.
- Se acortan la introducción, la revisión de literatura y la discusión de mecanismos.
- El texto principal conserva las especificaciones educativa y regional, dos cuadros y una figura de tres paneles.
- Las transiciones del panel y el contraste con 2025 se sintetizan.
- Las variantes de especificación se concentran en un cuadro del apéndice. Se conservan los diagnósticos adversos de tendencias y sensibilidad que modifican la interpretación.
- El ejercicio cercano al límite educativo se presenta como exploratorio: la educación no determina la asignación de la RMV y sus años son imputados por categoría. No se afirma que identifique una regresión discontinua causal.

## Reproducir la versión breve

Desde la raíz de `project/`:

```sh
Rscript scripts/R/build_paper_short.R
tectonic paper_espanol_corto.tex --outdir paper/espanol_corta --keep-logs
```

El primer comando usa R (`data.table` y `ggplot2`) para convertir los resultados existentes en cinco cuadros y una figura; no reestima los modelos. El segundo compila el manuscrito. Las estimaciones y su auditoría en R están documentadas en `notebooks/feedback_coautor.ipynb`, `notebooks/feedback_coautor.R` y `notebooks/revisar_feedback_coautor.R`.

Para editar solamente el texto y compilar, basta el segundo comando. El archivo `fuentes_version_breve.zip` contiene el manuscrito, sus fragmentos, cuadros, figura y bibliografía con las rutas necesarias. Descomprimir y ejecutar el segundo comando desde la carpeta que contiene `paper_espanol_corto.tex`.

## Procedencia de resultados

| Elemento | Archivos de origen |
| --- | --- |
| Cuadro principal | `output/main_did_coefs.csv`, `output/pretrend_tests.csv` |
| Figura de eventos | `output/event_study_coefs.csv` |
| Exposición regional | `output/rob_continuous.csv`, `output/exposure_leads.csv` |
| Comparación de 2025 | `output/validation2025_did.csv` |
| Variantes | `output/rob_specifications.csv`, `output/rob_migration.csv` |
| Comparaciones educativas locales | `notebooks/feedback_coautor_resultados.csv` |
| Transiciones | `output/panel_entry_did.csv`, `output/panel_transitions_did.csv` |
| Limitaciones y sensibilidad | `output/honestdid.csv`, `output/drdid_coefs.csv`, `output/rob_inference.csv`, `output/referee_regional_crisis.csv` |

Las proporciones se convierten a puntos porcentuales multiplicando coeficientes y errores estándar por 100. Los intervalos convencionales usan el valor crítico de una distribución t con 24 grados de libertad, correspondiente a 25 grupos departamentales. Las estimaciones de otros diseños o agregaciones se describen por separado para evitar combinar coeficientes con inferencia que no les corresponde.

## Verificación de entrega

El PDF tiene 13 páginas: nueve hasta el final de las referencias y cuatro de apéndices, frente a 64 páginas de la versión extensa. Se revisaron visualmente todas sus páginas. La compilación no presenta referencias indefinidas ni desbordamientos de cajas de texto.
