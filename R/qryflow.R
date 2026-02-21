#' Run a multi-step SQL workflow and return query results
#'
#' @description
#' `qryflow()` is the main entry point to the `qryflow` package. It executes a SQL workflow
#' defined in a tagged `.sql` script or character string and returns query results as R objects.
#'
#' The SQL script can contain multiple steps tagged with `@query` or `@exec`. Query results
#' are captured and returned as a named list, where names correspond to the `@query` tags.
#'
#' @details
#' This is a wrapper around the combination of [`qryflow_run()`], which always provides a list of results and metadata,
#' and [`qryflow_results()`], which filters the output of [`qryflow_run()`] to only include the results of the SQL.
#'
#' @param con A database connection from [DBI::dbConnect()]
#' @param sql A file path to a `.sql` workflow or a character string containing SQL code.
#' @param ... Additional arguments passed to [`qryflow_run()`] or [`qryflow_results()`].
#' @param on_error Controls behaviour when a chunk fails during execution.
#'   One of `"stop"` (default), `"warn"`, or `"collecte"`. `"stop"` halts
#'   execution immediately and returns the partially executed workflow. `"warn"`
#'   records the error in the chunk's `meta`, signaling immediately. `"collect"` gathers
#'   all errors from across all chunks and reports them at the end.
#' @param simplify Logical; if `TRUE` (default), a list of length 1 is simplified to the
#'   single result object.
#'
#' @returns A named list of query results, or a single result if `simplify = TRUE` and only one chunk exists.
#'
#' @seealso [`qryflow_run()`], [`qryflow_results()`]
#' @examples
#' con <- example_db_connect(mtcars)
#'
#' filepath <- example_sql_path("mtcars.sql")
#'
#' results <- qryflow(con, filepath)
#'
#' head(results$df_mtcars)
#'
#' DBI::dbDisconnect(con)
#' @export
qryflow <- function(
  con,
  sql,
  ...,
  on_error = c("stop", "warn", "collect"),
  simplify = TRUE
) {
  x <- qryflow_run(con, sql, ..., on_error)

  qryflow_results(x, ..., simplify = simplify)
}

#' Parse and execute a tagged SQL workflow
#'
#' @description
#' `qryflow_run()` reads a SQL workflow from a file path or character string, parses it into
#' tagged statements, and executes those statements against a database connection.
#'
#' This function is typically used internally by [`qryflow()`], but can also be called directly
#' for more control over workflow execution.
#'
#' @param con A database connection from [DBI::dbConnect()]
#' @param sql A character string representing either the path to a `.sql` file or raw SQL content.
#' @param ... Additional arguments passed to [`qryflow_execute()`].
#' @param on_error Controls behaviour when a chunk fails during execution.
#'   One of `"stop"` (default), `"warn"`, or `"collecte"`. `"stop"` halts
#'   execution immediately and returns the partially executed workflow. `"warn"`
#'   records the error in the chunk's `meta`, signaling immediately. `"collect"` gathers
#'   all errors from across all chunks and reports them at the end.
#'
#' @returns A list representing the evaluated workflow, containing query results, execution metadata,
#'   or both, depending on the contents of the SQL script.
#'
#' @seealso [`qryflow()`], [`qryflow_results()`], [`qryflow_execute()`], [`qryflow_parse()`]
#'
#' @examples
#' con <- example_db_connect(mtcars)
#'
#' filepath <- example_sql_path("mtcars.sql")
#'
#' obj <- qryflow_run(con, filepath)
#'
#' obj$df_mtcars$sql
#' obj$df_mtcars$results
#'
#' results <- qryflow_results(obj)
#'
#' head(results$df_mtcars$results)
#'
#' DBI::dbDisconnect(con)
#' @export
qryflow_run <- function(
  con,
  sql,
  ...,
  on_error = c("stop", "warn", "collect")
) {
  obj <- qryflow_run_(con, sql, ..., on_error = on_error)

  obj
}

#' Extract results from a `qryflow_workflow` object
#'
#' @description
#' `qryflow_results()` retrieves the query results from a list returned by [`qryflow_run()`],
#' typically one that includes parsed and executed SQL chunks.
#'
#' @param x Results from [`qryflow_run()`], usually containing a mixture of `qryflow_chunk` objects.
#' @param ... Reserved for future use.
#' @param simplify Logical; if `TRUE`, simplifies the result to a single object if only one
#'   query chunk is present. Defaults to `FALSE`.
#'
#' @returns A named list of query results, or a single result object if `simplify = TRUE` and only one result is present.
#'
#' @seealso [`qryflow()`], [`qryflow_run()`]
#'
#' @examples
#' con <- example_db_connect(mtcars)
#'
#' filepath <- example_sql_path("mtcars.sql")
#'
#' obj <- qryflow_run(con, filepath)
#'
#' results <- qryflow_results(obj)
#'
#' DBI::dbDisconnect(con)
#' @export
qryflow_results <- function(x, ..., simplify = FALSE) {
  if (!inherits(x, "qryflow")) {
    stop("`x` is not an object of class `qryflow_result`")
  }

  chunk_idx <- vapply(x, function(x) inherits(x, "qryflow_chunk"), logical(1))
  obj <- x[chunk_idx]

  res <- lapply(obj, function(x) x$results)

  if (simplify && length(res) == 1) {
    res <- res[[1]]
  }

  return(res)
}

qryflow_run_ <- function(con, sql, ..., on_error) {
  statement <- read_sql_lines(sql)

  wf <- qryflow_parse(statement)
  results <- qryflow_execute(con, wf, ..., on_error = on_error)

  return(results)
}

#' Access the default qryflow chunk type
#'
#' @description
#' Retrieves the value from the option `qryflow.default.type`, if set. Otherwise returns
#' "query", which is the officially supported default type. If any value is supplied
#' to the function, it returns that value.
#'
#' @param type Optional. The type you want to return.
#'
#' @returns Character. If set, result from `qryflow.default.type` option, otherwise "query" or value passed to `type`
#'
#' @examples
#' x <- getOption("qryflow.default.type", "query")
#'
#' y <- qryflow_default_type()
#'
#' identical(x, y)
#' @export
qryflow_default_type <- function(
  type = getOption("qryflow.default.type", "query")
) {
  return(type)
}
