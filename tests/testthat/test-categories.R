context("v1 categories endpoint")

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
sq_auth(squareupr_test_settings$personal_access_token)

req_category_columns <- c("id", "name", "v2_id")
our_locations <- sq_list_locations()
this_location <- our_locations$id[2]
categories <- sq_list_categories(this_location)

test_that("sq_list_categories", {
  
  expect_is(categories, "tbl_df")
  expect_named(categories, req_category_columns)
  
})

test_that("sq_create_category, sq_update_category, sq_delete_category", {
  
  # new_category_data <- list(name = "API Test Category",
  #                       variations = list(list(name="Small", ordinal=1), 
  #                                         list(name="Medium", ordinal=2), 
  #                                         list(name="Large", ordinal=3)))
  # this_category <- sq_create_category(location=this_location, new_category_data)
  # 
  # expect_is(this_category, "tbl_df")
  # expect_equal(this_category$name, new_category_data$name)
  # expect_equal(nrow(this_category), 1)
  # 
  # updated_category_data <- list(name = "API Test Test Test Category")
  # updated_category <- sq_update_category(location = this_location, 
  #                                        category_id = this_category$id[1],
  #                                        updated_category_data)
  # expect_is(updated_category, "tbl_df")
  # expect_equal(updated_category$name, updated_category_data$name)
  # expect_equal(nrow(updated_category), 1)
  # 
  # expect_true(sq_delete_category(location=this_location, updated_category$id[1]))  

})
