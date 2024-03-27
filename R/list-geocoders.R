#' List Available Geocoder Services
#'
#' Evaluates the logged in user from an authorization token and returns
#' a data.frame containing the available geocoding services for the
#' associated token.
#'
#' The `default_geocoder()`
#'
#' @returns a `data.frame`.
#'
#' @inheritParams arcgisutils::arc_base_req
#' @export
#' @examples
#' list_geocoders()
list_geocoders <- function(
    token = arc_token()) {
  # capture current env for error propagation
  # There may be a reason to include it in the
  # function arguments but im not convinced yet
  call <- rlang::current_env()

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
  structure(
    geocoder_metadata,
    class = c("tbl", "data.frame")
  )
}

#' @export
#' @rdname list_geocoders
default_geocoder <- function(token = arc_token()) {
  res <- list_geocoders(token = token)

  if (nrow(res) > 1) {
    cli::cli_abort("No geocoder services found.")
  }

  geocode_server(res[1, "url"])
}
