#' Create a GeocodeServer
#'
#' Create an object of class `GeocodeServer` from a URL. This object
#' stores the service definition of the geocoding service as a list object.
#'
#' @param url the URL of a geocoding server.
#' @inheritParams arcgisutils::arc_base_req
#' @examples
#' server_url <- "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"
#' geocode_server(server_url)
#' @export
#' @returns an object of class `GeocodeServer`.
geocode_server <- function(url, token = arc_token()) {
  b_req <- arc_base_req(url, token = token, query = c("f" = "json"))
  resp <- httr2::req_perform(b_req)
  jsn <- httr2::resp_body_string(resp)
  res <- RcppSimdJson::fparse(jsn)
  detect_errors(res) # check for any errors and report if thats the case
  res[["url"]] <- url
  structure(res, class = c("GeocodeServer", "list"))
}

world_geocoder_url <- "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer"

# Print method for the geocoder, must be exported
#' @export
print.GeocodeServer <- function(x, ...) {
  # if the description is "" we don't print it
  descrip <- x$serviceDescription
  if (!nzchar(descrip)) {
    descrip <- NULL
  }

  to_print <- compact(
    list(
      Description = descrip,
      Version = x$currentVersion,
      CRS = x[["spatialReference"]][["latestWkid"]]
    )
  )

  header <- "<GeocodeServer>"
  body <- paste0(names(to_print), ": ", to_print)

  cat(header, body, sep = "\n")
  invisible(x)
}

# handy check function to see if the type is a GeocodeServer
check_geocoder <- function(x, arg = rlang::caller_arg(x), call = rlang::caller_env()) {
  if (!rlang::inherits_any(x, "GeocodeServer")) {
    cli::cli_abort("Expected {.cls GeocodeServer}, {.arg {arg}} is {obj_type_friendly(x)}")
  }

  invisible(NULL)
}

#' Returns the capabilities of the geocoder as a character vector
#' @keywords internal
#' @noRd
capabilities <- function(geocoder) {
  tolower(strsplit(geocoder[["capabilities"]], ",")[[1]])
}

#' Determines if there are different fields in the geocoder object
#' TRUE if there are fields that are not in the default world geocoder
#' FALSE if there arent
#' @keywords internal
#' @noRd
has_custom_fields <- function(x) {
  custom_fields <- setdiff(
    x$candidateFields$name,
    arcgisgeocode::world_geocoder$candidateFields$name
  )

  length(custom_fields) > 0
}
