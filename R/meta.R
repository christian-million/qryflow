#' Extract metadata from qryflow objects
#'
#' @param x `qryflow` or `qryflow_chunk` object
#'
#' @examples
#' con <- example_db_connect(mtcars)
#'
#' filepath <- example_sql_path("mtcars.sql")
#'
#' parsed <- qryflow_parse(filepath)
#' qryflow_meta(parsed)
#' qryflow_meta(parsed[[1]])
#'
#' results <- qryflow_execute(con, parsed)
#' qryflow_meta(results)
#' qryflow_meta(results[[1]])
#'
#' DBI::dbDisconnect(con)
#' @export
qryflow_meta <- function(x) {
  attr(x, "meta")
}

set_meta <- function(x, ...) {
  m <- qryflow_meta(x)
  updates <- list(...)

  for (nm in names(updates)) {
    m[[nm]] <- updates[[nm]]
  }
  attr(x, "meta") <- m
  x
}

init_meta <- function(source = NULL) {
  list(
    source = source,
    start_time = NULL,
    end_time = NULL,
    duration = NULL,
    status = "init"
  )
}

meta_time <- function() {
  Sys.time()
}

meta_duration <- function(start, end) {
  as.numeric(difftime(end, start, units = "secs"))
}

fmt_duration <- function(x) {
  if (is.null(x)) {
    return(NA_character_)
  }
  if (x < 60) {
    return(paste0(round(x, 2), "s"))
  }
  if (x < 3600) {
    return(paste0(round(x / 60, 2), "m"))
  }
  if (x < 86400) {
    return(paste0(round(x / 3600, 2), "h"))
  }

  days <- floor(x / 86400)
  remain <- x %% 86400
  hours <- floor(remain / 3600)
  minutes <- floor((remain %% 3600) / 60)

  parts <- paste0(days, "d")
  if (hours > 0) {
    parts <- paste0(parts, " ", hours, "h")
  }
  if (minutes > 0) {
    parts <- paste0(parts, " ", minutes, "m")
  }

  parts
}
