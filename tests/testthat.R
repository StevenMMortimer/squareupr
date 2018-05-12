library(testthat)
suppressWarnings(suppressMessages(library(tidyverse)))
suppressWarnings(suppressMessages(library(squareupr)))

if (identical(tolower(Sys.getenv("NOT_CRAN")), "true") & 
    identical(tolower(Sys.getenv("TRAVIS_PULL_REQUEST")), "false")) {

  test_check("squareupr")
}