% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{sq_list_generic_v1}
\alias{sq_list_generic_v1}
\title{List Records from Connect V1 Endpoints}
\usage{
sq_list_generic_v1(endpoint, location, cursor = NULL, verbose = FALSE)
}
\arguments{
\item{endpoint}{character; a string that specifies which endpoint the generic 
method should target}

\item{location}{character; the Square ID or name associated to a location. 
This must be an exact match to the ID or name as found using \link{sq_list_locations}.}

\item{cursor}{character; A pagination cursor returned by a previous call to 
this endpoint. Typically this is not needed because functions in the package 
will automatically paginate results.}

\item{verbose}{logical; do you want informative messages?}
}
\value{
\code{tbl_df} of records from the specified endpoint
}
\description{
This generic function can be used on the list endpoints of the Connect V1 API. 
Most endpoints have specific functions to accomodate parameters. We use this 
generic to create functiosn for endpoints that do not have parameters we do not 
care about (e.g. begin time, end time, etc.)
}
\details{
This function and works for the following Connect V1 endpoints: 
items, categories, fees, discounts, modifier-lists.
}
\examples{
\dontrun{
our_locations <- sq_list_locations()
our_items <- sq_list_generic_v1(endpoint="items", location=our_locations$id[1])
}
}
\keyword{internal}
