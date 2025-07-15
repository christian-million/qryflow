#' Standardizes lines read from string, character vector, or file
#'
#' @description
#' This is a generic function to ensure lines read from a file, a single
#' character vector, or already parsed lines return the same format. This helps
#' avoid re-reading entire texts by enabling already read lines to pass easily.
#'
#' This is useful for folks who may want to extend qryflow.
#'
#' @param x a filepath or character vector containing SQL
#'
#' @returns A `qryflow_sql` object (inherits from character) with a length equal to the number of lines read
#'
#' @examples
#' # From a file #####
#' path <- example_sql_path()
#' read_sql_lines(path)
#'
#' # From a single string #####
#' sql <- "SELECT *
#' FROM mtcars;"
#' read_sql_lines(sql)
#'
#' # From a character #####
#' lines <- c("SELECT *", "FROM mtcars;")
#' read_sql_lines(lines)
#' @export
read_sql_lines <- function(x){
  UseMethod("read_sql_lines")
}

#' Collapse SQL lines into single character
#'
#' @description
#' A thin wrapper around `paste0(x, collapse = '\\n')` to standardize the way
#' qryflow collapses SQL lines.
#'
#' @param x character vector of SQL lines
#'
#' @returns a character vector of length 1
#'
#' @examples
#' path <- example_sql_path()
#'
#' lines <- read_sql_lines(path)
#'
#' sql <- collapse_sql_lines(lines)
#' @export
collapse_sql_lines <- function(x){

  paste0(x, collapse = "\n")

}

qryflow_sql <- function(x){
  structure(x, class = "qryflow_sql")
}

#' @export
read_sql_lines.character <- function(x){

  is_file <- length(x) == 1 && file.exists(x[1])

  if (is_file) {
    lines <- readLines(x)
  } else {
    # Handles lines (character vector > 1) the same as a single character vector
    lines <- readLines(textConnection(x))
  }

  # Removes leading whitespace to avoid it chunking
  first_nonblank <- which(!grepl("^\\s*$", lines))[1]

  if (is.na(first_nonblank)) {
    first_nonblank <- 1
  }

  out <- lines[first_nonblank:length(lines)]

  qryflow_sql(out)
}

#' @export
read_sql_lines.qryflow_sql <- function(x){
  x
}

#' @export
as.character.qryflow_sql <- function(x, ...){
  collapse_sql_lines(x)
}

#' @export
print.qryflow_sql <- function(x, ...){

  cat("<qryflow_sql>\n")
  out <- collapse_sql_lines(x)
  cat(out)

}

