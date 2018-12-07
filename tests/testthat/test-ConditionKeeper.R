context("ConditionKeeper")

test_that("ConditionKeeper", {
  x <- ConditionKeeper$new()

  expect_is(x, "ConditionKeeper")
})
