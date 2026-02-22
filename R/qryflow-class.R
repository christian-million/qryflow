new_qryflow <- function(chunks = list(), source = NULL) {
  structure(
    chunks,
    meta = init_meta(source = source),
    class = "qryflow"
  )
}


#' @export
print.qryflow <- function(x, ...) {
  meta <- qryflow_meta(x)
  chunks <- x
  n <- length(chunks)

  # Header
  status <- if (is.null(meta$status)) "pending" else meta$status
  duration <- if (!is.null(meta$duration)) fmt_duration(meta$duration) else NULL

  summary_parts <- c(
    paste0("chunks: ", n),
    paste0("status: ", status),
    if (!is.null(duration)) paste0("duration: ", duration)
  )

  cat(fmt_rule("qryflow"), "\n")
  cat(" ", paste(summary_parts, collapse = " | "), "\n\n")

  # Chunks
  if (n == 0) {
    cat("  (no chunks)\n")
    invisible(x)
    return()
  }

  # Pre-compute column widths for alignment
  chunk_names <- names(chunks)
  chunk_types <- vapply(
    chunks,
    function(c) if (is.null(c$type)) "unknown" else c$type,
    character(1)
  )
  name_width <- max(nchar(chunk_names))
  type_width <- max(nchar(chunk_types))

  for (i in seq_along(chunks)) {
    chunk <- chunks[[i]]
    chunk_meta <- qryflow_meta(chunk)
    nm <- chunk_names[i]
    tp <- chunk_types[i]

    status_str <- fmt_chunk_status(chunk_meta$status)
    duration_str <- if (!is.null(chunk_meta$duration)) {
      fmt_duration(chunk_meta$duration)
    } else {
      ""
    }

    cat(sprintf(
      "  %-*s  [%-*s]  %s  %s\n",
      name_width,
      nm,
      type_width,
      tp,
      status_str,
      duration_str
    ))
  }

  cat("\n")
  invisible(x)
}
