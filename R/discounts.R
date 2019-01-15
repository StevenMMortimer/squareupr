#' List Discounts
#' 
#' Lists all of a location's discounts.
#' 
#' @template location
#' @template verbose
#' @return \code{tbl_df} of discounts
#' @details Required permissions: \code{ITEMS_READ}
#' @examples
#' \dontrun{
#' my_discounts <- sq_list_discounts(location)
#' }
#' @export
sq_list_discounts <- function(location, verbose=FALSE){
  sq_list_generic_v1(endpoint="discounts", location=location, verbose=verbose)
}

#TODO
# Create Discount
# Update Discount
# Delete Discount