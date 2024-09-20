#' ArcGIS World Geocoder
#'
#' The [ArcGIS World Geocoder](https://www.esri.com/en-us/arcgis/products/arcgis-world-geocoder)
#' is made publicly available for some uses. The `world_geocoder` object is used
#' as the default `GeocodeServer` object in [`default_geocoder()`] when no
#' authorization token is found. The [`find_address_candidates()`],
#' [`reverse_geocode()`], and [`suggest_places()`] can be used without an
#' authorization token. The [`geocode_addresses()`] funciton requires an
#' authorization token to be used for batch geocoding.
#' @returns an object of class `GeocodeServer`
"world_geocoder"


#' Esri well-known IDs
#'
#' An integer vector containing the WKIDs of Esri authority
#' spatial references.
#' Esri WKIDs were identified from the [`{arcgeocoder}`](https://cran.r-project.org/package=arcgeocoder) package from
#' [@dieghernan](https://github.com/dieghernan).
#' @returns a numeric vector of well-known IDs
"esri_wkids"
