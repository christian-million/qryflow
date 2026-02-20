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
    status = NULL
  )
}
