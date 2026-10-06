# Replication notes

This file documents the exact steps and design decisions needed to reproduce the paper
"Differential Exposure to a National Minimum Wage: Wages, Formal Hiring, and Informality in Peru."

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

## External data for the pre-COVID extension (step 13)

Step `13_pretrend_extension.R` uses the annual ENAHO employment modules for 2018 and
2019 (module 05 of INEI surveys 634 and 687). Download and extract them to
`Data/ENAHO/ext/` (about 40 MB zipped):

    mkdir -p Data/ENAHO/ext && cd Data/ENAHO/ext
    curl -O https://proyectos.inei.gob.pe/iinei/srienaho/descarga/STATA/634-Modulo05.zip
    curl -O https://proyectos.inei.gob.pe/iinei/srienaho/descarga/STATA/687-Modulo05.zip
    unzip 634-Modulo05.zip -d 634 && unzip 687-Modulo05.zip -d 687

## External data for the political-crisis control (step 20)

Step `20_protest_control.R` uses department-level protest intensity during the
2022-23 political crisis, transcribed from the monthly conflict reports of the
Presidencia del Consejo de Ministros (SGSD), "Reporte de Conflictos Sociales",
gob.pe collection 11518. The tables "Maximo numero de personas movilizadas por
region" from the January-2023 and February-2023 reports (the peak months; the
December-2022 report predates that table) are transcribed in
`Data/conflictos/protest_intensity.csv`; the source PDFs are stored alongside
(`conflictos_2023_01.pdf`, `conflictos_2023_02.pdf`, downloaded 2026-07-12 from
https://www.gob.pe/institucion/pcm/colecciones/11518-reportes-de-conflictos-sociales).

## External data for the panel transitions (step 21)

Step `21_panel_transitions.R` uses the ENAHO Panel 2020-2024 (INEI survey 978,
published November 2025). Download the employment module (about 217 MB zipped,
4.3 GB extracted) to `Data/ENAHO/panel/`:

    mkdir -p Data/ENAHO/panel && cd Data/ENAHO/panel
    curl -O https://proyectos.inei.gob.pe/iinei/srienaho/descarga/STATA/978-Modulo1477.zip
    unzip 978-Modulo1477.zip

Module map for survey 978 (numbering is NOT the usual panel convention):
1474 = module 100 (dwelling; contains the Ficha Tecnica and the dictionary),
1479 = module 200, 1475 = module 300, 1476 = module 400, **1477 = module 500
(employment and income, `enaho01a-2020-2024-500-panel.dta`)**, 1478 = sumaria.
The script skips itself with a message if the file is absent.

## Pipeline order

Run `scripts/R/run_all.R` (about 20--35 minutes). The steps, in order, are:

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
9. `10_firststage.R` -- bunching/compliance first stage, Lee bounds, MDE, Figure 10.
10. `11_exposure_cells.R` -- exposure-leads diagnostics, cell fraction-affected designs.
11. `12_sector_occ.R` -- sector breadth, occupation dose-response.
12. `13_pretrend_extension.R` -- pre-COVID (2018-19) parallelism check (needs Data/ENAHO/ext/).
13. `14_sdid.R` -- synthetic DiD at the department level (jackknife SEs).
14. `15_monthly_event.R` -- monthly event studies, binned-endpoint quarterly ES, Figure 11.
15. `16_heterogeneity2.R` -- adjustment margins (contract, firm size, tenure, emplpsec) and
    subgroups (household head, ethnicity).
16. `17_pretest_power.R` -- Roth (2022) power of the pre-trends test.
17. `18_migration.R` -- robustness to the Venezuelan immigration wave.
18. `19_referee_checks.R` -- unconditional compositional outcomes (shares of the
    working-age population); regional-design sample checks (southern-bloc exclusion,
    2022-only post window) with randomization inference.
19. `20_protest_control.R` -- direct protest-intensity control in the continuous
    regional design (needs Data/conflictos/protest_intensity.csv, see above).
20. `21_panel_transitions.R` -- worker-level transitions across the reform using the
    ENAHO Panel 2020-2024 (needs Data/ENAHO/panel/, see above; skips if absent).
21. `22_state_dependence.R` -- state-dependence probe: floor position (swept band,
    bunching) vs labor-market churn (new-hire share) on the eve of each reform,
    plus department-level match-creation dose tests for both reforms.
22. `09_tables.R` -- assemble all LaTeX tables (runs last).

R packages beyond CRAN: `synthdid` and `pretrends` are installed from GitHub
(`synth-inference/synthdid`, `jonathandroth/pretrends`).

## Building the paper

- From the repository root: `tectonic paper_english.tex` (or `pdflatex; bibtex; pdflatex;
  pdflatex`). The Spanish version is `paper_espanol.tex`, its text in `paper/espanol/`.
- Spanish tables (`tables/es/`) and figures (`figures/es/`) are produced by the same run:
  `09_tables.R` and `save_fig()` translate them with the catalogs in `scripts/R/i18n/`.
  A segment missing from a catalog (for instance after a note or a number changes) stays
  in English and is listed in a warning.
- Overleaf is linked to this repository through GitHub Sync; choose the version with
  Menu > Main document (`paper_english.tex` or `paper_espanol.tex`).

## Key measurement decisions

- Education (p301a) coding validated against the weighted attainment distribution; low-skill
  = codes 1--6, high-skill = codes 7--11; code 12 (special education) and missing excluded.
- Informality: official `ocupinf` (coded 1 informal, 2 formal) used for 2021--2023; a
  reconstruction from pension affiliation, contract, and firm registration used for 2024--2025
  (validated at 88.3% agreement on the overlap).
- Wages: p524a1 is reported PER PAY PERIOD; it is converted to a monthly equivalent using
  the pay frequency p523 with INEI-consistent factors (daily x25, weekly x52/12,
  fortnightly x2, monthly x1; verified against INEI's own annualized i524a1). Wage earners =
  employees AND domestic workers (p507 in {3,4,6}; p507 codes 5/6 are TFNR/domestic --
  validated against the dictionary and the data). Own-account/employer income = p530a
  (already monthly). Incomes are deflated at the REFERENCE month (the month before the
  interview; January interviews roll back to December of the previous year) by the Lima CPI
  (Dec-2021=100, BCRP PN38705PM, regenerated by scripts/R/data_prep_external.R); hourly wage
  divides by 4.345 times weekly hours; winsorized once, in 01_build_panel.R, at 0.5/99.5
  percentiles on the canonical private wage-earner sample.
- Pension affiliation items p558a1..a5 are marked with their OPTION CODES (0/1, 0/2, ... 0/5),
  not 0/1; any positive value = selected.
- The partially treated transition quarter 2022Q2 is EXCLUDED from the baseline (the reform
  took effect 1 May 2022); an "include transition quarter" row appears in the robustness table.
- Public-sector workers are excluded from job-conditional outcomes (public pay scales do not
  respond to the RMV); an "include public sector" robustness row is reported.
- KNOWN DATA QUIRK: the raw ENAHO extracts contain a stray non-INEI column
  (`gpt4_rubric1_beta` in PER_T12022.dta) left by an earlier tool; it is never read by the
  pipeline (column whitelist in 01_build_panel.R).

## Summary of findings (for sanity-checking a re-run; post data-fix, July 2026)

- Log real hourly wage DiD: about -0.021 (s.e. 0.012), not significant at 5%; the joint
  pre-trend test rejects (p = 0.001) owing to a single spike at k=-4, so the wage estimate
  should be read with caution rather than as a precise null.
- Formal employment DiD: about -0.046 (pre-trend p = 0.15); self-employment DiD: about
  +0.036; employment DiD: about -0.025 (fragile: fails placebos, CR2, and has a
  pandemic-driven pre-trend).
- Continuous-exposure design (Post x regional Kaitz): employment -0.034 (RI p = 0.003),
  formality -0.018 (RI p < 0.001), self-employment +0.010 (RI p = 0.024) -- coherent with
  the education-group composition results.
- Triple difference: all null. DR-DiD with department-clustered SEs: all null.
- 2025 reform: wage, employment, formality null; self-employment reverses sign (-0.014).
