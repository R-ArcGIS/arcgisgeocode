#' Batch Geocode Addresses
#'
#' Gecocode a vector of addresses in batches.
#'
#' Addresses are partitioned into batches of up to `batch_size`
#' elements. The batches are then sent to the geocoding service
#' in parallel using [`httr2::req_perform_parallel()`].
#' The JSON responses are then processed
#' using Rust and returned as an sf object.
#'
#' If using a custom geocoding service with custom output variables
#' they are not captured at this time.
#' Please create a [GitHub issue](https://github.com/R-ArcGIS/arcgisgeocode/issues/new).
#'
#'
#' Utilizes the [`/geocodeAddresses`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-geocode-addresses.htm) endpoint.
#'
#' @param batch_size the number of addresses to geocode per
#'   request. Uses the suggested batch size property of the
#'   `geocoder`.
#' @inheritParams find_address_candidates
#' @inheritParams arc_base_token
#' @export
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
    .progress = TRUE) {
  # check that token exists
  obj_check_token(token)
  check_geocoder(geocoder, call = rlang::caller_env())

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
    call = rlang::current_env()
  )

  if (!is.null(search_extent)) {
    extent_crs <- validate_crs(
      sf::st_crs(search_extent),
      call = rlang::current_env()
    )[[1]]

    extent_json_raw <- c(
      as.list(search_extent),
      spatialReference = list(extent_crs)
    )
    search_extent <- jsonify::to_json(extent_json_raw, unbox = TRUE)
  }

  # single_line and addresses are mutually exclusive
  rlang::check_exclusive(single_line, address)

  address_fields <- c("single_line", "address", "address2", "address3", "neighborhood", "city", "subregion", "region", "postal", "postal_ext", "country_code", "location")

  # browser()
  fn_args <- rlang::env_get_list(nms = address_fields)
  arg_lengths <- lengths(fn_args)
  n <- max(arg_lengths)

  # do lengths check
  are_scalar <- arg_lengths == 1L
  are_null <- arg_lengths == 0L
  are_long <- arg_lengths == n
  n_checks <- are_scalar | are_null | are_long

  # abort if some are the wrong length
  if (!all(n_checks)) {
    cli::cli_abort(
      c(
        "Inconsistent number of elements in address fields",
        "i" = "must be a scalar or of equal length (expected {.val {n}} elements)",
        ">" = "problems with: {.field {names(n_checks)[!n_checks]}}"
      )
    )
  }

  if (!is.null(single_line)) {
    too_long <- nchar(single_line) > 200
    if (any(too_long)) {
      ids <- which(too_long)
      cli::cli_abort(
        c(
          "{.arg single_line} cannot be longer than 200 characters",
          ">" = "problems with features: {which(too_long)} "
        )
      )
    }
  }

  # input crs if location is provided
  if (!is.null(location)) {
    in_sr <- validate_crs(sf::st_crs(location))[[1]]
  } else {
    in_sr <- NULL
  }

  # remove null fields and convert into a data.frame
  # by converting to a data.frame, scalars are automatically lengthened
  to_partition <- data.frame(compact(fn_args))

  # identify the arguments that are missing that will need to be curried
  missing_vals <- setdiff(address_fields, names(to_partition))

  # we need to curry these missing NULLs into the call
  to_curry <- rlang::set_names(
    vector(mode = "list", length = length(missing_vals)),
    missing_vals
  )

  # check the batch size and ensure it conforms
  max_batch_size <- geocoder[["locatorProperties"]][["MaxBatchSize"]]

  suggested_batch_size <- geocoder[["locatorProperties"]][["SuggestedBatchSize"]]

  if (is.null(batch_size)) {
    # batch_size <- 150L
    batch_size <- suggested_batch_size %||% 150L
  } else if (batch_size > max_batch_size) {
    cli::cli_warn(c(
      "{.arg batch_size} exceeds maximum supported by service: {max_batch_size}",
      "!" = "using suggested batch size of {suggested_batch_size}"
    ))

    batch_size <- suggested_batch_size
  }

  # determine chunk indices
  indices <- chunk_indices(n, batch_size)
  # count how many chunks we will need
  n_chunks <- length(indices[["start"]])

  # instantiate empty vector for addresses
  address_batch_json <- character(n_chunks)

  # TODO make this into a simpler function
  # fill vector with json string
  for (i in seq_len(n_chunks)) {
    start <- indices[["start"]][i]
    end <- indices[["end"]][i]

    create_json_call <- rlang::call2(
      create_records,
      # subset the data frame
      !!!to_partition[start:end, , drop = FALSE],
      sr = in_sr,
      # FIXME n is used to populate objectid field in json
      # when chunked there will be duplicates. does this matter????
      n = end - start + 1
    )

    # execute the call and fill the numeric vector
    address_batch_json[i] <- rlang::eval_bare(
      rlang::call_modify(create_json_call, !!!to_curry)
    )
  }

  # create the base request
  b_req <- arc_base_req(
    geocoder[["url"]],
    token,
    path = "geocodeAddresses",
    query = list(f = "json")
  )

  # additional params
  addtl_params <- list(
    matchOutOfRange = match_out_of_range,
    category = category,
    locationType = location_type,
    preferredLabelValues = preferred_label_values,
    sourceCountry = source_country,
    langCode = lang_code,
    outSR = crs,
    searchExtent = search_extent,
    outFields = "*"
  )

  all_reqs <- lapply(address_batch_json, function(.addresses) {
    httr2::req_body_form(
      addresses = .addresses,
      b_req, !!!addtl_params
    )
  })

  all_resps <- httr2::req_perform_parallel(
    all_reqs,
    on_error = "continue",
    progress = .progress
  )

  # TODO! Handle errors
  all_results <- lapply(all_resps, function(.resp) {
    string <- httr2::resp_body_string(.resp)
    parse_locations_res(string)
  })

  results <- rbind_results(all_results)

  # if any issues occured they would've happened here
  errors <- attr(results, "null_elements")
  n_errors <- length(errors)

  # if errors occurred attach as an attribute
  if (n_errors > 0) {
    attr(results, "error_requests") <- all_reqs[errors]
    # add a warning when n_errors > 0
    cli::cli_warn(c(
      "x" = "Issue{cli::qty(n_errors)}{?s} encountered when processing response{cli::qty(n_errors)}{?s} {cli::qty(n_errors)} {errors}",
      "i" = "access problem requests with {.code attr(result, \"error_requests\")}"
    ))
  }

  results
}

parse_locations_res <- function(string) {
  res_list <- parse_location_json(string)
  if (is.null(res_list)) {
    return(NULL)
  }
  res <- res_list[["attributes"]]
  geometry <- sf::st_sfc(res_list[["locations"]], crs = res_list$sr$wkid)
  # craft the {sf} object
  sf::st_sf(res, geometry)
}

#' Might want to migrate into arcgisutils
#' https://github.com/R-ArcGIS/arcgislayers/blob/6e55b5f5b2c6037df1940fc10b72bfc42a11d9d6/R/utils.R#L84C1-L98C1
#' For a given number of items and a chunk size, determine the start and end
#' positions of each chunk.
#'
#' @param n the number of rows
#' @param m the chunk size
#' @keywords internal
#' @noRd
chunk_indices <- function(n, m) {
  n_chunks <- ceiling(n / m)
  chunk_starts <- seq(1, n, by = m)
  chunk_ends <- seq_len(n_chunks) * m
  chunk_ends[n_chunks] <- n
  list(start = chunk_starts, end = chunk_ends)
}
