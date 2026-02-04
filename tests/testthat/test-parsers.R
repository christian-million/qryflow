test_that("qryflow_parser_exists() returns logical", {
  expect_true(qryflow_parser_exists("query"))
})

test_that("ls_qryflow_parsers() returns supported types", {
  x <- ls_qryflow_parsers()
  expect_in(x, c("query", "exec"))
})

test_that("validate_qryflow_parser() passes valid function", {
  x <- function(x, ...) {}
  expect_true(validate_qryflow_parser(x))
})

test_that("validate_qryflow_parser() errors on improper order", {
  x <- function(..., x) {}
  expect_error(validate_qryflow_parser(x))
})

test_that("validate_qryflow_parser() errors if not function", {
  x <- list()
  expect_error(validate_qryflow_parser(x))
})
