#' Get Transaction
#' 
#' Retrieves details for a single transaction.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if
#' @importFrom httr content add_headers
#' @template location
#' @template transaction_id
#' @template verbose
#' @return \code{tbl_df} of a single transaction 
#' @details Required permissions: \code{PAYMENTS_READ}
#' @examples
#' \dontrun{
#' my_locations <- sq_list_locations()
#' this_transaction <- sq_get_transaction(location = my_locations$id[1], 
#'                                        transaction_id = "ThisIsATestTransactionId")
#' }
#' @export
sq_get_transaction <- function(location, 
                               transaction_id, 
                               verbose = FALSE){

  this_location <- sq_get_location(location=location)
  
  httr_url <- sprintf("%s/v2/locations/%s/transactions/%s", 
                      getOption("squareupr.api_base_url"),
                      location_id, 
                      transaction_id)
  
  if(verbose) message(httr_url)
  
  httr_response <- rGET(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                              Accept = "application/json"))
  response_parsed <- content(httr_response, "parsed")
  resultset <- response_parsed %>%
    map_df(~as_tibble(modify_if(., ~length(.x) > 1, list)))
  
  return(resultset)
}


#' #' List Transactions
#' #' 
#' #' Lists transactions for a particular location.
#' #' 
#' #' @importFrom dplyr as_tibble
#' #' @importFrom httr content add_headers
#' #' @template location
#' #' @template verbose
#' #' @return \code{tbl_df} of transactions
#' #' @details Transactions include payment information from sales and exchanges and 
#' #' refund information from returns and exchanges.
#' #' 
#' #' Max results per page: 50
#' #' 
#' #' Required permissions: \code{PAYMENTS_READ}
#' #' @examples
#' #' \dontrun{
#' #' my_transactions <- sq_list_transactions()
#' #' }
#' #' @export
#' sq_list_transactions <- function(location, 
#'                                  verbose = FALSE){
#'   
#' }
