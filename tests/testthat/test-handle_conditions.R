context("handle_conditions")

foom <- function(x) {
  message("you gave: ", x)
  return(x)
}

foow <- function(x) {
  warning("you gave: ", x)
  return(x)
}

test_that("handle_conditions", {
  expect_message(foom('a'), "you gave:")
  expect_message(handle_conditions(foom('a')), "you gave:")
  expect_message(handle_conditions(foom('a'), "message"), "you gave:")

  # returns whatever is passed to it
  x <- handle_conditions(5)
  expect_equal(x, 5)
})

test_that("handle_messages", {
  expect_identical(
    suppressMessages(handle_conditions(foom('a'))),
    suppressMessages(handle_messages(foom('a')))
  )
})

test_that("handle_warnings", {
  expect_identical(
    suppressWarnings(handle_conditions(foow('a'), "warning")),
    suppressWarnings(handle_warnings(foow('a')))
  )
})

test_that("handle_conditions fails well", {
  expect_error(handle_conditions(), "\"expr\" is missing")
  expect_error(handle_conditions(5, "foobar"), 
    "'condition' must be one of")
  expect_error(handle_conditions(5, times = "foo"), 
    "times must be of class")
})
