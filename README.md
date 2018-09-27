
squareupr<img src="man/figures/squareupr.png" width="120px" align="right" />
============================================================================

[![Build Status](https://travis-ci.org/StevenMMortimer/squareupr.svg?branch=master)](https://travis-ci.org/StevenMMortimer/squareupr) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/StevenMMortimer/squareupr?branch=master&svg=true)](https://ci.appveyor.com/project/StevenMMortimer/squareupr) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/squareupr)](http://cran.r-project.org/package=squareupr) [![Coverage Status](https://codecov.io/gh/StevenMMortimer/squareupr/branch/master/graph/badge.svg)](https://codecov.io/gh/StevenMMortimer/squareupr?branch=master)

**squareupr** is an R package that connects to the Square APIs (Connect v1 & v2).

-   OAuth 2.0 (Single sign-on) and Personal Access Token Authentication methods (`sq_auth()`)
-   v2 Locations Endpoint (`sq_list_locations()`, `sq_get_location()`)
-   v2 Transactions Endpoint (`sq_list_transactions()`, `sq_get_transaction()`)
-   v2 Customers Endpoint - CRUD (Create, Retrieve, Update, Delete) methods for customers with:
    -   `sq_list_customers()`, `sq_search_customers()`, `sq_get_customer()`, `sq_create_customer()`, `sq_update_customer()`, `sq_delete_customer()`
-   v1 Payments Endpoint (`sq_list_payments()`, `sq_get_payment()`)
-   v1 Items Endpoint - CRUD (Create, Retrieve, Update, Delete) methods for items with:
    -   `sq_list_items()`, `sq_get_item()`, `sq_create_item()`, `sq_update_item()`, `sq_delete_item()`

Table of Contents
-----------------

-   [Installation](#installation)
-   [Usage](#usage)
    -   [Authenticate](#authenticate)
    -   [Transactions](#transactions)
    -   [Customers](#customers)
-   [Credits](#credits)
-   [More Information](#more-information)

Installation
------------

``` r
# This package is not yet available on CRAN so you must install from GitHub
# install.packages("devtools")
devtools::install_github("StevenMMortimer/squareupr")
```

If you encounter a clear bug, please file a minimal reproducible example on [GitHub](https://github.com/StevenMMortimer/squareupr/issues).

Usage
-----

### Authenticate

First, load the **squareupr** package and authenticate. There are two ways to authenticate:

1.  Personal Access Token
2.  OAuth 2.0

``` r
library(tidyverse)
library(squareupr)

# Using Personal Access Token (PAT)
sq_auth(personal_access_token = "sq-Th1s1sMyPers0nalAcessT0ken")

# Using OAuth 2.0 authentication
sq_auth()
```

NOTE: Before using OAuth 2.0 authentication it is necessary that you set up your own Connected App in the Square dashboard. An App ID and App Secret will be provided, then you will be able to plug into your script like so:

``` r
options(squareupr.app_id = "sq0-99-thisisatest99connected33app22id")
options(squareupr.app_secret = "sq0-Th1s1sMyAppS3cr3t")
sq_auth()
```

OAuth 2.0 credentials will be cached locally in a file entitled `".httr-oauth-squareupr"` in the current working directory so that a new token is not needed each session.

### Transactions

Transactions are organized by location. With the v2 Locations endpoint you can pull information regarding all locations first to obtain the location IDs. Then with the `sq_list_transactions()` function you can provide the location and timeframe to search. The function defaults to pulling transactions from the previous day using `Sys.Date() - 1`. Once you obtain the transactions the `tenders` field lists all methods of payment used to pay in the transaction.

``` r
# list all locations
our_locations <- sq_list_locations()
our_transactions <- sq_list_transactions(location = our_locations$id[2], 
                                         begin_time = as.Date('2018-05-11'), 
                                         end_time = as.Date('2018-05-12'))
our_transactions
#> # A tibble: 245 x 6
#>    id          location_id  created_at    tenders product client_id       
#>    <chr>       <chr>        <chr>         <list>  <chr>   <chr>           
#>  1 bUjFGVjBvN… DRDCJ2X8E2P… 2018-05-12T0… <list … REGIST… D5528FBA-E5DE-4…
#>  2 5PZP31N5Zs… DRDCJ2X8E2P… 2018-05-11T2… <list … REGIST… A3A1FF51-325A-4…
#>  3 BTrGydD6he… DRDCJ2X8E2P… 2018-05-11T2… <list … REGIST… 2B3D32EB-8E58-4…
#>  4 XsqOAHl68z… DRDCJ2X8E2P… 2018-05-11T2… <list … REGIST… C50AF3D7-BE32-4…
#>  5 vmLRzrwByS… DRDCJ2X8E2P… 2018-05-11T2… <list … REGIST… 52E40E1B-2333-4…
#>  6 pTbzQApZW7… DRDCJ2X8E2P… 2018-05-11T2… <list … REGIST… 962766FF-1436-4…
#>  7 lnE20zklpP… DRDCJ2X8E2P… 2018-05-11T2… <list … REGIST… A02191CC-9AC9-4…
#>  8 DSumrqQW0L… DRDCJ2X8E2P… 2018-05-11T2… <list … REGIST… 1135FF4F-9B89-4…
#>  9 tPwFXetIwe… DRDCJ2X8E2P… 2018-05-11T2… <list … REGIST… 0D95E79D-B44C-4…
#> 10 bqUuFrzH71… DRDCJ2X8E2P… 2018-05-11T2… <list … REGIST… 48FD6A49-80A9-4…
#> # ... with 235 more rows
```

### Customers

Once you pull data about transactions you can take the customer\_id from the transaction `tenders` field and match that up with customer details. In Square customers can be placed into groups that allow for the analysis of transactions at a group-level.

``` r
# list customers created in the last 90 days
created_start <- format(Sys.Date()-90, '%Y-%m-%dT00:00:00-00:00')
created_end <- format(Sys.Date(), '%Y-%m-%dT00:00:00-00:00')
our_customers <- sq_search_customers(query = list(filter=
                                                    list(created_at=
                                                           list(start_at=created_start,
                                                                end_at=created_end))))
our_customers$given_name <- "{HIDDEN}"
our_customers$family_name <- "{HIDDEN}"
our_customers %>% select(id, created_at, updated_at, 
                         given_name, family_name, preferences, groups)
#> # A tibble: 8,087 x 7
#>    id     created_at  updated_at given_name family_name preferences groups
#>    <chr>  <chr>       <chr>      <chr>      <chr>       <list>      <list>
#>  1 BCKGB… 2018-08-14… 2018-08-3… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  2 YMZQ5… 2018-07-05… 2018-07-0… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  3 KBZVT… 2018-08-31… 2018-08-3… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  4 0M4VW… 2018-07-24… 2018-07-2… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  5 K9JR3… 2018-07-10… 2018-07-1… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  6 E735V… 2018-09-10… 2018-09-1… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  7 GAG2W… 2018-09-21… 2018-09-2… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  8 VDZZ7… 2018-07-25… 2018-07-2… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  9 RWTS7… 2018-09-03… 2018-09-0… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#> 10 RFJP4… 2018-08-25… 2018-08-2… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#> # ... with 8,077 more rows

# show the groups that each customer belongs to
# filter to the groups designated automatically by Square
sq_extract_cust_groups(our_customers) %>%
  filter(grepl("^CQ689YH4KCJMY", groups.id))
#> # A tibble: 3,606 x 3
#>    id                         groups.id                 groups.name      
#>    <chr>                      <chr>                     <chr>            
#>  1 BCKGBSEV4555AZ0B09VXG7AFWC CQ689YH4KCJMY.LOYALTY_ALL Loyalty Enrollees
#>  2 YMZQ5X2SX13W8VXHTSWCXP4R2C CQ689YH4KCJMY.REACHABLE   Reachable        
#>  3 KBZVT7KPFD1TMN0D1NDAF4XRKC CQ689YH4KCJMY.LOYAL       Regulars         
#>  4 KBZVT7KPFD1TMN0D1NDAF4XRKC CQ689YH4KCJMY.LOYALTY_ALL Loyalty Enrollees
#>  5 0M4VWF9NT9532R8E103Z1FWZGC CQ689YH4KCJMY.REACHABLE   Reachable        
#>  6 VDZZ7XA41S6MYK1GZT75N1FP8M CQ689YH4KCJMY.REACHABLE   Reachable        
#>  7 RWTS7E3B0X61WY8AW9K6SW2BFR CQ689YH4KCJMY.LOYAL       Regulars         
#>  8 RWTS7E3B0X61WY8AW9K6SW2BFR CQ689YH4KCJMY.LOYALTY_ALL Loyalty Enrollees
#>  9 T1HZ36NEAX2YPJGX45BSYM4EKW CQ689YH4KCJMY.LOYALTY_ALL Loyalty Enrollees
#> 10 56811Y4J2N152VH3SCDJ3N0E4G CQ689YH4KCJMY.REACHABLE   Reachable        
#> # ... with 3,596 more rows
```

Credits
-------

This application uses other open source software components. The authentication components are mostly verbatim copies of the routines established in the **googlesheets** package (<https://github.com/jennybc/googlesheets>). We acknowledge and are grateful to these developers for their contributions to open source.

More Information
----------------

This package makes requests best formatted to match what the APIs require as input. This articulation is not perfect and continued progress will be made to add and improve functionality. For details on formatting, attributes, and methods please refer to [Square's documentation](https://docs.connect.squareup.com/api/connect/v2) as they are explained better there.

More information is also available on the `pkgdown` site at <https://StevenMMortimer.github.io/squareupr>.

[Top](#squareupr)

------------------------------------------------------------------------

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
