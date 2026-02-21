#' Execute a parsed qryflow SQL workflow
#'
#' @description
#' `qryflow_execute()` takes a `qryflow` object (as returned by [`qryflow_parse()`]),
#' executes each chunk (e.g., `@query`, `@exec`), and collects the results and timing metadata.
#'
#' This function is used internally by [`qryflow_run()`], but can be called directly in concert with [`qryflow_parse()`] if you want
#' to manually control parsing and execution.
#'
#' @param con A database connection from [DBI::dbConnect()]
#' @param x A `qryflow` object, typically created by [`qryflow_parse()`]
#' @param ... Reserved for future use
#' @param on_error Controls behaviour when a chunk fails during execution.
#'   One of `"stop"` (default), `"warn"`, or `"collect"`. `"stop"` halts
#'   execution immediately and returns the partially executed workflow. `"warn"`
#'   records the error in the chunk's `meta`, signaling immediately. `"collect"` gathers
#'   all errors from across all chunks and reports them at the end.
#' @param verbose Logical. If `TRUE`, emits a message before each chunk
#'   identifying its name and type, and prints a summary on completion
#'   reporting total chunks run, successes, errors, skipped, and elapsed time.
#'   Defaults to `FALSE`. The global default can be set with
#'   `options(qryflow.verbose = TRUE)`.
#'
#' @returns An object of class `qryflow`, containing executed chunks with results and a `meta` field
#'   that includes timing and source information.
#'
#' @seealso [`qryflow_run()`], [`qryflow_parse()`]
#'
#' @examples
#' con <- example_db_connect(mtcars)
#'
#' filepath <- example_sql_path("mtcars.sql")
#'
#' parsed <- qryflow_parse(filepath)
#'
#' executed <- qryflow_execute(con, parsed)
#'
#' DBI::dbDisconnect(con)
#' @export
qryflow_execute <- function(
  con,
  x,
  ...,
  on_error = c("stop", "warn", "collect"),
  verbose = TRUE
) {
  if (!inherits(x, "qryflow")) {
    stop_qryflow("`x` is not an object of class `qryflow`")
  }
  on_error <- resolve_on_error(on_error)

  # Prepare vectors to store output
  chunk_names <- names(x)
  n <- length(x)
  errors <- list()

  chunk_results <- vector("list", n)
  chunk_meta <- vector("list", n)

  names(chunk_results) <- chunk_names
  names(chunk_meta) <- chunk_names

  # Workflow Start Time
  wf_start <- meta_time()

  # Avoiding copy-on-modify, by not assigning directly to `qryflow`
  for (i in seq_along(x)) {
    nm <- chunk_names[i]
    chunk <- x[[nm]]
    outcome <- qryflow_handle_chunk(con, chunk, ...)
    chunk_results[[nm]] <- outcome$result
    chunk_meta[[nm]] <- outcome$meta

    if (outcome$meta$status == 'error') {
      # Check if errors and operate as appropriate
      errors <- dispatch_on_error(
        on_error,
        message = outcome$meta$error_msg,
        chunk = chunk,
        workflow = x,
        errors = errors
      )
    }
  }

  for (nm in chunk_names) {
    m <- chunk_meta[[nm]]
    x[[nm]] <- set_meta(
      x[[nm]],
      start_time = m$start_time,
      end_time = m$end_time,
      duration = m$duration,
      status = m$status
    )
    x[[nm]]$results <- chunk_results[[nm]]
  }

  wf_end <- meta_time()

  all_statuses <- vapply(
    chunk_meta,
    function(m) if (is.null(m$status)) "skipped" else m$status,
    character(1)
  )

  wf_status <- if (all(all_statuses == "success")) {
    "success"
  } else {
    "partial"
  }

  out <- set_meta(
    x,
    start_time = wf_start,
    end_time = wf_end,
    duration = meta_duration(wf_start, wf_end),
    status = wf_status
  )

  if (on_error == "collect") {
    dispatch_collected_errors(errors, out)
  }

  return(out)
}
