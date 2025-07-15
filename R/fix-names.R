# Accepts a List of Chunks
fix_chunk_names <- function(x){

  chunk_names <- vapply(x, name_or_na, character(1))
  missing_idx <- which(is.na(chunk_names))
  any_missing <- length(missing_idx) > 0

  if (any_missing) {
    chunk_names[missing_idx] <- paste0("unnamed_chunk_", seq_along(missing_idx))
  }

  dup_idx <- which(duplicated(chunk_names))
  any_dups <- length(dup_idx) > 0

  if (any_dups) {
    chunk_names <- make.unique(chunk_names, sep = "_")
  }

  if (any_missing | any_dups) {

    # TODO: Only alter previously missing or duplicated
    for (i in seq_along(x)) {
      x[[i]]$name <- chunk_names[i]
    }

  }

  return(x)

}

name_or_na <- function(x){
  nm <- x$name

  if (is.null(nm) || is.na(nm)) {
    return(NA_character_)
  }

  return(nm)
}

