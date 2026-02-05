#' Register custom chunk types
#'
#' @description
#' Use these functions to register the parsers and handlers
#' associated with custom types. `register_qryflow_type` is a wrapper around both
#' `register_qryflow_parser` and `register_qryflow_handler`.
#'
#' @details
#' To avoid manually registering your custom type each session, consider adding
#' the registration code to your `.Rprofile` or creating a package that leverages
#' [.onLoad()]
#'
#' @param type Character indicating the chunk type (e.g., "exec", "query")
#' @param parser A function to parse the SQL associated with the type. Must accept arguments "x" and "..." and return a `qryflow_chunk` object.
#' @param handler A function to execute the SQL associated with the type. Must accept arguments "chunk", "con", and "...".
#' @param overwrite Logical. Overwrite existing parser and handler, if exists?
#'
#' @returns Logical. Indicating whether types were successfully registered.
#'
#' @examples
#' # Create custom parser #####
#' custom_parser <- function(x, ...){
#'   # Custom parsing code will go here
#'
#'   # new_qryflow_chunk(type = "custom", name = name, sql = sql_txt, tags = tags)
#' }
#'
#' # Create custom handler #####
#' custom_handler <- function(con, chunk, ...){
#'   # Custom execution code will go here...
#'   # return(result)
#' }
#'
#' # Register Separately #####
#' register_qryflow_parser("custom", custom_parser, overwrite = TRUE)
#'
#' register_qryflow_handler("custom", custom_handler, overwrite = TRUE)
#'
#'
#' # Register Simultaneously #####
#' register_qryflow_type("query-send", custom_parser, custom_handler, overwrite = TRUE)
#' @export
register_qryflow_type <- function(type, parser, handler, overwrite = FALSE) {
  p_success <- register_qryflow_parser(type, parser, overwrite)

  h_success <- register_qryflow_handler(type, handler, overwrite)

  all(p_success, h_success)
}

#' @export
#' @rdname register_qryflow_type
register_qryflow_parser <- function(type, parser, overwrite = FALSE) {
  stopifnot(is.character(type), length(type) == 1)
  validate_qryflow_parser(parser)

  p_exists <- qryflow_parser_exists(type)

  if (p_exists && !isTRUE(overwrite)) {
    stop(
      paste0(
        "A parser for type '",
        type,
        "' is already registered. Use `overwrite = TRUE` to replace it."
      ),
      call. = FALSE
    )
  }

  assign(type, parser, envir = .qryflow_parsers)

  return(TRUE)
}

#' @export
#' @rdname register_qryflow_type
register_qryflow_handler <- function(type, handler, overwrite = FALSE) {
  stopifnot(is.character(type), length(type) == 1)
  validate_qryflow_handler(handler)

  h_exists <- qryflow_handler_exists(type)

  if (h_exists && !isTRUE(overwrite)) {
    stop(
      paste0(
        "A handler for type '",
        type,
        "' is already registered. Use `overwrite = TRUE` to replace it."
      ),
      call. = FALSE
    )
  }

  assign(type, handler, envir = .qryflow_handlers)

  return(TRUE)
}

#' List currently registered chunk types
#'
#' @description
#' Helper function to access the names of the currently registered chunk types.
#' Functions available for accessing just the parsers or just the handlers.
#'
#' @details
#' `ls_qryflow_types` is implemented to return the union of the results of
#' `ls_qryflow_parsers` and `ls_qryflow_handlers`. It's expected that a both
#' a parser and a handler exist for each type. If this assumption is violated,
#' the `ls_qryflow_types` may suggest otherwise.
#'
#' @returns Character vector of registered chunk types
#'
#' @examples
#' ls_qryflow_types()
#' @export
ls_qryflow_types <- function() {
  x <- union(ls_qryflow_parsers(), ls_qryflow_handlers())

  return(x)
}
