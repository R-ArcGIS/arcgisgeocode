# [category] can also be passed in a request on its own without the singleline or address parameters

# single line poi search tips:
# https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm#GUID-8C5C17DC-064E-4F25-A1F2-3DEB481A4CED
find_address_candidate <- function(
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
    # Is search extent specified for each location or
    # as a whole?
    search_extent = NULL, # should be a bbox object
    location = NULL, # sfc_POINT or sfg
    category = NULL, # Needs validation
    crs = NULL, # validate
    max_locations = NULL, # max 50
    for_storage = FALSE, # warn
    match_out_of_range = NULL,
    location_type = c("rooftop", "street"),
    lang_code = NULL,
    source_country = NULL, # iso code
    preferred_label_values = c("postalCity", "localCity"),
    geocoder = default_geocoder(),
    token = arc_token(),
    .progress = TRUE
) {

  # type checking for all character types
  # they can be either NULL or not. When not, they cannot have NA values
  check_character(single_line, allow_null = TRUE, allow_na = FALSE)
  check_character(address, allow_null = TRUE, allow_na = FALSE)
  check_character(address2, allow_null = TRUE, allow_na = FALSE)
  check_character(address3, allow_null = TRUE, allow_na = FALSE)
  check_character(neighborhood, allow_null = TRUE, allow_na = FALSE)
  check_character(city, allow_null = TRUE, allow_na = FALSE)
  check_character(subregion, allow_null = TRUE, allow_na = FALSE)
  check_character(region, allow_null = TRUE, allow_na = FALSE)
  check_character(postal, allow_null = TRUE, allow_na = FALSE)
  check_character(postal_ext, allow_null = TRUE, allow_na = FALSE)
  check_character(category, allow_null = TRUE, allow_na = FALSE)
  check_character(location_type, allow_null = TRUE, allow_na = FALSE)
  check_character(source_country, allow_null = TRUE, allow_na = FALSE)
  check_character(preferred_label_values, allow_null = TRUE, allow_na = FALSE)

  # iso 3166 checks
  check_iso_3166(country_code, allow_null = TRUE, allow_na = TRUE, scalar = FALSE)
  check_iso_3166(lang_code, allow_null = TRUE, allow_na = TRUE, scalar = FALSE)
  check_logical(
    match_out_of_range,
    allow_null = TRUE,
    allow_na = FALSE
  )

  check_number_whole(
    max_locations,
    min = 1,
    max = 50,
    allow_null = TRUE,
    call = rlang::current_env()
  )

  check_for_storage(for_storage, token, call = rlang::current_env())

  # check that either single_line or address are not-null
  # all non-null values should be a scalar or the same length

  # It could be actually really easy to capture all of the arguments
  # except .progress, token, and geocoder to turn it into a data.frame
  # iterate through the rows and create the requests
  all_args <- rlang::fn_fmls()

  to_include <- !names(all_args) %in%
    c("crs", ".progress", "token", "geocoder")

  all_args[to_include & !vapply(all_args, is.null, logical(1))]
  # lets return all output fields always, just easier that way
  # outFields=*
  # httr2::req_perform()
}

# find_address_candidate(1, "a", list())
