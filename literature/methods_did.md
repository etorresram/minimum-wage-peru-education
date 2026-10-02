# DiD Methods Database — Minimum Wage in Peru

**Purpose.** Structured methods notes for an empirical labor-economics paper on the effects of Peru's **single national minimum-wage reform (May 2022)**, affecting all workers simultaneously. In our design, **treatment timing is common to everyone; treatment *intensity* varies cross-sectionally by worker skill/education** (a bite / exposure design), not by adoption date. Every entry below closes with an explicit read on whether the tool needs *staggered timing* (which we do NOT have) or applies to a *single-date / 2-group* design (which we DO have). See the **Recommendation Matrix** at the end for the bottom line.

Source folder: `Papers y documentos/DiD/` (carpeta local, fuera del repositorio)

---

## Quick classification

| # | Paper | Type | Needs staggered timing? | Directly usable in our single-date bite design? |
|---|-------|------|--------------------------|--------------------------------------------------|
| 1 | Kennedy-Shaffer (2024) — Generalized DiD (stepped-wedge) | Estimator | Yes (built on staggered/stepped-wedge adoption) | No (but permutation-inference idea transfers) |
| 2 | Rambachan & Roth (2023) — HonestDiD | Sensitivity/inference | No — needs multiple **pre-periods** | **Yes** — sensitivity on our event-study pre-trends |
| 3 | Wing, Simon & Bello-Gomez (2018) — Best practices (public health) | Review | No | **Yes** — design & inference checklist |
| 4 | Wing et al. (2024) — Staggered adoption guide | Review | Yes (scope is staggered) | Partly (background; estimators mostly N/A) |
| 5 | Butts & Gardner (2022) — did2s (two-stage) | Estimator/software | Yes (targets staggered TWFE bias) | No |
| 6 | Baker, Callaway, Cunningham, Goodman-Bacon & Sant'Anna (2026) — Practitioner's Guide (JEL) | Review | No — covers both | **Yes** — canonical 2×2 / 2×T guidance |
| 7 | Callaway & Sant'Anna (2021) — Multiple time periods | Estimator | Yes (multiple groups/periods) | The **2×2 DR building block** applies; full ATT(g,t) machinery N/A |
| 8 | Goodman-Bacon (2021) — Variation in treatment timing | Diagnostic | Yes (decomposition needs timing variation) | No (no timing variation to decompose) |
| 9 | Sant'Anna & Zhao (2020) — Doubly robust DiD | Estimator | **No — 2×2 single-date** | **Yes** — DR 2-period ATT with skill covariates |
| 10 | Bertrand, Duflo & Mullainathan (2004) — Trust DiD estimates | Inference critique | No — single-date, many groups | **Yes** — serial-correlation SE fixes |
| 11 | Baker, Larcker & Wang (2022) — Trust staggered estimates | Demonstration | Yes (bias is a staggered phenomenon) | **Yes as reassurance** — shows TWFE is unbiased at a single common date |
| 12 | Imai & Kim (2021) — TWFE for causal inference | Theory critique | No (general panels) | **Yes** — 2FE=DiD only in 2×2; linearity caveat |
| 13 | Greene & Liu (2020) — Review (policy test research) | Review/pedagogy | No | **Yes** — assumptions primer |
| 14 | Sudhaharan / Tilburg Science Hub — Staggered DiD in R | Tutorial | Yes | No |
| 15 | Bounthavong (2024) — Staggered DiD using R | Tutorial | Yes | No |
| 16 | Porreca (2022) — Synthetic DiD with staggered timing | Estimator | Extends SDID to staggered; SDID core is single-date-capable | **Yes (core SDID)** — with skill groups as "units" |
| 17 | de Chaisemartin & D'Haultfœuille — Package DiD (multiple periods/groups) | Estimator/software | Yes (many periods/groups; on/off) | No (single switch) |
| 18 | Roth, Sant'Anna, Bilinski & Poe (2023) — What's trending in DiD | Synthesis | No — covers both; explicit single-date guidance | **Yes** — the master decision guide |

---

## Full entries

### 1. Kennedy-Shaffer (2024) — A Generalized DiD Estimator for Randomized Stepped-Wedge and Observational Staggered Adoption Settings
- **Citation.** Lee Kennedy-Shaffer (2024). *A Generalized Difference-in-Differences Estimator for Randomized Stepped-Wedge and Observational Staggered Adoption Settings.* Dept. of Biostatistics, Yale School of Public Health. Working paper / preprint (arXiv:2405.08730v2, 22 Aug 2024).
- **Estimator.** Non-parametric class: a **weighted sum of all possible 2×2 DiD building blocks** `D = (Y_{ij'}−Y_{ij}) − (Y_{i'j'}−Y_{i'j})`, weights chosen to (a) target a desired estimand without bias under an assumed homogeneity setting and (b) minimize variance under a working covariance structure. Written `θ̂ = wᵀAy`. Callaway–Sant'Anna, de Chaisemartin–D'Haultfœuille, Sun–Abraham, and stepped-wedge estimators are special cases.
- **Assumptions.** (1) No spillover/SUTVA; (2) No anticipation; (3) Parallel trends (implied by randomized adoption sequences in stepped-wedge trials); staggered = absorbing treatment. Five nested homogeneity settings (S1 heterogeneous → S5 homogeneous).
- **Problem solved.** Unified, transparent bias–variance–generalizability management; avoids contaminated comparisons; makes weights (hence the implied estimand) explicit.
- **Appropriate vs inappropriate.** Built for **staggered / stepped-wedge (variable-timing)** designs; requires multiple periods and generally staggered structure. Overkill for a single-date 2×2 (which is one building block). Does not handle treatment on/off (only absorbing).
- **Inference.** **Permutation / randomization inference** (natural in randomized stepped-wedge); variance minimized under an assumed working covariance, with sensitivity across covariance assumptions.
- **Software.** Author-provided R code (no named CRAN package).
- **Our design.** Timing is common, so the staggered machinery is N/A; but the **permutation-inference** idea is transferable to our few-cluster settings.

### 2. Rambachan & Roth (2023) — A More Credible Approach to Parallel Trends (HonestDiD)
- **Citation.** Ashesh Rambachan & Jonathan Roth (2023). *A More Credible Approach to Parallel Trends.* Review of Economic Studies 90(5): 2555–2591. doi:10.1093/restud/rdad018.
- **Method.** **Sensitivity analysis / robust inference** for DiD & event studies when parallel trends may fail. Restrict the set `Δ` of possible post-treatment PT violations (relative to observed pre-trends), **partially identifying** `θ = l'τ_post`. Two inference routes: (1) conditional & hybrid **moment-inequality (ARP)** tests for polyhedral `Δ`; (2) **Fixed-Length Confidence Intervals (FLCIs)** for convex, centrosymmetric `Δ` (e.g. `Δ^SD`). Restriction choices: relative magnitudes `Δ^RM(M̄)`, smoothness/second-difference `Δ^SD(M)`, sign/monotonicity.
- **Assumptions.** Event-study `β̂` asymptotically normal, `β = τ + δ`, `τ_pre = 0` (no anticipation). Replaces exact PT (`δ_post = 0`) with `δ ∈ Δ`. **Needs multiple pre-periods.**
- **Problem solved.** Pre-trend tests are underpowered and conditioning on them distorts inference; conventional CIs undercover when PT is violated. Delivers uniformly valid inference and honest "breakdown" sensitivity.
- **Appropriate vs inappropriate.** **Any DiD/event study with multiple pre-periods** — explicitly nests the **single common-date canonical DiD** (their Example 1) and staggered (Example 2). **Does NOT require staggered timing.** Inapplicable to a pure 2-period, no-pre-period design.
- **Inference.** ARP conditional/hybrid for general `Δ`; FLCIs in the special convex case. Report confidence sets across a range of `M̄`/`M`.
- **Software.** **HonestDiD** in R and Stata.
- **Our design.** **Directly usable.** Run our single-cohort event study (multiple pre-2022 quarters/years), then use HonestDiD to test how large a differential skill-group trend would have to be to overturn the result.

### 3. Wing, Simon & Bello-Gomez (2018) — Designing DiD Studies: Best Practices for Public Health Policy Research
- **Citation.** Coady Wing, Kosali Simon & Ricardo A. Bello-Gomez (2018). *Designing Difference in Difference Studies: Best Practices for Public Health Policy Research.* Annual Review of Public Health 39: 453–469. doi:10.1146/annurev-publhealth-040617-013507.
- **Method (review).** Canonical 2×2 and generalized TWFE `Y_{gt} = a_g + b_t + δD_{gt} + ε`; graphical pre-trend checks, group-specific trends, balance tests, **Granger/leads tests**, event-study lags, and **triple-differences (DDD)**.
- **Assumptions.** Common (parallel) trends; **strict exogeneity** (whole treatment path independent of unobservables given FE — rules out anticipation); implicit no-anticipation, tested via leads.
- **Problem solved.** Practical guide to building credible DiD in public health, incl. policy intensity (taxes, minimum wage) and choice of comparison group.
- **Appropriate vs inappropriate.** General; covers both single-date 2×2 and multi-group/period TWFE. **Predates the staggered critique** — does not flag negative weighting. Solid design checklist; do not rely on alone for staggered+heterogeneous settings.
- **Inference.** Warns of Moulton/serial-correlation SE bias. Recommends aggregating to treatment level, **cluster-robust SEs with many clusters**; for **few clusters**: cluster-level **randomization/permutation**, **cluster bootstrap incl. wild cluster bootstrap**, bias-reduced linearization.
- **Software.** None named.
- **Our design.** **Usable** — DDD (e.g., skill × post × region) and the few-cluster inference menu are directly relevant.

### 4. Wing, Yozwiak, Hollingsworth, Freedman & Simon (2024) — Designing DiD Studies with Staggered Treatment Adoption
- **Citation.** Coady Wing, Madeline Yozwiak, Alex Hollingsworth, Seth Freedman & Kosali Simon (2024). *Designing Difference-in-Difference Studies with Staggered Treatment Adoption: Key Concepts and Practical Guidelines.* Annual Review of Public Health 45: 485–505. doi:10.1146/annurev-publhealth-061022-050825.
- **Method (review).** Frames staggered adoption as an ensemble of 2×2 subexperiments around `ATT(a,t)`; explains Goodman-Bacon decomposition, "forbidden"/bad comparisons, and clean controls. Compares six heterogeneity-robust estimators: **Stacked DID, Callaway–Sant'Anna, Gardner two-stage, Sun–Abraham, Wooldridge, de Chaisemartin–D'Haultfœuille** (side-by-side Table 1).
- **Assumptions.** (1) No anticipation; (2) common trends vs never-/not-yet-treated; binary absorbing treatment.
- **Problem solved.** Under staggered timing + time-varying/heterogeneous effects, TWFE `β_FE` is a (possibly negatively) variance-weighted average contaminated by late-vs-early forbidden comparisons.
- **Appropriate vs inappropriate.** Entire scope is **staggered/variable timing**. Explicitly notes that with a **single common date / 2-group 2×2, `β_FE = ATT`** and the staggered bias does not arise — the robust machinery is then unnecessary. Most estimators handle only binary absorbing treatments.
- **Inference (Table 1).** Stacked: cluster at group. CS & Sun–Abraham: bootstrap (CS also multiplier bootstrap w/ uniform bands). Gardner & Wooldridge: analytic asymptotic SEs. dCDH: novel asymptotic distribution. Athey–Imbens design-based alternative. Test pre-trends via Roth (power) and Rambachan–Roth (bounds).
- **Software.** did2s, did/csdid, didimputation, eventstudyinteract/sunab in fixest, staggered, STACKEDEV, did_multiplegt, bacondecomp, fixest.
- **Our design.** Background only. Its key sentence is reassuring for us: at a single common date TWFE equals the ATT, so the staggered estimators here are **N/A** for our timing structure.

### 5. Butts & Gardner (2022) — did2s: Two-Stage Difference-in-Differences
- **Citation.** Kyle Butts & John Gardner (2022). *did2s: Two-Stage Difference-in-Differences.* The R Journal 14(3): 162–173. (Implements Gardner 2022, arXiv:2207.05943.)
- **Estimator.** Two-stage imputation: Stage 1 estimate `μ_g + η_t` on untreated/not-yet-treated obs only, residualize; Stage 2 regress residuals on treatment (static) or leads/lags (dynamic). Avoids TWFE negative-weight contamination. Two-stage GMM ⇒ known asymptotic variance.
- **Assumptions.** Parallel trends for all units; limited/no anticipation; **correct specification of Y(0)** (imputation-based).
- **Problem solved.** TWFE negative weighting / forbidden comparisons under staggered timing with dynamic/heterogeneous effects.
- **Appropriate vs inappropriate.** Designed for **staggered adoption**; needs never- and not-yet-treated controls. Handles common-date as a special case but adds nothing there over TWFE.
- **Inference.** Naïve 2nd-stage SEs are wrong (generated regressor); package gives correct two-stage GMM analytic clustered SEs (`cluster_var`, default unit); optional bootstrap.
- **Software.** **did2s** (R), built on fixest; `event_study()` wrapper compares Gardner/BJS/CS/Sun–Abraham/staggered.
- **Our design.** **N/A** — no staggered timing to residualize away.

### 6. Baker, Callaway, Cunningham, Goodman-Bacon & Sant'Anna (2026) — Difference-in-Differences Designs: A Practitioner's Guide
- **Citation.** Andrew Baker, Brantly Callaway, Scott Cunningham, Andrew Goodman-Bacon & Pedro H. C. Sant'Anna (2026). *Difference-in-Differences Designs: A Practitioner's Guide.* Journal of Economic Literature 64(2): 498–557. doi:10.1257/jel.20251650.
- **Method (review).** "Forward-engineering" framework: any DiD (incl. staggered) = aggregation of 2×2 building blocks. Covers canonical 2×2, 2×T event study, and staggered G×T; plug-in ATT(g,t) under three PT variants; covariates via RA, IPW, DR.
- **Assumptions.** No-anticipation (NA/NA-S); SUTVA; graded PT: PT (2×2), PT-ES (2×T), and staggered PT-GT-NEV / PT-GT-NYT / PT-GT-ALL.
- **Problem solved.** Educates on TWFE wrong-sign risk under heterogeneity/staggering; pitfalls of covariate adjustment in TWFE and pre-trend "eye-tests."
- **Appropriate vs inappropriate.** **Covers BOTH** single common-date 2×2/2×T AND staggered. **Not tied to staggered timing.** Cautions on never-treated comparisons when comparison units differ or are few.
- **Inference.** Cluster SEs; for many ATT(g,t)'s use **simultaneous (sup-t) uniform bands**; Montiel Olea–Plagborg-Møller / nonparametric / Bayesian bootstrap. Pre-trends via Rambachan–Roth sensitivity. Discusses design- vs sampling-based inference.
- **Software.** R **did** package; R & Stata replication code.
- **Our design.** **Usable** — the 2×2 / 2×T portions, covariate DR guidance, and uniform bands for our single-cohort event study are the relevant parts.

### 7. Callaway & Sant'Anna (2021) — Difference-in-Differences with Multiple Time Periods
- **Citation.** Brantly Callaway & Pedro H. C. Sant'Anna (2021). *Difference-in-Differences with Multiple Time Periods.* Journal of Econometrics 225(2): 200–230. doi:10.1016/j.jeconom.2020.12.001. (Original application: minimum wage & teen employment.)
- **Estimator.** Group-time `ATT(g,t) = E[Y_t(g)−Y_t(0) | G_g=1]`, plus aggregations (event-study, group, calendar, overall). Identification via OR, IPW, or **doubly-robust** (Sant'Anna–Zhao); conditional PT with covariates.
- **Assumptions.** (1) Irreversibility (staggered/absorbing); (2) random sampling; (3) limited anticipation (δ≥0); (4 or 5) conditional PT vs **never-treated** or **not-yet-treated**; (6) overlap.
- **Problem solved.** Avoids TWFE negative weighting / forbidden comparisons under staggered timing; separates identification, aggregation, estimation.
- **Appropriate vs inappropriate.** Designed for **staggered timing, multiple periods/groups**; reduces to canonical ATT in the 2×2 case. Needs never- or not-yet-treated controls.
- **Inference.** **Multiplier (wild) bootstrap** with **simultaneous confidence bands**.
- **Software.** R **did** (CRAN).
- **Our design.** The full ATT(g,t) staggered machinery is **N/A** (only one cohort). But the paper's **doubly-robust 2×2 building block** with covariate-conditional PT is exactly what we should use for our two-period skill-group DiD (see #9).

### 8. Goodman-Bacon (2021) — Difference-in-Differences with Variation in Treatment Timing
- **Citation.** Andrew Goodman-Bacon (2021). *Difference-in-Differences with Variation in Treatment Timing.* Journal of Econometrics 225(2): 254–277. doi:10.1016/j.jeconom.2021.03.014.
- **Method (diagnostic).** DiD Decomposition Theorem: TWFEDD = weighted average of all 2×2 DiDs among timing groups, incl. earlier-vs-later ("forbidden") comparisons; weights ∝ group sizes × treatment variance. Target = variance-weighted ATT (VWATT).
- **Assumptions.** Variance-weighted common trends (VWCT=0); clean recovery needs constant-over-time effects (ΔATT=0), else timing comparisons inject bias/negative weights.
- **Problem solved.** Diagnoses why/how staggered TWFE fails; quantifies identifying variation.
- **Appropriate vs inappropriate.** A tool **specifically for staggered TWFE**; **does not apply to a single common-date 2×2** (no timing variation to decompose).
- **Inference.** Not an inference method; empirical work uses robust SEs; points to design-based inference.
- **Software.** Stata **bacondecomp** (SSC); R **bacondecomp**.
- **Our design.** **N/A** — nothing to decompose without timing variation.

### 9. Sant'Anna & Zhao (2020) — Doubly Robust Difference-in-Differences Estimators
- **Citation.** Pedro H. C. Sant'Anna & Jun Zhao (2020). *Doubly Robust Difference-in-Differences Estimators.* Journal of Econometrics 219(1): 101–122. doi:10.1016/j.jeconom.2020.06.003.
- **Estimator.** **Doubly-robust ATT** combining outcome regression (OR) and propensity-score (IPW): consistent if EITHER the PS model OR the comparison-group outcome model is correct. Panel and repeated-cross-section versions; "improved" DR estimators are also **doubly robust for inference** (variance invariant to which nuisance is right).
- **Assumptions.** (1) iid panel or stationary mixture (no compositional change in RCS); (2) **conditional parallel trends** given X; (3) overlap.
- **Problem solved.** Removes fragility of OR-only vs IPW-only DiD; adds semiparametric efficiency.
- **Appropriate vs inappropriate.** Framed for the **canonical two-period, two-group (single common date) setting with covariates** — **NOT a staggered estimator.** Ideal when PT is credible only conditional on covariates and covariate dimension is moderate/high. RCS case needs no compositional change.
- **Inference.** Influence-function analytic SEs; "improved" DR valid regardless of which nuisance model holds.
- **Software.** R **DRDID** (also Stata `drdid`).
- **Our design.** **Strong direct fit.** This is the workhorse 2-period DiD for us: high- vs low-skill(exposure) groups, pre vs post May-2022, with education/experience covariates entering the OR and PS models. Doubly robust to specification of either.

### 10. Bertrand, Duflo & Mullainathan (2004) — How Much Should We Trust Differences-in-Differences Estimates?
- **Citation.** Marianne Bertrand, Esther Duflo & Sendhil Mullainathan (2004). *How Much Should We Trust Differences-in-Differences Estimates?* Quarterly Journal of Economics 119(1): 249–275. (In-hand: NBER WP 8841, 2002.)
- **Method.** Inference critique: DiD SEs are severely biased **down** from serial correlation (compounded by the near-permanent treatment dummy and long panels). Placebo-law CPS Monte Carlo: significant "effects" in up to 45% of placebos.
- **Assumptions.** Takes identification as given; focus purely on variance/inference.
- **Problem solved.** Over-rejection from ignoring within-group serial correlation in multi-period DiD.
- **Appropriate vs inappropriate.** The **standard single-treatment-date, many-groups, multi-period DiD** — not a staggered estimator. Fixes evaluated by #groups/#periods.
- **Inference.** (1) **Cluster on the group** allowing arbitrary within-group covariance (works with many groups, over-rejects with few); (2) **collapse to pre/post** (residual aggregation if timing varies); (3) **randomization/permutation inference** (works regardless of #groups — preferred with few groups). Avoid parametric AR(k)/GLS and (few-group) block bootstrap.
- **Software.** Stata built-in `cluster`; no named package.
- **Our design.** **Directly usable.** With repeated cross-sections/panel over many pre/post periods and few skill "groups," prefer collapsing to pre/post and/or randomization inference; cluster at the level treatment varies.

### 11. Baker, Larcker & Wang (2022) — How Much Should We Trust Staggered DiD Estimates?
- **Citation.** Andrew C. Baker, David F. Larcker & Charles C. Y. Wang (2022). *How much should we trust staggered difference-in-differences estimates?* Journal of Financial Economics 144(2): 370–395. doi:10.1016/j.jfineco.2022.01.004.
- **Method.** Demonstration/survey of when staggered TWFE is biased; applies Callaway–Sant'Anna, Sun–Abraham, and Gormley–Matsa (stacked/cohort).
- **Assumptions.** PT, no anticipation, SUTVA, irreversible treatment.
- **Problem solved.** TWFE negative weighting / forbidden comparisons; `plim δ̂ = VWATT + VWCT − ΔATT`, so under heterogeneity a positive-everywhere effect can estimate negative.
- **Appropriate vs inappropriate — key for us.** Simulations show TWFE is **UNBIASED with a SINGLE common treatment date**, even under dynamic or cross-firm heterogeneous effects; also unbiased under staggering IF effects are homogeneous. **Bias arises specifically when staggered timing is COMBINED with heterogeneity.**
- **Inference.** Follows the chosen alternative estimator; no separate prescription.
- **Software.** None named in-text (methods map to `did`, `eventstudyinteract`).
- **Our design.** **Reassurance:** our common May-2022 date means the staggered bias these papers target does not arise. Standard/interacted TWFE and event studies are legitimate for the *timing* dimension; remaining concerns are about the *cross-sectional* comparison (parallel trends across skill groups), addressed by HonestDiD/DR/DDD.

### 12. Imai & Kim (2021) — On the Use of Two-Way Fixed Effects Regression Models for Causal Inference with Panel Data
- **Citation.** Kosuke Imai & In Song Kim (2021). *On the Use of Two-Way Fixed Effects Regression Models for Causal Inference with Panel Data.* Political Analysis 29(3): 405–415. doi:10.1017/pan.2020.33.
- **Method (theory).** Recasts 2FE as a **two-way matching estimator**. Formalizes a PT assumption; key result: 2FE's simultaneous adjustment for unit & time confounders relies critically on the **linear additive functional form** — it is not design-based.
- **Problem solved.** (a) Nonparametric adjustment for both confounder types is impossible in 2FE (mismatches ⇒ attenuation); (b) the "2FE = DiD" equivalence holds **only in the 2×2 case**; in general multi-period panels, DiD = a weighted 2FE with **some negative weights**.
- **Appropriate vs inappropriate.** Applies to general panels where treatment can switch on/off; a broad 2FE critique, both single-date and staggered. Message: 2FE is causal only under strong linearity; not generally = DiD outside 2×2.
- **Inference.** Analytical contribution; no specific inference prescription in the read pages. (Companion R tools: `wfe`, `PanelMatch`.)
- **Our design.** **Usable caveat:** because our clean comparison is essentially 2×2 (skill groups × pre/post), the 2FE=DiD equivalence holds and linearity concern is minimal; still worth noting if we add many periods/covariates linearly.

### 13. Greene & Liu (2020) — Review of Difference-in-Difference Analyses in Social Sciences
- **Citation.** William H. Greene & Min (Shirley) Liu (2020). *Review of Difference-in-Difference Analyses in Social Sciences: Application in Policy Test Research.* Ch. 124 in *Handbook of Financial Econometrics, Mathematics, Statistics, and Machine Learning* (Vol. 4), pp. 4259–4282, World Scientific.
- **Method (review/pedagogy).** 2×2 DiD, multi-group/period generalization (BDM-style two-step), and the **first-difference method**; comparisons to CITS, PSM, RDD.
- **Assumptions (Lechner 2011).** A1 SUTVA; A2 exogeneity; A3 treatment unrelated to baseline control outcome; A4 parallel/common-trend/bias-stability (most important).
- **Problem solved.** How DiD removes time-invariant confounding + common trends; first-difference additionally sweeps individual heterogeneity.
- **Appropriate vs inappropriate.** General; covers 2×2 and multi-group/period. **Predates staggered critiques** — use as introductory assumptions reference, not a staggered guide. CITS needs ≥4 pre-periods; PSM caution (King & Nielsen).
- **Inference.** t-stat on δ̂; clustered data via feasible GLS (Hansen 2007) or bootstrap (many groups); aggregate over individuals.
- **Software.** None.
- **Our design.** **Usable** primer for assumptions; first-difference framing maps to our pre/post skill-group differencing.

### 14. Sudhaharan / Tilburg Science Hub — Staggered Difference-in-Difference Estimation in R
- **Citation.** Roshini Sudhaharan. *Staggered Difference-in-Difference Estimation.* Tilburg Science Hub (online tutorial), Tilburg University. (Site © 2020–2024; year uncertain.)
- **Method.** Applies Callaway–Sant'Anna ATT(g,t) via R **did** (`att_gt`, `aggte`, `ggdid`), DR default.
- **Assumptions.** Staggered/irreversible adoption; PT vs never-treated (or not-yet-treated); conditional PT via `xformla`.
- **Problem solved.** Negative weights in staggered TWFE.
- **Appropriate vs inappropriate.** **Requires staggered timing**; explicitly says traditional DiD "works well for two groups and time periods with constant effects" — i.e., the canonical single-date case does not need this.
- **Inference.** `did` defaults — simultaneous bands, DR.
- **Software.** R **did**; HonestDiD mentioned.
- **Our design.** **N/A** (tutorial for the staggered case).

### 15. Bounthavong (2024) — Staggered Difference-in-Differences Design using R
- **Citation.** Mark Bounthavong (28 July 2024). *Staggered Difference-in-Differences Design using R.* Online educational article.
- **Method.** Callaway–Sant'Anna ATT(g,t), aggregated to a single weighted ATT; R **did** (`att_gt`, `aggte`, `ggdid`) + **panelView**; DR default; never- or not-yet-treated controls.
- **Assumptions.** Parallel trends; no anticipation; staggered/absorbing adoption.
- **Problem solved.** Variable rollout timing + time-varying effects.
- **Appropriate vs inappropriate.** **Requires staggered timing** (example: 5 cohorts over 6 periods). Single common date / pure 2-group is not the target; first-period adopters dropped.
- **Inference.** **Bootstrapped** SEs; simultaneous bands; Wald pre-test of PT; anticipation = 0.
- **Software.** R **did**, **panelView**.
- **Our design.** **N/A** (staggered tutorial).

### 16. Porreca (2022) — Synthetic Difference-in-Differences Estimation with Staggered Treatment Timing
- **Citation.** Zachary Porreca (2022). *Synthetic difference-in-differences estimation with staggered treatment timing.* Economics Letters 220: 110874. doi:10.1016/j.econlet.2022.110874.
- **Estimator.** Extends **Synthetic DiD (SDID, Arkhangelsky et al. 2021)** — which combines **unit weights** and **time weights** plus a unit FE — to staggered adoption by iterating SDID on never-treated + each cohort, then combining cohort τ̂ with weights `μ_ℓ = N_ℓ/ΣN_ℓ`.
- **Assumptions.** Latent-factor (interactive fixed effects) DGP `Y = L + Wτ + E`; **does not rely on parallel trends or treatment exogeneity** — approximate PT achieved through weighting of pre-periods and units.
- **Problem solved.** Extends SDID to staggered timing; robust when the additive-FE assumption is wrong (true DGP is a latent factor model); improves precision.
- **Appropriate vs inappropriate.** This note's contribution is the **staggered** case, but **core SDID applies to a single treatment period** and to SCM-type settings (few treated units, no clean control). Best when a latent-factor DGP is plausible. In big-data additive-FE settings, SDID ≈ TWFE, so the extra cost may be unwarranted.
- **Inference.** **Influence-function / jackknife** variance; in the application TWFE SEs clustered by state, CS bootstrapped, SCM jackknife. Covariate correction via partialling out X.
- **Software.** Standard **synthdid** R package (not named verbatim); compares to TWFE, CS (`did`), partially-pooled SCM.
- **Our design.** **Usable in single-date form.** Treat skill/education cells (or region×skill cells) as "units"; use base SDID (single May-2022 date) to build a data-driven synthetic low-exposure counterfactual for high-exposure groups — attractive if parallel trends across skill groups is doubtful. The *staggered* extension itself is N/A.

### 17. de Chaisemartin & D'Haultfœuille — Treatment Effects with Multiple Periods and Groups (Package DiD)
- **Citation.** Clément de Chaisemartin & Xavier D'Haultfœuille. *Treatment Effects with Multiple Periods and Groups* (documentation for the `DIDmultiplegt` / `did_multiplegt` package). See also their 2020 AER "Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects."
- **Estimator.** `DID_M` / `DID_ℓ` estimators of instantaneous and dynamic ATT that use **only "switchers"** compared to units whose treatment does not change between consecutive periods; handles treatments that turn **on and off** and non-absorbing/continuous designs — more general than CS/Sun–Abraham.
- **Assumptions.** Parallel trends; no anticipation; "stable" comparison groups over the relevant transitions.
- **Problem solved.** TWFE heterogeneity bias / negative weights, including in **non-absorbing** and **fuzzy/continuous** treatments where other robust estimators do not apply.
- **Appropriate vs inappropriate.** Needs **multiple periods with variation in treatment across groups/time** (switchers). A single simultaneous, absorbing switch for everyone provides no differential switchers, so the estimator is **N/A** to our common-date design.
- **Inference.** Novel asymptotic distribution; SEs via the package, typically clustered; bootstrap options.
- **Software.** Stata **did_multiplegt** / **DIDmultiplegt**; R port; companion **TwoWayFEWeights** for weight diagnostics.
- **Our design.** **N/A** — no timing variation / switchers.

### 18. Roth, Sant'Anna, Bilinski & Poe (2023) — What's Trending in Difference-in-Differences?
- **Citation.** Jonathan Roth, Pedro H. C. Sant'Anna, Alyssa Bilinski & John Poe (2023). *What's trending in difference-in-differences? A synthesis of the recent econometrics literature.* Journal of Econometrics 235(2): 2218–2244. doi:10.1016/j.jeconom.2023.03.008.
- **Method (synthesis + practitioner checklist).** Three strands: (i) heterogeneity-robust staggered estimators (CS, Sun–Abraham, dCDH, BJS imputation, Gardner, stacked); (ii) robustness to PT violations (conditional PT via RA/IPW/DR Sant'Anna–Zhao; HonestDiD; pre-trend testing caveats; bracketing bounds); (iii) inference under few clusters / design-based.
- **Assumptions.** Canonical PT + no anticipation (2-period); staggered PT (Assn 4/4a) + staggered no-anticipation (5); conditional PT (6) + strong overlap (7).
- **Problem solved.** Why static/dynamic TWFE misbehave under staggering + heterogeneity (forbidden comparisons, negative weighting, cross-lag contamination of event-study pre-trends).
- **Appropriate vs inappropriate — key checklist for us.** *"Is everyone treated at the same time? If yes,* and the panel is balanced, estimation with TWFE (static/dynamic) yields easily interpretable estimates." Only *"if no"* do you need a heterogeneity-robust staggered estimator. So for our **single common date, standard TWFE / event study is endorsed**; the staggered toolkit is optional and not required.
- **Inference.** Cluster at the level treatment is independently assigned. **Few treated clusters:** **cluster wild bootstrap** (caveats: Canay et al., MacKinnon–Webb), model-based (Donald–Lang, Conley–Taber, Ferman–Pinto), **permutation/randomization** (Hagemann), **Fisher Randomization Tests** (exact under sharp null when timing ~ random). Report event-study plots with uniform bands; assess pre-trend power; use Rambachan–Roth sensitivity. Prefer doubly-robust as default for conditional PT (regression adjustment under limited overlap).
- **Software (Table 2).** did/csdid, did2s, didimputation/did_imputation, DIDmultiplegt/did_multiplegt, eventstudyinteract, flexpaneldid, fixest (sunab), stackedev, staggered, xtevent; **DRDID/drdid**; bacondecomp/ddtiming, TwoWayFEWeights; **HonestDiD**; **pretrends**.
- **Our design.** **The master decision guide.** It authorizes TWFE/event-study for our common-date design and points us to DR (conditional PT across skill groups), HonestDiD (sensitivity), and the few-cluster inference menu.

---

## RECOMMENDATION MATRIX — Single national reform (May 2022), skill/education-exposure intensity

**Design summary.** One common treatment date for everyone; identification comes from **cross-sectional variation in exposure/bite** (by skill/education, possibly by region×skill or a continuous Kaitz-type index). There is **no staggered timing to correct for.** This changes the relevance of the modern literature: the entire "staggered TWFE is biased" branch is about *timing heterogeneity we do not have*. Our threats are instead (a) whether **skill groups would have trended in parallel absent the reform**, (b) **serial-correlation/few-cluster inference**, and (c) **functional form / composition**.

### (a) TOOLS THAT STILL APPLY — and how

| Tool | How to use it in our design |
|------|------------------------------|
| **Canonical 2×2 / event study (TWFE with a single cohort)** | Endorsed by Roth et al. (#18) and Baker-Larcker-Wang (#11): with a common date, TWFE/event-study is unbiased and interpretable. Estimate a single-cohort event study with treatment = skill-exposure group (or interact a continuous bite with post), leads for pre-2022 periods as the parallel-trends check. Imai-Kim (#12): the 2FE=DiD equivalence holds cleanly here (essentially 2×2), so linearity worries are minor. |
| **Doubly-robust 2-period DiD (Sant'Anna–Zhao, DRDID)** (#9; core of #7) | Primary estimator for the cross-sectional contrast: high- vs low-exposure groups, pre vs post, **conditional on education/experience/sector covariates**. Consistent if EITHER the propensity or the outcome model is right; influence-function SEs. This is the single most decision-relevant estimator here. |
| **HonestDiD sensitivity (Rambachan–Roth)** (#2; endorsed in #6, #18) | Does NOT need staggered timing — only multiple pre-periods, which we have. After the event study, report breakdown values: how large a differential skill-group pre-trend (relative-magnitude `M̄` or smoothness `M`) would overturn the employment/wage effect. Essential credibility check given non-random skill composition. |
| **Synthetic DiD (base SDID)** (#16, core Arkhangelsky et al.) | Use the **single-date** SDID (not the staggered extension) with skill×region cells as units to build a data-driven synthetic low-exposure counterfactual. Attractive precisely when parallel trends across skill groups is doubtful; robust to a latent-factor DGP. Jackknife/placebo inference. |
| **Triple-differences (DDD)** (#3) | If a plausible always-unaffected dimension exists (e.g., workers already far above the new minimum, or a comparison region), skill × post × (affected/unaffected) DDD nets out common skill-group and common-time shocks. |
| **Changes-in-changes / RIF & quantile DiD** (general, referenced across #6/#18) | Because minimum-wage effects are heterogeneous along the wage distribution, complement the mean ATT with distributional methods: changes-in-changes (Athey–Imbens) or RIF/unconditional-quantile DiD to trace effects across the wage/earnings distribution and at the bite region of the distribution. |
| **Inference: wild-cluster bootstrap, randomization inference, cluster choice** (#10 BDM; #3; #18) | We have the classic BDM problem: serial correlation + few effective "groups" (skill cells / regions). Recommended: **collapse to pre/post** (BDM) and/or **randomization/permutation inference**; if using regressions, **wild cluster bootstrap** (with the few-treated-cluster caveats of MacKinnon–Webb / Canay et al.); cluster at the level exposure is assigned (region or skill-cell). Do NOT rely on naïve clustered SEs with few clusters. |
| **Design guidance / assumptions primers** (#3 Wing et al. 2018; #6 JEL guide; #13 Greene–Liu; #18 Roth et al.) | Use for the 2×2/2×T portions: comparison-group choice, pre-trend graphics, covariate-adjustment pitfalls, uniform confidence bands (sup-t) for the single-cohort event study. |

### (b) TOOLS THAT DO NOT APPLY — and why

| Tool | Why it does not apply here |
|------|-----------------------------|
| **Callaway–Sant'Anna ATT(g,t) full machinery** (#7, #14, #15) | Requires multiple treatment **cohorts** (groups adopting at different dates). We have one adoption date, so there is a single "g" — nothing to aggregate across cohorts. (Its underlying **DR 2×2 building block still applies** — that is #9, which we DO use.) |
| **Sun–Abraham interaction-weighted estimator** (#4, #18) | Corrects contamination across cohorts in event-study TWFE. With one cohort there is no cross-cohort contamination to correct. |
| **de Chaisemartin–D'Haultfœuille `did_multiplegt`** (#17) | Needs "switchers" vs stable groups across periods and variation in treatment timing/intensity over time. A single simultaneous absorbing switch provides no differential switchers. |
| **Borusyak–Jaravel–Spiess / Gardner two-stage `did2s`** (#5) | Imputation estimators built to remove staggered-timing negative weighting; with a common date, TWFE already equals the ATT (Baker et al. #11), so they add nothing and their staggered structure is moot. |
| **Goodman-Bacon decomposition `bacondecomp`** (#8) | Decomposes a staggered TWFE estimand into timing-based 2×2s. With no timing variation there is nothing to decompose (no forbidden comparisons possible). |
| **Stacked DiD / synthetic DiD *for staggered timing*** (staggered parts of #4, #16) | The stacking-by-cohort and cohort-averaging steps presuppose multiple adoption dates. Only the **single-date** synthetic-control-flavored SDID survives (see (a)). |
| **Generalized stepped-wedge estimator (Kennedy-Shaffer)** (#1) | Built on the stepped-wedge/staggered-adoption structure (absorbing treatment introduced at different times). No stepped-wedge here. Its **permutation-inference** idea transfers, but the estimator does not. |

**Bottom line.** Our setting is a **single-date, cross-sectional-intensity DiD**, not a staggered-adoption problem. The correct toolkit is: (1) a **doubly-robust 2-period DiD** across skill/exposure groups with covariates (DRDID), (2) a **single-cohort event study** for the parallel-trends narrative, (3) **HonestDiD** sensitivity on the pre-trends, optionally (4) **single-date synthetic DiD** and **DDD** as robustness, (5) **distributional** (CIC / RIF-quantile) estimates because minimum-wage effects concentrate in the lower wage distribution, and (6) **randomization inference / wild-cluster bootstrap / collapse-to-pre-post** for honest few-cluster inference. The entire staggered-adoption literature here serves as *justification for why we do NOT need those estimators* — it is background, not method.

---

## BibTeX

```bibtex
@techreport{kennedyshaffer2024generalized,
  author      = {Kennedy-Shaffer, Lee},
  title       = {A Generalized Difference-in-Differences Estimator for Randomized Stepped-Wedge and Observational Staggered Adoption Settings},
  year        = {2024},
  institution = {Department of Biostatistics, Yale School of Public Health},
  note        = {arXiv:2405.08730} % TODO confirm final publication venue
}

@article{rambachan2023credible,
  author  = {Rambachan, Ashesh and Roth, Jonathan},
  title   = {A More Credible Approach to Parallel Trends},
  journal = {The Review of Economic Studies},
  volume  = {90},
  number  = {5},
  pages   = {2555--2591},
  year    = {2023},
  doi     = {10.1093/restud/rdad018}
}

@article{wing2018designing,
  author  = {Wing, Coady and Simon, Kosali and Bello-Gomez, Ricardo A.},
  title   = {Designing Difference in Difference Studies: Best Practices for Public Health Policy Research},
  journal = {Annual Review of Public Health},
  volume  = {39},
  pages   = {453--469},
  year    = {2018},
  doi     = {10.1146/annurev-publhealth-040617-013507}
}

@article{wing2024staggered,
  author  = {Wing, Coady and Yozwiak, Madeline and Hollingsworth, Alex and Freedman, Seth and Simon, Kosali},
  title   = {Designing Difference-in-Difference Studies with Staggered Treatment Adoption: Key Concepts and Practical Guidelines},
  journal = {Annual Review of Public Health},
  volume  = {45},
  pages   = {485--505},
  year    = {2024},
  doi     = {10.1146/annurev-publhealth-061022-050825}
}

@article{butts2022did2s,
  author  = {Butts, Kyle and Gardner, John},
  title   = {did2s: Two-Stage Difference-in-Differences},
  journal = {The R Journal},
  volume  = {14},
  number  = {3},
  pages   = {162--173},
  year    = {2022},
  doi     = {10.32614/RJ-2022-048} % TODO confirm DOI
}

@article{baker2026did,
  author  = {Baker, Andrew and Callaway, Brantly and Cunningham, Scott and Goodman-Bacon, Andrew and Sant'Anna, Pedro H. C.},
  title   = {Difference-in-Differences Designs: A Practitioner's Guide},
  journal = {Journal of Economic Literature},
  year    = {2026},
  volume  = {64},
  number  = {2},
  pages   = {498--557},
  doi     = {10.1257/jel.20251650}
}

@article{callaway2021did,
  author  = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title   = {Difference-in-Differences with Multiple Time Periods},
  journal = {Journal of Econometrics},
  year    = {2021},
  volume  = {225},
  number  = {2},
  pages   = {200--230},
  doi     = {10.1016/j.jeconom.2020.12.001}
}

@article{goodmanbacon2021did,
  author  = {Goodman-Bacon, Andrew},
  title   = {Difference-in-Differences with Variation in Treatment Timing},
  journal = {Journal of Econometrics},
  year    = {2021},
  volume  = {225},
  number  = {2},
  pages   = {254--277},
  doi     = {10.1016/j.jeconom.2021.03.014}
}

@article{santanna2020drdid,
  author  = {Sant'Anna, Pedro H. C. and Zhao, Jun},
  title   = {Doubly Robust Difference-in-Differences Estimators},
  journal = {Journal of Econometrics},
  year    = {2020},
  volume  = {219},
  number  = {1},
  pages   = {101--122},
  doi     = {10.1016/j.jeconom.2020.06.003}
}

@article{bertrand2004howmuch,
  author  = {Bertrand, Marianne and Duflo, Esther and Mullainathan, Sendhil},
  title   = {How Much Should We Trust Differences-in-Differences Estimates?},
  journal = {The Quarterly Journal of Economics},
  year    = {2004},
  volume  = {119},
  number  = {1},
  pages   = {249--275}
  % In-hand version: NBER Working Paper No. 8841 (2002)
}

@article{baker2022howmuch,
  author  = {Baker, Andrew C. and Larcker, David F. and Wang, Charles C. Y.},
  title   = {How Much Should We Trust Staggered Difference-in-Differences Estimates?},
  journal = {Journal of Financial Economics},
  year    = {2022},
  volume  = {144},
  number  = {2},
  pages   = {370--395},
  doi     = {10.1016/j.jfineco.2022.01.004}
}

@article{imai2021twoway,
  author  = {Imai, Kosuke and Kim, In Song},
  title   = {On the Use of Two-Way Fixed Effects Regression Models for Causal Inference with Panel Data},
  journal = {Political Analysis},
  year    = {2021},
  volume  = {29},
  number  = {3},
  pages   = {405--415},
  doi     = {10.1017/pan.2020.33}
}

@incollection{greene2020review,
  author    = {Greene, William H. and Liu, Min (Shirley)},
  title     = {Review of Difference-in-Difference Analyses in Social Sciences: Application in Policy Test Research},
  booktitle = {Handbook of Financial Econometrics, Mathematics, Statistics, and Machine Learning},
  publisher = {World Scientific},
  year      = {2020},
  volume    = {4},
  chapter   = {124},
  pages     = {4259--4282} % TODO confirm editors/volume details
}

@misc{sudhaharan_staggeredDiD_tsh,
  author       = {Sudhaharan, Roshini},
  title        = {Staggered Difference-in-Difference Estimation},
  howpublished = {Tilburg Science Hub, Tilburg University},
  year         = {2024}, % TODO exact year uncertain (site (c) 2020--2024)
  note         = {Online tutorial; uses the R \texttt{did} package (Callaway and Sant'Anna 2021)},
  url          = {https://tilburgsciencehub.com/} % TODO verify exact URL
}

@misc{bounthavong2024staggered,
  author       = {Bounthavong, Mark},
  title        = {Staggered Difference-in-Differences Design using R},
  year         = {2024},
  month        = {July},
  howpublished = {Online educational article},
  note         = {Uses R \texttt{did} and \texttt{panelView}; Callaway and Sant'Anna approach},
  url          = {} % TODO URL not printed in PDF
}

@article{porreca2022synthdid,
  author    = {Porreca, Zachary},
  title     = {Synthetic Difference-in-Differences Estimation with Staggered Treatment Timing},
  journal   = {Economics Letters},
  volume    = {220},
  pages     = {110874},
  year      = {2022},
  doi       = {10.1016/j.econlet.2022.110874},
  publisher = {Elsevier}
}

@article{dechaisemartin2020twfe,
  author  = {de Chaisemartin, Cl\'ement and D'Haultf{\oe}uille, Xavier},
  title   = {Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects},
  journal = {American Economic Review},
  year    = {2020},
  volume  = {110},
  number  = {9},
  pages   = {2964--2996},
  doi     = {10.1257/aer.20181169}
  % In-hand item is the package documentation "Treatment Effects with Multiple Periods and Groups"
  % TODO confirm which specific de Chaisemartin-D'Haultfoeuille document the PDF corresponds to
}

@article{roth2023trending,
  author    = {Roth, Jonathan and Sant'Anna, Pedro H. C. and Bilinski, Alyssa and Poe, John},
  title     = {What's Trending in Difference-in-Differences? A Synthesis of the Recent Econometrics Literature},
  journal   = {Journal of Econometrics},
  volume    = {235},
  number    = {2},
  pages     = {2218--2244},
  year      = {2023},
  doi       = {10.1016/j.jeconom.2023.03.008},
  publisher = {Elsevier}
}

@manual{callaway2026didpackage,
  author = {Callaway, Brantly and Sant'Anna, Pedro H. C.},
  title  = {did: Treatment Effects with Multiple Periods and Groups},
  year   = {2026},
  note   = {R package; method from Callaway and Sant'Anna (2021)},
  url    = {https://bcallaway11.github.io/did/}
}
```
