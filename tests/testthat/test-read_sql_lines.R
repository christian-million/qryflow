test_that("read_sql_lines returns class `qryflow_sql`", {
  expect_s3_class(read_sql_lines("SELECT *\nFROM TBL;"), "qryflow_sql")
  expect_s3_class(read_sql_lines(c("SELECT *", "FROM TBL;")), "qryflow_sql")
  expect_s3_class(read_sql_lines(example_sql_path()), "qryflow_sql")
})

test_that("read_sql_lines parses files correctly", {
  path <- example_sql_path("get_mtcars.sql")
  out <- c("-- @query: df_mtcars", "SELECT *", "FROM mtcars;")
  expect_equal(unclass(read_sql_lines(path)), out)
})

test_that("read_sql_lines parses characters correctly", {
  sql <- "-- @query: df_mtcars\nSELECT *\nFROM mtcars;"
  out <- c("-- @query: df_mtcars", "SELECT *", "FROM mtcars;")
  expect_equal(unclass(read_sql_lines(sql)), out)
})

test_that("read_sql_lines parses vectors correctly", {
  out <- c("-- @query: df_mtcars", "SELECT *", "FROM mtcars;")
  expect_equal(unclass(read_sql_lines(out)), out)
})


test_that("read_sql_lines parses `qryflow_sql` correctly", {
  out <- c("-- @query: df_mtcars", "SELECT *", "FROM mtcars;")
  expect_equal(read_sql_lines(out), qryflow_sql(out))
})

test_that("read_sql_lines handles empty vector", {
  expect_equal(unclass(read_sql_lines("")), "")
})

test_that("collapse_sql_lines works", {
  lines <- read_sql_lines(c("-- @query: df_mtcars", "SELECT *", "FROM mtcars;"))
  out <- "-- @query: df_mtcars\nSELECT *\nFROM mtcars;"
  expect_equal(collapse_sql_lines(lines), out)
})
