
# squareupr<img src="man/figures/squareupr.png" width="120px" align="right" />

[![Build
Status](https://travis-ci.org/StevenMMortimer/squareupr.svg?branch=master)](https://travis-ci.org/StevenMMortimer/squareupr)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/StevenMMortimer/squareupr?branch=master&svg=true)](https://ci.appveyor.com/project/StevenMMortimer/squareupr)
[![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/squareupr)](http://cran.r-project.org/package=squareupr)
[![Coverage
Status](https://codecov.io/gh/StevenMMortimer/squareupr/branch/master/graph/badge.svg)](https://codecov.io/gh/StevenMMortimer/squareupr?branch=master)

**squareupr** is an R package that connects to the Square APIs (Connect
v1 & v2).

  - OAuth 2.0 (Single sign-on) and Personal Access Token Authentication
    methods (`sq_auth()`)
  - v2 Locations Endpoint (`sq_list_locations()`, `sq_get_location()`)
  - v2 Transactions Endpoint (`sq_list_transactions()`,
    `sq_get_transaction()`)
  - v2 Customers Endpoint - CRUD (Create, Retrieve, Update, Delete)
    methods for customers with:
      - `sq_list_customers()`, `sq_search_customers()`,
        `sq_get_customer()`, `sq_create_customer()`,
        `sq_update_customer()`, `sq_delete_customer()`
  - v1 Payments Endpoint (`sq_list_payments()`, `sq_get_payment()`)
  - v1 Items Endpoint - CRUD (Create, Retrieve, Update, Delete) methods
    for items with:
      - `sq_list_items()`, `sq_get_item()`, `sq_create_item()`,
        `sq_update_item()`, `sq_delete_item()`
  - List v1 records (`sq_list_fees()`, `sq_list_categories()`,
    `sq_list_modifiers()`, `sq_list_discounts()`)

## Table of Contents

  - [Installation](#installation)
  - [Usage](#usage)
      - [Authenticate](#authenticate)
      - [Transactions](#transactions)
      - [Customers](#customers)
  - [Credits](#credits)
  - [More Information](#more-information)

## Installation

``` r
# This package is not yet available on CRAN so you must install from GitHub
# install.packages("devtools")
devtools::install_github("StevenMMortimer/squareupr")
```

If you encounter a clear bug, please file a minimal reproducible example
on [GitHub](https://github.com/StevenMMortimer/squareupr/issues).

## Usage

### Authenticate

First, load the **squareupr** package and authenticate. There are two
ways to authenticate:

1.  Personal Access Token
2.  OAuth 2.0

<!-- end list -->

``` r
library(dplyr)
library(squareupr)

# Using Personal Access Token (PAT)
sq_auth(personal_access_token = "sq-Th1s1sMyPers0nalAcessT0ken")

# Using OAuth 2.0 authentication
sq_auth()
```

NOTE: Before using OAuth 2.0 authentication it is necessary that you set
up your own Connected App in the Square dashboard. An App ID and App
Secret will be provided, then you will be able to plug into your script
like so:

``` r
options(squareupr.app_id = "sq0-99-thisisatest99connected33app22id")
options(squareupr.app_secret = "sq0-Th1s1sMyAppS3cr3t")
sq_auth()
```

OAuth 2.0 credentials will be cached locally in a file entitled
`".httr-oauth-squareupr"` in the current working directory so that a new
token is not needed each session.

### Transactions

Transactions are organized by location. With the v2 Locations endpoint
you can pull information regarding all locations first to obtain the
location IDs. Then with the `sq_list_transactions()` function you can
provide the location and timeframe to search. The function defaults to
pulling transactions from the previous day using `Sys.Date() - 1`. Once
you obtain the transactions the `tenders` field lists all methods of
payment used to pay in the transaction.

``` r
# list all locations
our_locations <- sq_list_locations()
our_transactions <- sq_list_transactions(location = our_locations$id[2], 
                                         begin_time = as.Date('2019-07-09'), 
                                         end_time = as.Date('2019-07-10'))
our_transactions
#> # A tibble: 197 x 9
#>    id    location_id created_at tenders product client_id refunds
#>    <chr> <chr>       <chr>      <list>  <chr>   <chr>     <list> 
#>  1 bu0b… DRDCJ2X8E2… 2019-07-1… <list … REGIST… BA6D16E9… <NULL> 
#>  2 7qmX… DRDCJ2X8E2… 2019-07-0… <list … REGIST… B3ACC564… <NULL> 
#>  3 fEg0… DRDCJ2X8E2… 2019-07-0… <list … REGIST… 117F4A34… <NULL> 
#>  4 rMhg… DRDCJ2X8E2… 2019-07-0… <list … REGIST… 3CC0E3F7… <NULL> 
#>  5 xFqx… DRDCJ2X8E2… 2019-07-0… <list … REGIST… 3E4CE781… <NULL> 
#>  6 JVGY… DRDCJ2X8E2… 2019-07-0… <list … REGIST… 1739D76B… <NULL> 
#>  7 9nKc… DRDCJ2X8E2… 2019-07-0… <list … REGIST… F511D38E… <NULL> 
#>  8 JPvy… DRDCJ2X8E2… 2019-07-0… <list … REGIST… F38E64B3… <NULL> 
#>  9 lH4U… DRDCJ2X8E2… 2019-07-0… <list … REGIST… 6ED7522B… <NULL> 
#> 10 9joO… DRDCJ2X8E2… 2019-07-0… <list … REGIST… 0DF58C0E… <NULL> 
#> # … with 187 more rows, and 2 more variables: reference_id <chr>,
#> #   order_id <chr>
```

### Customers

Once you pull data about transactions you can take the customer\_id from
the transaction `tenders` field and match that up with customer details.
In Square customers can be placed into groups that allow for the
analysis of transactions at a group-level.

``` r
# list customers created in the last 30 days
created_start <- format(Sys.Date() - 30, '%Y-%m-%dT00:00:00-00:00')
created_end <- format(Sys.Date(), '%Y-%m-%dT00:00:00-00:00')
our_customers <- sq_search_customers(query = list(filter=
                                                    list(created_at=
                                                           list(start_at=created_start,
                                                                end_at=created_end))))
our_customers$given_name <- "{HIDDEN}"
our_customers$family_name <- "{HIDDEN}"
our_customers %>% select(id, created_at, updated_at, 
                         given_name, family_name, preferences, groups)
#> # A tibble: 3,245 x 7
#>    id      created_at  updated_at given_name family_name preferences groups
#>    <chr>   <chr>       <chr>      <chr>      <chr>       <list>      <list>
#>  1 K498FM… 2019-06-20… 2019-06-3… {HIDDEN}   {HIDDEN}    <named lis… <list…
#>  2 3AXCBD… 2019-07-10… 2019-07-1… {HIDDEN}   {HIDDEN}    <named lis… <list…
#>  3 CAA1WX… 2019-07-05… 2019-07-0… {HIDDEN}   {HIDDEN}    <named lis… <list…
#>  4 PRFAB2… 2019-06-19… 2019-06-1… {HIDDEN}   {HIDDEN}    <named lis… <list…
#>  5 NZ585Y… 2019-06-15… 2019-06-1… {HIDDEN}   {HIDDEN}    <named lis… <list…
#>  6 CT6TJE… 2019-07-02… 2019-07-0… {HIDDEN}   {HIDDEN}    <named lis… <list…
#>  7 T70ZBH… 2019-06-12… 2019-06-1… {HIDDEN}   {HIDDEN}    <named lis… <list…
#>  8 GP4YJZ… 2019-06-23… 2019-06-2… {HIDDEN}   {HIDDEN}    <named lis… <list…
#>  9 9SN9EG… 2019-07-06… 2019-07-0… {HIDDEN}   {HIDDEN}    <named lis… <list…
#> 10 JBJ5ZC… 2019-07-07… 2019-07-0… {HIDDEN}   {HIDDEN}    <named lis… <list…
#> # … with 3,235 more rows

# show the groups that each customer belongs to
# filter to the groups designated automatically by Square
sq_extract_cust_groups(our_customers) %>%
  filter(grepl("^CQ689YH4KCJMY", groups.id))
#> # A tibble: 1,248 x 3
#>    id                         groups.id                 groups.name      
#>    <chr>                      <chr>                     <chr>            
#>  1 3AXCBD5Q5N260RPKKKBJW8348R CQ689YH4KCJMY.LOYALTY_ALL Loyalty Enrollees
#>  2 PRFAB2CABS4YCYQHHAPDQE5HHW CQ689YH4KCJMY.LOYAL       Regulars         
#>  3 PRFAB2CABS4YCYQHHAPDQE5HHW CQ689YH4KCJMY.LOYALTY_ALL Loyalty Enrollees
#>  4 T70ZBHDNXD3F4TY9GX7C4XVD98 CQ689YH4KCJMY.LOYAL       Regulars         
#>  5 9SN9EG2AP900PVTA59BWWFV4PW CQ689YH4KCJMY.REACHABLE   Reachable        
#>  6 9SN9EG2AP900PVTA59BWWFV4PW CQ689YH4KCJMY.LOYALTY_ALL Loyalty Enrollees
#>  7 KGVMB2R5K14RRJT3D4J6WAEMAM CQ689YH4KCJMY.LOYAL       Regulars         
#>  8 RVNVNEWGMH5SWZAQ21376P1RR8 CQ689YH4KCJMY.LOYAL       Regulars         
#>  9 RVNVNEWGMH5SWZAQ21376P1RR8 CQ689YH4KCJMY.REACHABLE   Reachable        
#> 10 F5AB5VQZVX034TGNNS3X6T9Q78 CQ689YH4KCJMY.REACHABLE   Reachable        
#> # … with 1,238 more rows
```

## Credits

This application uses other open source software components. The
authentication components are mostly verbatim copies of the routines
established in the **googlesheets** package
(<https://github.com/jennybc/googlesheets>). We acknowledge and are
grateful to these developers for their contributions to open source.

## More Information

This package makes requests best formatted to match what the APIs
require as input. This articulation is not perfect and continued
progress will be made to add and improve functionality. For details on
formatting, attributes, and methods please refer to [Square’s
documentation](https://docs.connect.squareup.com/api/connect/v2) as they
are explained better there.

More information is also available on the `pkgdown` site at
<https://StevenMMortimer.github.io/squareupr>.

[Top](#squareupr)

-----

Please note that this project is released with a [Contributor Code of
Conduct](CONDUCT.md). By participating in this project you agree to
abide by its terms.
