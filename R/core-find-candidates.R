#' Find Address Candidates
#'
#' Given an address, returns geocode result candidates.
#'
#' @details
#' Utilizes the [`/findAddressCandidates`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm) endpoint.
#'
#' The endpoint can only handle one request at a time. To
#' make the operation as performant as possible, requests are sent in parallel
#' using [`httr2::req_perform_parallel()`]. The JSON responses are then processed
#' using Rust and returned as an sf object.
#'
#' @examples
#' candidates_from_single <- find_address_candidates(
#'   single_line = "Bellwood Coffee, 1366 Glenwood Ave SE, Atlanta, GA, 30316, USA"
#' )
#'
#' candidates_from_parts <- find_address_candidates(
#'   address = c("Bellwood Coffee", "Joe's coffeehouse"),
#'   address2 = c("1366 Glenwood Ave SE", "510 Flat Shoals Ave"),
#'   city = "Atlanta",
#'   region = "GA",
#'   postal = "30316",
#'   country_code = "USA"
#' )
#'
#' str(candidates_from_parts)
#'
#' @param single_line a character vector of addresses to geocode. If provided
#'  other `address` fields cannot be used. If `address` is not provided,
#'  `single_line` must be.
#' @param address a character vector of the first part of a street address.
#'  Typically used for the street name and house number. But can also be a place
#'  or building name. If `single_line` is not provided, `address` must be.
#' @param address2 a character vector of the second part of a street address.
#'  Typically includes a house number, sub-unit, street, building, or place name.
#'  Optional.
#' @param address3 a character vector of the third part of an address. Optional.
#' @param neighborhood a character vector of the smallest administrative division
#'  associated with an address. Typically, a neighborhood or a section of a
#'  larger populated place. Optional.
#' @param city a character vector of the next largest administrative division
#'  associated with an address, typically, a city or municipality. A city is a
#'  subdivision of a subregion or a region. Optional.
#' @param subregion a character vector of the next largest administrative division
#'  associated with an address. Depending on the country, a subregion can
#'  represent a county, state, or province. Optional.
#' @param region a character vector of the largest administrative division
#'  associated with an address, typically, a state or province. Optional.
#' @param postal a character vector of the standard postal code for an address,
#'  typically, a three– to six-digit alphanumeric code. Optional.
#' @param postal_ext a character vector of the postal code extension, such as
#'  the United States Postal Service ZIP+4 code, provides finer resolution or
#'  higher accuracy when also passing postal. Optional.
#' @param max_locations the maximum number of results to return. The default is
#'   15 with a maximum of 50. Optional.
#' @param match_out_of_range set to `TRUE` by service by default. Matches locations Optional.
#' @param source_country default `NULL`. An ISO 3166 country code.
#'   See [`iso_3166_codes()`] for valid ISO codes. Optional.
#' @param magic_key a unique identifier returned from [`suggest_places()`].
#'   When a `magic_key` is provided, results are returned faster. Optional.
#' @inheritParams suggest_places
#' @inheritParams reverse_geocode
#' @returns
#' An `sf` object with 60 columns.
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
    magic_key = NULL,
    geocoder = default_geocoder(),
    token = arc_token(),
    .progress = TRUE) {
  check_geocoder(geocoder, call = rlang::caller_env())

  if (!"geocode" %in% capabilities(geocoder)) {
    arg <- rlang::caller_arg(geocoder)
    cli::cli_abort("{.arg {arg}} does not support  the {.path /findAddressCandidates} endpoint")
  }

  # this also checks the token
  check_for_storage(for_storage, token, call = rlang::caller_env())

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
  check_character(magic_key, allow_null = TRUE)

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
    call = rlang::caller_env()
  )

  # check that either single_line or address are not-null
  # all non-null values should be a scalar or the same length

  # It could be actually really easy to capture all of the arguments
  # except .progress, token, and geocoder to turn it into a data.frame
  # iterate through the rows and create the requests

  # NOTE when debugging inline
  # fml_nms <- rlang::fn_fmls_names(find_address_candidates)
  fml_nms <- rlang::fn_fmls_names()

  # get all values passed in
  all_args <- rlang::env_get_list(nms = fml_nms)

  # check to see if any are null
  null_args <- vapply(all_args, is.null, logical(1))

  # these arguments are scalars and shold not be handled in a vectorized manner
  to_exclude <- c("crs", ".progress", "token", "geocoder", "for_storage", "search_extent")
  to_include <- !names(all_args) %in% to_exclude

  # fetches all non-null arguments. These will be turned into a dataframe
  non_null_vals <- all_args[to_include & !null_args]

  # validate the preferred_label_values
  if (!is.null(non_null_vals[["preferred_label_values"]])) {
    non_null_vals[["preferred_label_values"]] <- match_label_values(
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
  location <- obj_as_points(location, allow_null = TRUE)

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
        "All arguments must be the same length or scalar or length 1"
      )
    )
  }

  # handle outSR
  if (!is.null(crs)) {
    crs <- jsonify::to_json(validate_crs(crs)[[1]], unbox = TRUE)
  }

  # handle extent
  # only 1 extent per function call, this will not be vectorized
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

  # create the base request
  b_req <- arc_base_req(
    geocoder[["url"]],
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
    params_i <- as.list(params_df[i, , drop = FALSE])

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

  all_resps <- httr2::req_perform_parallel(
    all_reqs,
    on_error = "continue",
    progress = .progress
  )

  # Before we can process the responses, we must know if
  # the locator has custom fields. If so, we need to use
  # RcppSimdJson and _not_ the Rust based implementation
  use_custom_json_processing <- has_custom_fields(geocoder)

  # TODO Handle errors
  all_results <- lapply(all_resps, function(.resp) {
    string <- httr2::resp_body_string(.resp)
    parse_candidate_res(string)
  })

  # combine all the results
  results <- rbind_results(all_results)

  # if any issues occured they would've happened here
  errors <- attr(results, "null_elements")
  n_errors <- length(errors)

  # if errors occurred attach as an attribute
  if (n_errors > 0) {
    attr(results, "error_requests") <- all_reqs[errors]

    # process resps and catch the errors
    error_messages <- lapply(
      all_resps[errors],
      function(.x) catch_error(httr2::resp_body_string(.x), rlang::caller_call(2))
    )

    # add a warning when n_errors > 0
    cli::cli_warn(c(
      "x" = "Issue{cli::qty(n_errors)}{?s} encountered when processing response{cli::qty(n_errors)}{?s} {cli::qty(n_errors)} {errors}",
      "i" = "access problem requests with {.code attr(result, \"error_requests\")}"
    ))

    # for each error message signal the condition
    for (cnd in error_messages) rlang::cnd_signal(cnd)
  }


  # # TODO handle errors!!!
  # successes <- httr2::resps_successes(all_resps)

  # all_results <- lapply(successes, function(.resp) {
  #   string <- httr2::resp_body_string(.resp)
  #   # string
  #   parse_candidate_res(string)
  # })

  # # combine together
  # res <- rbind_results(all_results)

  # # FIXME should the IDs be included as optional into `rbind_results()`?
  n_ids <- vapply(all_results, function(.x) nrow(.x) %||% 0L, integer(1))
  ids <- rep.int(1:length(all_results), n_ids)

  # # cbind() is slow but not that bad?
  res <- cbind(input_id = ids, results)
  attr(res, "error_requests") <- all_reqs[errors]
  attr(res, "error_ids") <- errors
  res
}


parse_candidate_res <- function(string) {
  res_list <- parse_candidate_json(string)

  if (is.null(res_list)) {
    return(NULL)
  }
  res <- res_list[["attributes"]]
  res[["extents"]] <- res_list[["extents"]]

  # TODO sometimes the wkid isn't a standard EPSG code.
  # Then we need to add `ESRI:{wkid}` in front of it.
  # But how do we know? The spatialReference database could be handy here.
  # but thats so bigg.....
  crs_obj <- parse_wkid(res_list$sr$wkid)
  geometry <- sf::st_sfc(res_list[["locations"]], crs = crs_obj)

  # geometry
  sf::st_sf(
    res,
    geometry
  )
}
