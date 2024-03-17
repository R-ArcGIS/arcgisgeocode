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
    lang = NULL,                                     # langCode
    feature_type = NULL,                             # featureType
    for_storage = TRUE,                              # forStorage
    location_type = c("rooftop", "street"),          # locationType
    preferred_label_values = c("postalCity", "localCity"),
    geocoder = default_geocoder(),
    token = arc_token()
) {

  # TODO
  # rlang::arg_match0(for_storage)
  # TODO
}
