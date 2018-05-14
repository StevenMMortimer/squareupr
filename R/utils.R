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
#' @importFrom dplyr mutate filter_ select_ as_tibble
#' @importFrom tidyr unnest_
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
    select_("id", "groups") %>%
    # drop the customers with NULL groups field
    mutate(groups_cnt = sapply(customer_data$groups, length)) %>%
    filter_(.dots = "groups_cnt > 0") %>%
    select_("id", "groups") %>%
    unnest_("groups") %>%
    transpose() %>%
    # convert the groups id and name into two separate columns
    map_df(~as_tibble(t(unlist(.))))
  
  return(res)
}

#' Convenience Function to Map NULL to NA
#' 
#' This function checks if a value is null and if so, returns NA. This is helpful 
#' when pulling information from lists and formatting to a \code{data.frame} structure 
#' where new rows cannot be NULL.
#'
#' @param x object; to be checked if NULL that returns NA if it is NULL
#' @return object
#' @examples
#' \dontrun{
#' sq_catch_null(3)
#' sq_catch_null(NULL)
#' sq_catch_null(list(x=1, y=2))
#' }
#' @export
sq_catch_null <- function(x){
  if(is.null(x)){
    NA
  } else {
    x
  }
}
