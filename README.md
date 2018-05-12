
squareupr<img src="man/figures/squareupr.png" width="120px" align="right" />
============================================================================

[![Build Status](https://travis-ci.org/StevenMMortimer/squareupr.svg?branch=master)](https://travis-ci.org/StevenMMortimer/squareupr) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/StevenMMortimer/squareupr?branch=master&svg=true)](https://ci.appveyor.com/project/StevenMMortimer/squareupr) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/squareupr)](http://cran.r-project.org/package=squareupr) [![Coverage Status](https://codecov.io/gh/StevenMMortimer/squareupr/branch/master/graph/badge.svg)](https://codecov.io/gh/StevenMMortimer/squareupr?branch=master)

**squareupr** is an R package that connects to Square APIs (Connect v1 & v2).

-   OAuth 2.0 (Single sign-on) and Personal Access Token Authentication methods (`sq_auth()`)
-   v2 Locations Endpoint
-   v2 Customers Endpoint
-   v2 Transactions Endpoint
-   v1 Payments Endpoint
-   v1 Orders Endpoint

Table of Contents
-----------------

-   [Installation](#installation)
-   [Usage](#usage)
    -   [Authenticate](#authenticate)
    -   [Locations](#locations)
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

First, load the **squareupr** package and login. There are two ways to authenticate:

1.  Personal Access Token
2.  OAuth 2.0

NOTE: It is recommended to use OAuth 2.0 so that passwords do not have to be shared or embedded within scripts. However, to use OAuth 2.0 authentication it is necessary that you setup your own Connected App in the Square dashboard. An app id and app secret will be provided, then you will be able to plug into your script like so:

``` r
options(squareupr.app_id = "sq0-99-thisisatest99connected33app22id")
options(squareupr.app_secret = "sq0-Th1s1sMyAppS3cr3t")
sq_auth()
```

OAuth 2.0 credentials will be cached locally in a file entitled `".httr-oauth-squareupr"` in the current working directory so that a new token is not needed each session.

``` r
suppressWarnings(suppressMessages(library(dplyr)))
library(squareupr)

# Using OAuth 2.0 authentication
sq_auth()

# Using Personal Access Token (PAT)
sq_auth(personal_access_token = "{PERSONAL_ACCESS_TOKEN_HERE}")
```

### Locations

You can pull information regarding locations for a specific location or listing all locations.

``` r
# list all locations
our_locations <- sq_list_locations()
our_locations$name <- "{HIDDEN}"
our_locations %>% select(id, name, address, timezone, 
                        capabilities, status, created_at)
#> # A tibble: 5 x 7
#>   id            name     address  timezone  capabilities status created_at
#>   <chr>         <chr>    <list>   <chr>     <list>       <chr>  <chr>     
#> 1 46FYN9N9RQS54 {HIDDEN} <list [… America/… <chr [1]>    ACTIVE 2017-04-2…
#> 2 DRDCJ2X8E2PMV {HIDDEN} <list [… America/… <chr [1]>    ACTIVE 2016-09-2…
#> 3 8T1TYXE840S00 {HIDDEN} <list [… America/… <chr [1]>    ACTIVE 2016-09-2…
#> 4 1AWPRVVVFWGQF {HIDDEN} <list [… America/… <chr [1]>    ACTIVE 2017-04-1…
#> 5 50X1GNAWEC8V0 {HIDDEN} <list [… America/… <chr [1]>    ACTIVE 2017-03-0…

# search by id
one_location <- sq_get_location(our_locations$id[1])
this_location_name <- one_location$name[1]
one_location$name <- "{HIDDEN}"
one_location %>% select(id, name, address, timezone, 
                        capabilities, status, created_at)
#> # A tibble: 1 x 7
#>   id            name     address  timezone  capabilities status created_at
#>   <chr>         <chr>    <list>   <chr>     <list>       <chr>  <chr>     
#> 1 46FYN9N9RQS54 {HIDDEN} <list [… America/… <chr [1]>    ACTIVE 2017-04-2…

# search by name (must be an exact match)
one_location <- sq_get_location(this_location_name)
one_location$name <- "{HIDDEN}"
one_location %>% select(id, name, address, timezone, 
                        capabilities, status, created_at)
#> # A tibble: 1 x 7
#>   id            name     address  timezone  capabilities status created_at
#>   <chr>         <chr>    <list>   <chr>     <list>       <chr>  <chr>     
#> 1 46FYN9N9RQS54 {HIDDEN} <list [… America/… <chr [1]>    ACTIVE 2017-04-2…
```

### Customers

Similarly, you can pull information regarding a specific customer or listing all customers.

``` r
# list all locations
our_customers <- sq_list_customers()
our_customers$given_name <- "{HIDDEN}"
our_customers$family_name <- "{HIDDEN}"
our_customers %>% select(id, created_at, updated_at, 
                         given_name, family_name, preferences, groups)
#> # A tibble: 100 x 7
#>    id     created_at  updated_at given_name family_name preferences groups
#>    <chr>  <chr>       <chr>      <chr>      <chr>       <list>      <list>
#>  1 M1RBD… 2017-01-09… 2018-02-0… {HIDDEN}   {HIDDEN}    <lgl [1]>   <list…
#>  2 56EB9… 2017-12-11… 2018-02-0… {HIDDEN}   {HIDDEN}    <lgl [1]>   <NULL>
#>  3 Z2HYX… 2017-12-19… 2018-02-0… {HIDDEN}   {HIDDEN}    <lgl [1]>   <NULL>
#>  4 017CX… 2017-10-04… 2018-02-0… {HIDDEN}   {HIDDEN}    <lgl [1]>   <NULL>
#>  5 58MK9… 2017-11-16… 2018-02-0… {HIDDEN}   {HIDDEN}    <lgl [1]>   <list…
#>  6 T5HXZ… 2018-01-02… 2018-02-0… {HIDDEN}   {HIDDEN}    <lgl [1]>   <NULL>
#>  7 MBSJA… 2017-05-31… 2017-05-3… {HIDDEN}   {HIDDEN}    <lgl [1]>   <list…
#>  8 ECVG5… 2017-09-30… 2018-03-1… {HIDDEN}   {HIDDEN}    <lgl [1]>   <list…
#>  9 H8BZA… 2017-07-06… 2018-02-1… {HIDDEN}   {HIDDEN}    <lgl [1]>   <list…
#> 10 ZCBZJ… 2018-01-16… 2018-03-0… {HIDDEN}   {HIDDEN}    <lgl [1]>   <list…
#> # ... with 90 more rows

# search by id
one_customer <- sq_get_customer(our_customers$id[1])
one_customer$given_name <- "{HIDDEN}"
one_customer$family_name <- "{HIDDEN}"
one_customer %>% select(id, created_at, updated_at, 
                        given_name, family_name, preferences, groups)
#> # A tibble: 1 x 7
#>   id      created_at  updated_at given_name family_name preferences groups
#>   <chr>   <chr>       <chr>      <chr>      <chr>       <list>      <list>
#> 1 M1RBDF… 2017-01-09… 2018-02-0… {HIDDEN}   {HIDDEN}    <lgl [1]>   <list…
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
