context("Utils")

test_that("sq_catch_null", {
  
  x <- 3
  expect_identical(sq_catch_null(x), x)
  
  expect_identical(sq_catch_null(NULL), NA)
  
  l <- list(x=1,y=2)
  expect_identical(sq_catch_null(l), l)
  
})
