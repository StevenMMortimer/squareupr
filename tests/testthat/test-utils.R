context("Utils")

test_that("sq_null_to_na", {
  
  x <- 3
  expect_identical(sq_null_to_na(x), x)
  
  expect_identical(sq_null_to_na(NULL), NA)
  
  l <- list(x=1,y=2)
  expect_identical(sq_null_to_na(l), l)
  
})

created_start <- format(Sys.Date()-30, '%Y-%m-%dT00:00:00-00:00')
created_end <- format(Sys.Date(), '%Y-%m-%dT00:00:00-00:00')
searched_customers <- sq_search_customers(query = list(filter=
                                                         list(created_at=
                                                                list(start_at=created_start,
                                                                     end_at=created_end))))

test_that("sq_extract_cust_groups", {
  extracted_groups <- sq_extract_cust_groups(searched_customers)
  expect_is(extracted_groups, "tbl_df")
  expect_named(extracted_groups, c("id", "groups.id", "groups.name"))
})
