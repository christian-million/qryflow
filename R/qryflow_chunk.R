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
  results = NULL
) {
  x <- list(
    type = type,
    name = name,
    sql = sql,
    tags = tags,
    results = results
  )

  structure(x, class = "qryflow_chunk")
}

#' @export
print.qryflow_chunk <- function(x, ...) {
  cat(paste0("<qryflow_chunk> ", x$name, "\n\n"))
  cat(paste0("[", x$type, "]\n"))
  if (length(x$tags) > 0) {
    cat("tags:", paste0(x$tags, collapse = ", "))
    cat("\n")
  }
  cat("\n")
  cat(substr(x$sql, 1, 100), "...\n")
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
