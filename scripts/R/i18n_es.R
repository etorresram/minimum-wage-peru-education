# ==============================================================================
# i18n_es.R  --  Spanish versions of the publication tables and figures.
# Translations live in two tab-separated catalogs (columns en, es), one row per segment:
#   i18n/tables_es.tsv   table captions, header/row-label cells, notes
#   i18n/figures_es.tsv  figure titles, axis labels, captions, legend/facet labels
# Tables: translate_tables_es() rewrites every tables/*.tex into tables/es/.
# Figures: save_fig() (theme_paper.R) also writes figures/es/ via translate_plot().
# A segment missing from its catalog stays in English and is reported with a
# warning, so a changed result or note shows up instead of failing silently.
# ==============================================================================
suppressMessages(library(data.table))

I18N_DIR <- file.path(PROJ_ROOT, "scripts", "R", "i18n")

read_catalog <- function(name) {
  f <- file.path(I18N_DIR, name)
  if (!file.exists(f)) return(setNames(character(), character()))
  cat <- fread(f, sep = "\t", quote = "", encoding = "UTF-8", colClasses = "character", na.strings = NULL)
  setNames(cat$es, cat$en)
}

# Thousands separator: 69,534 -> 69\,534 (a comma reads as a decimal mark in Spanish).
es_thousands <- function(x) gsub("(\\d),(\\d{3})(?!\\d)", "\\1\\\\,\\2", x, perl = TRUE)

## ---- Tables ------------------------------------------------------------------
# A cell needs translating if, once math and LaTeX commands are stripped, it
# still contains a word.
has_words <- function(x) {
  y <- gsub("\\$[^$]*\\$", " ", x)
  y <- gsub("\\\\[A-Za-z]+", " ", y)
  grepl("[A-Za-z]{2,}", y)
}

# A tabular row: cells, then "\\", optionally followed by rules such as \midrule.
ROW_END <- "\\s*\\\\\\\\((\\s*\\\\[a-z]+(\\{[^}]*\\}|\\([^)]*\\))*)*)\\s*$"
row_body <- function(l) sub(ROW_END, "", l)
row_tail <- function(l) sub(paste0("^.*?", ROW_END), "\\1", l, perl = TRUE)

# Split a .tex table into translatable segments: list(kind, text) per position.
table_segments <- function(lines) {
  out <- list()
  for (i in seq_along(lines)) {
    l <- lines[i]
    if (grepl("^\\\\caption\\{", l)) {
      m <- regmatches(l, regexec("^\\\\caption\\{(.*)\\}(\\\\label\\{[^}]*\\})$", l))[[1]]
      if (length(m)) out[[length(out) + 1]] <- list(i = i, kind = "caption", text = m[2])
    } else if (grepl("^\\\\item ", l)) {
      out[[length(out) + 1]] <- list(i = i, kind = "note", text = sub("^\\\\item ", "", l))
    } else if (grepl(ROW_END, l) && !grepl("^\\\\(toprule|midrule|bottomrule)", l)) {
      body  <- row_body(l)
      cells <- strsplit(body, " & ", fixed = TRUE)[[1]]
      for (j in seq_along(cells)) if (has_words(trimws(cells[j])))
        out[[length(out) + 1]] <- list(i = i, kind = "cell", j = j, text = trimws(cells[j]))
    }
  }
  out
}

translate_tables_es <- function(src = DIR_TAB, dst = file.path(DIR_TAB, "es")) {
  dir.create(dst, showWarnings = FALSE, recursive = TRUE)
  tr <- read_catalog("tables_es.tsv")
  missing <- character()
  for (f in list.files(src, pattern = "\\.tex$", full.names = TRUE)) {
    lines <- readLines(f, encoding = "UTF-8", warn = FALSE)
    out <- lines
    segs <- table_segments(lines)
    for (s in segs) {
      es <- tr[s$text]
      if (is.na(es)) { missing <- c(missing, sprintf("%s: %s", basename(f), s$text)); next }
      if (s$kind == "caption") {
        out[s$i] <- sub("^\\\\caption\\{.*\\}(\\\\label)", paste0("\\\\caption{", gsub("\\\\", "\\\\\\\\", es), "}\\1"), out[s$i])
      } else if (s$kind == "note") {
        out[s$i] <- paste0("\\item ", es)
      } else {
        body  <- row_body(out[s$i]); tail <- row_tail(out[s$i])
        cells <- strsplit(body, " & ", fixed = TRUE)[[1]]
        lead  <- sub("^(\\s*).*", "\\1", cells[s$j])
        cells[s$j] <- paste0(lead, es)
        out[s$i] <- paste0(paste(cells, collapse = " & "), " \\\\", tail)
      }
    }
    # thousands separators everywhere except in \label/\ref keys
    out <- ifelse(grepl("\\\\(label|ref)\\{", out) & !grepl("\\d,\\d{3}", out), out, es_thousands(out))
    writeLines(out, file.path(dst, basename(f)), useBytes = TRUE)
  }
  if (length(missing)) warning(sprintf(
    "%d table segment(s) have no Spanish translation in i18n/tables_es.tsv and stay in English:\n  %s",
    length(missing), paste(unique(missing), collapse = "\n  ")), call. = FALSE, immediate. = TRUE)
  invisible(unique(missing))
}

# Write every distinct English table segment (for building the catalog).
dump_table_segments <- function(src = DIR_TAB, file) {
  segs <- unlist(lapply(list.files(src, pattern = "\\.tex$", full.names = TRUE), function(f)
    vapply(table_segments(readLines(f, encoding = "UTF-8", warn = FALSE)), `[[`, "", "text")))
  fwrite(data.table(en = unique(segs)), file, sep = "\t", quote = FALSE)
}

## ---- Figures -----------------------------------------------------------------
FIG_MISSING <- new.env()

tr_fig <- function(x, tr = read_catalog("figures_es.tsv")) {
  vapply(as.character(x), function(s) {
    if (is.na(s) || !nzchar(s)) return(s)
    if (!is.na(tr[s])) return(unname(tr[s]))
    if (has_words(s)) assign(s, TRUE, envir = FIG_MISSING)
    s
  }, "", USE.NAMES = FALSE)
}

# Return a Spanish copy of a ggplot: plot/axis/legend titles via p$labels;
# legend keys, facet strips and discrete axis labels via scale/labeller label
# functions, so the data (and manual colour mappings keyed on it) stay intact.
translate_plot <- function(p) {
  tr <- read_catalog("figures_es.tsv")
  f  <- function(x) tr_fig(x, tr)
  q  <- p
  labs_es <- Filter(Negate(is.null), lapply(p$labels, function(v) if (is.character(v)) f(v) else NULL))
  # Spanish runs ~30% longer than English: wrap the caption so it is not clipped
  if (!is.null(labs_es$caption))
    labs_es$caption <- paste(strwrap(labs_es$caption, width = 105), collapse = "\n")
  q <- q + do.call(ggplot2::labs, labs_es)
  if (!inherits(p$facet, "FacetNull")) {
    q$facet <- ggplot2::ggproto(NULL, p$facet)
    q$facet$params$labeller <- ggplot2::as_labeller(f)
  }
  q$scales <- p$scales$clone()
  mapped <- names(p$mapping)
  for (a in intersect(c("colour", "fill", "shape", "linetype", "x", "y"), mapped)) {
    sc <- q$scales$get_scales(a)
    if (!is.null(sc)) {
      if (!sc$is_discrete()) next
      sc <- sc$clone()
      lab <- sc$labels
      sc$labels <- if (is.character(lab)) setNames(f(lab), names(lab)) else f
      q$scales$scales <- c(Filter(function(s) !(a %in% s$aesthetics), q$scales$scales), list(sc))
    } else {
      v <- tryCatch(rlang::eval_tidy(p$mapping[[a]], p$data), error = function(e) NULL)
      if (is.null(v) || !(is.character(v) || is.factor(v))) next
      add <- switch(a, colour = ggplot2::scale_colour_discrete(labels = f),
                    fill = ggplot2::scale_fill_discrete(labels = f),
                    shape = ggplot2::scale_shape_discrete(labels = f),
                    linetype = ggplot2::scale_linetype_discrete(labels = f),
                    x = ggplot2::scale_x_discrete(labels = f),
                    y = ggplot2::scale_y_discrete(labels = f))
      q <- q + add
    }
  }
  q
}

report_figure_missing <- function() {
  m <- ls(FIG_MISSING)
  if (length(m)) warning(sprintf(
    "%d figure label(s) have no Spanish translation in i18n/figures_es.tsv and stay in English:\n  %s",
    length(m), paste(m, collapse = "\n  ")), call. = FALSE, immediate. = TRUE)
  rm(list = m, envir = FIG_MISSING)   # report each figure's gaps once
  invisible(m)
}
