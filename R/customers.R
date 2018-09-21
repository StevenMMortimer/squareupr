#' Get Customer
#' 
#' Returns details for a single customer.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if map_df
#' @importFrom httr content add_headers
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
  
  httr_response <- rGET(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                              Accept = "application/json"))
  catch_errors_connect_v2(httr_response)
  response_parsed <- content(httr_response, "parsed")
  resultset <- response_parsed %>%
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))
  
  return(resultset)
}

#' List Customers
#' 
#' Lists a business's customers.
#' 
#' @importFrom dplyr as_tibble bind_rows
#' @importFrom purrr modify_if map_df
#' @importFrom httr content add_headers parse_url build_url
#' @template cursor
#' @template verbose
#' @return \code{tbl_df} of customers
#' @details Required permissions: \code{CUSTOMERS_READ}. Note, The \code{ListCustomers} 
#' endpoint actually doesn't list \code{instant profiles} (profiles created via Square, 
#' not explicitly by you).
#' @examples
#' \dontrun{
#' my_customers <- sq_list_customers()
#' }
#' @export
sq_list_customers <- function(cursor = NULL,
                              verbose = FALSE){
  
  endpoint_url <- parse_url(sprintf("%s/v2/customers", 
                                    getOption("squareupr.api_base_url")))
  if(!is.null(cursor)){
    endpoint_url$query <- list(cursor = cursor)
  }
  
  httr_url <- build_url(endpoint_url)  
  
  if(verbose) message(httr_url)
  
  httr_response <- rGET(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                              Accept = "application/json"))
  catch_errors_connect_v2(httr_response)
  response_parsed <- content(httr_response, "parsed")
  resultset <- response_parsed$customers %>%
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))
  
  # check whether it has another page of records and continue to pull if so
  if(!is.null(response_parsed$cursor)){
    next_records <- sq_list_customers(cursor=response_parsed$cursor)
    resultset <- bind_rows(resultset, next_records)
  }
  
  return(resultset)
}

#' Search Customers
#' 
#' Searches the customer profiles associated with a Square account. Calling SearchCustomers 
#' without an explicit query parameter returns all customer profiles ordered alphabetically 
#' based on given_name and family_name.
#' 
#' @importFrom dplyr as_tibble bind_rows
#' @importFrom purrr modify_if map_df
#' @importFrom httr content add_headers parse_url build_url
#' @template cursor
#' @param limit integer; A limit on the number of results to be returned in a single 
#' page. The limit is advisory - the implementation may return more or fewer results. 
#' If the supplied limit is negative, zero, or is higher than the maximum limit of 
#' 1,000, it will be ignored.
#' @param query list; A list containing \code{filter} and \code{sort} elements. 
#' Calling SearchCustomers without an explicit query parameter will return all 
#' customers ordered alphabetically based on \code{given_name} and \code{family_name}.
#' @template verbose
#' @return \code{tbl_df} of customers
#' @details Required permissions: \code{CUSTOMERS_READ}
#' @examples
#' \dontrun{
#' my_customers <- sq_search_customers()
#' }
#' @export
sq_search_customers <- function(cursor = NULL, 
                                limit = NULL, 
                                query = NULL,
                                verbose = FALSE){
  
  endpoint_url <- parse_url(sprintf("%s/v2/customers/search", 
                                    getOption("squareupr.api_base_url")))
  
  body_params <- NULL
  if(!is.null(cursor)){
    body_params$cursor <- cursor
  }
  if(!is.null(limit)){
    body_params$limit <- limit
  }
  if(!is.null(query)){
    body_params$query <- query
  }
  
  httr_url <- build_url(endpoint_url)  
  
  if(verbose) message(httr_url)
  
  httr_response <- rPOST(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                               Accept = "application/json"), 
                         body = body_params, 
                         encode = 'json')
  catch_errors_connect_v2(httr_response)
  response_parsed <- content(httr_response, "parsed")
  resultset <- response_parsed$customers %>%
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))
  
  # check whether it has another page of records and continue to pull if so
  if(!is.null(response_parsed$cursor)){
    next_records <- sq_search_customers(cursor=response_parsed$cursor, 
                                        limit=limit, 
                                        query=query)
    resultset <- bind_rows(resultset, next_records)
  }
  
  return(resultset)
}

#' Create Customer
#' 
#' Creates a new customer for a business, which can have associated cards on file.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if map_df
#' @importFrom httr content add_headers
#' @template input_data
#' @template verbose
#' @return \code{tbl_df} of the created customer record
#' @details You must provide at least one of the following values in your request 
#' to this endpoint:
#' \itemize{
#'   \item \code{given_name}
#'   \item \code{family_name}
#'   \item \code{company_name}
#'   \item \code{email_address}
#'   \item \code{phone_number}
#'  }
#' This endpoint does not accept an idempotency key. If you accidentally create a 
#' duplicate customer, you can delete it with the DeleteCustomer endpoint. Required 
#' permissions: \code{CUSTOMERS_WRITE}.
#' @examples
#' \dontrun{
#' new_cust_data <- list(given_name = "API Test",
#'                       family_name = "API Test",
#'                       note = "This customer was created by the API as a test")
#' this_customer <- sq_create_customer(new_cust_data)
#' }
#' @export
sq_create_customer <- function(input_data,
                               verbose = FALSE){
  
  if(!is.list(input_data)){
    stop("The data must be provided as a list.")
  }
  if(is.null(names(input_data))){
    stop("The elements of the list must be named")
  }
  
  httr_url <- sprintf("%s/v2/customers", 
                      getOption("squareupr.api_base_url"))
  
  if(verbose) message(httr_url)
  
  httr_response <- rPOST(httr_url, 
                        add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                    Accept = "application/json"), 
                        body = input_data, 
                        encode = "json")
  catch_errors_connect_v2(httr_response)
  response_parsed <- content(httr_response, "parsed")
  resultset <- response_parsed %>%
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))
  
  return(resultset)
}


#' Delete Customer
#' 
#' Deletes a customer from a business, along with any linked cards on file.
#' 
#' @importFrom httr content add_headers
#' @template customer_id
#' @template verbose
#' @return \code{tbl_df} of a single customer
#' @details Required permissions: \code{CUSTOMERS_WRITE}
#' @examples
#' \dontrun{
#' sq_delete_customer(customer_id="ThisIsATestCustomerId")
#' }
#' @export
sq_delete_customer <- function(customer_id, 
                               verbose = FALSE){
  
  httr_url <- sprintf("%s/v2/customers/%s", 
                      getOption("squareupr.api_base_url"),
                      customer_id)
  
  if(verbose) message(httr_url)
  
  httr_response <- rDELETE(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                                 Accept = "application/json"))
  catch_errors_connect_v2(httr_response)
  return(TRUE)
}

#' Update Customer
#' 
#' Updates the details of an existing customer.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if map_df
#' @importFrom httr content add_headers
#' @template customer_id
#' @template input_data
#' @template verbose
#' @return \code{tbl_df} of the updated customer record
#' @details The ID of the customer may change if the customer has been merged 
#' into another customer. Required permissions: \code{CUSTOMERS_WRITE}
#' @examples  
#' \dontrun{
#' updated_cust_data <- list(family_name = "API Test Test Test",
#'                           note = "This customer was updated by the API as a test.")
#' updated_customer <- sq_update_customer(customer_id="ThisIsATestCustomerId",
#'                                        updated_cust_data)
#' # you can confirm the update by retrieving the customer
#' this_customer <- sq_get_customer(updated_customer$id[1])
#' }
#' @export
sq_update_customer <- function(customer_id, 
                               input_data,
                               verbose = FALSE){
  httr_url <- sprintf("%s/v2/customers/%s", 
                      getOption("squareupr.api_base_url"),
                      customer_id)
  
  if(verbose) message(httr_url)
  
  httr_response <- rPUT(httr_url, 
                         add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                     Accept = "application/json"), 
                         body = input_data, 
                         encode = "json")
  catch_errors_connect_v2(httr_response)
  response_parsed <- content(httr_response, "parsed")
  resultset <- response_parsed %>%
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))
  
  return(resultset)
}
