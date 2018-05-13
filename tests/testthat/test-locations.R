context("v2 locations endpoint")

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
sq_auth(squareupr_test_settings$personal_access_token)

req_location_columns <- c("id", "name", "address", "merchant_id", "created_at")
locations <- sq_list_locations()

test_that("sq_list_locations", {
  
  expect_is(locations, "tbl_df")
  expect_true(all(req_location_columns %in% names(locations)))
  
})

test_that("sq_get_location", {
  
  # by id ----------------------------------------------------------------------
  this_location <- sq_get_location(locations$id[1])
  expect_is(locations, "tbl_df")
  expect_true(all(req_location_columns %in% names(this_location)))
  expect_equal(nrow(this_location), 1)
  
  # by name --------------------------------------------------------------------
  this_location <- sq_get_location(locations$name[1])
  expect_is(locations, "tbl_df")
  expect_true(all(c("id", "name", "address", "merchant_id", "created_at") %in% names(this_location)))
  expect_equal(nrow(this_location), 1)
  
  # not found ------------------------------------------------------------------
  expect_error(sq_get_location("sdlkjsdlk"))
  
})
