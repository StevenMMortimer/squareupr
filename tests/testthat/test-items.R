context("v1 items endpoint")

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
sq_auth(squareupr_test_settings$personal_access_token)

req_item_columns <- c("id", "name", "description", "variations", "fees", 
                      "category_id", "category")
our_locations <- sq_list_locations()
this_location <- our_locations$id[2]
items <- sq_list_items(this_location)

test_that("sq_list_items", {
  
  expect_is(items, "tbl_df")
  expect_true(all(req_item_columns %in% names(items)))
  
})

test_that("sq_get_item", {
  
  this_item <- sq_get_item(location=this_location, 
                           items$id[1])
  expect_is(this_item, "tbl_df")
  expect_true(all(req_item_columns %in% names(this_item)))

})

test_that("sq_create_item, sq_update_item, sq_delete_item", {
  
  # new_item_data <- list(name = "API Test Item",
  #                       variations = list(list(name="Small", ordinal=1), 
  #                                         list(name="Medium", ordinal=2), 
  #                                         list(name="Large", ordinal=3)))
  # this_item <- sq_create_item(location=this_location, new_item_data)
  # 
  # expect_is(this_item, "tbl_df")
  # expect_equal(this_item$name, new_item_data$name)
  # expect_equal(nrow(this_item), 1)
  # 
  # updated_item_data <- list(name = "API Test Test Test Item")
  # updated_item <- sq_update_item(location=this_location, item_id=this_item$id[1],
  #                                updated_item_data)
  # expect_is(updated_item, "tbl_df")
  # expect_equal(updated_item$name, updated_item_data$name)
  # expect_equal(nrow(updated_item), 1)
  # 
  # expect_true(sq_delete_item(location=this_location, updated_item$id[1]))  
  # expect_error(sq_get_item(location=this_location, updated_item$id[1]))

})
