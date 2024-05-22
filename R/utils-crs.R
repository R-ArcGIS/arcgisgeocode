#' Returns a CRS object from a WKID
#'
#' When an Esri WKID is returned, they are not recognized
#' by {sf} without a prefixed authority e.g. `"Esri:102719"`.
#' This function adds the Esri authority prefix if it is
#' recognized as an Esri WKID.
#'
#' @details
#' Esri WKIDs were identified from the [`{arcgeocoder}`](https://cran.r-project.org/package=arcgeocoder) package from
#' [\@dieghernan](https://github.com/dieghernan).
#'
#' @param wkid an integer scalar
#' @keywords internal
#' @noRd
parse_wkid <- function(wkid) {
  is_esri_srid <- any(wkid == esri_wkids)
  if (is_esri_srid) {
    sf::st_crs(paste("ESRI", wkid, sep = ":"))
  } else {
    sf::st_crs(wkid)
  }
}
