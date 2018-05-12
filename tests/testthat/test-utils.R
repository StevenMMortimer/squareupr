context("Utils")

skip("Dont Test Right Now")

test_that("testing input_data validation", {
  input_data <- 1:3
  res1a <- sq_input_data_validation(input_data)
  expect_equal(res1a, data.frame(`X1.3`=1:3, check.names = FALSE))
  res1b <- sq_input_data_validation(input_data, operation='delete')
  expect_equal(res1b, data.frame(Id=1:3))
  
  input_data <- list(1,2,3)
  res2a <- sq_input_data_validation(input_data)
  expect_equal(res2a, data.frame(`unlist(input_data)`=1:3, check.names = FALSE))
  res2b <- sq_input_data_validation(input_data, operation='delete')
  expect_equal(res2b, data.frame(Id=1:3))
  
  input_data <- c(Id=1,b=2,c=3)
  res3a <- sq_input_data_validation(input_data)
  expect_equal(res3a, data.frame(Id=1,b=2,c=3))
  res3b <- sq_input_data_validation(input_data, operation='delete')
  expect_equal(res3b, data.frame(Id=1,b=2,c=3))
  input_data <- input_data[-which(names(input_data)=="Id")]
  expect_error(sq_input_data_validation(input_data, operation='update'))
  
  input_data <- list(Id=1,b=2,c=3)
  res4a <- sq_input_data_validation(input_data)
  expect_equal(res4a, data.frame(Id=1,b=2,c=3))
  res4b <- sq_input_data_validation(input_data, operation='delete')
  expect_equal(res4b, data.frame(Id=1,b=2,c=3))
  input_data$Id <- NULL
  expect_error(sq_input_data_validation(input_data, operation='update'))
  
  input_data <- data.frame(Id=1,b=2,c=3)
  res5a <- sq_input_data_validation(input_data)
  expect_equal(res5a, input_data)
  res5b <- sq_input_data_validation(input_data, operation='delete')
  expect_equal(res5b, input_data)  
  input_data <- input_data[,c('b','c')]
  expect_error(sq_input_data_validation(input_data, operation='update'))  
})
