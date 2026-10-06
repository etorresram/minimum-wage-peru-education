# theme_paper.R : shared ggplot2 theme and palette for publication figures
suppressMessages({library(ggplot2)})
source(file.path(PROJ_ROOT, "scripts", "R", "i18n_es.R"))   # translate_plot()

theme_paper <- function(base_size = 11, base_family = "") {
  theme_bw(base_size = base_size, base_family = base_family) +
    theme(
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(linewidth = 0.25, colour = "grey88"),
      panel.border     = element_rect(colour = "grey40", linewidth = 0.4),
      axis.title       = element_text(size = rel(1.0)),
      axis.text        = element_text(colour = "grey20"),
      plot.title       = element_text(size = rel(1.05), face = "plain", hjust = 0),
      plot.subtitle    = element_text(size = rel(0.9), colour = "grey35"),
      plot.caption     = element_text(size = rel(0.75), colour = "grey45", hjust = 0),
      legend.position  = "bottom",
      legend.key       = element_blank(),
      legend.title     = element_text(size = rel(0.9)),
      strip.background = element_rect(fill = "grey92", colour = "grey40", linewidth = 0.4),
      strip.text       = element_text(size = rel(0.9))
    )
}
# colour-blind-friendly palette
pal_skill <- c("Low" = "#1b6ca8", "High" = "#c1272d")
pal_two   <- c("#1b6ca8", "#c1272d")

save_fig <- function(p, name, w = 6.5, h = 4.2) {
  # use the base pdf device (no cairo/X11 dependency) for LaTeX-ready vector output
  ggsave(file.path(DIR_FIG, paste0(name, ".pdf")), p, width = w, height = h,
         device = "pdf", useDingbats = FALSE)
  ggsave(file.path(DIR_FIG, paste0(name, ".png")), p, width = w, height = h, dpi = 200)
  # Spanish version for paper_espanol.tex (labels from i18n/figures_es.tsv)
  dir_es <- file.path(DIR_FIG, "es"); dir.create(dir_es, showWarnings = FALSE)
  q <- translate_plot(p)
  ggsave(file.path(dir_es, paste0(name, ".pdf")), q, width = w, height = h,
         device = "pdf", useDingbats = FALSE)
  ggsave(file.path(dir_es, paste0(name, ".png")), q, width = w, height = h, dpi = 200)
  report_figure_missing()
  invisible(p)
}
