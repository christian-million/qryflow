.qryflow_parsers <- new.env(parent = emptyenv())

qryflow_parse_chunk <- function(chunk) {

  parser <- get_qryflow_parser(chunk$type)

  if (is.null(parser)) {
    stop(paste0("No parser registered for chunk type '", chunk$type, "'"))
  }

  parser(chunk$text)

}

get_qryflow_parser <- function(type) {

  cat(names(type))
  parser <- get(type, envir = .qryflow_parsers)

  if (is.null(parser)) {
    stop(paste0("No parser registered for chunk type '", type, "'"))
  }

  parser

}

#' Check existence of a given parser in the registry
#'
#' @description
#' Checks whether the specified parser exists in the parser registry environment.
#'
#' @param type chunk type to check (e.g., "query", "exec")
#'
#' @returns Logical. Does `type` exist in the parser registry?
#'
#' @examples
#' qryflow_parser_exists("query")
#' @seealso [qryflow_handler_exists()] for the handler equivalent.
#' @export
qryflow_parser_exists <- function(type) {

  exists(type, envir = .qryflow_parsers, inherits = FALSE)

}

#' @export
#' @rdname ls_qryflow_types
ls_qryflow_parsers <- function() {

  ls(.qryflow_parsers)

}

#' Ensure correct parser structure
#'
#' @description
#' This function checks that the passed object is a function and contains
#' the arguments "x" and "..." - in that order. This is to help ensure users
#' only register valid parsers.
#'
#' @param parser object to check
#'
#' @returns Logical. Generates an error if the object does not pass all the
#' criteria.
#'
#' @examples
#'
#' custom_func <- function(x, ...){
#'
#'   # Parsing Code Goes Here
#'
#' }
#'
#' validate_qryflow_parser(custom_func)
#' @seealso [validate_qryflow_handler()] for the handler equivalent.
#' @export
validate_qryflow_parser <- function(parser){

  if (!is.function(parser)) {
    stop("Parser must be a function.")
  }

  f_args <- names(formals(parser))

  if (!identical(f_args, c("x", "..."))) {
    stop("Parser must have arguments 'x' and '...' in that order.")
  }

  invisible(TRUE)
}

