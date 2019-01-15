#' List Fees
#' 
#' Lists all of a location's fees.
#' 
#' @template location
#' @template verbose
#' @return \code{tbl_df} of fees
#' @details Required permissions: \code{ITEMS_READ}
#' @examples
#' \dontrun{
#' my_fees <- sq_list_fees(location)
#' }
#' @export
sq_list_fees <- function(location, verbose=FALSE){
  sq_list_generic_v1(endpoint="fees", location=location, verbose=verbose)
}

#TODO
# Create Fee
# Update Fee
# Delete Fee