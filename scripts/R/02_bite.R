# ==============================================================================
# 02_bite.R
# Purpose: Construct pre-reform minimum-wage "bite" (exposure) measures used for
#          the continuous-intensity (Card 1992 fraction-affected) design and the
#          triple-difference. Bite is measured in the PRE period (2021Q1-2022Q1)
#          so it is predetermined with respect to the May-2022 reform.
# Output:  data/processed/bite_region.csv, bite_region_skill.csv
#          + merges an exposure column back into enaho_pooled.rds
# ==============================================================================

source(file.path(Sys.getenv("MW_PROJ_ROOT",
        "/Users/etorresram/Desktop/minimum_wage/project"),
        "scripts", "R", "00_config.R"))
suppressMessages(library(matrixStats))

DT <- readRDS(file.path(DIR_PROC, "enaho_pooled.rds"))
NEW_MW <- 1025   # statutory MW after the reform

# Pre-reform dependent employees (predetermined exposure base)
pre <- DT[in_window==1 & employed==1 & dependent==1 & !is.na(ylab_nom) &
          t_index < 6]   # 2021Q1 .. 2022Q1

## ---- Region-level Kaitz index and fraction affected --------------------------
bite_region <- pre[, .(
    med_wage   = matrixStats::weightedMedian(ylab_nom, fac500a, na.rm=TRUE),
    mean_wage  = weighted.mean(ylab_nom, fac500a, na.rm=TRUE),
    frac_below = weighted.mean(as.numeric(ylab_nom < NEW_MW), fac500a, na.rm=TRUE),
    n = .N), by = region][order(region)]
bite_region[, kaitz := NEW_MW / med_wage]
# high-bite region = above (weighted) median fraction affected
cut <- median(bite_region$frac_below, na.rm=TRUE)
bite_region[, high_bite := as.integer(frac_below > cut)]
fwrite(bite_region, file.path(DIR_PROC, "bite_region.csv"))

## ---- Region x skill exposure (fraction affected) -----------------------------
bite_rs <- pre[!is.na(skill), .(
    frac_below = weighted.mean(as.numeric(ylab_nom < NEW_MW), fac500a, na.rm=TRUE),
    med_wage   = matrixStats::weightedMedian(ylab_nom, fac500a, na.rm=TRUE),
    n = .N), by = .(region, skill)]
bite_rs[, kaitz := NEW_MW / med_wage]
fwrite(bite_rs, file.path(DIR_PROC, "bite_region_skill.csv"))

## ---- Merge exposure back into the pooled data --------------------------------
DT <- merge(DT, bite_region[, .(region, kaitz_region=kaitz,
             frac_below_region=frac_below, high_bite)],
            by="region", all.x=TRUE, sort=FALSE)
# standardized regional exposure (mean 0, sd 1) for interpretable slopes
DT[, exposure_z := as.numeric(scale(kaitz_region))]
saveRDS(DT, file.path(DIR_PROC, "enaho_pooled.rds"))

cat("Region bite (Kaitz = 1025 / pre-reform median monthly wage of employees):\n")
print(bite_region[order(-kaitz), .(region, med_wage=round(med_wage), frac_below=round(frac_below,3),
      kaitz=round(kaitz,3), high_bite, n)])
cat("\nNational pre-reform median dependent wage:",
    round(matrixStats::weightedMedian(pre$ylab_nom, pre$fac500a, na.rm=TRUE)), "\n")
cat("Kaitz range:", round(range(bite_region$kaitz),3), "\n")
