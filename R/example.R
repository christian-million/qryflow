#' Create an example in-memory database
#'
#' @description
#' This function creates a connection to an in-memory SQLite database, with the
#' option to add a table to the database. This function is intended to facilitate
#' examples, vignettes, and package tests.
#'
#' @param df Optional data.frame to add to the database.
#'
#' @returns connection from [DBI::dbConnect()]
#'
#' @examples
#' con <- example_db_connect(mtcars)
#'
#' x <- DBI::dbGetQuery(con, "SELECT * FROM mtcars;")
#'
#' head(x)
#'
#' DBI::dbDisconnect(con)
#' @export
example_db_connect <- function(df = NULL) {
  con <- DBI::dbConnect(RSQLite::SQLite(), dbname = ":memory:")

  if (!is.null(df)) {
    nm <- deparse(substitute(df))
    DBI::dbWriteTable(con, nm, df)
  }

  con
}

#' Get path to qryflow example SQL scripts
#'
#' @description
#' qryflow provides example SQL scripts in its `inst/sql` directory. Use this
#' function to retrieve the path to an example script. This function is intended
#' to facilitate examples, vignettes, and package tests.
#'
#' @param path filename of the example script.
#'
#' @returns path to example SQL script
#'
#' @examples
#' path <- example_sql_path("mtcars.sql")
#'
#' file.exists(path)
#' @export
example_sql_path <- function(path = "mtcars.sql") {
  system.file("sql", path, package = "qryflow", mustWork = TRUE)
}
