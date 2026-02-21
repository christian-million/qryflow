#' Register custom chunk types
#'
#' @description
#' Use this function to register a custom chunk type with qryflow
#'
#' @details
#' To avoid manually registering your custom type each session, consider adding
#' the registration code to your `.Rprofile` or creating a package that leverages
#' [.onLoad()]
#'
#' @param type Character indicating the chunk type (e.g., "exec", "query")
#' @param handler A function to execute the SQL associated with the type. Must accept arguments "chunk", "con", and "...".
#' @param overwrite Logical. Overwrite existing handler, if exists?
#'
#' @returns Logical. Indicating whether types were successfully registered.
#'
#' @examples
#' # Create custom handler #####
#' custom_handler <- function(con, chunk, ...){
#'   # Custom execution code will go here...
#'   # return(result)
#' }
#'
#' register_qryflow_type("query-send", custom_handler, overwrite = TRUE)
#'
#' @export
register_qryflow_type <- function(type, handler, overwrite = FALSE) {
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
#'
#' @returns Character vector of registered chunk types
#'
#' @examples
#' ls_qryflow_types()
#' @export
ls_qryflow_types <- function() {
  x <- ls(.qryflow_handlers)

  return(x)
}
