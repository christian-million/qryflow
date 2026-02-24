# qryflow_parse #####
test_that("qryflow_parse() errors on unknown default_type", {
  sql <- read_sql_lines(example_sql_path('mtcars.sql'))
  expect_error(qryflow_parse(sql, default_type = "unknown"))
})

test_that("qryflow_parse() returns a `qryflow` object", {
  sql <- read_sql_lines(example_sql_path('mtcars.sql'))
  parsed <- qryflow_parse(sql)
  expect_s3_class(parsed, "qryflow")
})

# qryflow_parse() resolves types ####

test_that("qryflow_parse() messages when assigning default_type", {
  sql <- "-- @name: my_chunk\nSELECT *\nFROM mtcars;"
  expect_condition(
    qryflow_parse(sql, default_type = "query"),
    "Chunk 'my_chunk' has no type. Assigned default type 'query'."
  )
  expect_condition(
    qryflow_parse(sql, default_type = "exec"),
    "Chunk 'my_chunk' has no type. Assigned default type 'exec'."
  )
})

test_that("qryflow_parse() warns when unknown type specified in SQL tag", {
  sql <- "-- @name: my_chunk\n-- @type: unknown\nSELECT *\nFROM mtcars;"
  expect_condition(
    qryflow_parse(sql),
    "Chunk 'my_chunk' has unrecognised type 'unknown'. No handler is currently registered for this type."
  )
})

# qryflow_parse() resolves chunk names ####

test_that("qryflow_parse() assigns names", {
  sql <- "SELECT * FROM mtcars;"
  nm <- names(qryflow_parse(sql))
  expect_length(nm, 1)
  expect_equal(nm, "unnamed_chunk_1")
})

test_that("qryflow_parse() assigns unique names", {
  sql <- "SELECT * FROM mtcars;\n-- @name: unnamed_chunk_1\nSELECT * FROM mtcars;"
  nm <- names(qryflow_parse(sql))
  expect_length(unique(nm), 2)
  expect_equal(nm, c('unnamed_chunk_2', 'unnamed_chunk_1'))
})

test_that("qryflow_parse() errors with duplicate user-defined chunk names", {
  sql <- "-- @name: my_chunk\nSELECT * FROM mtcars;\n-- @name: my_chunk\nSELECT * FROM mtcars;"
  expect_error(qryflow_parse(sql))
})

test_that("qryflow_parse() messages when assigning names to chunk.", {
  sql <- "SELECT * FROM mtcars;"
  expect_condition(
    qryflow_parse(sql),
    "Chunk 1 unnamed. Assigned: 'unnamed_chunk_1'."
  )
})

test_that("qryflow_parse() returns correct number of chunks", {
  sql1 <- read_sql_lines(example_sql_path('mtcars.sql'))
  sql2 <- read_sql_lines(example_sql_path('get_mtcars.sql'))

  expect_length(qryflow_parse(sql1), 4)
  expect_length(qryflow_parse(sql2), 1)
})

test_that("qryflow_parse() handles no tags as 1 chunk", {
  sql <- "SELECT * FROM mtcars;\nSELECT * FROM mtcars;"
  expect_length(qryflow_parse(sql), 1)
})

test_that("qryflow_parse() handles empty chunk", {
  sql <- "-- @name: chunk1\nSELECT * FROM mtcars;\n\n-- @name: chunk2\n\n-- @name: chunk3\nSELECT * FROM mtcars;"
  expect_length(qryflow_parse(sql), 3)
  expect_equal(qryflow_parse(sql)$chunk2$sql, '')
})

# split_lines #####

test_that("split_chunks() returns correct number of chunks", {
  sql <- read_sql_lines("sql/blocks.sql")
  expect_length(split_chunks(sql), 5)
})

test_that("split_chunks() preserves blank lines and comments between chunks", {
  sql <- read_sql_lines("sql/blocks.sql")
  sp <- split_chunks(sql)
  expect_equal(sp[[4]], c("-- @query: solo", "", "-- Starting comment"))
})

test_that("split_chunks() correctly identifies starting chunk line", {
  sql <- read_sql_lines("sql/blocks.sql")
  firsts <- vapply(split_chunks(sql), \(x) x[[1]], character(1))
  expected <- c(
    "-- @query: block1",
    "-- @query: block2",
    "-- @query: block3",
    "-- @query: solo",
    "-- @query: block5"
  )
  expect_equal(firsts, expected)
})
