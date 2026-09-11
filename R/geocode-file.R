#' Read Batch Geocoding Results
#'
#' Reads the CSV written by a batch geocoding job.
#'
#' @param path String. Path to the result CSV.
#' @param crs Coordinate reference system of the result. Passed to `sf::st_crs()`.
#' @export
#' @returns An `sf` object, or a `data.frame` when the result has no coordinates.
#' @examples
#' \dontrun{
#' read_geocode_result("geocoded.csv")
#' }
read_geocode_result <- function(path, crs = 4326) {
  check_string(path, allow_empty = FALSE)

  if (!file.exists(path)) {
    cli::cli_abort("{.arg path} does not exist: {.file {path}}")
  }

  res <- utils::read.csv(path, check.names = FALSE, colClasses = "character")
  names(res) <- snake_geocode_names(names(res))

  res <- type.convert(res, as.is = TRUE)

  if (!all(c("x", "y") %in% names(res))) {
    return(data_frame(res))
  }

  sf::st_as_sf(
    data_frame(res),
    coords = c("x", "y"),
    crs = sf::st_crs(crs),
    na.fail = FALSE,
    remove = FALSE
  )
}

# result fields are prefixed with `LOC_`; input columns are returned untouched
snake_geocode_names <- function(x) {
  is_result <- startsWith(x, "LOC_")
  stripped <- sub("^LOC_", "", x[is_result])
  i <- match(stripped, names(esri_field_names))

  x[is_result] <- ifelse(is.na(i), to_snake_case(stripped), esri_field_names[i])
  x
}

to_snake_case <- function(x) {
  tolower(gsub("([a-z0-9])([A-Z])", "\\1_\\2", x))
}

# canonical names, matching the output of `geocode_addresses()`
esri_field_names <- c(
  "ResultID" = "result_id",
  "Loc_name" = "loc_name",
  "Status" = "status",
  "Score" = "score",
  "Match_addr" = "match_addr",
  "LongLabel" = "long_label",
  "ShortLabel" = "short_label",
  "Addr_type" = "addr_type",
  "Type" = "type_field",
  "PlaceName" = "place_name",
  "Place_addr" = "place_addr",
  "Phone" = "phone",
  "URL" = "url",
  "Rank" = "rank",
  "AddBldg" = "add_bldg",
  "AddNum" = "add_num",
  "AddNumFrom" = "add_num_from",
  "AddNumTo" = "add_num_to",
  "AddRange" = "add_range",
  "Side" = "side",
  "StPreDir" = "st_pre_dir",
  "StPreType" = "st_pre_type",
  "StName" = "st_name",
  "StType" = "st_type",
  "StDir" = "st_dir",
  "BldgType" = "bldg_type",
  "BldgName" = "bldg_name",
  "LevelType" = "level_type",
  "LevelName" = "level_name",
  "UnitType" = "unit_type",
  "UnitName" = "unit_name",
  "SubAddr" = "sub_addr",
  "StAddr" = "st_addr",
  "Block" = "block",
  "Sector" = "sector",
  "Nbrhd" = "nbrhd",
  "District" = "district",
  "City" = "city",
  "MetroArea" = "metro_area",
  "Subregion" = "subregion",
  "Region" = "region",
  "RegionAbbr" = "region_abbr",
  "Territory" = "territory",
  "Zone" = "zone",
  "Postal" = "postal",
  "PostalExt" = "postal_ext",
  "Country" = "country",
  "CntryName" = "cntry_name",
  "LangCode" = "lang_code",
  "Distance" = "distance",
  "X" = "x",
  "Y" = "y",
  "DisplayX" = "display_x",
  "DisplayY" = "display_y",
  "Xmin" = "xmin",
  "Xmax" = "xmax",
  "Ymin" = "ymin",
  "Ymax" = "ymax",
  "ExInfo" = "ex_info",
  "BldgComp" = "bldg_comp",
  "StrucType" = "struc_type",
  "StrucDet" = "struc_det",
  "ShapeX" = "shape_x",
  "ShapeY" = "shape_y"
)
