test_that("qryflow_parse() returns a `qryflow` object", {
  sql <- read_sql_lines(example_sql_path('mtcars.sql'))
  parsed <- qryflow_parse(sql)
  expect_s3_class(parsed, "qryflow")
})

test_that("parse_qryflow_chunks() returns correct number of chunks", {
  sql1 <- read_sql_lines(example_sql_path('mtcars.sql'))
  sql2 <- read_sql_lines(example_sql_path('get_mtcars.sql'))

  expect_length(parse_qryflow_chunks(sql1), 4)
  expect_length(parse_qryflow_chunks(sql2), 1)
})


test_that("parse_qryflow_chunks() assigns names", {
  sql <- "SELECT * FROM mtcars;"
  nm <- names(parse_qryflow_chunks(sql))
  expect_length(nm, 1)
})


test_that("parse_qryflow_chunks() assigns unique names", {
  sql <- "SELECT * FROM mtcars;\n-- @name: unnamed_chunk_1\nSELECT * FROM mtcars;"
  nm <- names(parse_qryflow_chunks(sql))
  expect_length(unique(nm), 2)
})

test_that("parse_qryflow_chunks() errors with duplicate user-defined chunk names", {
  sql <- "-- @name: my_chunk\nSELECT * FROM mtcars;\n-- @name: my_chunk\nSELECT * FROM mtcars;"
  expect_error(parse_qryflow_chunks(sql))
})

test_that("parse_qryflow_chunks() handles no tags as 1 chunk", {
  sql <- "SELECT * FROM mtcars;\nSELECT * FROM mtcars;"
  expect_length(parse_qryflow_chunks(sql), 1)
})

test_that("parse_qryflow_chunks() handles empty chunk", {
  sql <- "-- @name: chunk1\nSELECT * FROM mtcars;\n\n-- @name: chunk2\n\n-- @name: chunk3\nSELECT * FROM mtcars;"
  expect_length(parse_qryflow_chunks(sql), 3)
  expect_equal(parse_qryflow_chunks(sql)$chunk2$sql, '')
})
