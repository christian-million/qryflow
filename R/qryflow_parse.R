#' Parse a SQL workflow into tagged chunks
#'
#' `qryflow_parse()` reads a SQL file or character vector and parses it into
#' discrete chunks based on `@query`, `@exec`, and other custom markers.
#'
#' This function is used internally by [`qryflow_run()`], but can also be used directly to
#' preprocess or inspect the structure of a SQL workflow.
#'
#' @param sql A file path to a SQL workflow file, or a character vector containing SQL lines.
#' @param ... Reserved for future use.
#' @param default_type The default chunk type (defaults to "query"). The global default can be set with
#'   `options(qryflow.default_type = "query")`.
#'
#' @returns An object of class `qryflow`, which is a structured list of SQL chunks and
#'   metadata.
#'
#' @seealso [`qryflow()`], [`qryflow_run()`], [`qryflow_execute()`]
#'
#' @examples
#' filepath <- example_sql_path("mtcars.sql")
#'
#' parsed <- qryflow_parse(filepath)
#' @export
qryflow_parse <- function(
  sql,
  ...,
  default_type = getOption("qryflow.default_type", "query")
) {
  statement <- read_sql_lines(sql)
  default_type <- validate_qryflow_type(default_type)

  chunks <- parse_qryflow_chunks(statement, default_type)

  new_qryflow(chunks = chunks, source = collapse_sql_lines(statement))
}

parse_qryflow_chunks <- function(sql, default_type) {
  sql <- read_sql_lines(sql)
  split <- split_chunks(sql)
  parsed_chunks <- parse_chunks(split, default_type)

  return(parsed_chunks)
}

# Returns an unnamed list of character vectors
# Each list element is a chunk and each character represents lines
split_chunks <- function(lines) {
  # Find all lines that are tag lines
  tag_lines <- is_tag_line(lines)
  breaking <- is_block_breaking(lines)
  plain_comment <- is_plain_comment(lines)

  effective_breaking <- breaking
  for (i in seq_len(length(lines))[-1L]) {
    if (plain_comment[i]) {
      effective_breaking[i] <- effective_breaking[i - 1L]
    }
  }

  prev_breaking <- c(TRUE, effective_breaking[-length(effective_breaking)])
  chunk_starts <- which(tag_lines & prev_breaking)

  if (length(chunk_starts) == 0L || chunk_starts[1L] != 1L) {
    chunk_starts <- c(1L, chunk_starts)
  }

  chunk_ends <- c(chunk_starts[-1L] - 1L, length(lines))

  chunks <- vector("list", length(chunk_starts))
  for (j in seq_along(chunk_starts)) {
    chunks[[j]] <- lines[chunk_starts[j]:chunk_ends[j]]
  }

  chunks
}

# Parses an individual chunk
# Handle no information
parse_single_chunk <- function(chunk) {
  lines <- chunk
  all_tags <- extract_all_tags(lines)

  name <- all_tags$name
  type <- parse_chunk_type(all_tags)

  if (is.null(name)) {
    name <- all_tags[[type]]
  }

  # Get all tags not related to name or type
  type_nm <- if (is.na(type)) NULL else type
  rm_tags <- unique(c("name", "type", type_nm))
  tags <- subset_tags(all_tags, rm_tags, negate = TRUE)

  body_start <- which(is_block_breaking(lines))[1L]
  body_lines <- if (is.na(body_start)) {
    character(0L)
  } else {
    lines[body_start:length(lines)]
  }
  sql_txt <- collapse_sql_lines(lines[!is_tag_line(lines)])

  list(type = type, name = name, sql = sql_txt, tags = tags)
}

parse_chunks <- function(chunks, default_type) {
  src <- lapply(chunks, parse_single_chunk)
  src <- resolve_chunks(src, default_type)

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

resolve_chunks <- function(chunks, default_type) {
  registered_types <- ls_qryflow_types()
  defined_names <- vapply(
    chunks,
    function(x) if (is.null(x$name)) NA_character_ else x$name,
    character(1)
  )

  duplicates <- defined_names[!is.na(defined_names) & duplicated(defined_names)]
  if (length(duplicates) > 0) {
    stop_qryflow(
      "Duplicate user provided chunk names found: ",
      paste(unique(duplicates), collapse = ", ")
    )
  }

  auto_index <- 1

  for (i in seq_along(chunks)) {
    notes <- character(0)
    assigned_name <- FALSE
    if (is.na(defined_names[i])) {
      candidate <- paste0("chunk_", auto_index)
      while (candidate %in% defined_names) {
        auto_index <- auto_index + 1
        candidate <- paste0("chunk_", auto_index)
      }
      chunks[[i]]$name <- candidate
      defined_names[i] <- candidate
      assigned_name <- TRUE
      auto_index <- auto_index + 1
      notes <- c(notes, paste0("name '", candidate, "'"))
    }

    type <- chunks[[i]]$type
    if (is.na(type)) {
      chunks[[i]]$type <- default_type
      notes <- c(notes, paste0("default type '", default_type, "'"))
    } else if (!type %in% registered_types) {
      warn_qryflow(paste0(
        "'",
        chunks[[i]]$name,
        "' has unrecognised type '",
        type,
        "'"
      ))
    }

    if (length(notes) > 0) {
      nm <- if (assigned_name) i else paste0("'", defined_names[i], "'")
      message_qryflow(paste0(
        "Chunk ",
        nm,
        " assigned ",
        paste(notes, collapse = " and ")
      ))
    }
  }

  return(chunks)
}

parse_chunk_type <- function(all_tags) {
  type <- all_tags$type

  # Handle Shortcut Tags (exec, query)
  if (is.null(type)) {
    registered_types <- ls_qryflow_types()
    tags_nm <- names(all_tags)

    type <- tags_nm[which(tags_nm %in% registered_types)][1]

    if (is.null(type) || is.na(type)) {
      type <- NA_character_
    }
  }
  type
}
