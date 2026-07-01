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
  "01_build_panel.R",        # harmonize ENAHO, build outcomes, informality, deflate
  "02_bite.R",               # regional minimum-wage bite (Kaitz, fraction affected)
  "03_main_estimation.R",    # TWFE DiD, event study, doubly robust DiD
  "04_descriptives_figures.R",# descriptive table and figures 1-5
  "05_robustness.R",         # specification, inference, design, placebo, LOO, RI
  "06_heterogeneity.R",      # subgroup effects, figure 6
  "07_honest_distributional.R",# HonestDiD sensitivity + RIF quantile DiD, figs 7-8
  "08_validation2025.R",     # out-of-sample validation on the 2025 reform, fig 9
  "09_tables.R"              # assemble all LaTeX tables
)
for (s in steps) {
  message("\n=== Running ", s, " ===")
  source(file.path(root, "scripts", "R", s), local = new.env())
}
message("\nAll steps complete. See tables/ and figures/ for output.")
