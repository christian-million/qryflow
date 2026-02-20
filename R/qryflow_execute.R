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
#'   One of `"stop"` (default) or `"continue"`. `"stop"` halts
#'   execution immediately and returns the partially executed workflow. `"continue"`
#'   records the error in the chunk's `meta` and continues. The global
#'   default can be set with `options(qryflow.on_error = "continue")`.
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
  on_error = c("stop", "continue"),
  verbose = TRUE
) {
  # Prepare vectors to store output
  chunk_names <- names(x)
  n <- length(x)

  chunk_results <- vector("list", n)
  chunk_meta <- vector("list", n)

  names(chunk_results) <- chunk_names
  names(chunk_meta) <- chunk_names

  # Workflow Start Time
  wf_start <- Sys.time()

  # Avoiding copy-on-modify, by not assigning directly to `qryflow`
  for (i in seq_along(x)) {
    nm <- chunk_names[i]
    chunk <- x[[nm]]
    outcome <- execute_chunk(con, chunk, on_error)
    chunk_results[[nm]] <- outcome$result
    chunk_meta[[nm]] <- outcome$meta
  }

  for (nm in chunk_names) {
    x[[nm]] <- set_meta(x[[nm]], chunk_meta[[nm]])
    x[[nm]]$results <- chunk_results[[nm]]
  }

  wf_end <- Sys.time()
  wf_status <- "success"

  out <- set_meta(
    x,
    start_time = wf_start,
    end_time = wf_end,
    duration = difftime(wf_start, wf_end),
    status = wf_status
  )

  return(out)
}


execute_chunk <- function(con, chunk, on_error) {
  # TODO: Process "on_error"
  output <- qryflow_handle_chunk(
    con,
    chunk
  )

  output
}
