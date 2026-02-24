# qryflow_execute() inputs ####
test_that("qryflow_execute() only accepts `qryflow` object", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  sql <- read_sql_lines("sql/explicit_chunks.sql")
  expect_error(qryflow_execute(example_db_connect(), sql))
  expect_no_error(qryflow_execute(
    con,
    qryflow_parse(sql)
  ))
})

test_that("qryflow_execute() errors on invalid on_error", {
  con <- example_db_connect(mtcars)
  on.exit(DBI::dbDisconnect(con), add = TRUE)
  sql <- read_sql_lines("sql/explicit_chunks.sql")
  expect_error(qryflow_execute(
    con,
    qryflow_parse(sql),
    on_error = "IDK"
  ))
})

test_that("qryflow_execute() errors on invalid connection", {
  con <- example_db_connect(mtcars)
  DBI::dbDisconnect(con)
  sql <- read_sql_lines("sql/explicit_chunks.sql")
  expect_condition(
    qryflow_execute(
      con,
      qryflow_parse(sql)
    ),
    "'con' is not a valid connection. Has it been disconnected?"
  )
})

test_that("qryflow_execute() only accepts DBIConnection", {
  con <- ""
  sql <- read_sql_lines("sql/explicit_chunks.sql")
  expect_condition(
    qryflow_execute(
      con,
      qryflow_parse(sql)
    ),
    "'con' must be a DBI connection object from DBI::dbConnect()."
  )
})

# qryflow_execute() on_error ####

test_that("qryflow_execute() errors on_error = 'stop'", {
  con <- example_db_connect()
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  expect_condition(
    qryflow_execute(
      con,
      qryflow_parse("sql/explicit_chunks.sql"),
      on_error = "stop"
    ),
    "Chunk 'prep_cyl_6' failed with message: 'no such table: mtcars'"
  )
})

test_that("qryflow_execute() warns on_error = 'warn'", {
  con <- example_db_connect()
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  wrn <- capture_warnings(
    qryflow_execute(
      con,
      qryflow_parse("sql/explicit_chunks.sql"),
      on_error = "warn"
    )
  )

  expect_equal(wrn[1], "no such table: mtcars")
  expect_equal(wrn[2], "no such table: mtcars")
  expect_equal(wrn[3], "no such table: cyl_6")
})


test_that("qryflow_execute() errors when on_error = 'collect'", {
  con <- example_db_connect()
  on.exit(DBI::dbDisconnect(con), add = TRUE)

  err <- capture_error(
    qryflow_execute(
      con,
      qryflow_parse("sql/explicit_chunks.sql"),
      on_error = "collect"
    )
  )

  expect_equal(
    err$message,
    "3 chunks failed:\n  - prep_cyl_6: no such table: mtcars\n  - df_mtcars: no such table: mtcars\n  - df_cyl_6: no such table: cyl_6"
  )
})
