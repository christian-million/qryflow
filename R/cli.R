is_verbose <- function(verbose = NULL) {
  isTRUE(verbose)
}

# ---- Lifecycle reporters ----

report_workflow_start <- function(n, verbose = NULL) {
  if (!is_verbose(verbose)) {
    return(invisible(NULL))
  }
  message(sprintf("Running %d chunk%s", n, if (n != 1) "s" else ""))
}

report_chunk_start <- function(name, type, i, n, verbose = NULL) {
  if (!is_verbose(verbose)) {
    return(invisible(NULL))
  }
  message(sprintf("[%d/%d] %s [%s]", i, n, name, type))
}

report_chunk_end <- function(name, type, status, duration, verbose = NULL) {
  if (!is_verbose(verbose)) {
    return(invisible(NULL))
  }

  message(sprintf(
    "      %s  %s",
    fmt_chunk_status(status),
    if (!is.null(duration)) fmt_duration(duration) else ""
  ))
}

report_workflow_end <- function(x, verbose = NULL) {
  if (!is_verbose(verbose)) {
    return(invisible(NULL))
  }
  meta <- qryflow_meta(x)
  statuses <- vapply(
    x,
    function(c) {
      if (is.null(qryflow_meta(c)$status)) "pending" else qryflow_meta(x)$status
    },
    character(1)
  )

  message(sprintf(
    "Done in %s \u2014 %d success, %d error, %d skipped",
    fmt_duration(meta$duration),
    sum(statuses == "success"),
    sum(statuses == "error"),
    sum(statuses == "skipped")
  ))
}

# ---- Internal print helpers ----

fmt_rule <- function(title) {
  width <- getOption("width", 80)
  prefix <- paste0("\u2500\u2500 ", title, " ")
  rule_width <- max(0, width - nchar(prefix))
  paste0(prefix, strrep("\u2500", rule_width))
}

fmt_chunk_status <- function(status) {
  if (is.null(status)) {
    return("  pending  ")
  }
  switch(
    status,
    success = "\u2713 success",
    error = "\u2717 error  ",
    skipped = "\u2013 skipped",
    pending = "  pending"
  )
}

fmt_truncation <- function(n_remaining) {
  paste0(
    "\u2504\u2504 ... and ",
    n_remaining,
    " more line",
    if (n_remaining > 1) "s" else "",
    " \u2504\u2504"
  )
}
