context("v1 discounts endpoint")

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
sq_auth(squareupr_test_settings$personal_access_token)

req_discount_columns <- c("discount_type", "pin_required", "id", 
                          "name", "rate", "v2_id", "amount_money", "color")

our_locations <- sq_list_locations()
this_location <- our_locations$id[2]
discounts <- sq_list_discounts(this_location)

test_that("sq_list_discounts", {
  
  expect_is(discounts, "tbl_df")
  expect_named(discounts, req_discount_columns)
  
})

test_that("sq_create_discount, sq_update_discount, sq_delete_discount", {
  
  # new_discount_data <- list(name = "API Test Discount",
  #                       variations = list(list(name="Small", ordinal=1), 
  #                                         list(name="Medium", ordinal=2), 
  #                                         list(name="Large", ordinal=3)))
  # this_discount <- sq_create_discount(location=this_location, new_discount_data)
  # 
  # expect_is(this_discount, "tbl_df")
  # expect_equal(this_discount$name, new_discount_data$name)
  # expect_equal(nrow(this_discount), 1)
  # 
  # updated_discount_data <- list(name = "API Test Test Test Discount")
  # updated_discount <- sq_update_discount(location = this_location, 
  #                                        discount_id = this_discount$id[1],
  #                                        updated_discount_data)
  # expect_is(updated_discount, "tbl_df")
  # expect_equal(updated_discount$name, updated_discount_data$name)
  # expect_equal(nrow(updated_discount), 1)
  # 
  # expect_true(sq_delete_discount(location=this_location, updated_discount$id[1]))  

})
