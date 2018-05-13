#' Get Payment
#' 
#' Provides comprehensive information for a single payment.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if
#' @importFrom httr content add_headers
#' @template location
#' @template payment_id
#' @template verbose
#' @return \code{tbl_df} of a single payment 
#' @details Required permissions: \code{PAYMENTS_READ}
#' @examples
#' \dontrun{
#' our_locations <- sq_list_locations()
#' our_payments <- sq_list_payments(location = our_locations$id[1], 
#'                                  begin=Sys.Date()-1, end=Sys.Date())
#' # return just one payment                                          
#' this_payment <- sq_get_payment(location = our_locations$id[1], 
#'                                payment_id = our_payments$id[1])
#' }
#' @export
sq_get_payment <- function(location, 
                           payment_id, 
                           verbose = FALSE){

  this_location <- sq_get_location(location=location)
  
  httr_url <- sprintf("%s/v1/%s/payments/%s", 
                      getOption("squareupr.api_base_url"),
                      this_location$id[1], 
                      payment_id)
  
  if(verbose) message(httr_url)
  
  httr_response <- rGET(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                              Accept = "application/json"))
  catch_errors_connect_v1(httr_response)
  response_parsed <- content(httr_response, "parsed")
  resultset <- list(response_parsed) %>%
    map_df(~as_tibble(modify_if(., ~(length(.x) > 1 | is.list(.x)), list)))

  return(resultset)
}


#' List Payments
#'
#' Provides summary information for all payments taken by a merchant or any of 
#' the merchant's mobile staff during a date range. 
#'
#' @importFrom dplyr as_tibble bind_rows
#' @importFrom httr content add_headers
#' @importFrom lubridate as_datetime ymd_hms is.Date
#' @template location
#' @param begin_time Date or DateTime class; The beginning of the requested reporting 
#' period. The default value is one day prior at midnight local time (i.e. start of yesterday). 
#' If the value is a Date (no time component) the time is started at midnight of the date 
#' of the local timezone.
#' @param end_time Date or DateTime class; The end of the requested reporting period. 
#' The default value is today at midnight local time (i.e. start of today). If the 
#' value is a Date (no time component) the time is started at midnight of the date 
#' of the local timezone.
#' @param sort_order character; The order in which results are listed in the response 
#' (\code{ASC} for oldest first, \code{DESC} for newest first). The default value is \code{DESC}.
#' @template cursor
#' @template verbose
#' @return \code{tbl_df} of payments
#' @details Date ranges cannot exceed one year in length. When order is ASC (chronological), 
#' \code{begin_time} is inclusive and \code{end_time} is exclusive. This is the default behavior 
#' for all List endpoints. When order is DESC (reverse-chronological), \code{begin_time} 
#' is exclusive and \code{end_time} is inclusive. Required permissions: \code{PAYMENTS_READ}.
#' @examples
#' \dontrun{
#' our_locations <- sq_list_locations()
#' yesterdays_payments <- sq_list_payments(our_locations$id[1])
#' 
#' sorted_payments <- sq_list_payments(our_locations$id[1], 
#'                                     begin_time = Sys.Date() - 1, 
#'                                     end_time = Sys.Date(), 
#'                                     sort_order = "ASC")
#' # specify the time range as datetimes: 
#' #   - Beginning April 6th, 2018 at 5PM EDT                                    
#' #   - Ending April 8th, 2018 at 8AM EDT                                  
#' begin <- as.POSIXct("2018-04-06 17:00:00", tz="America/New_York")
#' end <- as.POSIXct("2018-04-08 8:00:00", tz="America/New_York")
#' custom_time_range <- sq_list_payments(our_locations$id[1], 
#'                                       begin_time = begin, 
#'                                       end_time = end)                                        
#' }
#' @export
sq_list_payments <- function(location,
                             begin_time = Sys.Date() - 1, 
                             end_time = Sys.Date(),
                             sort_order = c("DESC", "ASC"),
                             cursor = NULL,
                             verbose = FALSE){
  
  this_location <- sq_get_location(location=location)
  
  endpoint_url <- parse_url(sprintf("%s/v1/%s/payments", 
                                    getOption("squareupr.api_base_url"),
                                    this_location$id[1]))
  
  query_list <- list() 
    
  if(!is.null(cursor)){
    query_list$batch_token <- cursor
  }
  
  this_sort_order <- match.arg(sort_order)
  if(is.Date(begin_time)){
    begin_time <- ymd_hms(format(begin_time, "%Y-%m-%d 00:00:00"), 
                          tz = Sys.timezone())
  }
  if(is.Date(end_time)){
    end_time <- ymd_hms(format(end_time, "%Y-%m-%d 00:00:00"), 
                        tz = Sys.timezone())
  }
  query_list$begin_time <- format(as_datetime(begin_time), "%Y-%m-%dT%H:%M:%SZ")
  query_list$end_time <- format(as_datetime(end_time), "%Y-%m-%dT%H:%M:%SZ")
  query_list$order <- this_sort_order
  endpoint_url$query <- query_list
  
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
    this_cursor <- gsub("<(.*)\\?batch_token=(.*)&begin_time.*", "\\2", httr_response$headers$link)
    next_records <- sq_list_payments(location=location, 
                                     begin_time = begin_time, 
                                     end_time = end_time, 
                                     sort_order = this_sort_order,
                                     cursor=this_cursor)
    resultset <- bind_rows(resultset, next_records)
  }
  
  return(resultset)
}
