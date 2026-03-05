# qryflow() #####
test_that("qryflow() returns list when simplify=TRUE but multiple results", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  path <- example_sql_path()

  results <- qryflow(con, path, simplify = TRUE)

  expect_type(results, "list")
})

test_that("qryflow() returns `list` when simplify=FALSE", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  path <- example_sql_path()

  results <- qryflow(con, path, simplify = FALSE)

  expect_type(results, "list")
})

test_that("When simplify=TRUE, qryflow() returns data.frame with 1 chunk", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  path <- example_sql_path("get_mtcars.sql")

  results <- qryflow(con, path, simplify = TRUE)

  expect_s3_class(results, "data.frame")
})

# qryflow_run() #####

test_that("qryflow_run() returns `qryflow`", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  path <- example_sql_path("get_mtcars.sql")

  results <- qryflow_run(con, path)

  expect_s3_class(results, "qryflow")
})

# qryflow_results() #####

test_that("qryflow_results() returns list when multiple chunks and simplify = TRUE", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  path <- example_sql_path("get_mtcars.sql")

  obj <- qryflow_run(con, path)
  results <- qryflow_results(obj, simplify = TRUE)

  expect_type(results, "list")
})

test_that("qryflow_results() returns data.frame when simplify=TRUE and 1 chunk", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  path <- example_sql_path("get_mtcars.sql")

  obj <- qryflow_run(con, path)
  results <- qryflow_results(obj, simplify = TRUE)

  expect_s3_class(results, "data.frame")
})


## Test Global Options
### qryflow.verbose
test_that("qryflow() respects qryflow.verbose global option when TRUE", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  sql <- "-- @query: result\nSELECT * FROM mtcars LIMIT 1;"

  old_verbose <- getOption("qryflow.verbose")
  on.exit(options(qryflow.verbose = old_verbose), add = TRUE)

  options(qryflow.verbose = TRUE)

  expect_message(
    qryflow(con, sql, verbose = getOption("qryflow.verbose"))
  )
})

test_that("qryflow() verbose argument overrides global option", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  sql <- "-- @query: result\nSELECT * FROM mtcars;"

  # Set global option to FALSE
  old_verbose <- getOption("qryflow.verbose")
  on.exit(options(qryflow.verbose = old_verbose), add = TRUE)

  options(qryflow.verbose = FALSE)

  expect_message(qryflow(con, sql, verbose = TRUE))
  expect_silent(qryflow(con, sql, verbose = FALSE))
})


### qryflow.default_type
test_that("qryflow_parse() respects qryflow.default_type global option", {
  sql <- "-- @name: my_chunk\nSELECT * FROM mtcars;"

  old_default_type <- getOption("qryflow.default_type")
  on.exit(options(qryflow.default_type = old_default_type), add = TRUE)

  options(qryflow.default_type = "exec")

  parsed <- qryflow_parse(sql, default_type = getOption("qryflow.default_type"))

  expect_equal(parsed[[1]]$type, "exec")
})

test_that("qryflow() default_type argument overrides global option", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  sql <- "-- @name: my_chunk\nSELECT * FROM mtcars;"

  old_default_type <- getOption("qryflow.default_type")
  on.exit(options(qryflow.default_type = old_default_type), add = TRUE)

  options(qryflow.default_type = "exec")

  result <- qryflow(con, sql, default_type = "query")

  expect_s3_class(result, "data.frame")
})
