
squareupr<img src="man/figures/squareupr.png" width="120px" align="right" />
============================================================================

[![Build Status](https://travis-ci.org/StevenMMortimer/squareupr.svg?branch=master)](https://travis-ci.org/StevenMMortimer/squareupr) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/StevenMMortimer/squareupr?branch=master&svg=true)](https://ci.appveyor.com/project/StevenMMortimer/squareupr) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/squareupr)](http://cran.r-project.org/package=squareupr) [![Coverage Status](https://codecov.io/gh/StevenMMortimer/squareupr/branch/master/graph/badge.svg)](https://codecov.io/gh/StevenMMortimer/squareupr?branch=master)

**squareupr** is an R package that connects to the Square APIs (Connect v1 & v2).

-   OAuth 2.0 (Single sign-on) and Personal Access Token Authentication methods (`sq_auth()`)
-   v2 Locations Endpoint (`sq_list_locations()`, `sq_get_location()`)
-   v2 Transactions Endpoint (`sq_list_transactions()`, `sq_get_transaction()`)
-   v2 Customers Endpoint - CRUD (Create, Retrieve, Update, Delete) methods for customers with:
    -   `sq_list_customers()`, `sq_get_customer()`, `sq_create_customer()`, `sq_update_customer()`, `sq_delete_customer()`
-   v1 Payments Endpoint (`sq_list_payments()`, `sq_get_payment()`)
-   v1 Items Endpoint - CRUD (Create, Retrieve, Update, Delete) methods for items with:
    -   `sq_list_items()`, `sq_get_item()`, `sq_create_item()`, `sq_update_item()`, `sq_delete_item()`

Table of Contents
-----------------

-   [Installation](#installation)
-   [Usage](#usage)
    -   [Authenticate](#authenticate)
    -   [Customers](#customers)
    -   [Transactions](#transactions)
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
# list all customers
our_customers <- sq_list_customers()
our_customers$given_name <- "{HIDDEN}"
our_customers$family_name <- "{HIDDEN}"
our_customers %>% select(id, created_at, updated_at, 
                         given_name, family_name, preferences, groups)
#> # A tibble: 11,786 x 7
#>    id     created_at  updated_at given_name family_name preferences groups
#>    <chr>  <chr>       <chr>      <chr>      <chr>       <list>      <list>
#>  1 M1RBD… 2017-01-09… 2018-02-0… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  2 56EB9… 2017-12-11… 2018-02-0… {HIDDEN}   {HIDDEN}    <list [1]>  <NULL>
#>  3 Z2HYX… 2017-12-19… 2018-02-0… {HIDDEN}   {HIDDEN}    <list [1]>  <NULL>
#>  4 017CX… 2017-10-04… 2018-02-0… {HIDDEN}   {HIDDEN}    <list [1]>  <NULL>
#>  5 58MK9… 2017-11-16… 2018-02-0… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  6 T5HXZ… 2018-01-02… 2018-02-0… {HIDDEN}   {HIDDEN}    <list [1]>  <NULL>
#>  7 MBSJA… 2017-05-31… 2017-05-3… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  8 ECVG5… 2017-09-30… 2018-03-1… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#>  9 H8BZA… 2017-07-06… 2018-02-1… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#> 10 ZCBZJ… 2018-01-16… 2018-03-0… {HIDDEN}   {HIDDEN}    <list [1]>  <list…
#> # ... with 11,776 more rows

# show the groups that each customer belongs to
# filter to the groups designated automatically by Square
sq_extract_cust_groups(our_customers) %>%
  filter(grepl("^CQ689YH4KCJMY", groups.id))
#> # A tibble: 13,444 x 3
#>    id                         groups.id                 groups.name       
#>    <chr>                      <chr>                     <chr>             
#>  1 M1RBDFRK7S1Q1EP6EZFJFV3CBW CQ689YH4KCJMY.LOYALTY_ALL Loyalty Participa…
#>  2 58MK9F1HQ5447D1QZDX60NHTP4 CQ689YH4KCJMY.CHURN_RISK  Lapsed            
#>  3 58MK9F1HQ5447D1QZDX60NHTP4 CQ689YH4KCJMY.REACHABLE   Reachable         
#>  4 MBSJA4QV4WX6N2XV8WV9VJJTG8 CQ689YH4KCJMY.LOYALTY_ALL Loyalty Participa…
#>  5 MBSJA4QV4WX6N2XV8WV9VJJTG8 CQ689YH4KCJMY.REACHABLE   Reachable         
#>  6 ZCBZJ234217KTV812WX4DP2404 CQ689YH4KCJMY.REACHABLE   Reachable         
#>  7 FKEMR8KZCN3BH98RV78PKHKQ1R CQ689YH4KCJMY.LOYALTY_ALL Loyalty Participa…
#>  8 FKEMR8KZCN3BH98RV78PKHKQ1R CQ689YH4KCJMY.CHURN_RISK  Lapsed            
#>  9 78VMJPJNK959AHH0ZQPXDXEG3C CQ689YH4KCJMY.LOYALTY_ALL Loyalty Participa…
#> 10 QASM1G54VX0QN2S15YS6KHEFCC CQ689YH4KCJMY.LOYAL       Regulars          
#> # ... with 13,434 more rows
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
