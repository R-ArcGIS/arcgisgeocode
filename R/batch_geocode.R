geocode_addresses <- function(
    single_line = NULL,
    address = NULL,
    address2 = NULL,
    address3 = NULL,
    neighborhood = NULL,
    city = NULL,
    subregion = NULL,
    region = NULL,
    postal = NULL,
    postal_ext = NULL,
    country_code = NULL,
    location = NULL, # sfc_POINT
    search_extent = NULL,
    category = NULL, # Needs validation
    crs = NULL, # validate
    max_locations = NULL, # max 50
    for_storage = FALSE, # warn
    match_out_of_range = NULL,
    location_type = NULL,
    lang_code = NULL,
    source_country = NULL, # iso code
    preferred_label_values = NULL,
    batch_size = NULL,
    geocoder = default_geocoder(),
    token = arc_token(),
    .progress = TRUE
  ) {

  # check that token exists
  obj_check_token(token)

  # TODO
  # - check token
  # - check geocoder
  # - paginate batch size
  # - single line has a maximum character limit set by the geocoder service
  #    - this needs to be checked

  check_bool(.progress, allow_na = FALSE, allow_null = FALSE)
  check_for_storage(for_storage, token, call = rlang::current_env())

  # type checking for all character types
  # they can be either NULL or not. When not, they cannot have NA values

  # Address checks
  check_character(single_line, allow_null = TRUE)
  check_character(address, allow_null = TRUE)
  check_character(address2, allow_null = TRUE)
  check_character(address3, allow_null = TRUE)
  check_character(neighborhood, allow_null = TRUE)
  check_character(city, allow_null = TRUE)
  check_character(subregion, allow_null = TRUE)
  check_character(region, allow_null = TRUE)
  check_character(postal, allow_null = TRUE)
  check_character(postal_ext, allow_null = TRUE)
  check_iso_3166(country_code, allow_null = TRUE, scalar = FALSE)

  # Non-address checks
  check_bool(match_out_of_range, allow_null = TRUE, allow_na = FALSE)
  check_string(category, allow_null = TRUE, allow_empty = FALSE)
  check_string(location_type, allow_null = TRUE, allow_empty = FALSE)
  check_string(preferred_label_values, allow_null = TRUE, allow_empty = FALSE)
  check_iso_3166(source_country, allow_null = TRUE, scalar = TRUE)
  check_iso_3166(lang_code, allow_null = TRUE, scalar = TRUE)

  # outSR
  # handle outSR
  if (!is.null(crs)) {
    crs <- jsonify::to_json(validate_crs(crs)[[1]], unbox = TRUE)
  }

  # searchExtent
  check_extent(
    search_extent,
    arg = rlang::caller_arg(search_extent),
    call = call
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

  # single_line and addresses are mutually exclusive
  rlang::check_exclusive(single_line, address)

  address_fields <- c(
    "single_line",
    "address",
    "address2",
    "address3",
    "neighborhood",
    "city",
    "subregion",
    "region",
    "postal",
    "postal_ext",
    "country_code",
    "location"
  )

  rlang::env_get_list(nms = address_fields)

}
