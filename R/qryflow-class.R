new_qryflow <- function(chunks = list(), source = NULL) {
  structure(
    chunks,
    meta = init_meta(source = source),
    class = "qryflow"
  )
}


#' @export
print.qryflow <- function(x, ...) {
  types <- vapply(x, function(x) x$type, character(1))
  names <- vapply(x, function(x) x$name, character(1))

  chunk_length <- length(x)

  cat("<qryflow>")
  cat("\nChunks:", chunk_length)
  cat("\n\nChunks:\n")

  n <- min(c(chunk_length, 10))
  out <- paste0(types, ": ", names)

  for (i in 1:n) {
    cat(paste0(i, ") ", out[i], "\n"))
  }
}
