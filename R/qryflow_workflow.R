new_qryflow_workflow <- function(chunks = list(), source = NULL) {
  stopifnot(all(sapply(chunks, function(x) inherits(x, "qryflow_chunk"))))

  structure(
    list(
      chunks = chunks,
      source = source
    ),
    class = "qryflow_workflow"
  )
}

#' @export
print.qryflow_workflow <- function(x, ...) {
  types <- vapply(x$chunks, function(x) x$type, character(1))
  names <- vapply(x$chunks, function(x) x$name, character(1))

  chunk_length <- length(x$chunks)

  cat("<qryflow_workflow>")
  cat("\nChunks:", chunk_length)
  cat("\n\nChunks:\n")

  n <- min(c(chunk_length, 10))
  out <- paste0(types, ": ", names)

  for (i in 1:n) {
    cat(paste0(i, ") ", out[i], "\n"))
  }
}
