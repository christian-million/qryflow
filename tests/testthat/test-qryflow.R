# qryflow() #####
test_that("qryflow() returns list", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  path <- example_sql_path()

  results <- qryflow(con, path)

  expect_type(results, "list")
})

test_that("When simplify=TRUE, qryflow() returns data.frame with 1 chunk", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  path <- example_sql_path("get_mtcars.sql")

  results <- qryflow(con, path)

  expect_s3_class(results, "data.frame")
})

# qryflow_run() #####

test_that("qryflow_run() returns `qryflow_results`", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  path <- example_sql_path("get_mtcars.sql")

  results <- qryflow_run(con, path)

  expect_s3_class(results, "qryflow_result")
})

# qryflow_results() #####

test_that("qryflow_results() returns list", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  path <- example_sql_path("get_mtcars.sql")

  obj <- qryflow_run(con, path)
  results <- qryflow_results(obj)

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
