#' Search Suggestion
#'
#' @details
#'
#' Unlike the other functions in this package, `suggest_places()` is not
#' vectorized as it is intended to provide search suggestions for individual
#' queries such as those made in a search bar.
#'
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
  # FIXME
  # Location should be able to be a length 2 numeric vector or an sfg POINT

  check_string(text)
  check_string(category, allow_null = TRUE)

  # searchExtent
  check_extent(
    search_extent,
    arg = rlang::caller_arg(search_extent),
    call = rlang::current_env()
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
    allow_null = TRUE,
    call = rlang::current_env()
  )

  check_iso_3166(country_code, scalar = TRUE)

  check_string(preferred_label_values, allow_null = TRUE)

  if (!is.null(preferred_label_values)) {
    preferred_label_values <- match_label_values(preferred_label_values)
  }

  b_req <- arc_base_req(
    geocoder,
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
    maxSuggestions = max_suggestions,
    countryCode = country_code,
    preferredLabelValues = preferred_label_values
  )

  resp <- httr2::req_perform(req)

  # TODO 0 rows are returned when there was an issue parsing
  # should there be a warning?
  parse_suggestions(httr2::resp_body_string(resp))
}
