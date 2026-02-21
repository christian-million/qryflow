stop_qryflow_chunk <- function(message, chunk, workflow, call = NULL) {
  message <- paste0(
    "Chunk '",
    chunk$name,
    "' failed with message: '",
    message,
    "'"
  )
  err <- structure(
    list(
      message = message,
      chunk = chunk,
      call = call,
      workflow = workflow
    ),
    class = c("qryflow_chunk_error", "error", "condition")
  )
  stop(err)
}

warn_qryflow_chunk <- function(message, chunk, call = NULL) {
  wrn <- structure(
    list(
      message = message,
      call = call,
      chunk = chunk
    ),
    class = c("qryflow_chunk_warning", "warning", "condition")
  )
  warning(wrn)
}

stop_qryflow <- function(message, workflow = NULL, call = NULL, ...) {
  err <- structure(
    list(
      message = message,
      call = call,
      workflow = workflow,
      ...
    ),
    class = c("qryflow_error", "error", "condition")
  )
  stop(err)
}
