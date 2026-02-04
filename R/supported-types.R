# TYPE: 'exec' ----
qryflow_exec_parser <- function(x, ...) {
  lines <- read_sql_lines(x)

  all_tags <- extract_all_tags(lines)

  name <- all_tags$name

  if (is.null(name)) {
    name <- all_tags[["exec"]]
  }

  tags <- subset_tags(all_tags, c("exec", "name", "type"), negate = TRUE)

  sql_txt <- collapse_sql_lines(lines[!is_tag_line(lines)])

  new_qryflow_chunk(type = "exec", name = name, sql = sql_txt, tags = tags)
}

qryflow_exec_handler <- function(chunk, con, ...) {
  result <- DBI::dbExecute(con, chunk$sql, ...)

  result
}

# TYPE: 'query' ----
qryflow_query_parser <- function(x, ...) {
  lines <- read_sql_lines(x)

  all_tags <- extract_all_tags(lines)

  name <- all_tags$name

  if (is.null(name)) {
    name <- all_tags[["query"]]
  }

  tags <- subset_tags(all_tags, c("query", "name", "type"), negate = TRUE)

  sql_txt <- collapse_sql_lines(lines[!is_tag_line(lines)])

  new_qryflow_chunk(type = "query", name = name, sql = sql_txt, tags = tags)
}

qryflow_query_handler <- function(chunk, con, ...) {
  result <- DBI::dbGetQuery(con, chunk$sql, ...)

  result
}
