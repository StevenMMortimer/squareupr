#' Return the package's .state environment variable
#' 
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
squareupr_state <- function(){
  .state
}

#' Determine the host operating system
#' 
#' This function determines whether the system running the R code
#' is Windows, Mac, or Linux
#'
#' @return A character string
#' @examples
#' \dontrun{
#' get_os()
#' }
#' @seealso \url{http://conjugateprior.org/2015/06/identifying-the-os-from-r}
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
get_os <- function(){
  sysinf <- Sys.info()
  if (!is.null(sysinf)){
    os <- sysinf['sysname']
    if (os == 'Darwin'){
      os <- "osx"
    }
  } else {
    os <- .Platform$OS.type
    if (grepl("^darwin", R.version$os)){
      os <- "osx"
    }
    if (grepl("linux-gnu", R.version$os)){
      os <- "linux"
    }
  }
  unname(tolower(os))
}

#' Extract Group Membership from Customer Data
#' 
#' This function reformats the groups field of a list of customers longways (i.e. 
#' one row per customer per group).
#'
#' @importFrom dplyr mutate filter select as_tibble
#' @importFrom tidyr unnest
#' @importFrom purrr transpose map_df
#' @param customer_data \code{tbl_df} or \code{data.frame} containing an "id" and 
#' "groups" field
#' @return a \code{tbl_df} of customers and their groups
#' @examples
#' \dontrun{
#' our_customers <- sq_list_customers()
#' cust_groups <- sq_extract_cust_groups(our_customers)
#' }
#' @export
sq_extract_cust_groups <- function(customer_data){
  stopifnot(all(c("id", "groups") %in% names(customer_data)))
  
  res <- customer_data %>%
    select(id, groups) %>%
    # drop the customers with NULL groups field
    mutate(groups_cnt = sapply(customer_data$groups, length)) %>%
    filter(groups_cnt > 0) %>%
    select(id, groups) %>%
    unnest(groups) %>%
    transpose() %>%
    # convert the groups id and name into two separate columns
    map_df(~as_tibble(t(unlist(.))))
  
  return(res)
}

#' Convenience Function to Map \code{NULL} to \code{NA}
#' 
#' This function checks if a value is null and if so, returns NA. This is helpful 
#' when pulling information from lists and formatting to a \code{data.frame} structure 
#' where new rows cannot be NULL.
#'
#' @param x object; to be checked if NULL that returns NA if it is NULL
#' @return object
#' @examples
#' \dontrun{
#' sq_null_to_na(3)
#' sq_null_to_na(NULL)
#' sq_null_to_na(list(x=1, y=2))
#' }
#' @export
sq_null_to_na <- function(x){
  if(is.null(x)){
    NA
  } else {
    x
  }
}

#' List Records from Connect V1 Endpoints
#' 
#' This generic function can be used on the list endpoints of the Connect V1 API. 
#' Most endpoints have specific functions to accomodate parameters. We use this 
#' generic to create functiosn for endpoints that do not have parameters we do not 
#' care about (e.g. begin time, end time, etc.)
#'
#' @importFrom dplyr as_tibble bind_rows
#' @importFrom purrr modify_if map_df
#' @importFrom httr content add_headers parse_url build_url
#' @param endpoint character; a string that specifies which endpoint the generic 
#' method should target
#' @template location
#' @template cursor
#' @template verbose
#' @return \code{tbl_df} of records from the specified endpoint
#' @details This function and works for the following Connect V1 endpoints: 
#' items, categories, fees, discounts, modifier-lists.
#' @keywords internal
#' @examples
#' \dontrun{
#' our_locations <- sq_list_locations()
#' our_items <- sq_list_generic_v1(endpoint="items", location=our_locations$id[1])
#' }
#' @export
sq_list_generic_v1 <- function(endpoint, location, cursor=NULL, verbose=FALSE){
  
  this_location <- sq_get_location(location = location)
  
  endpoint_url <- parse_url(sprintf("%s/v1/%s/%s", 
                                    getOption("squareupr.api_base_url"), 
                                    this_location$id[1], 
                                    endpoint))
  if (!is.null(cursor)) {
    endpoint_url$query <- list(batch_token = cursor)
  }
  
  httr_url <- build_url(endpoint_url)
  
  if (verbose) 
    message(httr_url)
  
  httr_response <- rGET(httr_url, 
                        add_headers(Authorization = sprintf("Bearer %s", sq_token()),
                                    Accept = "application/json"))
  catch_errors_connect_v1(httr_response)
  response_parsed <- content(httr_response, "parsed")
  
  resultset <- response_parsed %>% 
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))
  
  if (!is.null(httr_response$headers$link)) {
    this_cursor <- gsub("<(.*)\\?batch_token=(.*).*", "\\2", 
                        httr_response$headers$link)
    next_records <- sq_list_generic_v1(endpoint=endpoint, location=location, 
                                       cursor=this_cursor, verbose=verbose)
    resultset <- bind_rows(resultset, next_records)
  }
  
  return(resultset)
}
