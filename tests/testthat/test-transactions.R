context("v2 transactions endpoint")

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
sq_auth(squareupr_test_settings$personal_access_token)

req_transaction_columns <- c("id", "location_id", "created_at", 
                             "tenders", "product", "client_id")
our_locations <- sq_list_locations()
this_location <- our_locations$id[2]
transactions <- sq_list_transactions(location = this_location,
                                     begin_time = as.Date("2018-05-11"), 
                                     end_time = as.Date("2018-05-12"))

test_that("sq_list_transactions", {
  
  expect_is(transactions, "tbl_df")
  expect_true(all(req_transaction_columns %in% names(transactions)))
  
})

test_that("sq_get_transaction", {
  
  this_transaction <- sq_get_transaction(this_location,
                                         transactions$id[1])
  expect_is(transactions, "tbl_df")
  expect_true(all(req_transaction_columns %in% names(this_transaction)))
  expect_equal(nrow(this_transaction), 1)
  
})
