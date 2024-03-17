
# Valid featuretypes to be returned
feature_types <- c("StreetInt", "DistanceMarker", "StreetAddress", "StreetName", "POI", "Subaddress", "PointAddress", "Postal", "Locality")

#  Intersection matches are only returned when featureTypes=StreetInt is included in the request.

# The locationType parameter only affects the location object in the geocode JSON response. It does not change the X/Y or DisplayX/DisplayY attribute values.

# loation_type
# Specifies whether the output geometry of PointAddress and Subaddress matches should be the rooftop point or street entrance location. Valid values are rooftop and street. The default value is rooftop.

reverse_geocode <- function(
    locations,
    crs = sf::st_crs(locations),
    ...,
    lang = NULL,
    feature_type = NULL,
    for_storage = TRUE,
    location_type = c("rooftop", "street"),
    preferred_label_values = c("postalCity", "localCity"),
    geocoder = default_geocoder(),
    token = arc_token()
) {

  # TODO
  # rlang::arg_match0(for_storage)
  # rlang::arg_match0(preferred_label_values)

  # Check that locations are an sf object
  # encode locations as a featureset (on the geometry only)
  # this endpoint only supports single addresses
  # we would want to use `req_perform_parallel` here
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
