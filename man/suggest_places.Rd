% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core-suggest.R
\name{suggest_places}
\alias{suggest_places}
\title{Search Suggestion}
\usage{
suggest_places(
  text,
  location = NULL,
  category = NULL,
  search_extent = NULL,
  max_suggestions = NULL,
  country_code = NULL,
  preferred_label_values = NULL,
  geocoder = default_geocoder(),
  token = arc_token()
)
}
\arguments{
\item{text}{a scalar character of search key to generate a place suggestion.}

\item{location}{an \code{sfc_POINT} object that centers the search. Optional.}

\item{category}{a scalar character. Place or address type that can be used to
filter suggest results. Optional.}

\item{search_extent}{an object of class \code{bbox} that limits the search area. This is especially useful for applications in which a user will search for places and addresses within the current map extent. Optional.}

\item{max_suggestions}{default \code{NULL}. The maximum number of suggestions to return.
The service default is 5 with a maximum of 15.}

\item{country_code}{default \code{NULL.} An ISO 3166 country code.
See \code{\link[=iso_3166_codes]{iso_3166_codes()}} for valid ISO codes. Optional.}

\item{preferred_label_values}{default NULL. Must be one of \code{"postalCity"}
or \code{"localCity"}. Optional.}

\item{geocoder}{default \code{\link[=default_geocoder]{default_geocoder()}}.}

\item{token}{an object of class \code{httr2_token} as generated by \code{\link[arcgisutils:auth_code]{auth_code()}}
or related function}
}
\value{
A \code{data.frame} with 3 columns: \code{text}, \code{magic_key}, and \code{is_collection}.
}
\description{
This function returns candidate locations based on a partial search query.
It is designed to be used in an interactive search experience in a client
facing application.
}
\details{
Unlike the other functions in this package, \code{suggest_places()} is not
vectorized as it is intended to provide search suggestions for individual
queries such as those made in a search bar.

Utilizes the \href{https://developers.arcgis.com/rest/geocode/api-reference/geocoding-suggest.htm}{\verb{/suggest}} endpoint.
}
\examples{
# identify a search point
location <- sf::st_sfc(sf::st_point(c(-84.34, 33.74)), crs = 4326)

# create a search extent from it
search_extent <- sf::st_bbox(sf::st_buffer(location, 10))

# find suggestions from it
suggestions <- suggest_places(
  "bellwood",
  location,
  search_extent = search_extent
)

# get address candidate information
# using the text and the magic key
find_address_candidates(
  suggestions$text,
  magic_key = suggestions$magic_key
)
}
