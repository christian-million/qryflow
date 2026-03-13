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
      message = paste0(message, "\n"),
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
      message = paste0(message, "\n"),
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
      message = paste0(message, "\n"),
      call = call,
      workflow = workflow,
      ...
    ),
    class = c("qryflow_error", "error", "condition")
  )
  stop(err)
}

warn_qryflow <- function(message, call = NULL, ...) {
  wrn <- structure(
    list(
      message = paste0(message, "\n"),
      call = call,
      ...
    ),
    class = c("qryflow_warning", "warning", "condition")
  )
  warning(wrn)
}

message_qryflow <- function(message, call = NULL, ...) {
  msg <- structure(
    list(
      message = paste0(message, "\n"),
      call = call,
      ...
    ),
    class = c("qryflow_message", "message", "condition")
  )
  message(msg)
}
