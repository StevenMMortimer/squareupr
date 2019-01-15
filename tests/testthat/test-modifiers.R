context("v1 modifiers endpoint")

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
sq_auth(squareupr_test_settings$personal_access_token)

req_modifier_columns <- c("modifier_options", "selection_type", "id", "name")
our_locations <- sq_list_locations()
this_location <- our_locations$id[2]
modifiers <- sq_list_modifiers(this_location)

test_that("sq_list_modifiers", {
  
  expect_is(modifiers, "tbl_df")
  expect_named(modifiers, req_modifier_columns)
  
})

test_that("sq_create_modifier, sq_update_modifier, sq_delete_modifier", {
  
  # new_modifier_data <- list(name = "API Test Modifier",
  #                       variations = list(list(name="Small", ordinal=1), 
  #                                         list(name="Medium", ordinal=2), 
  #                                         list(name="Large", ordinal=3)))
  # this_modifier <- sq_create_modifier(location=this_location, new_modifier_data)
  # 
  # expect_is(this_modifier, "tbl_df")
  # expect_equal(this_modifier$name, new_modifier_data$name)
  # expect_equal(nrow(this_modifier), 1)
  # 
  # updated_modifier_data <- list(name = "API Test Test Test Modifier")
  # updated_modifier <- sq_update_modifier(location = this_location, 
  #                                        modifier_id = this_modifier$id[1],
  #                                        updated_modifier_data)
  # expect_is(updated_modifier, "tbl_df")
  # expect_equal(updated_modifier$name, updated_modifier_data$name)
  # expect_equal(nrow(updated_modifier), 1)
  # 
  # expect_true(sq_delete_modifier(location=this_location, updated_modifier$id[1]))  

})
