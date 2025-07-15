parse_qryflow_chunks <- function(sql){

  statement <- read_sql_lines(sql)

  parse_qryflow_chunks_(statement)

}

parse_qryflow_chunks_ <- function(sql){

  split_chunks <- split_qryflow_chunks(sql)
  typed_chunks <- parse_qryflow_types(split_chunks)

  chunks <- list()

  for (i in seq_along(typed_chunks)) {
    chunks[[i]] <- qryflow_parse_chunk(typed_chunks[[i]])
  }

  out_chunks <- fix_chunk_names(chunks)

  names(out_chunks) <- vapply(out_chunks, function(x)x$name, character(1))

  return(out_chunks)

}

split_qryflow_chunks <- function(lines) {
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

  chunks <- list()

  for (j in seq_along(chunk_starts)) {
    start <- chunk_starts[j]
    end <- chunk_ends[j]
    chunk_lines <- lines[start:end]
    chunks[[j]] <- collapse_sql_lines(chunk_lines)
  }

  return(chunks)

}

# This function accepts the raw split chunks
# It should return a list of chunks (type, text)
parse_qryflow_types <- function(raw_chunks){

  unparsed_chunks <- list()

  for (i in seq_along(raw_chunks)) {

    chunk_lines <- read_sql_lines(raw_chunks[[i]])

    type <- extract_type(chunk_lines)

    unparsed_chunks[[i]] <- list(type = type, text = chunk_lines)

  }

  return(unparsed_chunks)

}

