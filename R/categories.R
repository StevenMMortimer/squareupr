#' List Categories
#' 
#' Lists all of a location's item categories.
#' 
#' @template location
#' @template verbose
#' @return \code{tbl_df} of categories
#' @details Required permissions: \code{ITEMS_READ}
#' @examples
#' \dontrun{
#' my_categories <- sq_list_categories(location)
#' }
#' @export
sq_list_categories <- function(location, verbose=FALSE){
  sq_list_generic_v1(endpoint="categories", location=location, verbose=verbose)
}

#TODO
# Create Category
# Update Category
# Delete Category