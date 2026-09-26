# ==============================================================================
# run_all.R  --  Master replication script.
# Runs the full pipeline from raw ENAHO files to tables and figures.
# Usage:  MW_PROJ_ROOT=/path/to/project Rscript scripts/R/run_all.R
#         (set MW_ENAHO_DIR if the raw .dta files are not in the default location)
# Expected wall-clock time: about 15-25 minutes on a modern laptop.
# ==============================================================================
root <- Sys.getenv("MW_PROJ_ROOT", getwd())
Sys.setenv(MW_PROJ_ROOT = root)
steps <- c(
  # "data_prep_external.R"   # OPTIONAL: regenerates the CPI deflator and MW
  #                          # series from the BCRP API (requires internet);
  #                          # the generated CSVs ship with the package.
  "01_build_panel.R",        # harmonize ENAHO, build outcomes, informality, deflate
  "02_bite.R",               # regional minimum-wage bite (Kaitz, fraction affected)
  "03_main_estimation.R",    # TWFE DiD, event study, doubly robust DiD
  "04_descriptives_figures.R",# descriptive table and figures 1-5
  "05_robustness.R",         # specification, inference, design, placebo, LOO, RI
  "06_heterogeneity.R",      # subgroup effects, figure 6
  "07_honest_distributional.R",# HonestDiD sensitivity + RIF quantile DiD, figs 7-8
  "08_validation2025.R",     # out-of-sample validation on the 2025 reform, fig 9
  "10_firststage.R",         # bunching/compliance first stage, Lee bounds, MDE, fig 10
  "11_exposure_cells.R",     # exposure-leads diagnostics + cell fraction-affected designs
  "12_sector_occ.R",         # sector breadth and occupation dose-response
  "13_pretrend_extension.R", # pre-COVID (2018-19) parallel-trends extension
  "14_sdid.R",               # synthetic DiD at the department level
  "15_monthly_event.R",      # monthly event studies + binned-endpoint quarterly ES
  "16_heterogeneity2.R",     # adjustment margins, household role, ethnicity
  "17_pretest_power.R",      # Roth (2022) power of the pre-trends test
  "18_migration.R",          # robustness to the Venezuelan immigration wave
  "19_referee_checks.R",     # unconditional outcomes + regional-design crisis checks
  "20_protest_control.R",    # 2022-23 political-crisis protest-intensity control
  "21_panel_transitions.R",  # worker-level transitions, ENAHO Panel 2020-2024
  "22_state_dependence.R",   # state-dependence probe: floor position vs market churn
  "09_tables.R"              # assemble all LaTeX tables (runs last: consumes all output)
)
# NOTE: step 13 requires the 2018-2019 ENAHO module-05 files (INEI surveys 634
# and 687), downloaded to Data/ENAHO/ext/ -- see replication/REPLICATION.md.
for (s in steps) {
  message("\n=== Running ", s, " ===")
  source(file.path(root, "scripts", "R", s), local = new.env())
}
message("\nAll steps complete. See tables/ and figures/ for output.")
