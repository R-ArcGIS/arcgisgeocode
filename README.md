
<!-- README.md is generated from README.Rmd. Please edit that file -->

# arcgeocode

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/arcgeocode)](https://CRAN.R-project.org/package=arcgeocode)
<!-- badges: end -->

The goal of arcgeocode is to provide access to ArcGIS geocoding services
from R. Enables address canddiate identification, batch geocoding,
reverse geocoding, autocomplete suggestions.

## Installation

arcgeocode uses [`extendr`](https://extendr.github.io/) and requires
Rust to be available to install the development version of arcgeocode.
Follow the [rustup instructions](https://rustup.rs/) to install Rust and
verify your installation is compatible using
[`rextendr::rust_sitrep()`](https://extendr.github.io/rextendr/dev/#sitrep).

You can install the development version of arcgeocode like so:

``` r
# install pak if not available
if (!requireNamespace("pak")) install.packages("pak")

# install development version of {arcgeocode}
pak::pak("r-arcgis/arcgeocode")
```

## Example

List available geocoders based on an authorization token.

``` r
library(arcgeocode)
#> Warning: replacing previous import 'arcgisutils::%||%' by 'rlang::%||%' when
#> loading 'arcgeocode'

# create a point
x <- sf::st_sfc(sf::st_point(c(-117.172, 34.052)), crs = 4326)

# reverse geocode
reverse_geocode(x)
#> Simple feature collection with 1 feature and 22 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -117.172 ymin: 34.052 xmax: -117.172 ymax: 34.052
#> Geodetic CRS:  WGS 84
#>                                       Match_addr
#> 1 600-620 E Home Pl, Redlands, California, 92374
#>                                     LongLabel        ShortLabel     Addr_type
#> 1 600-620 E Home Pl, Redlands, CA, 92374, USA 600-620 E Home Pl StreetAddress
#>   Type PlaceName AddNum       Address Block Sector   Neighborhood District
#> 1                   608 608 E Home Pl              South Redlands         
#>       City     MetroArea             Subregion     Region RegionAbbr Territory
#> 1 Redlands Inland Empire San Bernardino County California         CA          
#>   Postal PostalExt     CntryName CountryCode                geometry
#> 1  92374           United States         USA POINT (-117.172 34.052)

# list available geocoding services for signed in account
list_geocoders()
#> # A data frame: 1 × 9
#>   url         northLat southLat eastLon westLon name  batch placefinding suggest
#> * <chr>       <chr>    <chr>    <chr>   <chr>   <chr> <lgl> <lgl>        <lgl>  
#> 1 https://ge… Ymax     Ymin     Xmax    Xmin    ArcG… TRUE  TRUE         TRUE
```
