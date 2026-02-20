test_that("qryflow_handler_exists() returns logical", {
  expect_true(qryflow_handler_exists("query"))
})

test_that("validate_qryflow_handler() passes valid function", {
  x <- function(con, chunk, ...) {}
  expect_true(validate_qryflow_handler(x))
})

test_that("validate_qryflow_handler() errors on improper order", {
  x <- function(chunk, con, ...) {}
  expect_error(validate_qryflow_handler(x))
})

test_that("validate_qryflow_handler() errors if not function", {
  x <- list()
  expect_error(validate_qryflow_handler(x))
})
