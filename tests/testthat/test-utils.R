context("Utils")

test_that("sq_null_to_na", {
  
  x <- 3
  expect_identical(sq_null_to_na(x), x)
  
  expect_identical(sq_null_to_na(NULL), NA)
  
  l <- list(x=1,y=2)
  expect_identical(sq_null_to_na(l), l)
  
})
