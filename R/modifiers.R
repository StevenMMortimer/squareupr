#' List Modifiers
#' 
#' Lists all of a location's modifier.
#' 
#' @template location
#' @template verbose
#' @return \code{tbl_df} of modifiers.
#' @details Required permissions: \code{ITEMS_READ}
#' @examples
#' \dontrun{
#' my_modifiers <- sq_list_modifiers(location)
#' }
#' @export
sq_list_modifiers <- function(location, verbose=FALSE){
  sq_list_generic_v1(endpoint="modifier-lists", location=location, verbose=verbose)
}

#TODO
# Create Modifier
# Update Modifier
# Delete Modifier