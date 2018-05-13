#' Get Item
#' 
#' Provides the details for a single item, including associated modifier lists and fees.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if map_df
#' @importFrom httr content add_headers
#' @template location
#' @template item_id
#' @template verbose
#' @return \code{tbl_df} of a single item
#' @details Required permissions: \code{ITEMS_READ}
#' @examples
#' \dontrun{
#' this_item <- sq_get_item(location = location, 
#'                          item_id="ThisIsATestItemId")
#' }
#' @export
sq_get_item <- function(location, 
                        item_id, 
                        verbose = FALSE){
  
  this_location <- sq_get_location(location=location)

  httr_url <- sprintf("%s/v1/%s/items/%s", 
                      getOption("squareupr.api_base_url"),
                      this_location$id[1],
                      item_id)
  
  if(verbose) message(httr_url)
  
  httr_response <- rGET(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                              Accept = "application/json"))
  catch_errors_connect_v1(httr_response)
  response_parsed <- content(httr_response, "parsed")
  resultset <- list(response_parsed) %>%
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))
  
  return(resultset)
}

#' List Items
#' 
#' Provides summary information for all of a location's items.
#' 
#' @importFrom dplyr as_tibble bind_rows
#' @importFrom purrr modify_if map_df
#' @importFrom httr content add_headers parse_url build_url
#' @template location
#' @template cursor
#' @template verbose
#' @return \code{tbl_df} of items
#' @details Required permissions: \code{ITEMS_READ}
#' @examples
#' \dontrun{
#' my_items <- sq_list_items(location)
#' }
#' @export
sq_list_items <- function(location, 
                          cursor = NULL, 
                          verbose = FALSE){
  
  this_location <- sq_get_location(location=location)

  endpoint_url <- parse_url(sprintf("%s/v1/%s/items", 
                                    getOption("squareupr.api_base_url"), 
                                    this_location$id[1]))
  if(!is.null(cursor)){
    endpoint_url$query <- list(batch_token = cursor)
  }
  
  httr_url <- build_url(endpoint_url)  
  
  if(verbose) message(httr_url)
  
  httr_response <- rGET(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                              Accept = "application/json"))
  catch_errors_connect_v1(httr_response)
  response_parsed <- content(httr_response, "parsed")
  resultset <- response_parsed %>%
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))
  
  # check whether it has another page of records and continue to pull if so
  if(!is.null(httr_response$headers$link)){
    this_cursor <- gsub("<(.*)\\?batch_token=(.*).*", "\\2", httr_response$headers$link)
    next_records <- sq_list_items(location=location, 
                                  cursor=this_cursor)
    resultset <- bind_rows(resultset, next_records)
  }
  
  return(resultset)
}


#' Create Item
#' 
#' Creates an item and at least one variation for it.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if map_df
#' @importFrom httr content add_headers
#' @template location
#' @template input_data
#' @template verbose
#' @return \code{tbl_df} of the created item record
#' @details You must provide at the following fields in your request to this endpoint:
#' \itemize{
#'   \item \code{name}
#'   \item \code{variations}
#'  }
#' Required permissions: \code{ITEMS_WRITE}.
#' @examples
#' \dontrun{
#' new_item_data <- list(name = "API Test Item",
#'                       variations = list())
#' this_item <- sq_create_item(location, 
#'                             new_item_data)
#' }
#' @export
sq_create_item <- function(location, 
                           input_data,
                           verbose = FALSE){
  
  if(!is.list(input_data)){
    stop("The data must be provided as a list.")
  }
  if(is.null(names(input_data))){
    stop("The elements of the list must be named")
  }
  
  this_location <- sq_get_location(location=location)
  
  endpoint_url <- parse_url(sprintf("%s/v1/%s/items", 
                                    getOption("squareupr.api_base_url"), 
                                    this_location$id[1]))
  
  if(verbose) message(httr_url)
  
  httr_response <- rPOST(httr_url, 
                         add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                     Accept = "application/json"), 
                         body = input_data, 
                         encode = "json")
  catch_errors_connect_v1(httr_response)
  response_parsed <- content(httr_response, "parsed")
  resultset <- list(response_parsed) %>%
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))
  
  return(resultset)
}


#' Delete Item
#' 
#' Deletes an existing item and all item variations associated with it.
#' 
#' @importFrom httr content add_headers
#' @template location
#' @template item_id
#' @template verbose
#' @return \code{tbl_df} of a single item
#' @details Required permissions: \code{ITEMS_WRITE}
#' @examples
#' \dontrun{
#' sq_delete_item(item_id="ThisIsATestItemId")
#' }
#' @export
sq_delete_item <- function(location, 
                           item_id, 
                           verbose = FALSE){
  
  this_location <- sq_get_location(location=location)
  
  httr_url <- sprintf("%s/v1/%s/items/%s", 
                      getOption("squareupr.api_base_url"),
                      this_location$id[1],
                      item_id)
  
  if(verbose) message(httr_url)
  
  httr_response <- rDELETE(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                                 Accept = "application/json"))
  catch_errors_connect_v1(httr_response)
  return(TRUE)
}

#' Update Item
#' 
#' Modifies the core details of an existing item.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if map_df
#' @importFrom httr content add_headers
#' @template location
#' @template item_id
#' @template input_data
#' @template verbose
#' @return \code{tbl_df} of the updated item record
#' @details If you want to modify an item's variations, use the Update Variation 
#' endpoint instead. If you want to add or remove a modifier list from an item, 
#' use the Apply Modifier List and Remove Modifier List endpoints instead. If you 
#' want to add or remove a fee from an item, use the Apply Fee and Remove Fee 
#' endpoints instead. Required permissions: \code{ITEMS_WRITE}.
#' @examples  
#' \dontrun{
#' updated_item_data <- list(name = "API Test Test Test Item")
#' updated_item <- sq_update_item(location, 
#'                                item_id="ThisIsATestItemId",
#'                                updated_cust_data)
#' # you can confirm the update by retrieving the item
#' this_item <- sq_get_item(updated_item$id[1])
#' }
#' @export
sq_update_item <- function(item_id, 
                           input_data,
                           verbose = FALSE){
  
  this_location <- sq_get_location(location=location)
  
  httr_url <- sprintf("%s/v1/%s/items/%s", 
                      getOption("squareupr.api_base_url"),
                      this_location$id[1],
                      item_id)
  
  if(verbose) message(httr_url)
  
  httr_response <- rPUT(httr_url, 
                        add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                    Accept = "application/json"), 
                        body = input_data, 
                        encode = "json")
  catch_errors_connect_v1(httr_response)
  response_parsed <- content(httr_response, "parsed")
  resultset <- list(response_parsed) %>%
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))
  
  return(resultset)
}
