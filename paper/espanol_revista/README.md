# Borrador para revista: 16 páginas

Versión de trabajo del 20 de octubre de 2026. El límite solicitado de 20 páginas incluye portada, referencias, cuadros, figura y apéndices.

## Abrir en Overleaf

Sincronizar el proyecto existente con GitHub y seleccionar **`paper_espanol_revista.tex`** como documento principal. Las tablas, figura y bibliografía están incluidas; compilar el manuscrito no requiere ejecutar R. El PDF verificado está en `paper/espanol_revista/paper_espanol_revista.pdf`.

La versión de 64 páginas (`paper_espanol.tex`) y la primera síntesis de 13 páginas (`paper_espanol_corto.tex`) se conservan como antecedentes. Este borrador incorpora la especificación revisada del panel anual y es la versión preferida para continuar el trabajo editorial.

## Cambios respecto de la síntesis

- Motivación y contribución más desarrolladas, con distinción frente a Jaramillo y López (2006), Jiménez (2023) y Corcuera (2024).
- Descriptivos previos por educación: muestras, remuneraciones, proporciones bajo ambos pisos, franja entre pisos y composición del empleo.
- Cuatro cuadros centrales: descriptivos, resultados principales, exposición regional y transiciones.
- Ecuación explícita del panel anual y cuadro con entrada y permanencia, intervalos y tamaños de muestra.
- Tres cuadros de apéndice: 2025, variantes de especificación y exploración del límite educativo.
- Conserva las amenazas a la identificación y evita equiparar no significación con ausencia de efecto.
- Incluye disponibilidad de datos y código. No está adaptado todavía a las normas de una revista específica ni implica envío editorial.

## Revisión de las transiciones: cambio sustantivo

La especificación previa de `scripts/R/21_panel_transitions.R` incluye interacciones de baja educación con las ventanas de reforma y posterior, pero omite sus efectos comunes. Los efectos fijos de par de años no absorben completamente esos indicadores: los pares 2021–2022 y 2022–2023 contienen observaciones de dos ventanas.

El borrador añade ambos indicadores comunes, manteniendo las mismas muestras, controles, ponderadores y agrupamiento. La entrada posterior a empleo privado formal pasa de −2.12 pp (p = 0.011) a **−4.66 pp (p = 0.024)**. La permanencia al cruzar la reforma pasa de +8.26 a **+8.89 pp (p = 0.026)**; la permanencia posterior, de −2.23 a **−1.41 pp (p = 0.472)**.

Estas estimaciones son diferencias ajustadas de cambios: no deben restarse directamente de la tasa previa para obtener una probabilidad posterior. El estado formal puede incluir distintos puestos o empleadores. La entrada se estima desde asalariados informales e independientes no clasificados como formales, no desde todos los ocupados informales.

Las estimaciones trimestrales principales de salarios, formalidad y autoempleo no cambian. Los resultados antiguos del panel y la notebook original permanecen como antecedentes; para la nueva especificación debe usarse el script y los resultados de este directorio.

## Reproducir

Desde `project/`:

```sh
Rscript scripts/R/build_paper_journal.R
tectonic paper_espanol_revista.tex --outdir paper/espanol_revista --keep-logs
```

El script usa `data.table`, `fixest`, `haven`, `matrixStats` y `ggplot2`. Requiere `data/processed/enaho_pooled.rds` y el Panel ENAHO 2020–2024, módulo 1477; `MW_ENAHO_DIR` permite indicar la carpeta ENAHO que contiene `panel/978-Modulo1477/`. Se reutilizan las salidas trimestrales auditadas mediante `build_paper_short.R`, dirigido a esta carpeta sin modificar los archivos de la versión corta.

`journal_panel_data.R` conserva las definiciones y enlaces del panel original. El script verifica que reproduce los dos modelos anteriores antes de guardar la variante con indicadores comunes. Los nuevos modelos se contrastan también con `lm()` ponderado y una matriz de covarianza departamental calculada de forma independiente.

| Archivo en `results/` | Contenido |
| --- | --- |
| `descriptivos_previos.csv` | Valores de los descriptivos, antes de redondear |
| `transiciones.csv` | Especificaciones previa y revisada; coeficientes, EE, intervalos y valores p |
| `auditoria_transiciones.csv` | Diferencias frente al cálculo independiente |
| `sesion_R.txt` | Versiones del entorno de estimación |
| `verificacion_entrega.json` | Páginas y comprobaciones del PDF entregado |

Las diferencias de coeficientes y errores estándar en la auditoría son inferiores a 1e-9; las de valores p, inferiores a 1e-8. Se revisaron visualmente las 16 páginas. Las referencias terminan en la página 12 y los apéndices ocupan las páginas 13–16.

## Fuentes verificadas para la revisión bibliográfica

- Jaramillo y López (2006): https://grade.org.pe/wp-content/uploads/ddt50.pdf
- Jiménez (2023): https://doi.org/10.1016/j.labeco.2023.102463
- Corcuera (2024), versión del 2 de agosto: https://paulcorcuera.com/MWPeru_JMP.pdf
