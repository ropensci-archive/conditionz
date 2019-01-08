context("capture_message")

test_that("capture_message", {
  foom <- function(x) {
    message("its too bad")
    return(x)
  }
  z <- capture_message(foom(4))

  expect_is(z, "list")
  expect_equal(z$value, 4)
  expect_is(z$text, "list")
  expect_named(z$text, NULL)
  expect_is(z$text[[1]], 'message')
  expect_named(z$text[[1]], c('message', 'call'))
  expect_equal(z$type, "message")
})

test_that("capture_message: no message included", {
  x <- capture_message(5)

  expect_is(x, "list")
  expect_null(x$text)
  expect_equal(x$value, 5)
})

test_that("capture_message fails well", {
  expect_error(capture_message(), "\"expr\" is missing")
})
