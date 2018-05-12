
squareupr<img src="man/figures/squareupr.png" width="120px" align="right" />
============================================================================

[![Build Status](https://travis-ci.org/StevenMMortimer/squareupr.svg?branch=master)](https://travis-ci.org/StevenMMortimer/squareupr) [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/StevenMMortimer/squareupr?branch=master&svg=true)](https://ci.appveyor.com/project/StevenMMortimer/squareupr) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/squareupr)](http://cran.r-project.org/package=squareupr) [![Coverage Status](https://codecov.io/gh/StevenMMortimer/squareupr/branch/master/graph/badge.svg)](https://codecov.io/gh/StevenMMortimer/squareupr?branch=master)

**squareupr** is an R package that connects to Square APIs (Connect v1 & v2).

-   OAuth 2.0 (Single sign-on) and Personal Acces Token Authentication methods (`sq_auth()`)
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

1.  OAuth 2.0
2.  Personal Access Token

It is recommended to use OAuth 2.0 so that passwords do not have to be shared or embedded within scripts. User credentials will be stored in locally cached file entitled `".httr-oauth-squareupr"` in the current working directory.

``` r
suppressWarnings(suppressMessages(library(dplyr)))
suppressWarnings(suppressMessages(library(purrr)))
library(squareupr)

# Using OAuth 2.0 authentication
sq_auth()

# Using Basic Username-Password authentication
sq_auth(personal_access_token = "{PERSONAL_ACCESS_TOKEN_HERE}")
```

After logging in with `sq_auth()`, you can check your connectivity by looking at the information returned about the current user. It should be information about you!

``` r
# nothing yet!
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
