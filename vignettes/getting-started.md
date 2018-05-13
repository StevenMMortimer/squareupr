---
title: "Getting Started"
author: "Steven M. Mortimer"
date: "2018-05-11"
output:
  rmarkdown::html_vignette:
    toc: true
    toc_depth: 4
    keep_md: true
vignette: >
  %\VignetteIndexEntry{Getting Started}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



First, load the `squareupr` package and login. There are two ways to authenticate: 
1) OAuth 2.0 or a 2) Personal Access Token (PAT). It is recommended to use OAuth 2.0 so that 
your PAT does not have to be shared/embedded within scripts. User credentials will 
be stored in locally cached file entitled ".httr-oauth-squareupr" in the current working 
directory.




```r
suppressWarnings(suppressMessages(library(dplyr)))
library(squareupr)
sf_auth(personal_access_token = "sq-Th1s1sMyPers0nalAcessT0ken")
```

NOTE: In order to use OAuth 2.0 authentication it is necessary that you setup your 
own Connected App in the Square dashboard. An App ID and App Secret will be provided, 
then you will be able to plug into your script like so:


```r
options(squareupr.app_id = "sq0-99-thisisatest99connected33app22id")
options(squareupr.app_secret = "sq0-Th1s1sMyAppS3cr3t")

sq_auth()
```

### Check out the Tests
The **squareupr** package has quite a bit of unit test coverage to track any 
changes made between newly released versions of the Square APIs. These tests are 
great source of examples for how to interect with the API.
