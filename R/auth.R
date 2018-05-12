# Adapted from googlesheets package https://github.com/jennybc/googlesheets

# Modifications:
#  - Changed the scopes and authentication endpoints
#  - Renamed the function gs_auth to sq_auth to be consistent with package 
#    and added basic authentication handling
#  - Added basic authentication session handling functions

# Copyright (c) 2017 Jennifer Bryan, Joanna Zhao
#   
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#   
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# environment to store credentials
.state <- new.env(parent = emptyenv())

#' Log in to Square
#' 
#' Log in using a Personal Access Token or OAuth 2.0 authenticaion. OAuth does
#' not require sharing a token, but will require creating a connected app in the dashboard. 
#' Once you add the app id and secret, anytime you use \code{sq_auth} without a personal 
#' access token, then you will be directed to your default web browser, asked to sign 
#' in to your Square account, and to grant the connected app permission to pass data 
#' back to you on your behalf. By default, the oauth token credentials are cached 
#' in a file named \code{.httr-oauth-squareupr} in the current working directory.
#'
#' @importFrom httr content oauth2.0_token oauth_app oauth_endpoint
#' @param personal_access_token Square
#' @param token optional; an actual OAuth 2.0 token object or the path to a valid token
#'   stored as an \code{.rds} file
#' @param app_id,app_secret,callback_url the "App Id","App Secret", and "Callback URL" 
#' when using a connected app. NOTE: You must setup your own connected app and supply 
#' these arguments.
#' @param cache logical or character; TRUE means to cache using the default cache 
#' file \code{.httr-oauth-squareupr}, FALSE means don't cache. A string means use 
#' the specified path as the cache file.
#' @template verbose
#' @examples
#' \dontrun{
#' # log in using personal access token
#' sq_auth(personal_access_token = "ThisIsATestToken") 
#' 
#' # log in using OAuth 2.0
#' # Via brower or refresh of .httr-oauth-squareupr
#' sq_auth()
#' 
#' # Save token and log in using it
#' saveRDS(.state$token, "token.rds")
#' sq_auth(token = "token.rds")
#' }
#' @export
sq_auth <- function(personal_access_token = NULL,
                    token = NULL,
                    app_id = getOption("squareupr.app_id"),
                    app_secret = getOption("squareupr.app_secret"),
                    callback_url = getOption("squareupr.callback_url"),
                    cache = getOption("squareupr.httr_oauth_cache"),
                    verbose = FALSE){
  
  if(!is.null(personal_access_token)){
    
    # personal access token authentication -------------------------------------
    # set the global .state variable
    .state$auth_method <- "Basic"
    .state$token = NULL
    .state$personal_access_token <- personal_access_token
    
  } else {
    
    # OAuth 2.0 authentication -------------------------------------------------
    if (is.null(token)) {
      sq_oauth_app <- oauth_app("square",
                                key = app_id, 
                                secret = app_secret,
                                redirect_uri = callback_url)
      sq_oauth_endpoints <- oauth_endpoint(request = NULL,
                                           base_url = sprintf("%s/oauth2", getOption("squareupr.api_base_url")),
                                           authorize = "authorize", access = "token", revoke = "revoke")
      sq_token <- oauth2.0_token(endpoint = sq_oauth_endpoints,
                                 app = sq_oauth_app, 
                                 cache = cache)
      stopifnot(is_legit_token(sq_token, verbose = TRUE))
      
      # set the global .state variable
      .state$auth_method <- "OAuth"
      .state$token <- sq_token
      .state$personal_access_token <- NULL
      
    } else if (inherits(token, "Token2.0")) {
      
      # accept token from environment ------------------------------------------
      stopifnot(is_legit_token(token, verbose = TRUE))
      
      # set the global .state variable
      .state$auth_method <- "OAuth"
      .state$token <- token
      .state$personal_access_token <- NULL
      
    } else if (inherits(token, "character")) {
      
      # accept token from file -------------------------------------------------------
      sq_token <- try(suppressWarnings(readRDS(token)), silent = TRUE)
      
      if (inherits(sq_token, "try-error")) {
        spf("Cannot read token from alleged .rds file:\n%s", token)
      } else if (!is_legit_token(sq_token, verbose = TRUE)) {
        spf("File does not contain a proper token:\n%s", token)
      }
      
      # set the global .state variable
      .state$auth_method <- "OAuth"
      .state$token <- sq_token
      .state$personal_access_token <- NULL
      
    } else {
      spf("Input provided via 'token' is neither a",
          "token,\nnor a path to an .rds file containing a token.")
    }
  }
  
  invisible(list(auth_method = .state$auth_method, 
                 token = .state$token, 
                 personal_access_token = .state$personal_access_token))
}

#' Check that token appears to be legitimate
#'
#' @keywords internal
is_legit_token <- function(x, verbose = FALSE) {
  
  if (!inherits(x, "Token2.0")) {
    if (verbose) message("Not a Token2.0 object.")
    return(FALSE)
  }
  
  if ("invalid_client" %in% unlist(x$credentials)) {
    if (verbose) {
      message("Authorization error. Please check client_id and client_secret.")
    }
    return(FALSE)
  }
  
  if ("invalid_request" %in% unlist(x$credentials)) {
    if (verbose) message("Authorization error. No access token obtained.")
    return(FALSE)
  }
  
  TRUE
  
}

#' Check that an Authorized Square Session Exists
#'
#' Before the user makes any calls requiring an authorized session, check if an 
#' OAuth token or session is not already available, call \code{\link{sq_auth}} to 
#' by default initiate the OAuth 2.0 workflow that will load a token from cache or 
#' launch browser flow. Return the bare token. Use
#' \code{sq_access_token()} to reveal the actual access token, suitable for use
#' with \code{curl}.
#'
#' @importFrom lubridate ymd_hms
#' @template verbose
#' @return a \code{Token2.0} object (an S3 class provided by \code{httr}) or a 
#' a character string of the sessionId element of the current authorized 
#' API session
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
sq_auth_check <- function(verbose = FALSE) {
  if (!token_available(verbose) & !personal_access_token_available(verbose)) {
    # not auth'ed at all before a call that requires auth, so
    # start up the OAuth 2.0 workflow that should work seamlessly
    # if a cached file exists
    sq_auth(verbose = verbose)
    res <- .state$token
  } else if(token_available(verbose)) {
    expires_at_timestamp <- as.numeric(ymd_hms(.state$token$credentials$expires_at))
    nows_timestamp <- as.numeric(Sys.time())
    time_diff <- nows_timestamp - expires_at_timestamp
    if(time_diff > 0){
      # TODO: must be better way to validate the token.
      sq_auth_refresh(verbose = verbose)
    }
    res <- .state$token
  } else if(personal_access_token_available(verbose)) {
    res <- .state$personal_access_token
  } else {
    # somehow we've got a token and session id, just return the token
    res <- .state$token
  }
  invisible(res)
}

#' Refresh an existing Authorized Square Token
#'
#' Force the current OAuth to refresh. This is only needed for times when you 
#' load the token from outside the current working directory, it is expired, and 
#' you're running in non-interactive mode.
#'
#' @template verbose
#' @return a \code{Token2.0} object (an S3 class provided by \code{httr}) or a 
#' a character string of the personal access token of the current authorized 
#' API session
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
sq_auth_refresh <- function(verbose = FALSE) {
  if(token_available(verbose)){

    # token renew
    httr_url <- sprintf("%s/oauth2/clients/%s/access-token/renew", 
                        getOption("squareupr.api_base_url"),
                        getOption("squareupr.app_id"))
    
    if(verbose) message(httr_url)         
               
    httr_response <- POST(httr_url,
                          add_headers(Authorization = sprintf("Client %s", .state$token$app$secret), 
                                      Accept = "application/json"),
                          body = list(access_token = .state$token$credentials$access_token), 
                          encode = "json")
    response_parsed <- content(httr_response, "parsed")
    .state$token$credentials <- response_parsed
  } else {
    message("No token found. sq_auth_refresh() only refreshes OAuth tokens")
  }
  invisible(.state$token)
}

#' Check personal_access_token availability
#'
#' Check if a personal_access_token is available in \code{\link{squareupr}}'s internal
#' \code{.state} environment.
#'
#' @return logical
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
personal_access_token_available <- function(verbose = TRUE) {
  if (is.null(.state$personal_access_token)) {
    if (verbose) {
      message("The personal_access_token is NULL in squareupr's internal .state environment. ", 
              "This can occur if the user is authorized using OAuth 2.0, which doesn't ", 
              "require a personal_access_token, or the user is not yet performed any authorization ", 
              "routine.\n",
              "When/if needed, 'squareupr' will initiate authentication ",
              "and authorization.\nOr run sq_auth() to trigger this explicitly.")
    }
    return(FALSE)
  }
  TRUE
}

#' Check token availability
#'
#' Check if a token is available in \code{\link{squareupr}}'s internal
#' \code{.state} environment.
#'
#' @return logical
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
token_available <- function(verbose = TRUE) {
  if (is.null(.state$token)) {
    if (verbose) {
      if (file.exists(".httr-oauth-squareupr")) {
        message("A '.httr-oauth-squareupr' file exists in current working ",
                "directory.\nWhen/if needed, the credentials cached in ",
                "'.httr-oauth-squareupr' will be used for this session.\nOr run sq_auth() ",
                "for explicit authentication and authorization.")
      } else {
        message("No '.httr-oauth-squareupr' file exists in current working directory.\n",
                "When/if needed, squareupr will initiate authentication ",
                "and authorization.\nOr run sq_auth() to trigger this explicitly.")
      }
    }
    return(FALSE)
  }
  TRUE
}

#' Return access_token attribute of OAuth 2.0 Token
#'
#' @template verbose
#' @return character; a string of the access_token element of the current token in 
#' force; otherwise NULL
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
sq_access_token <- function(verbose = FALSE) {
  if (!token_available(verbose = verbose)) return(NULL)
  .state$token$credentials$access_token
}

#' Return personal_access_token resulting from Basic auth routine
#'
#' @template verbose
#' @return character; a string of the sessionId element of the current authorized 
#' API session; otherwise NULL
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
sq_personal_access_token <- function(verbose = TRUE) {
  if (!personal_access_token_available(verbose = verbose)) return(NULL)
  .state$personal_access_token
}

#' Return either the personal_access_token or OAuth access_token
#'
#' @return character; an access token used for authorizing requests
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
sq_token <- function(){
  sq_auth_check()
  if(.state$auth_method == "OAuth"){
    res <- sq_access_token(verbose = FALSE)
  } else {
    res <- sq_personal_access_token(verbose = FALSE)
  }
  stopifnot(!is.null(res))
  return(res)
}
