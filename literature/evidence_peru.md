# Minimum-Wage Effects in Peru — Structured Evidence Review

**Purpose.** Positioning file for an empirical paper on the effects of minimum-wage (RMV) increases on Peruvian workers of different education levels, using quarterly ENAHO data, 2021–2024, with an event-study / difference-in-differences (DiD) design built around the **May 2022 RMV reform (930 → 1,025 soles)**.

**Scope.** Five PDFs in `Papers y documentos/Efectos de salario mínimo/Evidencia Perú/`. One important caveat up front (see Paper 4): the file named *"Minimum Wage and Ethnic-Gaps — Who are the Winners?"* does **not** contain a paper on ethnic gaps; its actual content is a **Greene & Liu DiD methodology review chapter**. The real ethnic-gaps paper is not in the folder.

Terminology: **RMV** = *Remuneración Mínima Vital* = Peru's single national minimum wage. **ENAHO** = *Encuesta Nacional de Hogares* (INEI). **EPE** = *Encuesta Permanente de Empleo* (INEI, Lima Metropolitana, rotating quarterly panel). **ENDES/DHS** = Demographic and Family Health Survey.

---

## Paper 1 — Jaramillo & López (2006)

**Full citation.** Jaramillo, Miguel, and Kristian López. *¿Cómo se ajusta el mercado de trabajo ante cambios en el salario mínimo en el Perú? Una evaluación de la experiencia de la última década.* Lima: GRADE, Documento de Trabajo 50, December 2006 (also No. 26 of the CIES "Diagnóstico y Propuesta" series). ISBN 9972-615-40-5.

**Research question & context.** How the Peruvian labor market adjusts to RMV changes over 1996–2004, with attention to effects along the income distribution and across the formal/informal divide. Core empirical exercise centers on the **September 2003 hike (+12%, 410 → 460 soles)**.

**Data.** MTPE household surveys (1986–1995) and INEI **ENAHO** for graphical/historical analysis; the regression analysis uses the **EPE two-period quarterly panels for Lima Metropolitana, 2002–2004** (25 panels, ~2,100 panel individuals per round). Panels for 2001 excluded (education not asked).

**Identification & estimators.** Two approaches. (i) **Kernel density** analysis (Parzen kernel, bandwidth 0.15) of formal/informal wage distributions around hikes — descriptive. (ii) **Regression on quarterly panels** following Neumark, Schweitzer & Wascher (2000): compare transitions of individuals *observed before-and-after* a MW change (dummy **E** = "affected") against unaffected transitions, controlling for individual characteristics (X: sex, age, education), job characteristics (Z: firm size, tenure), season dummies, sector GDP growth, and income-range dummies **Dⱼ** (position relative to MW). The coefficient of interest is the interaction **γⱼ = Dⱼ × E**. Estimated for (a) change in monthly labor income and (b) probability of staying employed (probit). Explicitly corrects for **regression-to-the-mean** (includes level of income in the first period) and for **sample-selection** (income equation with employment as selection equation, ML, censored obs = −1). Only **short-run** effects; only one hike.

**Treatment / control.** "Affected" = individuals spanning a MW change. Income groups defined relative to MW (0.3–0.6, 0.6–0.9, **0.9–1.2 = "trapped"**, 1.2–1.5, 1.5–2, 2–2.5, 2.5–3 × SM1). Worker types: private salaried formal, private salaried informal, independents. **Formal** = salaried worker with access to health insurance.

**Outcome measurement in ENAHO/EPE.** Wage = *ingreso mensual por ocupación/trabajo principal* (EPE); employment retention (probit); *masa salarial* (wage bill) as a combined income×employment measure. Informality proxied by no health insurance / no contract / no pay slip / not unionized.

**Main results.** The 12% 2003 hike produced **few significant effects**. No significant income effects in the informal sector or among independents. In the formal sector, the only significant positive income effect is on **"trapped" workers (0.9–1.2 × MW): ~17% vs. the 12% legal rise, significant at 90%**; paradoxically negative for those earning 20–50% above. Employment-retention coefficients are almost uniformly **negative**: significant for salaried in the 1.2–2 MW range (implied elasticities ≈ 0.75), for informal workers in 0.9–2 × MW, for formal only in 1.5–2 × MW, and for independents earning 60–90% of MW. **Wage-bill analysis: no favorable distributive effect for low-income workers** — the hike is, on balance, "an innocuous instrument" or a remedy potentially worse than the disease. Negative informal-sector employment effects are read as formal→informal displacement raising competition.

**Institutional facts documented.** RMV used since 1914 (municipal), national since 1985; the tripartite **Consejo Nacional del Trabajo (CNT), created 2001, has never actually set the RMV** — the President does so discretionarily. History is erratic/volatile (big jumps then long freezes); Peru among the most volatile MW setters in LatAm. Non-compliance high: 2002 ENAHO, **~30–43%** of affected workers earn below the RMV (rural 77% vs. urban 28%; small firms 57%). RMV ≈ 60% of the median wage (5th highest in LatAm). Nominal-RMV change table 1990–2006 (reaches S/500 by Jan-2006).

**Limitations / gap left open.** Short-run only (quarterly panels); a single hike (2003); cannot measure informalization; no longitudinal data for longer horizons; thin domestic literature. Calls for longer horizons, replication across hikes, and regional MW analysis.

---

## Paper 2 — Céspedes (2005)

**Full citation.** Céspedes, Nikita. *Efectos del salario mínimo en el mercado laboral peruano.* Banco Central de Reserva del Perú, *Estudios Económicos* [working-paper/journal series]. Presented at the Primera Conferencia de Economía Laboral (Nov 2004) and the XXII Encuentro de Economistas del BCRP (Jan 2005). *(Volume/number/pages: % TODO.)*

**Research question & context.** Relationship of the RMV with employment and wages, plus its distributive effects. Employment panel covers **1997–2003**; Granger tests **1993–2002**; the micro before/after exercise centers on the **September 2003 hike (410 → 460 soles)**.

**Data.** Lima Metropolitana. **EPE panel, Jul–Sep vs. Oct–Dec 2003** (3,769 employed panel individuals). **ENAHO 2002-IV** for coverage/non-compliance. Sectoral employment series 1997–2003 (firms with 10+ workers); formal wage time series 1980–2002.

**Identification & estimators.** (1) **Granger-causality** tests RMV→wages, 1993–2002. (2) **Dynamic panel employment equation by economic sector, Arellano–Bond (1991)**, 1997–2003, estimating the **employment–RMV elasticity**. (3) **Discrete-choice Probit** (à la Maloney & Núñez 2002) on the EPE panel: probability of remaining employed as a function of income level, formality dummy, and controls (sex, age, years of education); Model II adds inactivity. (4) Distributive: **kernel densities** of income before/after the hike, plus a **Probit for the probability of an income increase**.

**Treatment / control.** Young workers **14–25** vs. rest; income expressed in **fractions of the RMV**. Formal = access to health insurance.

**Outcome measurement.** Formal employment = log employment index (firms 10+); probability of staying employed; **ingreso por trabajo principal** (EPE); probability of an income rise.

**Main results.** Employment–RMV elasticity ≈ **−0.13** (Arellano–Bond), but **only significant at 83–84%** (below conventional levels). A 10% RMV rise ⇒ ~**9,200 formal jobs lost** in Lima Metropolitana (5% ⇒ ~4,600). Probability of remaining employed is **lower for low-income and young workers** (~20% lower for low-income). Distributive: the 2003 hike **shifted the income distribution toward low-income workers** (kernel mass moves near the RMV in the formal sector; the informal distribution is symmetric and largely unaffected — RMV is not a clear reference there). Probability of an income increase ≈ 0.34 on average, **lower (0.31) for youth**, higher for low-income. **RMV Granger-causes formal wages, 1993–2002** ⇒ RMV acts as a reference/"lighthouse" in formal wage-setting. Compliance high inside formal firms (92.9% obreros, 96.8% empleados); overall non-compliance 30.1–42.9%.

**Institutional facts documented.** RMV is a single national value set by the State (1993 Constitution). Coverage: **~40.8% of the employed (≈4.97 million, ENAHO 2002)** are potentially affected. Indexation web: *asignación familiar* = 10% of RMV; mining +5%; agricultural daily = RMV/26; Pymes and domestic workers pegged to RMV. Real RMV: peak 1974 (S/1,007 in 1994 soles), trough 1993 (S/90); three phases — declining 1980–90, stable 1990–96, recovering 1996–2004; RMV/average-wage ratio ~49% by 2003.

**Limitations / gap.** Partial-equilibrium; employment elasticity weakly significant; only *formal*-sector job loss estimated (cannot net out informalization); Lima only. Suggests **regionally differentiated MW** as future work.

---

## Paper 3 — Jiménez (2023)  *[most methodologically relevant]*

**Full citation.** Jiménez, Bruno. "The Political Economy of the Minimum Wage." *Labour Economics* 85 (2023): 102463. DOI: 10.1016/j.labeco.2023.102463. (Princeton University; CEDLAS / IIE-FCE, Universidad Nacional de La Plata.)

**Research question & context.** Does raising the MW improve citizens' approval of government? Exploits the **May 2016 Peruvian MW hike (750 → 850 PEN)** as a natural experiment. Secondarily (and directly relevant to us) it estimates the **labor-market effects** of that hike: employment, formality, wages, family income.

**Data.** **ENAHO 2015–2017**, urban, ages 18–65, **repeated cross-section** (not a panel). Governance, Transparency and Democracy module for approval/trust/well-being.

**Identification & estimators.** **DiD with continuous treatment intensity.** *Dose*ᵈ = share of *formal* workers in department *d* earning **between 750 and 850 PEN in 2015** (i.e., the share whose wages must mechanically rise); *Post* = 1 from May 2016. Department + quarter fixed effects; controls (gender, age, age², marital status, geographic domain, education). Also a **binary** above-/below-median-dose version and a **dynamic/event-study** specification with pre-treatment δ-coefficients and a joint pre-trend test. Framed as a canonical DiD analog to **Callaway, Goodman-Bacon & Sant'Anna (2021)**; builds on Card (1992), Caliendo et al. (2018), Derenoncourt et al. (2021). **Wild-bootstrap** inference (only 25 department clusters). Rural areas excluded to avoid JUNTOS cash-transfer confounding. Battery of falsification/placebo tests (fake 2015 hike), anticipation adjustments, alternative dose (formal + informal).

**Treatment / control.** Departments with **above-median** share of affected formal workers ("strongly treated", ~7% dose) vs. **below-median** ("weakly treated", ~3% dose).

**Outcome measurement in ENAHO — variable names disclosed (useful for our build).**
- **Labor formality** = INEI variable **`ocupinf`** (informal = no employer-financed social security, or unpaid family workers).
- **Labor income** = sum of ENAHO variables **`i524a1`, `d529t`, `i530a`, `d536`** (independent + dependent income in the main occupation, annualized, invalid-value imputed, deflated to 2015 PEN). **Monthly wage = that sum ÷ 12** (for salaried workers).
- **Dose** = share of salaried workers per department earning 750–850 PEN in 2015, using the "employment and income" supplement's sampling weights.

**Main results.** A **1-pp rise in the share of treated workers ⇒ ~1-pp rise in central-government approval** (average department +5.8 pp); partial spillover to regional/provincial/district approval (monotonically smaller). Robust to placebo/falsification and to alternative dose measures. **Labor market: no dis-employment** (employment effect ≈ 0), **formality up 2.5–2.8 pp**, **wages up ~4.1–5.4%**, **total family income up ~3.9–5.1%** — i.e., **non-negative labor-market effects**. Mechanism: improved subjective well-being (own household *and* community) → sociotropic/social-interaction voting. Consistent with **employer market power/monopsony** in Peru (Amodio & De Roux 2021) and with firms absorbing infrequent hikes via prices (Brummund & Strain 2020).

**Institutional facts documented.** The National Labor Council should periodically adjust the MW for inflation/productivity, but in practice the **President sets it discretionarily**, irregularly in frequency and level; among LatAm's most volatile. Peru updated its MW **only once in 2013–2017** while neighbors did so 3–5 times. The 2016 hike merely **restored the real MW to its June-2012 level** (real MW had fallen ~15%). Enforcement weak (SUNAFIL, ~30 inspectors per department except Lima), yet **formal-sector non-compliance is well below 10%**. Timeline: informal announcement 30 Mar 2016 → formalized 11 Apr (DS 005-2016-TR) → enacted 1 May; presidential run-off 5 Jun; next hike 850 → 930 PEN in Apr 2018.

**Limitations / gap.** The paper's *object* is political approval, not the labor-market causal effects (those are a supporting result, estimated at the **department** level, repeated cross-section). Cannot test voting behavior. **Crucially, Jiménez states explicitly that prior Peruvian MW studies (Céspedes 2005; Jaramillo 2012; Del Valle 2009) could not convincingly identify treatment vs. control because there is no sub-national variation in the *nominal* MW** — his fix is to exploit regional heterogeneity in the *share of affected workers*. This is the closest existing precedent to our design.

---

## Paper 4 — Greene & Liu (2020) — *filename/content mismatch*

**⚠️ Content note.** The PDF titled *"Minimum Wage and Ethnic-Gaps — Who are the Winners?"* does **not** contain that paper. Its actual content (all 27 pages) is a **methodology review chapter**:

**Full citation.** Greene, William H., and Min (Shirley) Liu. "Review of Difference-in-Difference Analyses in Social Sciences: Application in Policy Test Research." Chapter 124 in *Handbook of Financial Econometrics, Mathematics, Statistics, and Machine Learning* (Vol. 4), pp. 4259–4284. Singapore: World Scientific, 2020/2021.

**What it is.** A DiD/first-difference primer: 2×2 and multi-period DiD models (Bertrand, Duflo & Mullainathan 2004); causal-inference assumptions (SUTVA, exogeneity, treatment-unrelated-to-baseline, **parallel trends**); the first-difference implementation; worked examples including **Card & Krueger (1994)** NJ–PA minimum-wage DiD, plus finance/accounting applications; and comparisons of DiD with CITS, PSM, and RDD.

**Relevance to us.** Useful only as a **methodological citation** for the DiD identifying assumptions and parallel-trends discussion. It provides **no Peru-specific minimum-wage evidence.** The actual "ethnic-gaps" study should be re-sourced if it is meant to be part of the review.

---

## Paper 5 — Chávez (~2022)

**Full citation.** Chávez, Carlos. "Domestic Violence, Labor Market, and Minimum Wage: Theory and Evidence from Peru." Working paper, Universidad Nacional Mayor de San Marcos, Lima. SSRN abstract 4224811. *(Year: % TODO — c. 2022.)* JEL: J12, E24, E26.

**Research question & context.** Effect of MW increases on domestic violence (VAW/IPV) against women, transmitted through the labor market and informality. Period **2013–2019**; exploits the **2016 and 2018 MW hikes**.

**Data.** **ENDES/DHS** (INEI) 2013–2019, women 15–49, violence module. **ENAHO** used for labor stylized facts (e.g., 74% informal in 2019); ECW/MIMP for violence-center data. (Note: the *outcome* data are DHS, not ENAHO.)

**Identification & estimators.** Pooled cross-section OLS (Eq. 1) with **time-FE + region-FE, SE clustered by region**; **DiD** (Eq. 2: MW × EmploymentStatus); **triple-difference DDD** (Eq. 3: MW × EmploymentStatus × InformalStatus); plus MW × EarnMore and MW × WorkingAway. **Event-study graphs** to check pre-trends. MW enters as a multilevel dummy (0 pre-2016, 1 for 2016–17, 2 for 2018–19); hikes treated as exogenous shocks.

**Outcome / labor variables (DHS codes).** Eight violence measures from D105A–J, D106, D107, D108, D101A–F; labor variables `V714` (currently working), `v731` (worked last 12 months), `V732` (all-year/seasonal → informality proxy), `V705` (partner's occupation), `v721` (works away from home), `D112A` (prior violence).

**Main results.** MW increases **reduce physical (−0.006 to −0.015) and psychological (−0.027 to −0.072) violence; no significant effect on sexual violence.** Event studies show flat pre-trends and negative post-hike effects. Reductions are **larger for unemployed / informally-employed women** than for employed/formal ones — so the effect runs mainly through the **partner (male) channel** (reduced financial stress), not the woman's-empowerment channel; the triple interaction is insignificant. When the partner is unemployed, violence rises.

**Institutional facts documented.** High informality (74% in 2019); two MW hikes (2016, 2018); rising reported VAW; expansion of Emergency Centers for Women.

**Limitations / gap.** DHS violence underreporting; partner informality unobservable; the labor-market MW question is tangential to its focus. Chiefly relevant to us as a **recent Peruvian example of an event-study / DDD design around MW hikes**, and for informality stylized facts.

---

## Synthesis

### (1) State of knowledge on MW effects in Peru
- The domestic empirical literature is **thin, old, and Lima-centric**, dominated by two mid-2000s studies (Jaramillo & López 2006; Céspedes 2005) plus a recent political-economy paper (Jiménez 2023) and a tangential domestic-violence paper (Chávez ~2022).
- **Wages / "lighthouse" effect:** consistent evidence that the RMV is a **reference in formal wage-setting** (Céspedes: RMV Granger-causes formal wages 1993–2002; Jiménez: +4–5% wages after 2016) and that hikes compress the lower tail of the formal distribution. The informal distribution is only loosely tied to the RMV.
- **Employment:** older work finds **small negative** formal-employment effects (Céspedes: elasticity ≈ −0.13, weakly significant; ~9,200 Lima jobs per 10% hike) and negative employment-retention effects concentrated near the MW and among youth (both Jaramillo and Céspedes). The most credible recent estimate (Jiménez 2016 hike) finds **no dis-employment** and **rising formality** — consistent with monopsony and infrequent, inflation-eroded hikes.
- **Distribution / skill & youth heterogeneity:** effects concentrate on low-income, less-educated, and **young (14–25)** workers, and on workers "trapped" between the old and new MW. Jaramillo finds **no favorable distributive effect** from the 2003 hike; Céspedes finds a modest favorable shift; Jiménez finds rising family income. **Education-based heterogeneity is only implicit/descriptive** in all of them (income-range or age cuts), never an explicit education-cell treatment/control contrast.
- **Institutional consensus:** single national RMV set discretionarily by the Presidency (the tripartite CNT is inert); erratic and among LatAm's most volatile; **high non-compliance overall (30–43%)** but low inside formal firms (<10%); heavy informality (~74%); weak enforcement (SUNAFIL).

### (2) Identification strategies used, and their weaknesses
| Study | Strategy | Key weakness |
|---|---|---|
| Yamada & Bazán (1994); Céspedes (2005) | Time-series **Granger causality** | No counterfactual; endogeneity; low power; aggregate. |
| Céspedes (2005) | **Dynamic panel (Arellano–Bond)** sectoral employment elasticity | Weak significance (83–84%); aggregate; formal Lima only; no distributional detail. |
| Jaramillo & López (2006); Céspedes (2005) | **Short quarterly before/after panels** (EPE), income-range interactions, selection/regression-to-mean corrections | Short-run only; single hike (2003); Lima only; cannot capture informalization; small panels. |
| Jaramillo; Céspedes | **Kernel density** distribution plots | Descriptive; no causal inference. |
| **Jiménez (2023)** | **DiD with continuous department-level treatment intensity + event study + wild bootstrap** (Callaway et al. analog) | Treatment is **department-level**, **repeated cross-section**; dose must be constructed because the nominal MW is national; possible confounders (JUNTOS), spillovers; primary outcome is political approval, labor effects secondary. |
| Chávez (~2022) | **DiD / triple-difference + event study** (DHS) | Outcome is violence, not labor; DHS underreporting; MW-labor question tangential. |

The recurring, binding constraint (stated by Jiménez) is that **Peru's MW is a single national value**, so there is **no cross-sectional variation in the treatment itself** — credible designs must manufacture differential *exposure* (a "dose" or "bite"), whether geographic (Jiménez) or by worker characteristics.

### (3) The clear gap our paper fills — and honest limits on novelty
**Our design:** worker-level **event-study / DiD around the May 2022 RMV reform (930 → 1,025 soles)**, contrasting **low- vs. high-education workers** (differential bite: low-education workers cluster near the RMV; high-education workers sit far above and serve as the comparison group), using **quarterly ENAHO 2021–2024** and **heterogeneity-robust modern DiD estimators** (e.g., Callaway–Sant'Anna, Sun–Abraham, de Chaisemartin–D'Haultfœuille) for employment, wages, and informality.

**What is genuinely new:**
1. **Reform and period.** *No* existing Peru study covers the **2022 reform** or the **2021–2024 post-pandemic** window. All prior micro-evidence stops at 2016 (Jiménez) or 2003–2004 (Jaramillo/Céspedes).
2. **Education-based exposure at the worker level.** Prior papers cut heterogeneity by income-range or age, or use a *department* dose; **none uses an explicit low- vs. high-education worker-cell contrast** as treatment/control in a DiD/event study for the Peruvian MW.
3. **Distributional labor outcomes as the primary object.** Unlike Jiménez (where labor effects are a by-product of a political-approval study estimated at the department level), we make **employment / wage / informality effects by skill the main estimand**, at the individual level, with quarterly resolution.

**What we must NOT overclaim (be honest):**
- **"Modern DiD inference" is not itself new to this literature** — Jiménez (2023) already used a Callaway-style estimator with wild-bootstrap inference. Our contribution is *applying* heterogeneity-robust estimators to a **new reform, new period, and an education-based worker-level design**, not inventing the toolkit.
- The **"fraction-affected / bite" design is standard internationally** (Card 1992; Lee 1999; Derenoncourt et al. 2021). Using **education as the source of differential bite** is a well-known device; novelty is the Peruvian 2022 application, not the identification idea.
- **Identification caveats we must defend head-on:** with a single national MW, all workers are "treated in time," so identification rests entirely on **differential bite by education** — this requires (a) demonstrating high-education workers are effectively unexposed (wages far above the RMV), and (b) **parallel pre-trends** in the 2021 recovery, when skill groups were differentially hit by the pandemic and its rebound. Education is correlated with many confounders (sector, region, formality), so the parallel-trends defense and covariate/anticipation robustness (à la Jiménez) are essential. We should also address **spillovers/general-equilibrium** effects (formal→informal displacement documented by Jaramillo) that can contaminate a "clean control."

**Bottom line.** The literature leaves a real, specific hole — **a worker-level, education-heterogeneity, post-pandemic (2021–2024) event-study/DiD of the 2022 RMV reform on employment, wages, and informality** — that no existing Peruvian study fills. Our marginal contribution is the *combination* (new reform + new period + education-cell design + distributional labor focus), executed with credible modern DiD inference, rather than a brand-new identification strategy.

---

## BibTeX

```bibtex
@techreport{jaramillo_lopez_2006_rmv,
  author      = {Jaramillo, Miguel and L{\'o}pez, Kristian},
  title       = {{\'{}}C{\'o}mo se ajusta el mercado de trabajo ante cambios en el salario m{\'i}nimo en el Per{\'u}? Una evaluaci{\'o}n de la experiencia de la {\'u}ltima d{\'e}cada},
  institution = {Grupo de An{\'a}lisis para el Desarrollo (GRADE)},
  type        = {Documento de Trabajo},
  number      = {50},
  address     = {Lima},
  year        = {2006},
  month       = {December},
  note        = {Also No.~26 of the CIES ``Diagn{\'o}stico y Propuesta'' series. ISBN 9972-615-40-5}
}

@article{cespedes_2005_rmv,
  author  = {C{\'e}spedes, Nikita},
  title   = {Efectos del salario m{\'i}nimo en el mercado laboral peruano},
  journal = {Estudios Econ{\'o}micos},
  publisher = {Banco Central de Reserva del Per{\'u}},
  year    = {2005},
  volume  = {}, % TODO
  number  = {}, % TODO
  pages   = {}, % TODO
  note    = {Presented at the Primera Conferencia de Econom{\'i}a Laboral (Nov 2004) and the XXII Encuentro de Economistas del BCRP (Jan 2005). Exact issue/pages unverified}
}

@article{jimenez_2023_political_economy_mw,
  author  = {Jim{\'e}nez, Bruno},
  title   = {The Political Economy of the Minimum Wage},
  journal = {Labour Economics},
  year    = {2023},
  volume  = {85},
  pages   = {102463},
  doi     = {10.1016/j.labeco.2023.102463}
}

@incollection{greene_liu_2020_did_review,
  author    = {Greene, William H. and Liu, Min (Shirley)},
  title     = {Review of Difference-in-Difference Analyses in Social Sciences: Application in Policy Test Research},
  booktitle = {Handbook of Financial Econometrics, Mathematics, Statistics, and Machine Learning},
  volume    = {4},
  chapter   = {124},
  pages     = {4259--4284},
  publisher = {World Scientific},
  address   = {Singapore},
  year      = {2020}, % TODO: confirm 2020 vs 2021 imprint
  note      = {This is the actual content of the file mislabeled ``Minimum Wage and Ethnic-Gaps -- Who are the Winners?''}
}

@techreport{chavez_dv_mw_peru,
  author      = {Ch{\'a}vez, Carlos},
  title       = {Domestic Violence, Labor Market, and Minimum Wage: Theory and Evidence from Peru},
  institution = {Universidad Nacional Mayor de San Marcos},
  type        = {Working Paper},
  address     = {Lima},
  year        = {2022}, % TODO: confirm year
  note        = {SSRN abstract 4224811. JEL: J12, E24, E26}
}
```
