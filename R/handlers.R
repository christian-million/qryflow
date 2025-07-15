.qryflow_handlers <- new.env(parent = emptyenv())

qryflow_handle_chunk <- function(chunk, con, ...) {

  handler <- get_qryflow_handler(chunk$type)

  if (is.null(handler)) {
    stop(paste0("No handler registered for chunk type '", chunk$type, "'"))
  }

  handler(chunk, con, ...)

}

get_qryflow_handler <- function(type) {

  handler <- get(type, envir = .qryflow_handlers)

  if (is.null(handler)) {
    stop(paste0("No handler registered for chunk type '", type, "'"))
  }

  handler

}

#' Check existence of a given handler in the registry
#'
#' @description
#' Checks whether the specified handler exists in the handler registry environment.
#'
#' @param type chunk type to check (e.g., "query", "exec")
#'
#' @returns Logical. Does `type` exist in the handler registry?
#'
#' @examples
#' qryflow_handler_exists("query")
#' @seealso [qryflow_parser_exists()] for the parser equivalent.
#' @export
qryflow_handler_exists <- function(type) {

  exists(type, envir = .qryflow_handlers, inherits = FALSE)

}

#' @export
#' @rdname ls_qryflow_types
ls_qryflow_handlers <- function() {

  ls(.qryflow_handlers)

}

#' Ensure correct handler structure
#'
#' @description
#' This function checks that the passed object is a function and contains
#' the arguments "chunk", "con, and "..." - in that order. This is to help ensure users
#' only register valid handlers.
#'
#' @param handler object to check
#'
#' @returns Logical. Generates an error if the object does not pass all the
#' criteria.
#'
#' @examples
#' custom_func <- function(chunk, con, ...){
#'
#'   # Parsing Code Goes Here
#'
#' }
#'
#' validate_qryflow_handler(custom_func)
#' @seealso [validate_qryflow_parser()] for the parser equivalent.
#' @export
validate_qryflow_handler <- function(handler){

  if (!is.function(handler)) {
    stop("Handler must be a function.")
  }

  f_args <- names(formals(handler))

  if (!identical(f_args, c("chunk", "con", "..."))) {
    stop("Handler must have arguments 'chunk', 'con', '...' in that order.")
  }

  invisible(TRUE)
}

