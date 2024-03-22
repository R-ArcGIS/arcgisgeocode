#'
#' @keywords internal
#' @noRd
check_for_storage <- function(
    for_storage,
    token,
    call = rlang::caller_env()
) {
  check_bool(for_storage, call = call)
  # Tokens are required for reverseGeocoding for storage
  if (for_storage) {
    obj_check_token(token, call = call)
  }

  # TODO create message / warning for storage param
}

match_location_type <- function(
    location_type, call = rlang::caller_env()
) {
  # TODO maybe want to use error_arg for better message
  rlang::arg_match0(
    location_type,
    values = c("rooftop", "street"),
    error_call = call
  )
}

match_label_values <- function(
    preferred_label_values, call = rlang::caller_env()
) {
  rlang::arg_match0(
    preferred_label_values,
    values = c("postalCity", "localCity"),
    error_call = call
  )
}

check_iso_3166 <- function(
    lang_code,
    allow_null = TRUE,
    allow_na = FALSE,
    scalar = FALSE,
    arg = rlang::caller_arg(lang_code),
    call = rlang::caller_env()
) {
  if (scalar) {
    check_string(lang_code, allow_null = allow_null, allow_na = allow_na)
  } else {
    check_character(lang_code, allow_null = allow_null, allow_na = allow_na)
  }

  if (!all(is_iso3166(lang_code))) {
    cli::cli_abort(
      c(
        "{.arg {arg}} is not a recognized Country Code",
        "i" = "See {.fn iso_3166_codes} for ISO 3166 codes"
      ),
      call = call
    )
  }
}
