context("capture_warning")

test_that("capture_warning", {
  foom <- function(x) {
    warning("its too bad")
    return(x)
  }
  z <- capture_warning(foom(4))

  expect_is(z, "list")
  expect_equal(z$value, 4)
  expect_is(z$text, "list")
  expect_named(z$text, NULL)
  expect_is(z$text[[1]], 'warning')
  expect_named(z$text[[1]], c('message', 'call'))
  expect_equal(z$type, "warning")
})

test_that("capture_warning: no warning included", {
  x <- capture_warning(5)

  expect_is(x, "list")
  expect_null(x$text)
  expect_equal(x$value, 5)
})

test_that("capture_warning fails well", {
  expect_error(capture_warning(), "\"expr\" is missing")
})
