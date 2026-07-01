# Institutional background: the Peruvian minimum wage (RMV), 2021–2025

## Verified minimum wage changes (Remuneración Mínima Vital, RMV)

Peru sets a **single national** minimum wage (Remuneración Mínima Vital) for private-sector
salaried workers. There is no regional or industry-varying statutory minimum for the general
regime, so there is **no staggered geographic adoption** to exploit. The relevant statutory
changes, verified against the official decrees and the BCRP series PN02124PM (source: MTPE), are:

| Decree | Published | Effective | Old RMV | New RMV | Change |
|---|---|---|---|---|---|
| D.S. 003-2022-TR | 3 Apr 2022 | **1 May 2022** | S/ 930 | S/ 1,025 | +S/ 95 (+10.2%) |
| D.S. 006-2024-TR | 28 Dec 2024 | **1 Jan 2025** | S/ 1,025 | S/ 1,130 | +S/ 105 (+10.2%) |

The RMV had been held at S/ 930 since April 2018 (D.S. 004-2018-TR).

## Implication for identification

Within the stated study window **2021Q1–2024Q4 there is exactly one reform**, effective
1 May 2022. Because the change is national and simultaneous, a **staggered** difference-in-differences
design (Callaway–Sant'Anna, Sun–Abraham, Borusyak et al.) is **not** the natural estimator:
there is no cross-unit variation in *timing*. The credible design instead exploits variation in
*exposure* to the (common) reform:

1. **Skill-exposure DiD / event study.** Low-skilled workers (education ≤ secondary complete)
   are far more likely to be bound by the minimum wage than high-skilled workers
   (higher education). The reform therefore acts as a treatment whose intensity differs by
   skill group. Event-study leads/lags around 2022Q2 identify dynamics and test pre-trends.
2. **Triple difference (DDD) / continuous-intensity DiD.** The "bite" of a common national
   minimum wage is larger where median wages are lower. Interacting the skill dimension with
   the regional Kaitz index (or fraction-affected) and post period sharpens identification and
   guards against skill-specific national shocks (à la the developing-country MW literature).

The **January 2025 reform** falls just outside the window but the 2025 ENAHO quarters are
available, providing an independent second event to validate the design out of sample.

Sources: D.S. 003-2022-TR (El Peruano, busquedas.elperuano.pe/dispositivo/NL/2054921-1);
D.S. 006-2024-TR (gob.pe/institucion/mtpe/normas-legales/6335262-006-2024-tr;
El Peruano NL/2357884-10); BCRP series PN02124PM (Remuneración Mínima Vital - Nominal).
