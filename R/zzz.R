.onLoad <- function(libname, pkgname) {
  
  op <- options()
  op.squareupr <- list(
    squareupr.personal_access_token = NULL,
    squareupr.api_base_url = "https://connect.squareup.com",
    squareupr.app_id = NULL,
    squareupr.app_secret = NULL,
    squareupr.callback_url = "http://localhost:1410/",
    squareupr.httr_oauth_cache = ".httr-oauth-squareupr"
  )
  toset <- !(names(op.squareupr) %in% names(op))
  if(any(toset)) options(op.squareupr[toset])
  
  invisible()
  
}

# store state variables in the '.state' internal environment (created in auth.R)
.state$auth_method <- NULL
.state$token <- NULL
.state$personal_access_token <- NULL
