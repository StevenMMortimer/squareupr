context("v2 customers endpoint")

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
sq_auth(squareupr_test_settings$personal_access_token)

req_customer_columns <- c("id", "created_at", "updated_at", "given_name", 
                          "family_name", "preferences", "groups")
customers <- sq_list_customers()

test_that("sq_list_customers", {
  
  expect_is(customers, "tbl_df")
  expect_true(all(req_customer_columns %in% names(customers)))
  
})

test_that("sq_get_customer", {
  
  this_customer <- sq_get_customer(customers$id[1])
  expect_is(customers, "tbl_df")
  expect_true(all(req_customer_columns %in% names(this_customer)))

})
