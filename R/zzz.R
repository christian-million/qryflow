.onLoad <- function(libname, pkgname) {

  register_qryflow_type("exec",
                        parser = qryflow_exec_parser,
                        handler = qryflow_exec_handler,
                        overwrite = TRUE)

  register_qryflow_type("query",
                        parser = qryflow_query_parser,
                        handler = qryflow_query_handler,
                        overwrite = TRUE)

}

