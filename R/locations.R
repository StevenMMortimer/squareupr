#' List Locations
#' 
#' Provides the details for all of a business's locations.
#' 
#' @importFrom dplyr as_tibble 
#' @importFrom purrr modify_if map_df
#' @importFrom httr GET content add_headers
#' @template verbose
#' @return \code{tbl_df} of locations
#' @details Most other Connect API endpoints have a required location_id path parameter. 
#' The id field of the Location objects returned by this endpoint correspond to 
#' that location_id parameter. Required permissions: \code{MERCHANT_PROFILE_READ}
#' @examples
#' \dontrun{
#' my_locations <- sq_list_locations()
#' }
#' @export
sq_list_locations <- function(verbose = FALSE){

  httr_url <- sprintf("%s/v2/locations", 
                      getOption("squareupr.api_base_url"))
  
  if(verbose) message(httr_url)
  
  httr_response <- rGET(httr_url, add_headers(Authorization = sprintf("Bearer %s", sq_token()), 
                                              Accept = "application/json"))
  response_parsed <- content(httr_response, "parsed")
  resultset <- response_parsed$locations %>%
    map_df(~as_tibble(modify_if(., ~length(.x) > 1, list)))
  
  return(resultset)
}


#' Get Location
#' 
#' Returns details for a single location.
#' 
#' @template location
#' @template verbose
#' @return \code{tbl_df} of a single location
#' @details Required permissions: \code{MERCHANT_PROFILE_READ}
#' @examples
#' \dontrun{
#' # retrieve details using the location id
#' this_location1 <- sq_get_location(location = "ThisIsATestLocationId")
#' 
#' # retrieve details using the location name
#' this_location2 <- sq_get_location(location = "My Store Name")
#' }
#' @export
sq_get_location <- function(location, verbose=FALSE){
  
  valid_locations <- sq_list_locations(verbose=verbose)
  
  if(location %in% valid_locations$id){
    result <- valid_locations[valid_locations$id == location,]
  } else if(location %in% valid_locations$name){
    result <- valid_locations[valid_locations$name == location,]
  } else {
    stop(paste(location, "is not a recognized location.",
               "Run sq_list_locations() to see a valid list of locations.", 
               "This function requires you to specify the location by an exact match to the ID or name."))
  }
  
  return(result)
}
