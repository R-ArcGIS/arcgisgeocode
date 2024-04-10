#' @import arcgisutils
#' @keywords internal
"_PACKAGE"

## usethis namespace: start
## usethis namespace: end
NULL


#' Storing Geocoding Results
#'
#' The results of geocoding operations cannot be stored or
#' persisted unless the `for_storage` argument is set to
#' `TRUE`. The default argument value is `for_storage = FALSE`, which indicates the results of the operation can't be stored, but they can be temporarily displayed on a map, for instance. If you store the results, in a database, for example, you need to set this parameter to true.
#'
#' See [the official documentation](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm#ESRI_SECTION3_BBCB5704B46B4CDF8377749B873B1A7F) for more context.
#' @name storage
NULL
