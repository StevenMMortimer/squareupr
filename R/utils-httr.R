# Adapted from googlesheets package https://github.com/jennybc/googlesheets

# Modifications:
#  - Added catch_errors() function

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

#' Generic implementation of HTTP methods with retries and authentication
#' 
#' @importFrom httr status_code
#' @importFrom stats runif
#' @param VERB function; an HTTP verb (e.g. GET, POST, etc.)
#' @param n integer; the number of retries
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
VERB_n <- function(VERB, n = 5) {
  function(...) {
    for (i in seq_len(n)) {
      out <- VERB(...)
      status <- status_code(out)
      if (status < 500 || i == n) break
      backoff <- runif(n = 1, min = 0, max = 2 ^ i - 1)
      ## TO DO: honor a verbose argument or option
      mess <- paste("HTTP error %s on attempt %d ...\n",
                    "  backing off %0.2f seconds, retrying")
      mpf(mess, status, i, backoff)
      Sys.sleep(backoff)
    }
    out
  }
}

#' GETs with retries and authentication
#' 
#' @importFrom httr GET
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
rGET <- VERB_n(GET)

#' POSTs with retries and authentication
#' 
#' @importFrom httr POST
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
rPOST <- VERB_n(POST)

#' PATCHs with retries and authentication
#' 
#' @importFrom httr PATCH
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
rPATCH <- VERB_n(PATCH)

#' PUTs with retries and authentication
#' 
#' @importFrom httr PUT
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
rPUT <- VERB_n(PUT)

#' DELETEs with retries and authentication
#' 
#' @importFrom httr DELETE
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
rDELETE <- VERB_n(DELETE)

## good news: these are handy and call. = FALSE is built-in
##  bad news: 'fmt' must be exactly 1 string, i.e. you've got to paste, iff
##             you're counting on sprintf() substitution
cpf <- function(...) cat(paste0(sprintf(...), "\n"))
mpf <- function(...) message(sprintf(...))
wpf <- function(...) warning(sprintf(...), call. = FALSE)
spf <- function(...) stop(sprintf(...), call. = FALSE)

#' Catches Connect v1 httr errors and prints them nicely
#' 
#' @importFrom httr http_error content
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
catch_errors_connect_v1 <- function(httr_response){
  if(http_error(httr_response)){
    response_parsed <- content(httr_response, "parsed")
    stop(sprintf("%s - %s", 
                 response_parsed$type,
                 response_parsed$message) , call. = FALSE)
  }
  return(invisible(FALSE))
}

#' Catches Connect v2 httr errors and prints them nicely
#' 
#' @importFrom httr http_error content
#' @note This function is meant to be used internally. Only use when debugging.
#' @keywords internal
#' @export
catch_errors_connect_v2 <- function(httr_response){
  if(http_error(httr_response)){
    response_parsed <- content(httr_response, "parsed")
    stop(sprintf("%s - %s", 
                 response_parsed$errors[[1]]$code,
                 response_parsed$errors[[1]]$detail) , call. = FALSE)
  }
  return(invisible(FALSE))
}