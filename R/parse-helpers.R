#' Detect the presence of a properly structured tagline
#'
#' @description
#' Checks whether a specially structured comment line if formatted in the way that
#' qryflow expects.
#'
#' @details
#' Tag lines should look like this: `-- @key: value`
#'  - Begins with an inline comment (`--`)
#'  - An `@` precedes a tag type (e.g., `type`, `name`, `query`, `exec`) and is followed by a colon (`:`)
#'  - A value is provided
#'
#' @param line A character vector to check. It is a vectorized function.
#'
#' @returns Logical. Indicating whether each line matches tag specification.
#'
#' @examples
#' a <- "-- @query: df_mtcars"
#' b <- "-- @exec: prep_tbl"
#' c <- "-- @type: query"
#'
#' lines <- c(a, b, c)
#'
#' is_tag_line(lines)
#' @export
is_tag_line <- function(line) {
  grepl("^\\s*--\\s*@[^:]+:", line)
}

#' Extract tagged metadata from a SQL chunk
#'
#' @description
#' `extract_all_tags()` scans SQL for specially formatted comment tags (e.g., `-- @tag: value`)
#' and returns them as a named list. This is exported with the intent to be useful for users
#' extending `qryflow`. It's typically used against a single SQL chunk, such as one parsed from a
#' `.sql` file.
#'
#'
#' @param text A character vector of SQL lines or a file path to a SQL script.
#' @param tags A named list of tags, typically from `extract_all_tags()`. Used in `subset_tags()`.
#' @param keep A character vector of tag names to keep or exclude in `subset_tags()`.
#' @param negate Logical; if `TRUE`, `subset_tags()` returns all tags except those listed in `keep`.
#'
#' @returns
#' - `extract_all_tags()`: A named list of all tags found in the SQL chunk.
#' - `subset_tags()`: A filtered named list of tags or `NULL` if none remain.
#'
#' @examples
#' filepath <- example_sql_path('mtcars.sql')
#' parsed <- qryflow_parse(filepath)
#'
#' chunk <- parsed[[1]]
#' tags <- extract_all_tags(chunk$sql)
#' subset_tags(tags, keep = c("query"))
#' @seealso [qryflow_parse()], [ls_qryflow_types()], [qryflow_default_type()]
#'
#' @export
extract_all_tags <- function(
  text
) {
  tag_pattern = "^\\s*--\\s*@([^:]+):\\s*(.*)$"
  lines <- read_sql_lines(text)
  taglines <- lines[is_tag_line(lines)]

  if (length(taglines) == 0) {
    return(list())
  }

  # Apply regexec
  matches <- regexec(tag_pattern, taglines)

  # Extract matches
  matched <- regmatches(taglines, matches)

  df <- as.data.frame(do.call(rbind, matched))[, 2:3]

  names(df) <- c("tag", "value")

  l <- as.list(df$value)
  names(l) <- df$tag

  return(l)
}

#' @export
#' @rdname extract_all_tags
subset_tags <- function(tags, keep, negate = FALSE) {
  nm <- names(tags)
  keep_idx <- nm %in% keep

  if (negate) {
    keep_idx <- !keep_idx
  }

  l <- tags[keep_idx]

  if (length(l) == 0) {
    return(list())
  }

  return(l)
}
