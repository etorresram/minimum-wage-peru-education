# Shifting, Not Lifting: Minimum Wages, Informality, and Low-Skilled Workers in Peru

Replication package for the paper studying how Peru's May 2022 minimum wage increase
(from 930 to 1,025 soles, Supreme Decree 003-2022-TR) affected workers with different
levels of education, using the quarterly ENAHO employment surveys, 2021--2024, with an
out-of-sample validation on the January 2025 reform (to 1,130 soles, Supreme Decree
006-2024-TR).

## Summary of the design and findings

Peru sets a single national minimum wage, so there is no cross-sectional or staggered
variation in the policy. Identification exploits differential **exposure by education**:
low-education workers (at most complete secondary schooling) cluster around the minimum
wage and are bound by it, while high-education workers (any tertiary schooling) earn far
above it and serve as a comparison group. The design is a repeated-cross-section
difference-in-differences with a dynamic event study.

Main results: the reform did **not** raise the real wages of low-education workers
relative to high-education workers (a precisely estimated null that replicates around the
2025 reform and holds across the wage distribution). Around 2022 there is evidence of a
shift from formal employment toward self-employment, concentrated among youth and women,
but this compositional effect is less robust and does not replicate in 2025. The
aggregate employment effect is confounded by the uneven post-pandemic recovery and is
treated as inconclusive.

## Repository structure

```
project/
  data/
    raw/            # (not distributed) place the ENAHO .dta files here, or set MW_ENAHO_DIR
    processed/      # built analysis datasets, CPI, minimum-wage series, bite measures
    interim/
  scripts/
    R/              # all analysis code (see below)
    python/
  figures/          # publication figures (pdf + png)
  tables/           # publication LaTeX tables
  output/           # estimation output as CSV
  logs/             # run logs
  paper/            # LaTeX manuscript (Overleaf-ready)
    sections/ appendix/ tables/ figures/ references.bib main.tex
  literature/       # structured literature database built from the source PDFs
  docs/             # institutional background and notes
  replication/      # replication notes
```

## Requirements

- R >= 4.3. Packages: `haven`, `data.table`, `fixest`, `DRDID`, `HonestDiD`,
  `clubSandwich`, `ggplot2`, `matrixStats`, `sandwich`, `lmtest`. Optional:
  `modelsummary`, `kableExtra`.
- Python >= 3.10 with `pandas`, `pyreadstat`, `openpyxl` (used only for initial data
  inspection and the CPI/minimum-wage series; the analysis pipeline is in R).
- LaTeX (TeX Live or MiKTeX) with `natbib`, `booktabs`, `threeparttable` to compile the paper.

Install the R dependencies with:

```r
install.packages(c("haven","data.table","fixest","DRDID","HonestDiD",
                   "clubSandwich","ggplot2","matrixStats","sandwich","lmtest"))
```

## How to reproduce

1. Obtain the ENAHO quarterly employment modules (module 500) for 2021Q1--2025Q4 from
   INEI (<https://www.inei.gob.pe>) and place the `.dta` files in `data/raw/` (or point
   `MW_ENAHO_DIR` at their location). The files are named `PER_T{q}{yyyy}.dta`.
2. From the `project/` directory run:

   ```bash
   MW_PROJ_ROOT="$(pwd)" MW_ENAHO_DIR=/path/to/enaho Rscript scripts/R/run_all.R
   ```

   This builds the analysis dataset, runs all estimation, and writes every figure and
   table. Expected time is about 15--25 minutes.
3. Compile the paper:

   ```bash
   cd paper && pdflatex main && bibtex main && pdflatex main && pdflatex main
   ```

## Script guide

| Script | Purpose |
|---|---|
| `00_config.R` | Paths, verified minimum-wage schedule, education mapping, helpers |
| `01_build_panel.R` | Harmonize 20 ENAHO quarters; build outcomes; reconstruct and validate informality; deflate |
| `02_bite.R` | Regional Kaitz index and fraction-affected exposure measures |
| `03_main_estimation.R` | TWFE DiD, dynamic event study, doubly robust DiD, pre-trend tests |
| `04_descriptives_figures.R` | Descriptive statistics table and Figures 1--5 |
| `05_robustness.R` | Specification, inference (CR2, randomization), design (bite, triple difference), placebo, leave-one-out |
| `06_heterogeneity.R` | Subgroup effects and Figure 6 |
| `07_honest_distributional.R` | HonestDiD sensitivity and RIF unconditional-quantile DiD (Figures 7--8) |
| `08_validation2025.R` | Out-of-sample validation on the 2025 reform (Figure 9) |
| `09_tables.R` | Assemble all LaTeX tables |
| `run_all.R` | Master script running the full pipeline |

## Data provenance

- **ENAHO** quarterly employment modules: INEI, public use microdata.
- **Minimum wage schedule**: Supreme Decrees 003-2022-TR and 006-2024-TR, verified
  against Banco Central de Reserva del Perú series PN02124PM.
- **Consumer price index** (Lima, December 2021 = 100): BCRP series PN38705PM.

## License

Code is released under the MIT License (see `LICENSE`). The ENAHO microdata are subject
to INEI's terms of use and are not redistributed here.
