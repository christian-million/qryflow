#' Create an instance of the `qryflow_chunk` class
#'
#' @details
#' Exported for users intending to extend qryflow. Subsequent processes rely on
#' the structure of a qryflow_chunk.
#'
#' @param type Character indicating the type of chunk (e.g., "query", "exec")
#' @param name Name of the chunk
#' @param sql SQL statement associated with chunk
#' @param tags Optional, additional tags included in chunk
#' @param results Optional, filled in after chunk execution
#' @param meta Optional, stores meta data on the object
#'
#' @returns An list-like object of class `qryflow_chunk`
#'
#' @examples
#' chunk <- new_qryflow_chunk("query", "df_name", "SELECT * FROM mtcars;")
#' @export
new_qryflow_chunk <- function(
  type = character(),
  name = character(),
  sql = character(),
  tags = NULL,
  results = NULL,
  meta = init_meta()
) {
  x <- list(
    type = type,
    name = name,
    sql = sql,
    tags = tags,
    results = results
  )

  structure(x, meta = meta, class = "qryflow_chunk")
}

#' @export
print.qryflow_chunk <- function(x, ...) {
  meta <- qryflow_meta(x)

  # Header
  cat(fmt_rule(paste0("qryflow_chunk: ", x$name)), "\n")

  # Summary Line
  status_str <- fmt_chunk_status(meta$status)
  duration_str <- if (!is.null(meta$duration)) {
    paste0(" | duration: ", fmt_duration(meta$duration))
  } else {
    ""
  }

  cat("  type: ", x$type, " | ", status_str, duration_str, "\n", sep = "")

  # Tags
  if (length(x$tags) > 0) {
    tag_str <- paste(
      mapply(function(k, v) paste0(k, ": ", v), names(x$tags), x$tags),
      collapse = " | "
    )
    cat("  tags: ", tag_str, "\n", sep = "")
  }

  # Error Message
  if (!is.null(meta$error_message)) {
    cat("  error: ", meta$error_message, "\n", sep = "")
  }

  # SQL Preview
  cat("\n")

  sql_lines <- strsplit(x$sql, "\n")[[1]]
  sql_lines <- sql_lines[nzchar(trimws(sql_lines))] # drop blank lines
  n_lines <- length(sql_lines)
  preview <- min(8L, n_lines)

  for (line in sql_lines[seq_len(preview)]) {
    cat("  ", line, "\n", sep = "")
  }

  if (n_lines > 8L) {
    cat("  ", fmt_truncation(n_lines - 8L), "\n", sep = "")
  }

  cat("\n")
  invisible(x)
}

# ---- Internal helper ----

fmt_truncation <- function(n_remaining) {
  paste0(
    "\u2504\u2504 ... and ",
    n_remaining,
    " more line",
    if (n_remaining > 1) "s" else "",
    " \u2504\u2504"
  )
}

#' @export
as.list.qryflow_chunk <- function(x, ...) {
  unclass(x)
}

#' @export
as.data.frame.qryflow_chunk <- function(x, ...) {
  l <- as.list(x)
  as.data.frame(l, ...)
}
