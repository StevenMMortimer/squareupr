## ---- echo = FALSE-------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

## ----auth, include = FALSE-----------------------------------------------
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(here)))
library(squareupr)
token_path <- here::here("tests", "testthat", "squareupr_token.rds")
suppressMessages(sq_auth(token = token_path, verbose = FALSE))

## ----load-package, eval=FALSE--------------------------------------------
#  suppressWarnings(suppressMessages(library(dplyr)))
#  library(squareupr)
#  sf_auth(personal_access_token = "sq-Th1s1sMyPers0nalAcessT0ken")

## ----other-params, eval=FALSE--------------------------------------------
#  options(squareupr.app_id = "sq0-99-thisisatest99connected33app22id")
#  options(squareupr.app_secret = "sq0-Th1s1sMyAppS3cr3t")
#  
#  sq_auth()

