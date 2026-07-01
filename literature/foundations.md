# Foundations: Minimum Wage Effects — Structured Literature Notes

Prepared for an empirical labor-economics paper on minimum wage effects by education
level in Peru. Covers the four "Foundations" PDFs plus the canonical Card (1992)
fraction-affected template on which the design builds.

Source folder: `Papers y documentos/Efectos de salario mínimo/Foundations/`

---

## 1. Card & Krueger (1994) — New Jersey / Pennsylvania fast-food

**Full citation.** Card, David, and Alan B. Krueger. 1994. "Minimum Wages and
Employment: A Case Study of the Fast-Food Industry in New Jersey and Pennsylvania."
*American Economic Review* 84(4): 772–793.

**Theoretical framework.**
- *Competitive prediction (Stigler 1946):* a binding minimum wage lowers
  establishment-level employment; for the whole industry total employment falls and
  product prices rise. Unambiguous negative sign.
- *Monopsony / search alternative:* if firms face an upward-sloping labor-supply curve
  (monopsony) or wage-posting/search frictions (Mortensen 1988; Burdett–Mortensen
  1989), a binding minimum can *raise* employment at affected firms and predicts the
  largest employment gains at firms initially paying the lowest wages. The paper's
  results are read as inconsistent with the competitive model and consistent with
  monopsony/search.

**Identification & data.**
- Natural experiment: NJ raised its state minimum from $4.25 to $5.05 on 1 April 1992
  while neighboring eastern PA stayed at $4.25 (federal).
- Own telephone survey of 410 fast-food stores (Burger King, KFC, Wendy's, Roy Rogers).
  Wave 1: Feb–Mar 1992 (pre); Wave 2: Nov–Dec 1992 (~8 months post). 100% closure
  status tracked. Response rate 87%.
- Estimator = **difference-in-differences** (NJ = treatment, PA = control) plus a second
  within-NJ DiD (stores initially paying <$5.05 vs. stores already ≥$5.00, the latter
  "unaffected"). Outcome = FTE employment (full-time + managers + 0.5×part-time).

**Bite / treatment-intensity measure.**
- `GAP_i` = proportional increase in the starting wage needed to reach the new minimum:
  `GAP_i = (5.05 − W_1i)/W_1i` for NJ stores below $5.05; = 0 for PA stores and for NJ
  stores already at ≥$5.05. This is a store-level continuous "fraction-affected"/wage-gap
  intensity measure (mean GAP among NJ stores ≈ 0.11). GAP predicts actual wage change
  well (R²=0.75; slope ≈ 1.03).

**Main results.**
- *Wages:* NJ starting wages rose ~10%; by Wave 2 a spike of ~85% of NJ stores paid
  exactly $5.05. **No spillover** onto initially higher-wage stores (their mean wage
  change was −3.1%).
- *Employment:* **no disemployment** — NJ FTE employment rose *relative* to PA. Simple
  DiD = +2.76 FTE per store (≈13%, t = 2.03). Within NJ, low-wage (more-affected) stores
  gained relative to high-wage stores. GAP coefficient positive; implied
  employment-wage elasticity ≈ +0.73. Point estimates reject the competitive prediction;
  cannot rule out a small negative effect in some specifications.
- *Prices:* meal prices rose ~4% faster in NJ (consistent with cost pass-through, a
  competitive-on-the-product-side result), but within NJ prices did **not** rise faster
  at more-affected stores.
- *Other margins:* no effect on store openings, hours open, cash registers, or fringe
  (free/reduced meals); full-/part-time mix ambiguous.

**Key contributions to cite.** Canonical case-study DiD template; the GAP wage-gap /
fraction-affected continuous treatment measure; the empirical spike at the new minimum;
evidence used to motivate monopsony/search over the competitive model; the "no spillover
to unaffected stores" finding.

---

## 2. Card & Krueger (1995) — *Myth and Measurement*

**Full citation.** Card, David, and Alan B. Krueger. 1995. *Myth and Measurement: The
New Economics of the Minimum Wage.* Princeton, NJ: Princeton University Press.
(Twentieth-Anniversary Edition, 2016, with a new preface by the authors; ISBN
978-0-691-16912-5.)

**Structure (what the book assembles).** A "collage" of natural experiments and
re-evaluations: Ch. 2 NJ/PA fast food; Ch. 3 the 1988 California minimum; Ch. 4 the
1990–91 federal increases via cross-state comparisons; Ch. 5 additional employment
outcomes and spillovers; Ch. 6 evaluation of the time-series evidence; Ch. 7 evaluation
of cross-section/panel evidence; Ch. 8 Puerto Rico ("can the minimum be too high?");
Ch. 9 wage distribution, family earnings and poverty; Ch. 10 how much employers/
shareholders lose (stock-price event study); Ch. 11 alternative labor-market models;
Ch. 12 conclusions.

**Theoretical framework.**
- Rejects the textbook *competitive* model as the right description of low-wage labor
  markets: minor, realistic changes to assumptions (a firm raising pay a few cents cannot
  instantly recruit all workers it wants; incumbents care about wages relative to new
  hires) overturn the negative-employment prediction.
- Emphasizes **static monopsony** and its **dynamic search analogue** (developed further
  in Manning 2003, 2004 wage-posting models; Flinn 2006, 2010 search-and-matching with
  bargaining). Search/wage-posting models explain the observed **wage spike** at the
  minimum and imply an *ambiguous* average employment effect. Fairness / reservation-wage
  norms (Fehr–Schmidt) rationalize spillovers and raises for unconstrained workers.
- *Price test to distinguish models:* competitive → higher prices; monopsony → ambiguous
  (if employment rises, prices could even fall).

**Identification & data.** Establishment- and state-level natural experiments; own survey
data plus CPS; DiD and cross-state fraction-affected comparisons. Deliberately favors
transparent research designs ("credibility revolution") over national time-series.

**Main results.**
- Minimum-wage increases **raise wages of low-paid workers with no noticeable employment
  decline**; low-wage states did not show slower job growth after the 1990–91 federal
  increases (Ch. 4).
- **Spillovers / "knock-on":** workers not directly constrained (uncovered, or already
  above the new minimum) often still got raises (Ch. 5).
- **Distribution:** minimum wages compress the lower tail and reduce wage inequality;
  raise earnings/incomes of low-income families (Ch. 9).

**Publication-bias / meta discussion (esp. 20th-anniversary preface).**
- Belman & Wolfson (2014) meta-analysis: 23 studies (2000–2013), 439 estimates — median
  employment/hours elasticity **−0.05**; precision-weighted mean/median **−0.03**
  (essentially zero, about as likely positive as negative).
- Doucouliagos & Stanley (2009) meta-regression corroborates an insignificant effect
  (and consistency with publication bias toward negative estimates); Neumark & Wascher
  (2008) reach a different, more subjective conclusion.
- Lee (1999) finds large distributional effects via spillovers; Autor, Manning & Smith
  (2015) argue Lee overstates but still find spillovers. Dube (2013): poverty-rate
  elasticity ≈ −0.15. Dube, Lester & Reich (2010, 2015) border-county designs extend the
  NJ/PA logic and cluster employment effects near zero.

**Key contributions to cite.** The natural-experiment/DiD paradigm for minimum-wage
research; monopsony/search reinterpretation of low-wage markets; documentation of
spillover ("ripple") effects; the meta-analytic case that moderate minimums have ~zero
employment effect; motivation for national minimum wages (UK, Germany).

---

## 3. Charles Brown (1999) — Handbook of Labor Economics, Chapter 32

**Full citation.** Brown, Charles. 1999. "Minimum Wages, Employment, and the
Distribution of Income." In *Handbook of Labor Economics*, Vol. 3, edited by Orley
Ashenfelter and David Card, Chapter 32, pp. 2101–2163. Amsterdam: North-Holland
(Elsevier). *(End page approximate — references begin p. 2158; % TODO verify final page.)*

**Theoretical framework (the survey's taxonomy).**
- *Competitive, complete coverage (Fig. 1):* a binding minimum makes employment
  demand-determined, `E_m = D(w_m)`; the log employment loss `ln(E_m) − ln(E*)` depends
  only on the labor-demand elasticity and the gap `ln(w_m) − ln(w*)`. Excess supply may
  show up as unemployment *or* as discouraged withdrawal from the labor force.
- *Two-sector / partial-coverage models (Welch 1976; Gramlich 1976; Mincer 1976):* an
  uncovered sector **dilutes but does not eliminate** the negative employment effect; the
  uncovered wage may rise or fall.
- *Heterogeneous labor (Kosters–Welch 1972; Heckman–Sedlacek):* only low-skill workers
  are directly affected; better-paid workers are substitutes, so measured employment
  effects for a broad group are a net of losses (directly affected) and gains
  (substitutes) — hence *small* aggregate effects and the focus on high-exposure groups
  such as teenagers.
- *Monopsony (Fig. 3):* a "skillfully set" minimum can raise employment, but the
  consensus is that labor supply to any one low-wage employer is nearly perfectly
  elastic, so the employment-enhancing range is negligible; Stigler's (1946) point that a
  *uniform* minimum across heterogeneous employers is unlikely to be in that range.
- *Search models (Card–Krueger turnover interpretation; Burdett–Mortensen 1998):*
  generate a monopsony-like equilibrium and the wage spike, but Stigler's doubts carry
  over with heterogeneous firms.
- *Offsets (Wessels 1980; Mincer 1984; Rebitzer–Taylor 1995 efficiency wages):* firms can
  offset a higher minimum by cutting fringe benefits/training, or *magnify* it by raising
  required effort — so effects on bodies/hours can exceed the wage-cost change.

**Measurement concepts.**
- **Kaitz index:** coverage-weighted ratio of the minimum to the average wage — the
  dominant time-series minimum-wage regressor.
- Distinguishes **β** (`Δln E / Δln w_m`, elasticity of employment w.r.t. the *minimum*)
  from **η** (`Δln E* / Δln w*`, demand elasticity of *directly-affected* low-wage labor).
  Because many teens receive no raise, `Δln w*` ≪ `Δln w_m`, so |η| > |β| by a multiplier
  (~5–9). E.g. 1989–92 the average teen wage rose only ~9% while the minimum rose 27%.

**Empirical synthesis.**
- Time-series model `E_t = αX_t + βMW_t + ε_t`. Late-1970s consensus: a 10% minimum
  increase lowered teen employment ~1–3% (Table 2 catalogs studies, Kaitz 1970 −0.98 …
  Card–Krueger 1995 −0.72). **Adding 1980s data shrinks the estimate toward zero and
  often to statistical insignificance** — the central "small effects" puzzle.
- Reviews cross-state and panel-data studies (the Card–Krueger vs. Neumark–Wascher
  debate) and low-wage-industry studies (retail trade, fast food).
- Distribution (§9): the minimum's ability to equalize the *family income* distribution
  is limited because many minimum-wage workers belong to middle-income families.

**Key contributions to cite.** The authoritative pre-2000 survey; the formal
two-sector/coverage theory; the Kaitz index; the **β-vs-η / fraction-directly-affected
logic** (the theoretical backbone of exposure designs); the framing of "accounting for
small employment effects."

---

## 4. Machin, Manning & Rahman (2003) — UK National Minimum Wage, residential care homes

**Full citation.** Machin, Stephen, Alan Manning, and Lupin Rahman. 2003. "Where the
Minimum Wage Bites Hard: The Introduction of the UK National Minimum Wage to a Low Wage
Sector." *Journal of the European Economic Association* 1(1): 154–180.
DOI: 10.1162/154247603322256792.

**Theoretical framework.** Explicitly agnostic between competition and monopsony, but
stresses that **all models predict that a high-enough minimum reduces employment** — so a
high-bite sector is where a negative effect is *most likely* to be detected. The care-homes
product market is largely price-regulated (DSS/local-authority capped fees not raised with
the minimum), removing the price pass-through channel and sharpening identification of
employment effects.

**Identification & data.**
- Setting: the first UK-wide minimum (National Minimum Wage) introduced April 1999 at
  £3.60/hr (adults 22+) and £3.00 (18–21), into a market with *no* prior minimum (Wages
  Councils abolished 1993).
- Own large-scale survey of the **whole population** of UK residential care homes (from
  Yellow Pages), sampled 1/9 per month in the nine months before and after introduction;
  ~20% response; **balanced panel of 641 homes**. Chosen because the sector is very
  low-wage, non-unionised, made of many small homogeneous firms with good monitoring, and
  price-regulated.
- Design = **Card (1992) fraction-affected / wage-gap** exposure design. Because the
  minimum is national, all cross-home variation in exposure comes from the *initial wage
  level*. Estimate `Δln W_it = α + β·MIN_{i,t-1} + δX_{i,t-1} + ε` (and the analogous
  employment equation). Identifying assumption: absent the minimum, no relationship
  between the initial wage level and subsequent wage change (wages ≈ random walk).
  **Tested** against an earlier 1992/93 "policy-off" survey using a counterfactual
  minimum placed at the same percentile — the wage-change/initial-wage relationship shifts
  markedly only in the policy-on period. The minimum is also used as an **instrument** for
  the wage change to recover the labor-demand elasticity.

**Bite / treatment-intensity measures.**
- Average wage ≈ £4/hr before introduction; **~32%** paid below the (age-specific)
  minimum, **~38%** below the adult minimum.
- **Wage gap** `GAP_i = Σ_j h_ji·max(W_ji^min − W_ji, 0) / Σ_j h_ji·W_ji` (hours-weighted
  shortfall) ≈ 4% (age-specific) / 4.7% (adult).
- Post-introduction **spike of ~30% at exactly the minimum**; little non-compliance. The
  minimum "bit hard."

**Main results.**
- *Wages / distribution:* very strong. Homes with more low-paid workers had much larger
  wage growth (initial-low-pay coefficient ≈ 0.145; wage-gap coefficient ≈ 0.80). Big
  **lower-tail compression**: the 50–10 log-wage gap fell from 0.21 to 0.09 while the
  90–50 gap was unchanged (0.34) → sharp reduction in wage inequality.
- *Employment:* basic reduced-form estimates negative but insignificant; **with controls
  they become significantly negative** for both employment and hours. Implied employment
  elasticities −0.15 to −0.40 (for a hypothetical 40p rise); structural labor-demand
  (wage) elasticity −0.35 to −0.55 — "moderate," and modest relative to the very large
  wage impact. No home closures in the short run.
- *Other margins:* no evidence of price pass-through (regulated) or of
  productivity/effort increases.
- *Caveat the authors stress:* because this is an unusually high-bite, price-constrained
  sector, one should **not** extrapolate to the whole UK economy (where Stewart 2001 finds
  little job loss).

**Key contributions to cite.** A clean exposure-by-initial-wage ("bite") design applied
to a national minimum; the wage-gap intensity measure; demonstration that large wage
compression can coexist with only moderate employment effects; the external-validity
caution about high-bite sectors; the "choose a heavily-exposed subgroup to maximize
detection power" logic (cf. Castillo-Freeman & Freeman 1991 on Puerto Rico).

---

## 5. Synthesis for the Peru exposure-by-education design

### 5.1 Competitive vs. monopsony/search predictions
- **Competitive model** (Stigler 1946; Brown 1999 §2.1): a binding minimum unambiguously
  reduces employment of affected workers; the size of the loss is the product of the
  labor-demand elasticity and the gap between the minimum and the market-clearing wage;
  product prices rise with cost pass-through. Applied to a broad group, the *measured*
  employment effect is small because only the low-skill share is directly affected and
  better-skilled substitutes may gain (Brown's β-vs-η distinction).
- **Monopsony / search-and-matching model** (Robinson; Burdett–Mortensen 1998; Manning
  2003; Card–Krueger 1995): with an upward-sloping firm-level supply curve or wage-posting
  frictions, a moderate minimum can leave employment unchanged or even raise it, produces
  a **spike** at the minimum, generates **spillovers/ripple effects** onto workers just
  above the minimum (via fairness norms and relative-wage concerns), and — because it can
  raise employment — need not raise (may lower) prices. The empirical record
  (Card–Krueger 1994; *Myth and Measurement*; Belman–Wolfson 2014 median elasticity
  ≈ −0.05 to −0.03) is more consistent with this class for *moderate* minimums, while
  every model agrees a *high-enough* minimum (Machin–Manning–Rahman's high-bite sector;
  Puerto Rico) can cut jobs.

### 5.2 What "bite" means and why it motivates an exposure-by-skill design
- **"Bite"** = the extent to which the minimum is binding in a given
  market/group/firm — measured as the *share of workers directly affected* (paid below the
  new minimum) and/or the *wage gap* (the hours-weighted proportional raise needed to
  reach the minimum), and confirmed ex post by a spike at the minimum and lower-tail
  compression.
- Bite is not uniform: it is largest where wages are lowest. In Peru, **education proxies
  skill and hence the initial wage level**, so less-educated workers face a mechanically
  larger fraction-affected and larger wage gap. This heterogeneity is exactly the
  identifying variation: an **exposure-by-education (× region/time) design** compares
  employment and wage changes across education groups (and areas) that differ in initial
  bite around a common national minimum change — the same logic Machin–Manning–Rahman use
  across care homes and Brown formalizes with the fraction-directly-affected argument.
  Choosing high-exposure groups also maximizes statistical power to detect any employment
  effect (Castillo-Freeman–Freeman 1991 logic), at the cost of external validity.

### 5.3 Canonical empirical templates we build on
1. **Card (1992) fraction-affected / initial-wage exposure.** Relate the *change* in
   employment (and wages) across cells to the *fraction of workers initially below the new
   minimum* or to the *wage gap* in the pre-period. National minimum → variation comes
   from initial wage levels; identifying assumption is no baseline relation between initial
   wage level and subsequent change (test against a policy-off period). Directly adopted by
   Machin–Manning–Rahman (2003) and embedded in Card–Krueger's GAP variable. This maps to
   an exposure-by-education specification for Peru.
2. **Card–Krueger case-study DiD.** Treatment vs. control jurisdiction, before/after,
   plus a within-treatment high- vs. low-wage (unaffected vs. affected) comparison; FTE
   outcomes; robustness across measures and subsamples. Generalizes to a difference-in-
   differences / triple-difference by education group and region.
3. **Time-series/Kaitz benchmark and its critique (Brown 1999).** Provides the β-vs-η
   framework and the "small effects when the 1980s are added" cautionary tale that
   motivated the move to design-based (cross-sectional exposure/DiD) evidence.

---

## BibTeX

```bibtex
@article{CardKrueger1994,
  author  = {Card, David and Krueger, Alan B.},
  title   = {Minimum Wages and Employment: A Case Study of the Fast-Food Industry
             in New Jersey and Pennsylvania},
  journal = {American Economic Review},
  year    = {1994},
  volume  = {84},
  number  = {4},
  pages   = {772--793}
}

@book{CardKrueger1995,
  author    = {Card, David and Krueger, Alan B.},
  title     = {Myth and Measurement: The New Economics of the Minimum Wage},
  publisher = {Princeton University Press},
  address   = {Princeton, NJ},
  year      = {1995},
  note      = {Twentieth-Anniversary Edition, 2016, with a new preface by the authors;
               ISBN 978-0-691-16912-5}
}

@incollection{Brown1999,
  author    = {Brown, Charles},
  title     = {Minimum Wages, Employment, and the Distribution of Income},
  booktitle = {Handbook of Labor Economics},
  editor    = {Ashenfelter, Orley and Card, David},
  publisher = {North-Holland (Elsevier)},
  address   = {Amsterdam},
  year      = {1999},
  volume    = {3},
  chapter   = {32},
  pages     = {2101--2163} % TODO verify final page (references begin p. 2158)
}

@article{MachinManningRahman2003,
  author  = {Machin, Stephen and Manning, Alan and Rahman, Lupin},
  title   = {Where the Minimum Wage Bites Hard: The Introduction of the UK National
             Minimum Wage to a Low Wage Sector},
  journal = {Journal of the European Economic Association},
  year    = {2003},
  volume  = {1},
  number  = {1},
  pages   = {154--180},
  doi     = {10.1162/154247603322256792}
}

@article{Card1992,
  author  = {Card, David},
  title   = {Using Regional Variation in Wages to Measure the Effects of the
             Federal Minimum Wage},
  journal = {Industrial and Labor Relations Review},
  year    = {1992},
  volume  = {46},
  number  = {1},
  pages   = {22--37}
}
```
