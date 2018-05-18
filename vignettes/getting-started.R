## ---- echo = FALSE-------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

## ----other-params, eval=FALSE--------------------------------------------
#  options(squareupr.app_id = "sq0-99-thisisatest99connected33app22id")
#  options(squareupr.app_secret = "sq0-Th1s1sMyAppS3cr3t")
#  sq_auth()

## ----auth, include = FALSE-----------------------------------------------
library(tidyverse)
library(squareupr)
settings <- readRDS(here::here("tests", "testthat", "squareupr_test_settings.rds"))
suppressMessages(sq_auth(personal_access_token = settings$personal_access_token, 
                         verbose = FALSE))

## ---- eval=FALSE---------------------------------------------------------
#  library(tidyverse)
#  library(squareupr)
#  
#  # Using Personal Access Token (PAT)
#  sq_auth(personal_access_token = "sq-Th1s1sMyPers0nalAcessT0ken")
#  
#  # Using OAuth 2.0 authentication
#  sq_auth()

## ----transactions-by-location--------------------------------------------
# list all locations
our_locations <- sq_list_locations()
our_transactions <- sq_list_transactions(location = our_locations$id[2], 
                                         begin_time = as.Date('2018-05-11'), 
                                         end_time = as.Date('2018-05-12'))
our_transactions

## ----customers-----------------------------------------------------------
# list all customers
our_customers <- sq_list_customers()
our_customers$given_name <- "{HIDDEN}"
our_customers$family_name <- "{HIDDEN}"
our_customers %>% select(id, created_at, updated_at, 
                         given_name, family_name, preferences, groups)

# show the groups that each customer belongs to
# filter to the groups designated automatically by Square
sq_extract_cust_groups(our_customers) %>%
  filter(grepl("^CQ689YH4KCJMY", groups.id))

