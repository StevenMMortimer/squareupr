context("v2 locations endpoint")

skip("Dont Test Right Now")

#squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
#options(squareupr.personal_access_token = squareupr_test_settings$personal_access_token)

test_that("sq_list_locations", {
  
  locations <- sq_list_locations()
  
  expect_is(locations, "tbl_df")
  expect_true(all(c("id", "name", "address", "merchant_id", "created_at") %in% names(locations)))
  
})

test_that("sq_get_location", {
  
  locations <- sq_list_locations()
  
  # by id ----------------------------------------------------------------------
  this_location <- sq_get_location(locations$id[1])
  expect_is(locations, "tbl_df")
  expect_true(all(c("id", "name", "address", "merchant_id", "created_at") %in% names(this_location)))
  expect_equal(nrow(this_location), 1)
  
  # by name --------------------------------------------------------------------
  this_location <- sq_get_location(locations$name[1])
  expect_is(locations, "tbl_df")
  expect_true(all(c("id", "name", "address", "merchant_id", "created_at") %in% names(this_location)))
  expect_equal(nrow(this_location), 1)
  
})
