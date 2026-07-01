# Replication notes

This file documents the exact steps and design decisions needed to reproduce the paper
"Minimum Wages and Workers by Education Level: Evidence from Peru's 2022 Reform."

## Environment used

- macOS (Darwin), R 4.5.0, Python 3.11.
- Key R packages: `haven`, `data.table`, `fixest`, `DRDID`, `HonestDiD`, `clubSandwich`,
  `ggplot2`, `matrixStats`. LaTeX via `tectonic` (or any TeX Live).

## Verified institutional facts (do not change without re-verifying)

- The minimum wage (RMV) was S/930 through April 2022, S/1,025 from 1 May 2022
  (D.S. 003-2022-TR), and S/1,130 from 1 January 2025 (D.S. 006-2024-TR). Verified against
  the decrees and BCRP series PN02124PM.
- The study window 2021Q1--2024Q4 contains exactly one reform (May 2022). This is why the
  design is a single-date, cross-sectional-exposure DiD and NOT a staggered-adoption design.

## Pipeline order

Run `scripts/R/run_all.R` (about 15--25 minutes). The steps, in order, are:

1. `01_build_panel.R` -- reads the 20 ENAHO quarterly files, harmonizes variables, builds
   the skill groups and outcomes, reconstructs and validates informality, deflates by CPI.
2. `02_bite.R` -- regional Kaitz index and fraction-affected exposure measures.
3. `03_main_estimation.R` -- TWFE DiD, dynamic event study, doubly robust DiD, pre-trend tests.
4. `04_descriptives_figures.R` -- descriptive table and Figures 1--5.
5. `05_robustness.R` -- specifications, inference (CR2 on collapsed cells; randomization
   inference on regional exposure, 2,000 draws), triple difference, continuous exposure,
   placebo, leave-one-out. NOTE: randomization inference and CR2 are applied to
   department-level collapsed cells; applying CR2 to the full 200k-row sample is infeasible
   (it builds per-cluster O(n^2) matrices).
6. `06_heterogeneity.R` -- subgroup effects and Figure 6.
7. `07_honest_distributional.R` -- HonestDiD sensitivity (average post-reform effect) and
   RIF unconditional-quantile DiD, Figures 7--8.
8. `08_validation2025.R` -- out-of-sample validation on the 2025 reform, Figure 9.
9. `09_tables.R` -- assemble all LaTeX tables.

## Building the paper

- `cd paper && tectonic -X compile main.tex` (or `pdflatex; bibtex; pdflatex; pdflatex`).
- For an Overleaf-ready, self-contained bundle: `bash scripts/make_overleaf.sh`, which
  writes `replication/overleaf/` and `replication/overleaf_project.zip`.

## Key measurement decisions

- Education (p301a) coding validated against the weighted attainment distribution; low-skill
  = codes 1--6, high-skill = codes 7--11; code 12 (special education) and missing excluded.
- Informality: official `ocupinf` (coded 1 informal, 2 formal) used for 2021--2023; a
  reconstruction from pension affiliation, contract, and firm registration used for 2024--2025
  (validated at 88.3% agreement on the overlap).
- Wages: nominal monthly labor income (p524a1 for employees, p530a for own-account) deflated
  by the Lima CPI to December 2021 soles; hourly wage divides by 4.345 times weekly hours;
  winsorized at 0.5/99.5 percentiles. Because quarter fixed effects absorb national inflation,
  log-wage DiD estimates are invariant to the national deflator.

## Summary of findings (for sanity-checking a re-run)

- Log real hourly wage DiD: about -0.009 (s.e. 0.022), a precise null; pre-trend p = 0.60.
- Formal employment DiD: about -0.036; self-employment DiD: about +0.029; employment DiD:
  about -0.025 (fragile; fails conservative inference and has a pandemic-driven pre-trend).
- 2025 reform: wage null again; formality/employment null; self-employment reverses sign.
