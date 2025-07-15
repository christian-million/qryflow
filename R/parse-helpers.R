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
#' @examples
#' a <- "-- @query: df_mtcars"
#' b <- "-- @exec: prep_tbl"
#' c <- "-- @type: query"
#'
#' lines <- c(a, b, c)
#'
#' is_tag_line(lines)
#' @export
is_tag_line <- function(line){

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
#' Additional helpers like `extract_tag()`, `extract_name()`, and `extract_type()` provide
#' convenient access to specific tag values. `subset_tags()` lets you filter or exclude tags by name.
#'
#' @details
#' The formal type of a qryflow SQL chunk is determined by `extract_type()` using a prioritized approach:
#'
#' 1. If the chunk includes an explicit `-- @type:` tag, its value is used directly as the chunk type.
#'
#' 2. If the `@type:` tag is absent, `qryflow` searches for other tags (e.g., `@query:`, `@exec:`) that
#'    correspond to registered chunk types through [ls_qryflow_types()]. The first matching tag found defines the chunk type.
#'
#' 3. If neither an explicit `@type:` tag nor any recognized tag is present, the chunk type falls back
#'    to the default type returned by [`qryflow_default_type()`].
#'
#'
#' @param text A character vector of SQL lines or a file path to a SQL script.
#' @param tag_pattern A regular expression for extracting tags. Defaults to lines in the form `-- @tag: value`.
#' @param tag A character string naming the tag to extract (used in `extract_tag()`).
#' @param tags A named list of tags, typically from `extract_all_tags()`. Used in `subset_tags()`.
#' @param keep A character vector of tag names to keep or exclude in `subset_tags()`.
#' @param negate Logical; if `TRUE`, `subset_tags()` returns all tags except those listed in `keep`.
#'
#' @return
#' - `extract_all_tags()`: A named list of all tags found in the SQL chunk.
#' - `extract_tag()`, `extract_name()`, `extract_type()`: A single tag value (character or `NULL`).
#' - `subset_tags()`: A filtered named list of tags or `NULL` if none remain.
#'
#' @examples
#' filepath <- example_sql_path('mtcars.sql')
#' parsed <- qryflow_parse(filepath)
#'
#' chunk <- parsed$chunks[[1]]
#' tags <- extract_all_tags(chunk$sql)
#'
#' extract_name(chunk$sql)
#' extract_type(chunk$sql)
#' subset_tags(tags, keep = c("query"))
#' @seealso [qryflow_parse()], [ls_qryflow_types()], [qryflow_default_type()]
#'
#' @export
extract_all_tags <- function(text, tag_pattern = "^\\s*--\\s*@([^:]+):\\s*(.*)$"){

  lines <- read_sql_lines(text)
  taglines <- lines[is_tag_line(lines)]

  if (length(taglines) == 0) {
    return(list())
  }

  # Apply regexec
  matches <- regexec(tag_pattern, taglines)

  # Extract matches
  matched <- regmatches(taglines, matches)

  df <- as.data.frame(do.call(rbind, matched))[,2:3]

  names(df) <- c("tag", "value")

  l <- as.list(df$value)
  names(l) <- df$tag

  return(l)

}

#' @export
#' @rdname extract_all_tags
extract_tag <- function(text, tag){
  x <- extract_all_tags(text)

  x[[tag]]
}

#' @export
#' @rdname extract_all_tags
extract_name <- function(text){
  extract_tag(text, "name")
}

#' @export
#' @rdname extract_all_tags
extract_type <- function(text){
  all_tags <- extract_all_tags(text)
  type <- all_tags[["type"]]

  if (is.null(type)) {

    registered_types <- ls_qryflow_types()
    tag_names <- names(all_tags)
    implicit_type_idx <- which(tag_names %in% registered_types)[1]

    if (!is.na(implicit_type_idx)) {
      type <- tag_names[implicit_type_idx]
    } else {
      type <- qryflow_default_type()
    }

  }

  return(type)

}

#' @export
#' @rdname extract_all_tags
subset_tags <- function(tags, keep, negate = FALSE){

  nm <- names(tags)
  keep_idx <- nm %in% keep

  if (negate) {
    keep_idx <- !keep_idx
  }

  l <- tags[keep_idx]

  if(length(l) == 0){
    return(list())
  }

  return(l)

}

