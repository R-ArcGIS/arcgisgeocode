#' List Available Geocoder Services
#'
#' Evaluates the logged in user from an authorization token and returns
#' a data.frame containing the available geocoding services for the
#' associated token.
#'
#' The `default_geocoder()` will return the ArcGIS World Geocoder if no
#' token is available. `list_geocoder()` requires an authorization
#' token.
#'
#' @returns a `data.frame` with columns `url`, `northLat`, `southLat`,
#' `eastLon`, `westLon`, `name`, `suggest`, `zoomScale`, `placefinding`, `batch`.
#'
#' @inheritParams arcgisutils::arc_base_req
#' @export
#' @examples
#'
#' # Default geocoder object
#' # ArcGIS World Geocoder b/c no token
#' default_geocoder()
#'
#' # Requires an Authorization Token
#' \dontrun{
#' list_geocoders()
#' }
list_geocoders <- function(token = arc_token()) {
  # capture current env for error propagation
  # There may be a reason to include it in the
  # function arguments but im not convinced yet
  call <- rlang::current_env()

  if (is.null(token)) {
    cli::cli_abort(
      "{.arg token} is {.code NULL}. Cannot search for geocoders."
    )
  }
  # extract helper services
  self <- arc_self_meta(error_call = call)
  # extrac geocode metadata
  geocoder_metadata <- self[["helperServices"]][["geocode"]]

  if (is.null(geocoder_metadata)) {
    current_user <- self$user$username %||% "not signed in"

    cli::cli_abort(
      c(
        "No geocoder services found",
        ">" = "Current user: {.emph {current_user}}",
        ">" = "Portal: {.url {self$portalHostname}}",
        call = call
      )
    )
  }

  # use pillar -- should be done in arcgisutils
  data_frame(geocoder_metadata)
}

#' Provides a default GeocodeServer
#'
#' For users who have not signed into a private portal or ArcGIS Online,
#' the public [ArcGIS World Geocoder](https://www.esri.com/en-us/arcgis/products/arcgis-world-geocoder) is used. Otherwise, the first available geocoding service associated
#' with your authorization token is used.
#'
#' To manually create a `GeocodeServer` object, see [`geocode_server()`].
#' @inheritParams arc_token
#' @export
#' @rdname list_geocoders
default_geocoder <- function(token = arc_token()) {
  if (is.null(token)) {
    return(world_geocoder)
  }

  res <- list_geocoders(token = token)

  if (nrow(res) > 1) {
    return(world_geocoder)
  }

  geocode_server(res[1, "url"])
}
