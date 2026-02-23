# subset_tags() #####
test_that("subset_tags() properly subsets existing elements", {
  x <- list(a = 1, b = 2, c = 3)
  expect_equal(subset_tags(x, c("a")), list(a = 1))
  expect_equal(subset_tags(x, c("a", "b")), list(a = 1, b = 2))
  expect_equal(subset_tags(x, c("a", "b", "c")), list(a = 1, b = 2, c = 3))
})

test_that("subset_tags() returns empty list for no matches", {
  x <- list(a = 1, b = 2, c = 3)
  expect_equal(subset_tags(x, c("d")), list())
  expect_equal(subset_tags(x, c("d", "e")), list())
  expect_equal(subset_tags(x, c("a", "b", "c"), negate = TRUE), list())
})

test_that("subset_tags() negates properly", {
  x <- list(a = 1, b = 2, c = 3)
  expect_equal(subset_tags(x, c("a"), negate = TRUE), list(b = 2, c = 3))
  expect_equal(subset_tags(x, c("a", "b"), negate = TRUE), list(c = 3))
})

test_that("subset_tags() handles empty list with empty list", {
  expect_equal(subset_tags(list(), c("a")), list())
  expect_equal(subset_tags(list(), c("a", "b"), negate = TRUE), list())
})

# is_tag_line() #####
test_that("is_tag_line() accurately indicates correct lines", {
  expect_true(is_tag_line("-- @query: value"))
  expect_true(is_tag_line("--@query:value"))
  expect_true(is_tag_line(" --@query:value"))
})

test_that("is_tag_line() accurately indicates incorrect lines", {
  expect_false(is_tag_line("-- @query value"))
  expect_false(is_tag_line("-- query:value"))
  expect_false(is_tag_line("- @query: value"))
})

# extract_all_tags() #####
test_that("extract_all_tags() returns tags", {
  sql <- "
  -- @query: mtcars
  -- @test: value
  "
  expect_equal(extract_all_tags(sql), list(query = "mtcars", test = "value"))
})

test_that("extract_all_tags() returns empty list if no tags", {
  sql <- "SELECT * FROM TABLE"
  expect_equal(extract_all_tags(sql), list())
  expect_equal(extract_all_tags(""), list())
})
