# ==============================================================================
# 02_bite.R
# Purpose: Construct pre-reform minimum-wage "bite" (exposure) measures used for
#          the continuous-intensity (Card 1992 fraction-affected) design and the
#          triple-difference. Bite is measured in the PRE period (2021Q1-2022Q1)
#          so it is predetermined with respect to the May-2022 reform.
#          Base population: private-sector MW-covered wage earners (employees
#          and domestic workers), monthly-equivalent earnings.
# Output:  data/processed/bite_region.csv, bite_region_skill.csv
#          + merges exposure columns back into enaho_pooled.rds (idempotent)
# ==============================================================================

source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
suppressMessages(library(matrixStats))

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
# post-reform statutory MW, from the verified schedule (no hard-coding)
NEW_MW <- mw_value(as.integer(format(REFORM_DATE, "%Y")),
                   as.integer(format(REFORM_DATE, "%m")))
stopifnot(NEW_MW == 1025)

# Pre-reform private MW-covered wage earners (predetermined exposure base)
pre <- DT[in_window==1 & employed==1 & wage_worker==1 & public_sector==0 &
          !is.na(ylab_nom) & t_index < 6]   # 2021Q1 .. 2022Q1

## ---- Region-level Kaitz index and fraction affected --------------------------
bite_region <- pre[, .(
    med_wage   = matrixStats::weightedMedian(ylab_nom, fac500a, na.rm=TRUE),
    mean_wage  = weighted.mean(ylab_nom, fac500a, na.rm=TRUE),
    frac_below = weighted.mean(as.numeric(ylab_nom < NEW_MW), fac500a, na.rm=TRUE),
    n = .N), by = region][order(region)]
bite_region[, kaitz := NEW_MW / med_wage]
# high-bite region = above-median fraction affected
cut <- median(bite_region$frac_below, na.rm=TRUE)
bite_region[, high_bite := as.integer(frac_below > cut)]
# standardized exposure: z-score of the Kaitz index ACROSS THE 25 REGIONS
# (so "one SD" is one SD of the cross-regional exposure distribution)
bite_region[, exposure_z := (kaitz - mean(kaitz)) / sd(kaitz)]
fwrite(bite_region, file.path(DIR_PROC, "bite_region.csv"))

## ---- Region x skill exposure (fraction affected) -----------------------------
bite_rs <- pre[!is.na(skill), .(
    frac_below = weighted.mean(as.numeric(ylab_nom < NEW_MW), fac500a, na.rm=TRUE),
    med_wage   = matrixStats::weightedMedian(ylab_nom, fac500a, na.rm=TRUE),
    n = .N), by = .(region, skill)]
bite_rs[, kaitz := NEW_MW / med_wage]
fwrite(bite_rs, file.path(DIR_PROC, "bite_region_skill.csv"))

## ---- Merge exposure back into the pooled data (idempotent) -------------------
drop_cols <- intersect(c("kaitz_region","frac_below_region","high_bite","exposure_z"),
                       names(DT))
if (length(drop_cols)) DT[, (drop_cols) := NULL]
DT <- merge(DT, bite_region[, .(region, kaitz_region=kaitz,
             frac_below_region=frac_below, high_bite, exposure_z)],
            by="region", all.x=TRUE, sort=FALSE)
saveRDS(DT, file.path(DIR_PROC, "enaho_pooled.rds"))

cat("Region bite (Kaitz = ", NEW_MW,
    " / pre-reform median monthly wage, private wage earners):\n", sep="")
print(bite_region[order(-kaitz), .(region, med_wage=round(med_wage),
      frac_below=round(frac_below,3), kaitz=round(kaitz,3), high_bite, n)])
cat("\nNational pre-reform median wage (private wage earners):",
    round(matrixStats::weightedMedian(pre$ylab_nom, pre$fac500a, na.rm=TRUE)), "\n")
cat("Kaitz range:", round(range(bite_region$kaitz),3),
    "| exposure_z range:", round(range(bite_region$exposure_z),2), "\n")
