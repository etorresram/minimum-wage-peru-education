# Latin American Evidence on Minimum Wage Effects — Structured Literature Database

*Compiled for: empirical paper on minimum-wage effects by education level in Peru (ENAHO quarterly data, DiD / event-study around the May 2022 reform).*
*Source folder:* `Papers y documentos/Efectos de salario mínimo/Evidencia países Latam/`
*Papers reviewed: 7 (Colombia, Brazil ×2, Ecuador ×2 [one micro, one macro], Honduras, Uruguay).*
*Date compiled: 2026-07-01.*

---

## How to read this file

Each entry follows a fixed template: citation → country/period/data → identification → treatment/bite → outcomes/results → emphasis (low-skilled, informality, lighthouse) → limitations. A cross-country synthesis and a BibTeX block follow at the end. Fields not printed in the source PDFs are marked `% TODO`; no DOIs are fabricated (DOIs shown are printed verbatim on the article).

**Quick methods map (most relevant to a differential-exposure-by-skill DiD design):**

| Paper | Country | Design | Bite / exposure measure | Skill/education split | Informality |
|---|---|---|---|---|---|
| Wong (2019) | Ecuador | **Individual-panel DiD** + wage-gap intensity, Heckman selection | treated = covered workers with w<MW(t+1); wage gap = ln(MW/w) | women/youth/agri/domestic interactions | covered vs non-covered proxy |
| Ham (2018) | Honduras | Fraction-affected level regressions (Probit/MNL/OLS) + DiD compliance | category (industry×firm-size) MW level; Kaitz index | covered vs uncovered (education gap descriptive) | **core**: formal→informal reallocation |
| Katzkowicz et al. (2021) | Uruguay | **Density-discontinuity** (Jales 2017; dual economy) | mass with latent wage < MW (F₀=20.3%) | low-skilled women (domestic sector) | **core**: formal/informal transitions |
| Lemos (2009) | Brazil | Panel FE, "fraction-at" bite, formal & informal separately | fraction at ±2% band of MW | ≤4 yrs schooling subsample | **core**: both sectors estimated |
| Lemos (2004) | Brazil | Sector-specific reduced-form, fraction-affected×4.5 | fraction affected; spike | bottom percentiles | control only |
| Arango et al. (2022) | Colombia | Multi-method (RIF quantile, cost-of-compliance, IV, 3 GE models) | **Kaitz index** (≈0.9), cost of compliance | low-educ/youth/women; self-employed | **core**: MW→informality driver |
| Carrillo-Maldonado & Cruz (2026) | Ecuador | Macro narrative-ID SVAR + Local Projections | narrative (exogenous) MW shocks | none (macro) | dual-market framing only |

---

## 1. Arango-Thomas et al. (2022) — Colombia

**Citation.** Arango-Thomas, L. E. (coord.), Ávila-Montealegre, Ó., Bonilla-Mejía, L., et al. (2022). "Efectos macroeconómicos del salario mínimo en Colombia." *Ensayos sobre Política Económica (ESPE)*, núm. 103, Banco de la República (Colombia). DOI: 10.32468/espe103. (~100 pp.; a book-length ESPE monograph, ~21 authors.)

**Country / period / data.** Colombia; roughly 2007/08–2019 for microdata, price series to 2019, GE simulations to 2030. Data: GEIH household survey (DANE), PILA formal payroll administrative records, CPI microdata (390 items, 2009–2018), input-output matrices (2010/2015/2017), fiscal accounts.

**Identification / estimators.** Multi-method compendium: (i) **Kaitz index** (MW/median) as central bite measure; (ii) **RIF/unconditional quantile regressions** (Firpo-Fortin-Lemieux) for distributional effects with city×time variation and FE; (iii) **cost-of-compliance** firm-level payroll-shock design on PILA for employment flows; (iv) time-series OLS/IV for inflation pass-through; (v) event-study/Aaronson-type price regressions; (vi) input-output Leontief price model; (vii) **three general-equilibrium models** (heterogeneous-agent DSGE with formal/informal sectors; NK small-open-economy DSGE; CGE for fiscal effects); (viii) a DiD on the 2014 apprentice-stipend change.

**Bite / exposure.** Kaitz index very high — near **0.90** (≈1.04 in 2019), the highest MW-to-median in the OECD comparison group (vs ~0.50 OECD average). Also "cost of compliance" (firm-specific payroll gap) and SM/S_p70. Informality ≈ 56% in 2019.

**Main results.**
- *Formal employment:* 1% real MW → +0.44 pp job destruction, −0.56 pp job creation ⇒ net ~46,000 formal jobs lost/yr (2009–19); net elasticity ≈ **−1.0** (−0.68 balanced panel). Effects **larger in small (≤20 emp: −1.34%) and young (<4 yr: −1.85%) firms**; large firms adjust via churning.
- *Unemployment:* 5% real MW → +0.6–1.2% unemployment, strongest for young women.
- *Wages/distribution:* rising Kaitz shifts most groups' hourly-income distributions right, but **does NOT reduce inequality** (Gini +0.089% per +0.01 Kaitz); the poorest households (q10) and self-employed without higher education gain little/negatively; **monetary poverty rises**.
- *Prices:* 1% MW → +0.14 to +0.29 bp on inflation depending on method; food-away-from-home pass-through +0.51% (regressive).
- *GE:* permanent 1% real MW → aggregate welfare −0.70%, formal share −1 pp; CGE: 1% real MW → ~72,000 jobs lost (GDP elasticity ≈ −0.17, informality +0.1 pp).

**Low-skilled / informality / lighthouse.** Adverse employment and informality effects concentrate on the **least educated, youth, and women**. MW is a key driver of high informality: +1 pp in SM/S_p70 → +0.14–0.21 pp probability of informal work, strongest for low-educated. **Lighthouse ("faro") effect:** prior Colombian evidence (Maloney-Núñez 2004) found a positive lighthouse effect; **this paper is skeptical** — for informal groups the estimated Kaitz coefficients are numerically tiny ("if a lighthouse effect exists it would be very faint [muy tenue]" for 2008–2019), though wage propagation above the MW among salaried workers is found.

**Limitations.** Single national MW ⇒ little exogenous variation (identification leans on constructed bite measures and possibly-endogenous city×time variation); large employment-loss figures "must be interpreted with caution"; firm-flow estimates are a lower bound; RIF results are marginal (small-change) effects; GE models use different informality definitions and limited endogenous responses; coverage ends 2019 (pre-COVID).

---

## 2. Lemos (2004) — Brazil (private vs public sector)

**Citation.** Lemos, Sara (2004). "Minimum Wage Effects Across the Private and Public Sectors in Brazil." University of Leicester, Dept. of Economics Working Paper (June 24, 2004). JEL: J38. *(A related version was later published in* Journal of Development Studies *43(4):700–720, 2007 — not stated in this PDF; verify before citing.)*

**Country / period / data.** Brazil; monthly 1982–2000. Data: Pesquisa Mensal de Emprego (PME), a rotating panel over six metropolitan regions; CPI for deflation. National uniform MW (no regional variation).

**Identification / estimators.** Reduced-form MW regressions (Brown 1999 framework) in first differences with region and month FE, region trends, and controls. Key identifying variable = **"fraction affected"** (Card 1992), converted to real-MW elasticities by ×4.5. **Private and public sectors estimated separately and compared** (parallel regressions, not a formal cross-sector DiD). Employment decomposed into hours effect + jobs effect.

**Bite / exposure.** "Fraction affected" = share earning within a ±1.02 band around old/new real MW. Descriptive "spike" averages **11% private vs 7% public** (more binding in private sector).

**Main results.**
- *Wages:* MW compresses the distribution in **both** sectors; per 10% real MW, wages at the 10th pct +1.50% (private) / +5.71% (public); 90–10 gap −1.17% (private) / −4.52% (public). Compression extends higher up the distribution in the private sector.
- *Employment:* short-run effects insignificant in both sectors. Long-run (≈2 yr): total employment **−0.06% private (adverse, via reduced hours) vs +0.66% public (non-negative)**. Public-sector labor demand appears inelastic (government can fund the wage bill). Magnitudes small; the non-negative public effect dilutes aggregate figures.

**Low-skilled / informality / lighthouse.** Focus on bottom percentiles (5th–20th) where MW binds; largest gains at the very bottom (esp. public sector). **No formal/informal partition** — informality only a control. No explicit "lighthouse" term, but the conclusion attributes stronger private-sector effects to "larger spike, larger spillover effects, and stronger compression" — i.e., numeraire/spillover effects up the distribution.

**Limitations.** No formal/informal split; no formal cross-sector DiD; identification rests on the fraction-affected ×4.5 conversion (strong functional assumption); no prior benchmark for public-sector MW effects; six metros only; constant MW weakens identifying variation.

---

## 3. Lemos (2009) — Brazil (formal & informal sectors)

**Citation.** Lemos, Sara (2009). "Minimum wage effects in a developing country." *Labour Economics* 16(2):224–237. DOI: 10.1016/j.labeco.2008.07.003.

**Country / period / data.** Brazil; monthly Jan 1982–Dec 2004 (employment analysis focuses on low-inflation Jan 1995–Dec 2004). Data: PME (IBGE), six metros; deflated with INPC/IPC. ~13,000 obs per region-month cell.

**Identification / estimators.** (i) Nonparametric kernel densities of log real wages before/after MW hikes, formal vs informal; (ii) parametric panel reduced-form employment regressions (Brown 1999) estimated **separately for formal and informal sectors** via GLS, with region & time FE, dynamics (12/24 lags), robustness via long-differencing. Identifying variable = **"fraction at"** (superior to Card's "fraction affected" when MW is constant).

**Bite / exposure.** "Fraction at" = share earning within ±2% band of the nominal MW. Larger/more binding in poor regions (Recife ~4.8% formal vs São Paulo ~3.0%); jumped to 12–14% after the Sept-1991 hike.

**Main results.** Large **wage compression in BOTH formal and informal sectors**, but **NO adverse employment effect** (neither jobs nor hours) in either sector, short- or long-run. Long-run employment coefficients small and insignificant (e.g., formal total −0.021; informal total 0.041). Effect smaller than the ~−0.1% US benchmark.

**Low-skilled / informality / lighthouse.** *Low-educated (≤4 yrs schooling) subsample:* stronger wage compression/spillovers but employment effects **still insignificant** — MW does not adversely affect low-educated employment. *Informality:* the two-sector (Welch-Gramlich-Mincer) prediction (positive wage/negative employment in covered; opposite in uncovered) **does not hold** — compression and no employment effect in both sectors; little formal→informal transition (cites Soares; Corseuil-Carneiro). ***Strong support for the "lighthouse effect" (Teoria do Farol):*** a spike at the MW appears in the informal sector and even among the **self-employed**, where the two-sector model predicts no binding — direct evidence of the MW as numeraire/reference wage in the uncovered sector.

**Limitations.** Cross-study comparability; identifying assumption that unobservables are uncorrelated with "fraction at" (macro shocks could bias); MW endogeneity/sorting (Hausman tests used as validation); GLS breaks exact additivity of the jobs+hours decomposition; frequency sensitivity; metropolitan salaried focus.

---

## 4. Wong (2019) — Ecuador (micro DiD)

**Citation.** Wong, Sara A. (2019). "Minimum wage impacts on wages and hours worked of low-income workers in Ecuador." *World Development* 116:77–99. DOI: 10.1016/j.worlddev.2018.12.004. JEL: J21, J23, J38.

**Country / period / data.** Ecuador (dollarized since 2000, low inflation). Policy: Jan 2012 minimum wage US$264→US$292 (+10.61% nominal / +5.24% real). Panel: Dec 2011 (before) vs Dec 2012 (after). Data: ENEMDU household survey (INEC), from which the author builds an **individual-level 2-period panel** via a within-household matching algorithm; sectoral MWs from Registro Oficial; industry GDP/CPI from Central Bank.

**Identification / estimators.** **Difference-in-differences on the individual panel** (removes time-constant unobservables), exploiting sectoral-MW variation; adds a **wage-gap intensity** term, wage gap = ln(MW_{t+1}/W_t); **Heckman two-step** correction for selection/attrition (Inverse Mills generally insignificant → little bias). This is the design closest in spirit to a differential-exposure-by-skill Peru DiD.

**Treatment / control.** *Treated* = covered (private-sector wage) workers earning below next-year MW, w(t) < MW(t+1). *Control* = non-covered (public, self-employed, business owners) + covered high-earners with w ≥ MW(t+1). *Spillover categories:* indirect_a = non-covered with wage below MW (lighthouse test); indirect_b = non-covered above MW.

**Main results.**
- *Wages:* +0.41% to +0.48% per 1% MW rise for treated low-income workers. **Positive spillover** onto non-covered low earners (indirect_a ≈ +0.48, same size as direct effect). **Negative** effect on high-income control workers (indirect_b ≈ −0.10; compression, employers offset costs at the top).
- *Hours:* small positive for treated (+0.056–0.067% per 1% MW); intensity interaction (treated×wage-gap) ≈ +0.18–0.20.
- *Heterogeneity:* **Women** get lower wage gains (−0.138 interaction, ~⅓ smaller) and **negative hours effects** — MW may fail to close the bottom gender gap. **Youth** get positive hours effects. **Agricultural** workers get extra positive wage effect. Full-time women show the only significant negative hours effect.
- *Employment:* NOT estimated (panel restricted to those employed in both periods). *Informality:* not separately measured (covered/non-covered used as proxy).

**Low-skilled / informality / lighthouse.** Core beneficiaries are low-income covered workers (modest positive wage + small hours gains). **Lighthouse effect confirmed:** low-wage earners in the non-covered sector see wage spillovers of roughly the same magnitude as the direct treatment effect.

**Limitations.** No employment/job-loss estimates; no formal/informal distinction (data); only 2 periods (parallel-trends untestable); selection on time-varying unobservables; matching-algorithm measurement issues; noncompliance (bunching below MW for youth/women/small firms) may bias effects downward; boom-period estimates may not generalize to downturns.

---

## 5. Carrillo-Maldonado & Cruz (2026) — Ecuador (macro)

**Citation.** Carrillo-Maldonado, Paul, and Cruz, Zoe (2026). "Macroeconomic consequences of minimum wage in a developing country." *Structural Change and Economic Dynamics* 77:137–148. DOI: 10.1016/j.strueco.2026.01.004. JEL: E20, E24, C22, C32.

**Country / period / data.** Ecuador (dollarized ⇒ MW is an unusually salient macro lever). Quarterly 2007Q1–2019Q4 (narrative MW series 2000–2021; sample ends 2019 due to COVID survey break). Data: Ministry of Labor MW agreements (+ newspapers), INEC (CPI, labor), Central Bank (GDP, projections), FRED (WTI oil).

**Identification / estimators.** **Narrative identification** (Romer & Romer) isolating *exogenous* MW changes — those the Minister of Labor imposes unilaterally when the tripartite council fails to agree — from endogenous negotiated changes. Impulse responses via **SVAR** (recursive, MW ordered first) **and Local Projections** (Jordà), small 4-variable models, wild bootstrap CIs. **This is a macro time-series shock design — NOT a micro bite / treatment-control design.**

**Main results (directional IRFs).**
- *Output/GDP:* **positive** medium-term effect (significant Q3–Q6).
- *Inflation:* no robust response (small delayed rise from Q6).
- *Unemployment:* **no significant response** (only a temporary reduction under the productivity-adjusted shock).
- *Real wage & "decent employment":* no significant short/medium response.
- FEVD: MW shocks explain up to ~50% of output-growth variance at 4q. Interpreted as demand-side / wage-led: higher MW → household income/consumption → output, with firms absorbing costs via margins rather than prices or layoffs.

**Low-skilled / informality / lighthouse.** No skill/education heterogeneity (macro). Draws on cited micro work (Herrero-Olarte) that MW raises income in the bottom half. Uses a **dual-labor-market** framing and a "decent employment" proxy (does not respond to MW). Cites Campos et al. (2017) that MW can reduce informality; **no explicit lighthouse test**.

**Limitations.** Inconclusive stationarity tests (weak inference); small sample (~52 quarters) and small models; no micro heterogeneity; results method-dependent (SVAR vs LP diverge); narrative-rule opacity; COVID truncation.

---

## 6. Ham (2018) — Honduras

**Citation.** Ham, Andrés (2018). "The Consequences of Legal Minimum Wages in Honduras." *World Development* 102:135–157. DOI: 10.1016/j.worlddev.2017.09.015.

**Country / period / data.** Honduras; 2005–2012 (eight wage-floor hikes). Data: 13 waves of EPHPM household survey (INE), ~327,764 valid obs (repeated cross-sections, no panel); MW decrees from La Gaceta (industry×firm-size floors); Central Bank price/production indices.

**Identification / estimators.** Exploits **category-level variation** — Honduras sets separate minima by **industry × firm-size** (23 categories most years, reformed to 2/6/37 categories in 2009–11), "akin to state-level differences." Exogeneity from annual reforms, a ~60% real hike decreed for 2009 (argued exogenous), and category-count changes. Two pieces: (i) **DiD compliance test** using the public sector as control; (ii) **fraction-affected / level-of-MW regressions** (Neumark-Wascher) via Probit (employment, poverty), Multinomial Logit (labor-force composition), OLS (log hours, log wages); coefficients read as elasticities; SEs clustered by category; IV robustness. **Author cautions results are not strictly causal (no panel).**

**Treatment / bite.** Covered = private wage earners (large/small firms), public, domestic. Uncovered = self-employed, unpaid family, employers. Bite = the real hourly MW level assigned to each worker's industry×firm-size category; also a Kaitz index rising **0.66 (2005) → 1.13 (2012)**.

**Main results (per 10% MW increase).**
- *Employment:* overall −0.9% to −1.1% (modest negative).
- *Labor-force composition:* covered (formal) employment probability **−8% to −10%**; uncovered (informal) **+5% to +7%** — driven by wage-earners becoming **self-employed** (+ small rise in unpaid work).
- *Hours:* −2% overall, concentrated in the covered sector; no effect in uncovered.
- *Wages:* covered **+2.4% to +2.9%** (positive); uncovered **−5.2% to −6.9%** (negative); full-sample ≈ 0 (offsetting).
- *Poverty:* **no reduction** — extreme poverty rises for the uncovered labor force (+1.6% to +4.5%); poverty gaps widen (extreme +16.3%, moderate +12%).
- *Compliance:* ~47% of covered employees earn below the MW; non-compliance far higher in small firms (62%) than large (32%); after the 2009 hike, compliant large firms raised non-compliance ~36% (partial compliance).

**Low-skilled / informality / lighthouse.** Uncovered sector has lower education (5.0 vs 7.5 yrs), lower wages, higher poverty; adverse effects fall on these lower-skilled informal workers (self-employed and unpaid most harmed). **Central finding: MW hikes reallocate workers formal→informal (into self-employment)** — consistent with dual-sector Harris-Todaro models. **Lighthouse effect does NOT dominate here:** contrary to much LatAm evidence, MW pushes informal wages **down** (−0.52 to −0.69), because the labor-supply influx from the formal sector overwhelms any numeraire spillover. A notable counter-case.

**Limitations.** No panel (the key limitation — cannot track transitions or firmly establish causality); labor-force entrants excluded; poverty-line/income-imputation issues; measurement error in hourly floors; aggregation to category panel loses power; scarce enforcement data. Author calls Honduras "a cautionary tale," not a template.

---

## 7. Katzkowicz, Pedetti, Querejeta & Bergolo (2021) — Uruguay (density discontinuity)

**Citation.** Katzkowicz, S., Pedetti, G., Querejeta, M., & Bergolo, M. (2021). "Low-skilled workers and the effects of minimum wage in a developing country: Evidence based on a density-discontinuity approach." *World Development* 139:105279. DOI: 10.1016/j.worlddev.2020.105279.

**Country / period / data.** Uruguay; 2006–2016. Focus: the **domestic-work sector for women** (highly feminized, low-skilled), which got a sector MW in 2006 (Law 18.065). Data: National Household Survey (ECH/INE) repeated cross-sections, 44,326 domestic-worker obs; Social Security inspection data. Formal/informal = social-security contribution.

**Identification / estimators.** **Dual-economy density-discontinuity design** (Jales 2017, extending Doyle 2006) using only cross-sectional data. It exploits the spike-and-hole discontinuity the MW induces in the marginal wage density at the MW, and models the joint distribution of wages and formal/informal sector to recover the counterfactual latent distribution. Combines a **nonparametric density-discontinuity estimate** (McCrary local-linear, giving the non-compliance probability) with a **parametric sector-probability model**. Recovers transition probabilities (π): compliance, non-compliance, non-employment, and formal↔informal moves.

**Treatment / bite.** *Mass of affected workers* F₀(m) = share of women with latent wage below MW = **20.3%** (rising 16.6%→25.1%, 2006–16). "Low-skilled" proxied by the domestic sector (≈half have <7 yrs schooling; 54% informal). "Fraction" bunched = within 0.05 SD of the MW.

**Main results (pooled).**
- *Wages/compliance:* π_m = **19.3%** of affected women raised wages to the MW; positive and significant in **both** formal (6.3%) and informal (33.5%) sectors; sector wage inequality fell.
- *Non-employment:* π_u = **15.4%** of affected workers left domestic employment (naive employment elasticity ≈ **0.3**, within the 0.15–0.33 low-skilled LatAm range; ~3% employment drop at a 10% MW rise).
- *Formal→informal mobility:* π_d¹ = **64.3%** of affected formal workers kept a below-MW wage and moved to informality (negative for formalization) — yet overall formal domestic employment still rose over 2006–16 (attributed to growth + inspections/campaigns, not the MW alone).

**Low-skilled / informality / lighthouse.** Entire paper is about low-skilled women. **Strong evidence for the lighthouse effect:** wages of *informal* (uncovered) domestic workers rose (π_m⁰ = 33.5%) — MW as a reference/benchmark even without legal coverage. But a **dual informality effect**: MW simultaneously raised informal wages (lighthouse) and pushed 64% of affected formal workers into informality. Heterogeneity: education/ethnicity differences not significant; younger women more likely to informalize, older women more likely to become non-employed.

**Limitations.** Single-sector design ⇒ π_u conflates true unemployment with moves to other formal occupations (upper bound on job loss); external validity limited to the distinctive domestic-work population; confounding simultaneous policies and strong 2006–16 growth (offsetting evidence only "suggestive"); density discontinuity weaker in practice than in theory (McCrary tests reject in only some years); wage-heaping measurement error.

---

# Synthesis: What the Latin American Evidence Says

## (i) Employment effects
Employment effects range from **near-zero to modestly negative**, and are consistently **smaller than a naive competitive model predicts** — but they are **not zero for low-skilled/informal-margin workers**.
- *Zero/insignificant:* Lemos (2009, Brazil) finds no adverse jobs or hours effect in either sector, even for the ≤4-yrs-schooling subsample; Lemos (2004) finds only a small long-run private-sector decline (via hours) and non-negative public-sector employment; Carrillo-Maldonado & Cruz (2026, macro Ecuador) find no unemployment response.
- *Negative:* Ham (2018, Honduras) finds −0.9% to −1.1% employment and −2% hours per 10% MW; Katzkowicz et al. (2021, Uruguay) find 15.4% of affected workers non-employed (elasticity ≈ 0.3); Colombia (Arango et al. 2022) finds the largest effects (net elasticity ≈ −1.0), concentrated in **small and young firms**.
- *Recurring pattern:* effects concentrate on **small/young firms and low-skilled, youth, and women**; adjustment often runs through **hours** and **firm entry/creation** margins rather than outright job destruction of incumbents.

## (ii) Wage effects
Robustly **positive at the bottom** and **compressing** the distribution. Direct wage gains for affected/low-income workers: Wong (Ecuador) +0.41–0.48% per 1% MW; Ham (Honduras) +2.4–2.9% per 10% in the covered sector; Katzkowicz (Uruguay) ~19% of affected workers reach the MW; Lemos (Brazil) strong compression in both sectors. A recurring **compression** feature: gains at the bottom, sometimes offset by *negative* effects on higher earners (Wong's indirect_b ≈ −0.10; Lemos's 90–10 narrowing). Distributional/poverty *welfare* gains are weaker than wage gains suggest — Colombia and Honduras both find **no poverty/inequality reduction** (even increases), because employment and informality losses offset wage gains.

## (iii) Informality / formal–informal reallocation (central in high-informality settings)
Two opposing informal-sector channels appear, and which dominates is the key empirical question:
1. **Lighthouse ("farol/faro") effect — wages:** the legal MW acts as a numeraire/reference price that lifts wages *in the uncovered informal sector* even though it does not legally apply. Confirmed strongly in Brazil (Lemos 2009 — spike even among the self-employed), Uruguay (Katzkowicz — informal π_m⁰ = 33.5%), and Ecuador (Wong — informal spillover ≈ direct effect). Skeptical/absent in Colombia (Arango et al. — "very faint if it exists") and **reversed in Honduras** (Ham — informal wages fall).
2. **Reallocation — quantities:** MW pushes workers *from formal into informal* employment (self-employment). Strong in Honduras (covered −8/−10%, uncovered +5/+7%) and Uruguay (64% of affected formal workers informalize); a driver of high informality in Colombia (+0.14–0.21 pp informality per pp of bite). Weak/absent in Brazil (Lemos finds little formal→informal transition).
- **Net message:** in high-informality economies the MW can raise informal wages (lighthouse) *and* enlarge the informal sector (reallocation) at the same time; the poverty payoff depends on which dominates. Where labor-supply reallocation is large (Honduras), the lighthouse effect is overwhelmed and informal wages fall.

## (iv) Heterogeneity by skill / education
The most decision-relevant dimension for a by-education Peru design. Evidence consistently shows the MW **binds hardest on the low-educated, youth, and women**, who populate the bottom of the wage distribution and the informal sector. Wage gains and any adverse employment/informality effects are both concentrated there (Colombia, Honduras, Uruguay explicit). Notably, Lemos (2009) shows that *even where wage compression is strongest for the ≤4-yrs-schooling group, employment effects remain insignificant* — i.e., stronger bite need not mean larger job loss. Ecuador (Wong) adds a caution that **women** may see smaller wage gains and negative hours effects, so skill heterogeneity interacts with gender.

## (v) How identification is done in high-informality developing settings — and lessons for a differential-exposure-by-skill design
1. **Bite / fraction-affected / fraction-at:** the workhorse when the MW is a single national floor with little exogenous variation (Lemos Brazil; Ham Honduras; Colombia's Kaitz index). The identifying variation is cross-group (region, industry×firm-size, or skill cell) differences in *how binding* the MW is. **Directly analogous to a differential-exposure-by-skill DiD:** define each education group's initial exposure (share below the new MW, or Kaitz index by education cell) and interact it with post-reform timing.
2. **DiD with a covered/non-covered (or treated/control) split** (Wong Ecuador; Ham's compliance DiD): treated = workers below the new MW in the covered sector; controls = higher earners and/or the non-covered sector. **The cleanest template for the Peru paper** — Wong's individual-panel DiD + wage-gap intensity + Heckman selection correction is the closest methodological match; note its limitation (2 periods ⇒ untestable parallel trends), which an **event-study around May 2022** with ENAHO quarterly data can improve upon.
3. **Density-discontinuity / bunching** (Katzkowicz Uruguay): recovers compliance, non-employment, and formal↔informal transitions from cross-sectional wage densities without needing a control group — useful as a **complement** to DiD to decompose the informality margin and to measure noncompliance directly.
4. **Multiple minimum wages** (Honduras industry×firm-size; Ecuador sectoral MWs) provide extra exogenous variation "akin to state-level differences"; if Peru has any occupation/sector/regional MW variation or a discrete reform, exploit it.
5. **Macro/narrative and GE** (Carrillo-Maldonado; Colombia's DSGE/CGE) answer aggregate output/inflation/fiscal questions but **cannot identify skill heterogeneity** — not the right tool for a by-education design, though useful for framing aggregate stakes.

**Practical takeaways for the Peru ENAHO / May-2022 DiD by education:**
- Build an **education-cell exposure/bite measure** (share below new MW, or Kaitz index per education group) and use it as continuous treatment intensity in a DiD/event-study — the fraction-affected logic used across these papers.
- **Model both margins of informality** (informal wage = lighthouse test; formal↔informal transitions = reallocation) since ENAHO identifies formality; the LatAm evidence shows these move in opposite directions and net poverty effects hinge on the balance.
- Expect **compression** (bottom gains, possible top spillovers), **hours** as an adjustment margin, and **heterogeneity** concentrated in low-education/youth/women cells and small/young firms.
- Use ENAHO's quarterly frequency to run an **event study** that tests pre-trends (addressing the 2-period weakness in Wong) and to separate short- vs long-run adjustment (as Lemos stresses).
- Treat **noncompliance** explicitly (bunching below MW is pervasive in every paper); it biases reduced-form effects toward zero.

---

# BibTeX

```bibtex
@article{Arango2022EfectosMacroSMColombia,
  author  = {Arango-Thomas, Luis E. and {\'A}vila-Montealegre, {\'O}scar and
             Bonilla-Mej{\'i}a, Leonardo and Botero-Garc{\'i}a, Jes{\'u}s and
             Caicedo-Garc{\'i}a, {\'E}dgar and D{\'a}valos-{\'A}lvarez, Eleonora and
             Fl{\'o}rez, Luz Adriana and G{\'o}mez-Pineda, Javier and
             Grajales-Olarte, Anderson and Guar{\'i}n-L{\'o}pez, Alexander and
             Hamann-Salcedo, Franz and Hermida-Giraldo, Didier and
             Julio-Rom{\'a}n, Juan Manuel and Lasso-Valderrama, Francisco Javier and
             Mart{\'i}nez-Cort{\'e}s, Nicol{\'a}s and M{\'e}ndez-Vizca{\'i}no, Juan Camilo and
             Morales-Zurita, Leonardo and Ospina-Tejeiro, Juan J. and
             Pulido-Mahecha, Karen and Ramos-Veloza, Mario and
             Vargas-Ria{\~n}o, Carmi{\~n}a Ofelia},
  title   = {Efectos macroecon{\'o}micos del salario m{\'i}nimo en Colombia},
  journal = {Ensayos sobre Pol{\'i}tica Econ{\'o}mica (ESPE)},
  year    = {2022},
  number  = {103},
  month   = {sep},
  pages   = {1--100}, % TODO verify exact page range
  publisher = {Banco de la Rep{\'u}blica (Colombia)},
  issn    = {2665-1327},
  doi     = {10.32468/espe103},
  note    = {Luis E. Arango, coordinator},
  keywords= {salario m{\'i}nimo, empleo, informalidad laboral, desempleo, distribuci{\'o}n, pobreza, desigualdad, inflaci{\'o}n, bienestar}
}

@techreport{Lemos2004PrivatePublic,
  author      = {Lemos, Sara},
  title       = {Minimum Wage Effects Across the Private and Public Sectors in Brazil},
  institution = {University of Leicester, Department of Economics},
  type        = {Working Paper},
  year        = {2004},
  month       = {6},
  address     = {Leicester, UK},
  note        = {Dated June 24, 2004. JEL: J38. Data: PME, 1982--2000, six metropolitan regions},
  % number    = {},  % TODO: working-paper series number not printed in PDF
  % Later published version (verify before citing): Journal of Development Studies 43(4):700--720, 2007 % TODO
}

@article{Lemos2009MinimumWage,
  author  = {Lemos, Sara},
  title   = {Minimum wage effects in a developing country},
  journal = {Labour Economics},
  year    = {2009},
  volume  = {16},
  number  = {2},
  pages   = {224--237},
  doi     = {10.1016/j.labeco.2008.07.003},
  publisher = {Elsevier},
  note    = {Data: Brazilian PME (IBGE), 1982--2004}
}

@article{Wong2019MinimumWageEcuador,
  author  = {Wong, Sara A.},
  title   = {Minimum wage impacts on wages and hours worked of low-income workers in {Ecuador}},
  journal = {World Development},
  year    = {2019},
  volume  = {116},
  pages   = {77--99},
  month   = apr, % TODO verify issue month
  doi     = {10.1016/j.worlddev.2018.12.004},
  issn    = {0305-750X},
  publisher = {Elsevier},
  note    = {Accepted 9 December 2018; available online 28 December 2018},
  keywords = {Minimum wage; Difference-in-difference; Hours worked; Heterogeneous effects; Latin America; Ecuador}
}

@article{CarrilloMaldonadoCruz2026,
  author  = {Carrillo-Maldonado, Paul and Cruz, Zoe},
  title   = {Macroeconomic consequences of minimum wage in a developing country},
  journal = {Structural Change and Economic Dynamics},
  year    = {2026},
  volume  = {77},
  pages   = {137--148},
  doi     = {10.1016/j.strueco.2026.01.004},
  note    = {Received 8 May 2025; accepted 7 January 2026. Country: Ecuador; Data 2007Q1--2019Q4},
  keywords = {Minimum wage, Real sector, Labor market}
  % issn = {0954-349X} % TODO verify
}

@article{Ham2018Honduras,
  author  = {Ham, Andr{\'e}s},
  title   = {The Consequences of Legal Minimum Wages in Honduras},
  journal = {World Development},
  year    = {2018},
  volume  = {102},
  pages   = {135--157},
  doi     = {10.1016/j.worlddev.2017.09.015},
  publisher = {Elsevier},
  note    = {Accepted 20 September 2017; available online 5 November 2017. Data: EPHPM, 2005--2012}
}

@article{Katzkowicz2021LowSkilled,
  author  = {Katzkowicz, Sharon and Pedetti, Gabriela and Querejeta, Martina and Bergolo, Marcelo},
  title   = {Low-skilled workers and the effects of minimum wage in a developing country: Evidence based on a density-discontinuity approach},
  journal = {World Development},
  year    = {2021},
  volume  = {139},
  pages   = {105279},
  doi     = {10.1016/j.worlddev.2020.105279},
  issn    = {0305-750X},
  publisher = {Elsevier},
  note    = {Article 105279. Country: Uruguay (domestic-work sector); Data ECH/INE, 2006--2016},
  keywords = {Minimum wage, Labour market, Gender, Informal sector, Developing countries}
}
```
