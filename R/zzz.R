.onLoad <- function(libname, pkgname) {
  register_qryflow_type(
    "exec",
    handler = qryflow_exec_handler,
    overwrite = TRUE
  )

  register_qryflow_type(
    "query",
    handler = qryflow_query_handler,
    overwrite = TRUE
  )
}
