#' Parse a SQL workflow into tagged chunks
#'
#' `qryflow_parse()` reads a SQL workflow file or character vector and parses it into
#' discrete tagged chunks based on `@query`, `@exec`, and other custom markers.
#'
#' This function is used internally by [`qryflow_run()`], but can also be used directly to
#' preprocess or inspect the structure of a SQL workflow.
#'
#' @param sql A file path to a SQL workflow file, or a character vector containing SQL lines.
#' @param default_type The default chunk type (defaults to "query")
#'
#' @returns An object of class `qryflow_workflow`, which is a structured list of SQL chunks and
#'   metadata.
#'
#' @seealso [`qryflow()`], [`qryflow_run()`], [`qryflow_execute()`]
#'
#' @examples
#' filepath <- example_sql_path("mtcars.sql")
#'
#' parsed <- qryflow_parse(filepath)
#' @export
qryflow_parse <- function(sql, default_type = "query") {
  statement <- read_sql_lines(sql)

  chunks <- parse_qryflow_chunks(statement, default_type)

  new_qryflow(chunks = chunks, source = collapse_sql_lines(statement))
}

parse_qryflow_chunks <- function(sql, default_type = "query") {
  statement <- read_sql_lines(sql)
  split <- split_chunks(statement)
  parsed_chunks <- parse_chunks(split, default_type)

  return(parsed_chunks)
}

# Returns an unnamed list of character vectors
# Each list element is a chunk and each character represents lines
split_chunks <- function(lines) {
  # Find all lines that are tag lines
  tag_lines <- is_tag_line(lines)

  # Find the starting lines of each tag block
  chunk_starts <- c()
  in_tag_block <- FALSE

  for (i in seq_along(lines)) {
    if (tag_lines[i] && !in_tag_block) {
      chunk_starts <- c(chunk_starts, i)
      in_tag_block <- TRUE
    } else if (!tag_lines[i]) {
      in_tag_block <- FALSE
    }
  }

  # Always start from line 1 if it isn't already part of a tagged chunk
  if (length(chunk_starts) == 0 || chunk_starts[1] != 1) {
    chunk_starts <- c(1, chunk_starts)
  }

  # Calculate end points of chunks
  chunk_ends <- c(chunk_starts[-1] - 1, length(lines))

  chunks <- vector("list", length(chunk_starts))

  for (j in seq_along(chunk_starts)) {
    start <- chunk_starts[j]
    end <- chunk_ends[j]
    chunk_lines <- lines[start:end]
    chunks[[j]] <- chunk_lines
  }

  return(chunks)
}

# Parses an individual chunk
# Handle no information
parse_single_chunk <- function(chunk, default_type = "query") {
  lines <- read_sql_lines(chunk)
  all_tags <- extract_all_tags(lines)

  name <- all_tags$name
  type <- all_tags$type

  # Handle Shortcut Tags (exec, query)
  if (is.null(type)) {
    registered_types <- ls_qryflow_types()
    tags_nm <- names(all_tags)

    type <- tags_nm[which(tags_nm %in% registered_types)][1]

    if (is.null(type) || is.na(type)) {
      type <- default_type
    }
  }

  # TODO: validate type
  # TODO: user_feedback

  if (is.null(name)) {
    name <- all_tags[[type]]
  }

  # Get all tags not related to name or type
  rm_tags <- unique(c("name", "type", type))
  tags <- subset_tags(all_tags, rm_tags, negate = TRUE)

  sql_txt <- collapse_sql_lines(lines[!is_tag_line(lines)])

  list(type = type, name = name, sql = sql_txt, tags = tags)
}

parse_chunks <- function(chunks, default_type = "query") {
  src <- vector("list", length(chunks))

  for (i in seq_along(src)) {
    src[[i]] <- parse_single_chunk(chunks[[i]], default_type)
  }

  src <- resolve_chunk_names(src)

  parsed_chunks <- vector("list", length(src))

  for (i in seq_along(src)) {
    parsed_chunks[[i]] <- new_qryflow_chunk(
      type = src[[i]]$type,
      name = src[[i]]$name,
      sql = src[[i]]$sql,
      tags = src[[i]]$tags,
      meta = init_meta(source = paste0(chunks[[i]], collapse = "\n"))
    )
  }

  names(parsed_chunks) <- vapply(
    parsed_chunks,
    function(x) x$name,
    character(1)
  )

  return(parsed_chunks)
}

resolve_chunk_names <- function(chunks) {
  # Separate user-defined names from chunks needing auto-names
  user_names <- vapply(
    chunks,
    function(x) {
      #previously name_or_na
      if (is.null(x$name)) NA_character_ else x$name
    },
    character(1)
  )

  # Error on duplicate user-defined names
  defined_names <- user_names[!is.na(user_names)]
  duplicates <- defined_names[duplicated(defined_names)]
  if (length(duplicates) > 0) {
    stop(
      "Duplicate chunk names found and will overwrite each other in results: ",
      paste(unique(duplicates), collapse = ", "),
      call. = FALSE
    )
  }

  # Assign auto-names to unnamed chunks, avoiding all known names
  all_known_names <- defined_names
  auto_index <- 1

  for (i in seq_along(chunks)) {
    if (is.na(user_names[i])) {
      candidate <- paste0("unnamed_chunk_", auto_index)
      while (candidate %in% defined_names) {
        auto_index <- auto_index + 1
        candidate <- paste0("unnamed_chunk_", auto_index)
      }
      chunks[[i]]$name <- candidate
      defined_names <- c(defined_names, candidate)
      # TODO: user_feedback
      # message("Chunk ", i, " unnamed. Assigned '", candidate, "'.")
      auto_index <- auto_index + 1
    }
  }

  return(chunks)
}
