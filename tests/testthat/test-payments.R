context("v1 payments endpoint")

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
sq_auth(squareupr_test_settings$personal_access_token)

req_payment_columns <- c("id", "merchant_id", "created_at", 
                         "device", "total_collected_money", "processing_fee_money", 
                         "net_total_money", "tender", "refunds", "itemizations")
our_locations <- sq_list_locations()
this_location <- our_locations$id[2]
payments <- sq_list_payments(location = this_location,
                                     begin_time = as.Date("2018-05-11"), 
                                     end_time = as.Date("2018-05-12"))

test_that("sq_list_payments", {
  
  expect_is(payments, "tbl_df")
  expect_true(all(req_payment_columns %in% names(payments)))
  
})

test_that("sq_get_payment", {
  
  this_payment <- sq_get_payment(this_location,
                                 payments$id[1])
  expect_is(payments, "tbl_df")
  expect_true(all(req_payment_columns %in% names(this_payment)))
  expect_equal(nrow(this_payment), 1)
  
})
