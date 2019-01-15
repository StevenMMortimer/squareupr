context("v1 fees endpoint")

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
sq_auth(squareupr_test_settings$personal_access_token)

req_fee_columns <- c("inclusion_type", "enabled", "applies_to_custom_amounts", 
                     "adjustment_type", "calculation_phase", "id", "name", "rate", "type")
our_locations <- sq_list_locations()
this_location <- our_locations$id[2]
fees <- sq_list_fees(this_location)

test_that("sq_list_fees", {
  
  expect_is(fees, "tbl_df")
  expect_named(fees, req_fee_columns)
  
})

test_that("sq_create_fee, sq_update_fee, sq_delete_fee", {
  
  # new_fee_data <- list(name = "API Test Fee",
  #                       variations = list(list(name="Small", ordinal=1), 
  #                                         list(name="Medium", ordinal=2), 
  #                                         list(name="Large", ordinal=3)))
  # this_fee <- sq_create_fee(location=this_location, new_fee_data)
  # 
  # expect_is(this_fee, "tbl_df")
  # expect_equal(this_fee$name, new_fee_data$name)
  # expect_equal(nrow(this_fee), 1)
  # 
  # updated_fee_data <- list(name = "API Test Test Test Fee")
  # updated_fee <- sq_update_fee(location = this_location, 
  #                              fee_id = this_fee$id[1],
  #                              updated_fee_data)
  # expect_is(updated_fee, "tbl_df")
  # expect_equal(updated_fee$name, updated_fee_data$name)
  # expect_equal(nrow(updated_fee), 1)
  # 
  # expect_true(sq_delete_fee(location=this_location, updated_fee$id[1]))  

})
