test_that("example_db_connect returns a valid DBI connection", {
  skip_if_not_installed("RSQLite")
  con <- example_db_connect()
  expect_s4_class(con, "SQLiteConnection")
  DBI::dbDisconnect(con)
})

test_that("example_db_connect writes the data.frame to the DB with the correct name", {
  skip_if_not_installed("RSQLite")
  test_df <- data.frame(x = 1:3, y = letters[1:3])
  con <- example_db_connect(test_df)

  # Use deparse(substitute(df)) logic: the table should be named "test_df"
  tables <- DBI::dbListTables(con)
  expect_true("test_df" %in% tables)

  # Check contents
  res <- DBI::dbReadTable(con, "test_df")
  expect_equal(res, test_df)

  DBI::dbDisconnect(con)
})

test_that("example_db_connect with NULL returns empty in-memory DB", {
  skip_if_not_installed("RSQLite")
  con <- example_db_connect(NULL)
  tables <- DBI::dbListTables(con)
  expect_length(tables, 0)
  DBI::dbDisconnect(con)
})


test_that("example_sql_path returns valid path for existing file", {
  path <- example_sql_path("mtcars.sql")

  expect_type(path, "character")
  expect_true(file.exists(path))
})
