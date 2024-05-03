#' Search Suggestion
#'
#' This function returns candidate locations based on a partial search query.
#' It is designed to be used in an interactive search experience in a client
#' facing application.
#'
#' @details
#'
#' Unlike the other functions in this package, `suggest_places()` is not
#' vectorized as it is intended to provide search suggestions for individual
#' queries such as those made in a search bar.
#'
#' Utilizes the [`/suggest`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-suggest.htm) endpoint.
#'
#' @param text a scalar character of search key to generate a place suggestion.
#' @param location an `sfc_POINT` object that centers the search. Optional.
#' @param category a scalar character. Place or address type that can be used to
#'  filter suggest results. Optional.
#' @param search_extent an object of class `bbox` that limits the search area. This is especially useful for applications in which a user will search for places and addresses within the current map extent. Optional.
#' @param country_code default `NULL.` An ISO 3166 country code.
#'   See [`iso_3166_codes()`] for valid ISO codes. Optional.
#' @param max_suggestions default `NULL`. The maximum number of suggestions to return.
#'   The service default is 5 with a maximum of 15.
#' @inheritParams reverse_geocode
#' @inheritParams find_address_candidates
#' @returns
#' A `data.frame` with 3 columns: `text`, `magic_key`, and `is_collection`.
#' @export
#' @examples
#' # identify a search point
#' location <- sf::st_sfc(sf::st_point(c(-84.34, 33.74)), crs = 4326)
#'
#' # create a search extent from it
#' search_extent <- sf::st_bbox(sf::st_buffer(location, 10))
#'
#' # find suggestions from it
#' suggestions <- suggest_places(
#'   "bellwood",
#'   location,
#'   search_extent = search_extent
#' )
#'
#' # get address candidate information
#' # using the text and the magic key
#' find_address_candidates(
#'   suggestions$text,
#'   magic_key = suggestions$magic_key
#' )
suggest_places <- function(
    text,
    location = NULL,
    category = NULL,
    search_extent = NULL,
    max_suggestions = NULL,
    country_code = NULL,
    preferred_label_values = NULL,
    geocoder = default_geocoder(),
    token = arc_token()) {
  if (!"suggest" %in% capabilities(geocoder)) {
    arg <- rlang::caller_arg(geocoder)
    cli::cli_abort("{.arg {arg}} does not support  the {.path /suggest} endpoint")
  }

  location <- obj_as_points(location, allow_null = TRUE, call = rlang::caller_env())
  # FIXME
  # Location should be able to be a length 2 numeric vector or an sfg POINT
  check_geocoder(geocoder, call = rlang::caller_env())

  check_string(text)
  check_string(category, allow_null = TRUE)

  # searchExtent
  check_extent(
    search_extent,
    arg = rlang::caller_arg(search_extent)
  )


  if (!is.null(search_extent)) {
    extent_crs <- validate_crs(
      sf::st_crs(search_extent),
      call = rlang::current_call()
    )[[1]]

    extent_json_raw <- c(
      as.list(search_extent),
      spatialReference = list(extent_crs)
    )
    search_extent <- jsonify::to_json(extent_json_raw, unbox = TRUE)
  }

  check_number_whole(
    max_suggestions,
    min = 1,
    max = 15,
    allow_null = TRUE
  )

  check_iso_3166(country_code, scalar = TRUE)

  check_string(preferred_label_values, allow_null = TRUE)

  if (!is.null(preferred_label_values)) {
    preferred_label_values <- match_label_values(preferred_label_values)
  }

  b_req <- arc_base_req(
    geocoder[["url"]],
    path = "suggest", query = list(f = "json")
  )

  if (!is.null(location)) {
    in_sr <- validate_crs(sf::st_crs(location))[[1]]
  } else {
    in_sr <- NULL
  }

  # get the location as json
  if (!is.null(location)) {
    loc_json <- as_esri_point_json(location, in_sr)
  } else {
    loc_json <- NULL
  }

  req <- httr2::req_body_form(
    b_req,
    text = text,
    location = loc_json,
    category = category,
    maxSuggestions = max_suggestions,
    countryCode = country_code,
    preferredLabelValues = preferred_label_values
  )

  resp <- httr2::req_perform(req)
  resp_string <- httr2::resp_body_string(resp)

  # capture the response
  res <- data_frame(parse_suggestions(resp_string))

  # if there are more than 0 rows, no error occured
  if (nrow(res) > 0) {
    return(res)
  } else {
    # if there are 0 rows, an error occurred, capture and signal it
    # still return empty data frame
    rlang::cnd_signal(catch_error(resp_string, error_call = rlang::caller_env()))
    return(res)
  }
}
