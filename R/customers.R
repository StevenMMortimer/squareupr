#' Get Customer
#' 
#' Returns details for a single customer.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if map_df
#' @importFrom httr parse_url build_url GET content
#' @template customer_id
#' @template verbose
#' @return \code{tbl_df} of a single customer
#' @details Required permissions: \code{CUSTOMERS_READ}
#' @examples
#' \dontrun{
#' this_customer <- sq_get_customer(customer_id="ThisIsATestCustomerId")
#' }
#' @export
sq_get_customer <- function(customer_id, 
                            verbose = FALSE){

  httr_url <- sprintf("%s/v2/customers/%s", 
                      getOption("squareupr.api_base_url"),
                      customer_id)
  
  if(verbose) message(httr_url)
  
  httr_response <- GET(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                             Accept = "application/json"))
  response_parsed <- content(httr_response, "parsed")
  resultset <- response_parsed %>%
    map_df(~as_tibble(modify_if(., ~length(.x) > 1, list)))
  
  return(resultset)
}

#' List Customers
#' 
#' Lists a business's customers.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if map_df
#' @importFrom httr parse_url build_url GET content
#' @template verbose
#' @return \code{tbl_df} of customers
#' @details Required permissions: \code{CUSTOMERS_READ}
#' @examples
#' \dontrun{
#' my_customers <- sq_list_customers()
#' }
#' @export
sq_list_customers <- function(verbose = FALSE){
  
  httr_url <- sprintf("%s/v2/customers", 
                      getOption("squareupr.api_base_url"))
  
  if(verbose) message(httr_url)
  
  httr_response <- GET(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                             Accept = "application/json"))
  response_parsed <- content(httr_response, "parsed")
  resultset <- response_parsed$customers %>%
    map_df(~as_tibble(modify_if(., ~length(.x) > 1, list)))
  
  return(resultset)
}
