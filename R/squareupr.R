#' \code{squareupr} package
#'
#' An R package connecting to Square REST APIs using tidy principles
#'
#' A package that connects to Square REST APIs and emphasizes the use of tidy 
#' data principles found in the tidyverse.
#' 
#' Additional material can be found in the 
#' \href{https://github.com/StevenMMortimer/squareupr}{README} on GitHub
#'
#' @docType package
#' @name squareupr
#' @importFrom dplyr %>%
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))