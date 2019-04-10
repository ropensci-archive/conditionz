context("ConditionKeeper: general")
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

context("ConditionKeeper: print")
test_that("ConditionKeeper: print", {
  x <- ConditionKeeper$new(times = 8)

  expect_output(x$print(), "ConditionKeeper")
  expect_output(x$print(), "id:")
  expect_output(x$print(), "times:")
  expect_output(x$print(), "messages:")
})

context("ConditionKeeper: remove")
test_that("ConditionKeeper: remove", {
  x <- ConditionKeeper$new(times = 4)

  # nothing to remove
  expect_null(x$remove())

  # add something to remove
  mssg <- "brown cow"
  x$add(mssg)

  # remove it
  z <- x$remove()
  expect_equal(z, mssg)
  ## and now x is empty
  expect_equal(length(x$bucket), 0)
})

context("ConditionKeeper: handle_conditions")
test_that("ConditionKeeper: handle_conditions", {
  x <- ConditionKeeper$new(times = 4)
  foo <- function(x) {
    message("you gave: ", x)
    return(x)
  }
  expect_message(x$handle_conditions(foo('a')), "you gave: a")
  expect_message(x$handle_conditions(foo('a')), "you gave: a")
  expect_message(x$handle_conditions(foo('a')), "you gave: a")
  expect_message(x$handle_conditions(foo('a')), "you gave: a")
  expect_message(x$handle_conditions(foo('a')), NA)
})

context("ConditionKeeper: fails well")
test_that("ConditionKeeper fails well", {
  expect_error(ConditionKeeper$new(times = "a"), 
    "times must be of class numeric, integer")
  expect_error(ConditionKeeper$new(condition = 5), 
    "condition must be of class character")
  expect_error(ConditionKeeper$new(condition = "elephant"), 
    "'condition' must be one of 'message' or 'warning'")
})
