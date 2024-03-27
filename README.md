
<!-- README.md is generated from README.Rmd. Please edit that file -->

# arcgisgeocode

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/arcgisgeocode)](https://CRAN.R-project.org/package=arcgisgeocode)
[![R-CMD-check](https://github.com/R-ArcGIS/arcgisgeocode/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/R-ArcGIS/arcgisgeocode/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of arcgisgeocode is to provide access to ArcGIS geocoding
services from R. Enables address canddiate identification, batch
geocoding, reverse geocoding, autocomplete suggestions.

## Installation

arcgisgeocode uses [`extendr`](https://extendr.github.io/) and requires
Rust to be available to install the development version of
arcgisgeocode. Follow the [rustup instructions](https://rustup.rs/) to
install Rust and verify your installation is compatible using
[`rextendr::rust_sitrep()`](https://extendr.github.io/rextendr/dev/#sitrep).

You can install the development version of arcgisgeocode like so:

``` r
# install pak if not available
if (!requireNamespace("pak")) install.packages("pak")

# install development version of {arcgisgeocode}
pak::pak("r-arcgis/arcgisgeocode")
```

## Example

List available geocoders based on an authorization token.

``` r
library(arcgisgeocode)

# create a point
x <- sf::st_sfc(sf::st_point(c(-117.172, 34.052)), crs = 4326)

# reverse geocode
reverse_geocode(x)
#> Simple feature collection with 1 feature and 22 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -117.172 ymin: 34.05204 xmax: -117.172 ymax: 34.05204
#> Geodetic CRS:  WGS 84
#>                                     Match_addr
#> 1 600-620 Home Pl, Redlands, California, 92374
#>                                   LongLabel      ShortLabel     Addr_type Type
#> 1 600-620 Home Pl, Redlands, CA, 92374, USA 600-620 Home Pl StreetAddress     
#>   PlaceName AddNum     Address Block Sector   Neighborhood District     City
#> 1              608 608 Home Pl              South Redlands          Redlands
#>   MetroArea             Subregion     Region RegionAbbr Territory Postal
#> 1           San Bernardino County California         CA            92374
#>   PostalExt     CntryName CountryCode                  geometry
#> 1           United States         USA POINT (-117.172 34.05204)

# find address candidates
candidates <- find_address_candidates(
  address = c("esri"),
  city = "redlands",
  country_code = "usa"
)

dplyr::glimpse(candidates[,1:10])
#> Rows: 1
#> Columns: 11
#> $ input_id    <int> 1
#> $ loc_name    <chr> "World"
#> $ status      <chr> "M"
#> $ score       <dbl> 100
#> $ match_addr  <chr> "Esri"
#> $ long_label  <chr> "Esri, 380 New York St, Redlands, CA, 92373, USA"
#> $ short_label <chr> "Esri"
#> $ addr_type   <chr> "POI"
#> $ type_field  <chr> "Business Facility"
#> $ place_name  <chr> "Esri"
#> $ geometry    <POINT [°]> POINT (-117.1957 34.05609)

# list available geocoding services for signed in account
# list_geocoders()
```
