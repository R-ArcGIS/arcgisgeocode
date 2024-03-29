#'
#' @keywords internal
#' @noRd
check_for_storage <- function(
    for_storage,
    token,
    call = rlang::caller_env()) {
  check_bool(for_storage, call = call)
  # Tokens are required for reverseGeocoding for storage
  if (for_storage) {
    obj_check_token(token, call = call)
  }

  # TODO create message / warning for storage param
}

match_location_type <- function(
    location_type,
    .multiple = FALSE,
    call = rlang::caller_env()) {
  # TODO maybe want to use error_arg for better message
  rlang::arg_match(
    location_type,
    values = c("rooftop", "street"),
    multiple = .multiple,
    error_call = call
  )
}

match_label_values <- function(
    preferred_label_values,
    .multiple = FALSE,
    call = rlang::caller_env()) {
  rlang::arg_match(
    preferred_label_values,
    values = c("postalCity", "localCity"),
    multiple = .multiple,
    error_call = call
  )
}

check_iso_3166 <- function(
    x,
    allow_null = TRUE,
    scalar = FALSE,
    arg = rlang::caller_arg(x),
    call = rlang::caller_env()) {
  if (is.null(x)) {
    return(invisible(NULL))
  }

  if (scalar) {
    check_string(x, allow_null = allow_null)
  } else {
    check_character(x, allow_null = allow_null)
  }

  if (!all(is_iso3166(x))) {
    cli::cli_abort(
      c(
        "{.arg {arg}} is not a recognized Country Code",
        "i" = "See {.fn iso_3166_codes} for ISO 3166 codes"
      ),
      call = call
    )
  }
}


check_locations <- function(
    locations,
    allow_null = TRUE,
    call = rlang::caller_env()) {
  if (is.null(locations)) {
    return(invisible(NULL))
  }

  if (!rlang::inherits_all(locations, c("sfc_POINT", "sfc"))) {
    stop_input_type(locations, "sfc_POINT", call = call)
  }
}

check_extent <- function(
    extent,
    allow_null = TRUE,
    arg = rlang::caller_arg(extent),
    call = rlang::caller_env()) {
  if (is.null(extent)) {
    return(invisible(NULL))
  }

  if (!rlang::inherits_all(extent, "bbox")) {
    stop_input_type(extent, "bbox", call = call)
  }
}

inform_for_storage <- function(call = rlang::current_env()) {
  # TODO have a global option check that will supress this message
  cli::cli_inform(
    c(
      "!" = "{.arg for_storage} is set to {.code FALSE}, results cannot be persisted",
      "i" = "see legal obligations at {.url https://esri.com}"
    ),
    .frequency = "once", .frequency_id = "for_storage"
  )
}

obj_as_points <- function(
    x,
    allow_null = TRUE,
    arg = rlang::caller_arg(x),
    call = rlang::current_env()) {
  if (is.null(x) && allow_null) {
    return(NULL)
  } else if (rlang::inherits_any(x, "POINT")) {
    if (abs(x[1]) > 180 || abs(x[[2]]) > 90) {
      abort_4326(arg, call)
    }
    return(sf::st_sfc(x, crs = 4326))
  } else if (rlang::inherits_any(x, "matrix") && is.numeric(x)) {
    if (max(abs(x[, 1]), na.rm = TRUE) > 180 || max(abs(x[, 2]), na.rm = TRUE) > 90) {
      abort_4326(arg, call)
    }
    return(sf::st_cast(sf::st_sfc(sf::st_multipoint(x), crs = 4326), "POINT"))
  } else if (is.numeric(x)) {
    if (abs(x[1]) > 180 || abs(x[[2]]) > 90) {
      abort_4326(arg, call)
    }
    return(sf::st_sfc(sf::st_point(x), crs = 4326))
  } else if (rlang::inherits_all(x, c("sfc_POINT", "sfc"))) {
    return(x)
  } else {
    cli::cli_abort(c(
      "{.arg {arg}} cannot be converted to a point",
      "i" = "found {obj_type_friendly(x)}"
    ), arg = arg, call = call)
  }
}

abort_4326 <- function(arg, call) {
  cli::cli_abort(c(
    "{.arg {arg}}, {obj_type_friendly(x)}, must be in EPSG:4326",
    ">" = "{.code longitude} values must be in the range [-180, 180]",
    " " = "and {.code latitude} values must be in the range [-90, 90]"
  ), call = call)
}

#
# check_extent <- function(
#     x,
#     ...,
#     allow_null = FALSE,
#     arg = rlang::caller_arg(x),
#     call = rlang::caller_env()
# ) {
#   if (!missing(x)) {
#     if (rlang::inherits_any(x, "bbox")) {
#       return(invisible(NULL))
#     }
#     if (allow_null && rlang::is_null(x)) {
#       return(invisible(NULL))
#     }
#   }
#
#   stop_input_type(
#     x,
#     "a `bbox`",
#     ...,
#     allow_na = FALSE,
#     allow_null = allow_null,
#     arg = arg,
#     call = call
#   )
# }
