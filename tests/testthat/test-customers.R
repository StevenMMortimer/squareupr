context("v2 customers endpoint")

squareupr_test_settings <- readRDS("squareupr_test_settings.rds")
sq_auth(squareupr_test_settings$personal_access_token)

req_customer_columns <- c("id", "created_at", "updated_at", "preferences")

listed_customers <- sq_list_customers()

created_start <- format(Sys.Date()-90, '%Y-%m-%dT00:00:00-00:00')
created_end <- format(Sys.Date(), '%Y-%m-%dT00:00:00-00:00')
searched_customers <- sq_search_customers(query = list(filter=
                                                         list(created_at=
                                                                list(start_at=created_start,
                                                                     end_at=created_end))))

test_that("sq_list_customers", {
  
  expect_is(listed_customers, "tbl_df")
  expect_true(all(req_customer_columns %in% names(listed_customers)))
  
})

test_that("sq_search_customers", {
  
  expect_is(searched_customers, "tbl_df")
  expect_true(all(req_customer_columns %in% names(searched_customers)))
  
})

test_that("sq_get_customer", {
  
  this_customer <- sq_get_customer(searched_customers$id[1])
  expect_is(this_customer, "tbl_df")
  expect_true(all(req_customer_columns %in% names(this_customer)))

})

test_that("sq_create_customer, sq_update_customer, sq_delete_customer", {
  
  new_cust_data <- list(given_name = "API Test",
                        family_name = "API Test",
                        note = "This customer was created by the API as a test")
  this_customer <- sq_create_customer(new_cust_data)
  
  expect_is(this_customer, "tbl_df")
  expect_equal(this_customer$given_name, new_cust_data$given_name)
  expect_equal(this_customer$family_name, new_cust_data$family_name)
  expect_equal(this_customer$note, new_cust_data$note)
  expect_equal(nrow(this_customer), 1)
  
  updated_cust_data <- list(family_name = "API Test Test Test",
                            note = "This customer was updated by the API as a test.")
  updated_customer <- sq_update_customer(customer_id=this_customer$id[1],
                                         updated_cust_data)
  expect_is(updated_customer, "tbl_df")
  expect_equal(updated_customer$given_name, new_cust_data$given_name)
  expect_equal(updated_customer$family_name, updated_customer$family_name)
  expect_equal(updated_customer$note, updated_customer$note)
  expect_equal(nrow(updated_customer), 1)
  
  expect_true(sq_delete_customer(updated_customer$id[1]))  
  expect_error(sq_get_customer(updated_customer$id[1]))

})
