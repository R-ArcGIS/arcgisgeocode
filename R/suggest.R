suggest_places <- function(
    text,
    location = NULL,
    category = NULL,
    search_extent = NULL,
    max_suggestions = NULL,
    country_code = NULL,
    preferred_label_values = NULL,
    geocoder = default_geocoder(),
    token = arc_token()
) {

  check_string(text)
  check_string(category, allow_null = TRUE)

  # searchExtent
  check_extent(
    search_extent,
    arg = rlang::caller_arg(search_extent),
    call = rlang::current_env()
  )

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
    geocoder, path = "suggest", query = list(f = "json")
  )

  httr2::req_body_form(

  )
}
