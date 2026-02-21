resolve_on_error <- function(on_error) {
  valid <- c("stop", "warn", "collect")

  first_on_error <- on_error[1]

  if (!first_on_error %in% valid) {
    stop_qryflow(
      sprintf(
        "'on_error' must be one of %s, not %s.",
        paste(valid, collapse = ", "),
        first_on_error
      )
    )
  }
  first_on_error
}

dispatch_on_error <- function(on_error, message, chunk, workflow, errors) {
  switch(
    on_error,
    stop = {
      stop_qryflow_chunk(message, chunk, workflow)
    },
    warn = {
      warn_qryflow_chunk(message, chunk)
    },
    collect = {
      # Accumulate silently - signal is deferred to end of workflow
      c(errors, list(list(name = chunk$name, message = message)))
    }
  )
}

dispatch_collected_errors <- function(errors, workflow) {
  if (length(errors) == 0) {
    return(invisible(NULL))
  }

  n <- length(errors)
  names <- vapply(errors, `[[`, character(1), "name")
  messages <- vapply(errors, `[[`, character(1), "message")

  detail <- paste(
    sprintf("  - %s: %s", names, messages),
    collapse = "\n"
  )

  stop_qryflow(
    message = sprintf(
      "%d chunk%s failed:\n%s",
      n,
      if (n != 1) "s" else "",
      detail
    ),
    workflow = workflow
  )
}
