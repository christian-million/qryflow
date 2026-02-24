test_that("register_qryflow_type() returns true on success", {
  h <- function(con, chunk, ...) {}
  expect_true(register_qryflow_type("test", h, TRUE))
})

test_that("register_qryflow_type() errors on invalid handler type", {
  h <- 1
  expect_condition(
    register_qryflow_type("test", h, TRUE),
    "Handler must be a function."
  )
})

test_that("register_qryflow_type() errors on invalid handler args", {
  h <- function(chunk, con, ...) {}
  expect_condition(
    register_qryflow_type("test", h, TRUE),
    "Handler must have arguments 'con', 'chunk', '...' in that order."
  )
})

test_that("register_qryflow_type() errors on non-overwrite registration", {
  h <- function(con, chunk, ...) {}
  expect_condition(
    register_qryflow_type("query", h, FALSE),
    "A handler for type 'query' is already registered. Use `overwrite = TRUE` to replace it."
  )
})
