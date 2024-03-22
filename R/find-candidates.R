# [category] can also be passed in a request on its own without the singleline or address parameters

# single line poi search tips:
# https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm#GUID-8C5C17DC-064E-4F25-A1F2-3DEB481A4CED


#' Find Address Candidates
#'
#' @inheritParams reverse_geocode
#' @export
find_address_candidates <- function(
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
    location_type = NULL,
    lang_code = NULL,
    source_country = NULL, # iso code
    preferred_label_values = NULL,
    geocoder = default_geocoder(),
    token = arc_token(),
    .progress = TRUE
) {

  # TODO CHECKS
  # - geocoder

  check_bool(.progress, allow_na = FALSE, allow_null = FALSE)

  # type checking for all character types
  # they can be either NULL or not. When not, they cannot have NA values
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
  check_character(category, allow_null = TRUE)
  check_character(location_type, allow_null = TRUE)
  check_character(preferred_label_values, allow_null = TRUE)

  # iso 3166 checks
  check_iso_3166(country_code, allow_null = TRUE, scalar = FALSE)
  check_iso_3166(lang_code, allow_null = TRUE, scalar = FALSE)
  check_iso_3166(source_country, allow_null = TRUE, scalar = FALSE)

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

  # this also checks the token
  check_for_storage(for_storage, token, call = rlang::current_env())

  # check that either single_line or address are not-null
  # all non-null values should be a scalar or the same length

  # It could be actually really easy to capture all of the arguments
  # except .progress, token, and geocoder to turn it into a data.frame
  # iterate through the rows and create the requests
  # fml_nms <- rlang::fn_fmls_names()
  fml_nms <- names(rlang::fn_fmls())

  # get all values passed in
  all_args <- rlang::env_get_list(nms = fml_nms)

  null_args <- vapply(all_args, is.null, logical(1))

  to_exclude <- c("crs", ".progress", "token", "geocoder", "for_storage")
  to_include <- !names(all_args) %in% to_exclude

  non_null_vals <- all_args[to_include & !null_args]

  # validate the preferred_label_values
  if (!is.null(non_null_vals[["preferred_label_values"]])) {
    non_null_vals[["preferred_label_values"]] <-  match_label_values(
      non_null_vals[["preferred_label_values"]],
      .multiple = TRUE
    )
  }

  # validate location types
  if (!is.null(non_null_vals[["location_type"]])) {
    non_null_vals[["location_type"]] <- match_location_type(
      non_null_vals[["location_type"]],
      .multiple = TRUE
    )
  }

  # check for locations
  check_locations(location)

  # convert to esri json if not missing
  if (!is.null(location)) {
    in_crs <- sf::st_crs(location)
    in_sr <- validate_crs(in_crs, call = call)[[1]]
    non_null_vals[["location"]] <- as_esri_point_json(location, in_sr)
  }


  # check lengths
  ns <- lengths(non_null_vals)
  n_checks <- ns == max(ns) | ns == 1L

  if (!all(n_checks)) {
    cli::cli_abort(
      c(
        "All arguments must be the same or length 1",
        ">" = "Problems with: {names(non_null_vals)[!n_checks]}"
      )
    )
  }

  # handle outSR
  if (!is.null(crs)) {
    crs <- jsonify::to_json(validate_crs(crs)[[1]], unbox = TRUE)
  }

  # handle extent
  # only 1 extent per function call, this will not be vectorized
  check_extent(search_extent, arg = rlang::caller_arg(search_extent), call = call)

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

  # create the base request
  b_req <- arc_base_req(
    geocoder,
    token,
    path = "findAddressCandidates",
    query = c("f" = "json")
  )

  # create a data frame to take advantage of auto-recycling
  params_df <- data.frame(non_null_vals)

  # how many requests we will have to make
  n <- nrow(params_df)

  # pre-allocate list
  all_reqs <- vector(mode = "list", length = n)

  for (i in seq_len(n)) {
    # capture params as a list
    params_i <- as.list(params_df[i,])
    # convert the names to lowerCamel for endpoint
    names(params_i) <- to_lower_camel(names(params_i))
    # store in list
    all_reqs[[i]] <- httr2::req_body_form(
      b_req,
      !!!params_i,
      outFields = "*",
      outSR = crs,
      searchExtent = search_extent
    )
  }

  all_resps <- httr2::req_perform_parallel(
    all_reqs,
    on_error = "continue",
    progress = .progress
  )

  # TODO handle errors!!!
  successes <- httr2::resps_successes(all_resps)

  all_results <- lapply(successes, function(.resp) {
    string <- httr2::resp_body_string(.resp)
    # string
    parse_candidate_res(string)
  })

  collapse::rowbind(all_results)
}


parse_candidate_res <- function(string) {
  res_list <- parse_candidate_json(string)
  res <- res_list[["attributes"]]
  res[["extents"]] <- res_list[["extents"]]

  geometry <- sf::st_sfc(res_list[["locations"]], crs = res_list$sr$wkid)

  # geometry
  sf::st_sf(
    res,
    geometry
  )
}

# parse_candidate_res(string)

