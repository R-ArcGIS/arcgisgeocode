#' Reverse Geocode Locations
#'
#' Determines the address for a given point.
#'
#' @details
#' This function utilizes the
#' [`/reverseGeocode`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm) endpoint of a geocoding service. By default, it uses
#' the public ArcGIS World Geocoder.
#'
#' - Intersection matches are only returned when `feature_types = "StreetInt"`. See [REST documentation for more](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm#ESRI_SECTION3_1FE6B6D350714E45B2707845ADA22E1E).
#'
#' ## Location Type
#'
#' - Specifies whether the output geometry shuold be the rooftop point or the
#' street entrance location.
#' - The `location_type` parameter changes the geometry's placement but does not
#' change the attribute values of `X`, `Y`, or `DisplayX`, and `DisplayY`.
#'
#' ## Storage
#'
#' **Very Important**
#'
#' The argument `for_storage` is used to determine if the request allows you to
#' persist the results of the query. It is important to note that there are
#' contractual obligations to appropriately set this argument. **You cannot save
#' or persist results** when `for_storage = FALSE` (the default).
#'
#' ## Execution
#'
#' The `/reverseGeocode` endpoint can only handle one address at a time. To
#' make the operation as performant as possible, requests are sent in parallel
#' using [`httr2::req_perform_parallel()`]. The JSON responses are then processed
#' using Rust and returned as an sf object.
#'
#' @examples
#' # Find addresses from locations
#' reverse_geocode(c(-117.172, 34.052))
#' @param locations an `sfc_POINT` object of the locations to be reverse geocoded.
#' @param crs the CRS of the returned geometries. Passed to `sf::st_crs()`.
#'   Ignored if `locations` is not an `sfc_POINT` object.
#' @param ... unused.
#' @param lang_code default `NULL`. An ISO 3166 country code.
#'   See [`iso_3166_codes()`] for valid ISO codes. Optional.
#' @param feature_type limits the possible match types returned. Must be one of
#' `"StreetInt"`, `"DistanceMarker"`, `"StreetAddress"`, `"StreetName"`,
#' `"POI"`, `"Subaddress"`, `"PointAddress"`, `"Postal"`, or `"Locality"`. Optional.
#' @param location_type default `"rooftop"`. Must be one of `"rooftop"` or `"street"`.
#'  Optional.
#' @param preferred_label_values default NULL. Must be one of `"postalCity"`
#'  or `"localCity"`. Optional.
#' @param for_storage default `FALSE`. Whether or not the results will be saved
#'    for long term storage.
#' @param geocoder default [`default_geocoder()`].
#' @param .progress default `TRUE`. Whether a progress bar should be provided.
#' @inheritParams arcgisutils::arc_base_req
#' @export
#' @return An sf object.
reverse_geocode <- function(
    locations,
    crs = sf::st_crs(locations),
    ...,
    lang_code = NULL,
    feature_type = NULL,
    location_type = c("rooftop", "street"),
    preferred_label_values = c("postalCity", "localCity"),
    for_storage = FALSE,
    geocoder = default_geocoder(),
    token = arc_token(),
    .progress = TRUE) {
  # TODO ask users to verify their `for_storage` use
  # This is super important and can lead to contractual violations
  check_geocoder(geocoder, call = rlang::caller_env())

  if (!"reversegeocode" %in% capabilities(geocoder)) {
    arg <- rlang::caller_arg(geocoder)
    cli::cli_abort("{.arg {arg}} does not support  the {.path /reverseGeocode} endpoint")
  }

  check_for_storage(for_storage, token, call = rlang::caller_env())

  check_bool(.progress)

  # check feature type if not missing
  if (!is.null(feature_type)) {
    rlang::arg_match(
      feature_type,
      c(
        "StreetInt", "DistanceMarker", "StreetAddress",
        "StreetName", "POI", "Subaddress",
        "PointAddress", "Postal", "Locality"
      )
    )
  }

  # verify location type argument
  location_type <- rlang::arg_match(location_type, values = c("rooftop", "street"))

  # verify label value arg
  preferred_label_values <- rlang::arg_match(
    preferred_label_values,
    values = c("postalCity", "localCity")
  )

  # if locations is not an sfc object, we set to 4326
  # otherwise we validate output CRS
  if (!rlang::inherits_all(locations, c("sfc_POINT", "sfc"))) {
    crs <- 4326
  } else if (is.na(crs)) {
    cli::cli_warn(
      c(
        "!" = "{.arg crs} is set to {.cls NA}",
        "i" = "using {.code EPSG:4326}"
      )
    )
    crs <- 4326
  }

  # TODO use wk to use any wk_handle-able points
  # validates location input
  locations <- obj_as_points(locations)

  # ensure lang_code a single string
  check_string(lang_code, allow_null = TRUE)

  # if not missing and not valid, error
  if (!is.null(lang_code) && !is_iso3166(lang_code)) {
    cli::cli_abort(
      c(
        "{.arg lang_code} is not a recognized Country Code",
        "i" = "See {.fn iso_3166_codes} for ISO 3166 codes"
      )
    )
  }

  # get the JSON output
  out_crs <- validate_crs(crs)[[1]]

  # create list of provided parameters
  query_params <- compact(list(
    langCode = lang_code,
    outSR = jsonify::to_json(out_crs, unbox = TRUE),
    featureType = feature_type,
    forStorage = for_storage,
    locationType = location_type,
    preferredLabelValues = preferred_label_values
  ))

  # validate the input CRS
  in_crs <- validate_crs(sf::st_crs(locations))[[1]]

  # convert to EsriPoint JSON
  locs_json <- as_esri_point_json(locations, in_crs)

  b_req <- arc_base_req(
    geocoder[["url"]],
    token,
    path = "reverseGeocode"
  )

  # allocate list to store requests
  all_reqs <- vector(mode = "list", length = length(locs_json))

  # fill requests with for loop
  for (i in seq_along(locs_json)) {
    all_reqs[[i]] <- httr2::req_body_form(
      f = "json",
      b_req,
      !!!query_params,
      location = locs_json[[i]]
    )
  }

  # Run requests in parallel
  all_resps <- httr2::req_perform_parallel(
    all_reqs,
    on_error = "continue",
    progress = .progress
  )

  # TODO capture which locations had an error and either return
  # requests or points
  # also, should return missing values or IDs to associate with the points
  # so that they can be merged back on to the input locations?
  # TODO check for errors which will be encoded as json
  resps_json <- httr2::resps_data(all_resps, httr2::resp_body_string)

  # process the raw json using rust
  res_raw <- parse_rev_geocode_resp(resps_json)

  # TODO incorporate squish DF into arcgisutils. This is stopgap solution
  # https://github.com/R-ArcGIS/arcgislayers/pull/167
  res_attr <- data_frame(rbind_results(res_raw$attributes))

  # cast into sf object
  res_sf <- sf::st_sf(
    res_attr,
    geometry = sf::st_sfc(res_raw[["geometry"]], crs = crs)
  )

  res_sf
  # Return the errors as an attribute this will let people
  # handle the failures later on if they need to do an iterative / recursive
  # approach to it.
  # or use tokio....
  # I'll try both
}


# notes -------------------------------------------------------------------

# We need to have an object for GeocoderService
# Much like we have one for FeatureLayer etc
# These store so much metadata that will be needed.
# What is the workflow?
# arc_open("geocoder-url") or `geocoder("url"/"id")`
# We can use rust to create the JSON from the points
# Or do we want to have Rust do it _all_? I think that might be nice..
# would need to inherit the arc_agent() and X-Esri-Authorization headerre
