new_qryflow_result <- function(..., meta = NULL) {
  x <- list(
    ...,
    meta = meta
  )

  structure(x, class = "qryflow_result")
}

#' @export
print.qryflow_result <- function(x, ...) {
  stopifnot(inherits(x, "qryflow_result"))

  cat("<qryflow_result>:\n")
  cat("Chunks executed:", length(x) - 1, "\n")
  cat("Available objects:", paste(names(x), collapse = ", "), "\n")
}

#' @export
summary.qryflow_result <- function(object, ...) {
  stopifnot(inherits(object, "qryflow_result"))

  cat("<qryflow_result>\n")
  cat("Chunks executed:", length(object) - 1, "\n")
  cat("Available objects:", paste(names(object), collapse = ", "), "\n")

  invisible(object)
}
