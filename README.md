
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

list_geocoders()
#>                                                                   url northLat
#> 1 https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer     Ymax
#>   southLat eastLon westLon                           name batch placefinding
#> 1     Ymin    Xmax    Xmin ArcGIS World Geocoding Service  TRUE         TRUE
#>   suggest
#> 1    TRUE
```
