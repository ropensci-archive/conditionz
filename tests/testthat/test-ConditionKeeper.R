context("ConditionKeeper")

test_that("ConditionKeeper works", {
  x <- ConditionKeeper$new(times = 4)

  expect_is(x, "ConditionKeeper")
  expect_is(x, "R6")
  expect_equal(x$condition, "message")
  expect_equal(x$times, 4)
  expect_null(x$bucket)
  expect_is(x$get_id, "function")
  expect_is(x$handle_conditions, "function")
  expect_is(x$thrown_enough, "function")
  expect_is(x$thrown_times, "function")
  expect_is(x$not_thrown_yet, "function")
  expect_is(x$thrown_already, "function")
  expect_is(x$purge, "function")
  expect_is(x$remove, "function")
  expect_is(x$add, "function")

  expect_is(x$get_id(), "character")
  expect_is(x$add("one"), "ConditionKeeper")
  expect_is(x$add("two"), "ConditionKeeper")
  expect_equal(length(x$bucket), 2)
})

test_that("ConditionKeeper fails well", {
  expect_error(ConditionKeeper$new(times = "a"), 
    "times must be of class numeric, integer")
  expect_error(ConditionKeeper$new(condition = 5), 
    "condition must be of class character")
})
