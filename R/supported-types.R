qryflow_exec_handler <- function(con, chunk, ...) {
  result <- DBI::dbExecute(con, chunk$sql, ...)

  result
}

qryflow_query_handler <- function(con, chunk, ...) {
  result <- DBI::dbGetQuery(con, chunk$sql, ...)

  result
}
