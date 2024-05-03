
<!-- README.md is generated from README.Rmd. Please edit that file -->

# arcgisgeocode

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/arcgisgeocode.png)](https://CRAN.R-project.org/package=arcgisgeocode)
[![R-CMD-check](https://github.com/R-ArcGIS/arcgisgeocode/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/R-ArcGIS/arcgisgeocode/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

arcgisgeocode provides access to ArcGIS geocoding services from R. It
supports address candidate identification, batch geocoding, reverse
geocoding, and autocomplete suggestions.

## Installation

Install the package from CRAN

``` r
# install from CRAN 
install.packages("arcgisgeocode")
```

You can also install the development version from r-universe as a binary
for Mac, Windows, or Ubuntu from r-universe like so:

``` r
# install from R-universe
install.packages("arcgisgeocode", repos = "https://r-arcgis.r-universe.dev")
```

Or you can install the package from source which requires Rust to be
available. Follow the [rustup instructions](https://rustup.rs/) to
install Rust and verify your installation is compatible using
[`rextendr::rust_sitrep()`](https://extendr.github.io/rextendr/dev/#sitrep).
Then install the development version from GitHub:

``` r
# install pak if not available
if (!requireNamespace("pak")) install.packages("pak")

# install development version of {arcgisgeocode}
pak::pak("r-arcgis/arcgisgeocode")
```

## Usage

By default, the [ArcGIS World
Geocoder](https://www.esri.com/en-us/arcgis/products/arcgis-world-geocoder)
will be used. This geocoding server provides public access to the
[`/findAddressCandidates`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-find-address-candidates.htm),
[`/reverseGeocode`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-reverse-geocode.htm),
and
[`/suggest`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-suggest.htm)
endpoints made available via the `find_address_candidates()`,
`reverse_geocode()`, and `suggest_places()` functions respectively.

The batch geocoding endpoint
[`/geocodeAddresses`](https://developers.arcgis.com/rest/geocode/api-reference/geocoding-geocode-addresses.htm)
is available via `geocode_addresses()`. However, this requires the use
of an authorization token and may consume credits.

Refer to the ArcGIS World Geocoder [official
documentation](https://developers.arcgis.com/rest/geocode/api-reference/overview-world-geocoding-service.htm)
for additional information on use restrictions and licensing. For
example, a valid token is required to [store the
results](#important-storing-results) of geocoding transactions.

### Reverse geocoding

Reverse geocoding takes a location and finds the associated address.

> [!TIP]
>
> A token *is not required* to use this function.

``` r
library(arcgisgeocode)

# Find addresses from locations
rev_res <- reverse_geocode(c(-117.172, 34.052))

# preview results
dplyr::glimpse(rev_res)
#> Rows: 1
#> Columns: 23
#> $ match_addr   <chr> "600-620 Home Pl, Redlands, California, 92374"
#> $ long_label   <chr> "600-620 Home Pl, Redlands, CA, 92374, USA"
#> $ short_label  <chr> "600-620 Home Pl"
#> $ addr_type    <chr> "StreetAddress"
#> $ type_field   <chr> ""
#> $ place_name   <chr> ""
#> $ add_num      <chr> "608"
#> $ address      <chr> "608 Home Pl"
#> $ block        <chr> ""
#> $ sector       <chr> ""
#> $ neighborhood <chr> "South Redlands"
#> $ district     <chr> ""
#> $ city         <chr> "Redlands"
#> $ metro_area   <chr> ""
#> $ subregion    <chr> "San Bernardino County"
#> $ region       <chr> "California"
#> $ region_abbr  <chr> "CA"
#> $ territory    <chr> ""
#> $ postal       <chr> "92374"
#> $ postal_ext   <chr> ""
#> $ country_name <chr> "United States"
#> $ country_code <chr> "USA"
#> $ geometry     <POINT [°]> POINT (-117.172 34.05204)
```

### Address search

The `find_address_candidates()` function returns geocoding candidate
results. The function is vectorized over the input and will perform
multiple requests in parallel. Each request geocodes one location at a
time.

One or more candidates are returned from the endpoint. You can limit the
number of candidates using the `max_locations` argument (with a maximum
of 50).

> [!TIP]
>
> A token *is not required* to use this function.

``` r
# Find addresses from address search
candidates <- find_address_candidates(
  address = "esri",
  address2 = "380 new york street",
  city = "redlands",
  country_code = "usa",
  max_locations = 2
)

dplyr::glimpse(candidates[, 1:10])
#> Rows: 2
#> Columns: 11
#> $ input_id    <int> 1, 1
#> $ result_id   <int> NA, NA
#> $ loc_name    <chr> "World", "World"
#> $ status      <chr> "M", "M"
#> $ score       <dbl> 100.00, 98.57
#> $ match_addr  <chr> "Esri", "380 New York St, Redlands, California, 92373"
#> $ long_label  <chr> "Esri, 380 New York St, Redlands, CA, 92373, USA", "380 Ne…
#> $ short_label <chr> "Esri", "380 New York St"
#> $ addr_type   <chr> "POI", "PointAddress"
#> $ type_field  <chr> "Business Facility", NA
#> $ geometry    <POINT [°]> POINT (-117.1957 34.05609), POINT (-117.1948 34.05726)…
```

### Suggest locations

Geocoding services can also provide a location suggestion based on a
search term and, optionally, a location or extent. The
`suggest_places()` function (`/suggest` endpoint) is intended to be used
as part of a client-facing application that provides autocomplete
suggestions.

In this example we create a search extent around a single point and find
suggestions based on the search term `"bellwood"`.

> [!TIP]
>
> A token *is not required* to use this function.

``` r
# identify a search point as a simple feature column
location <- sf::st_sfc(
  sf::st_point(c(-84.34, 33.74)),
  crs = 4326
)

# buffer and create a bbox object to search within the extent
search_extent <- sf::st_bbox(
  sf::st_buffer(location, 10)
)

# find suggestions within the bounding box
suggestions <- suggest_places(
  "bellwood",
  location,
  search_extent = search_extent
)

suggestions
#> # A data frame: 5 × 3
#>   text                                                   magic_key is_collection
#> * <chr>                                                  <chr>     <lgl>        
#> 1 Bellwood Coffee, 1366 Glenwood Ave SE, Atlanta, GA, 3… dHA9MCN0… FALSE        
#> 2 Bellwood, Atlanta, GA, USA                             dHA9MCN0… FALSE        
#> 3 Bellwood Church, Atlanta, GA, USA                      dHA9MCN0… FALSE        
#> 4 Bellwood Yard, Atlanta, GA, USA                        dHA9MCN0… FALSE        
#> 5 Bellwood, IL, USA                                      dHA9NCN0… FALSE
```

The result is intended to be provided to `find_address_candidates()` to
complete the geocoding process. The column `text` contains the address
to geocode. The column `magic_key` is a special identifier that makes it
much faster to fetch results. Pass this into the argument `magic_key`.

``` r
# get address candidate information
# using the text and the magic key
res <- find_address_candidates(
  suggestions$text,
  magic_key = suggestions$magic_key
)

dplyr::glimpse(res[, 1:10])
#> Rows: 7
#> Columns: 11
#> $ input_id    <int> 1, 2, 3, 4, 5, 5, 5
#> $ result_id   <int> NA, NA, NA, NA, NA, NA, NA
#> $ loc_name    <chr> NA, NA, NA, NA, NA, NA, NA
#> $ status      <chr> "M", "M", "M", "M", "T", "T", "T"
#> $ score       <dbl> 100, 100, 100, 100, 100, 100, 100
#> $ match_addr  <chr> "Bellwood Coffee", "Bellwood, Atlanta, Georgia", "Bellwood…
#> $ long_label  <chr> "Bellwood Coffee, 1366 Glenwood Ave SE, Atlanta, GA, 30316…
#> $ short_label <chr> "Bellwood Coffee", "Bellwood", "Bellwood Church", "Bellwoo…
#> $ addr_type   <chr> "POI", "Locality", "POI", "POI", "Locality", "Locality", "…
#> $ type_field  <chr> "Snacks", "City", "Church", "Building", "City", "City", "C…
#> $ geometry    <POINT [°]> POINT (-84.34273 33.74034), POINT (-84.41243 33.77455), PO…
```

## *Important*: Storing results

By default, the argument `for_storage = FALSE` meaning that the results
of the geocoding operation cannot be persisted. If you intend to persist
the results of the geocoding operation, you must set
`for_storage = TRUE`.

To learn more about free and paid geocoding operations refer to the
[storage parameter
documentation](https://developers.arcgis.com/documentation/mapping-apis-and-services/geocoding/services/geocoding-service/#storage-parameter).

## Batch geocoding

Many addresses can be geocoded very quickly using the
`geocode_addresses()` function which calls the `/geocodeAddresses`
endpoint. Note that this function requires an authorization token.
`geocode_addresses()` sends the input addresses in chunks as parallel
requests.

Batch geocoding requires a signed in user. Load the
[`{arcgisutils}`](https://github.com/r-arcgis/arcgisutils) to authorize
and set your token. This example uses the [Geocoding Test
Dataset](#%20https://datacatalog.urban.org/node/6158/revisions/14192/view)
from the [Urban Institute](https://www.urban.org/).

> [!TIP]
>
> A token *is required* to use this function with the World Geocoding
> Service. It may not be necessary if you are using a private ArcGIS
> Enterprise service.

``` r
library(arcgisutils)
library(arcgisgeocode)

set_arc_token(auth_user())

# Example dataset from the Urban Institute
fp <- "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2020/02/25/geocoding_test_data.csv"

to_geocode <- readr::read_csv(fp, readr::locale(encoding = "latin1"))

geocoded <- to_geocode |>
  dplyr::reframe(
    geocode_addresses(
      address = address,
      city = city,
      region = state,
      postal = zip
    )
  )

dplyr::glimpse(res[, 1:10])
```

## Using other locators

`{arcgisgeocode}` can be used with other geocoding services, including
custom locators hosted on ArcGIS Online or Enterprise. For example, we
can use the [AddressNC](https://www.nconemap.gov/pages/addresses)
geocoding service [available on ArcGIS
Online](https://www.arcgis.com/home/item.html?id=247dfe30ec42476a96926ad9e35f725f).

Create a new `GeocodeServer` object using `geocode_server()`. This
geocoder can be passed into the `geocoder` argument to any of the
geocoding functions.

``` r
address_nc <- geocode_server(
  "https://services.nconemap.gov/secure/rest/services/AddressNC/AddressNC_geocoder/GeocodeServer",
  token = NULL
)

res <- find_address_candidates(
  address = "rowan coffee",
  city = "asheville",
  geocoder = address_nc
)

dplyr::glimpse(res[, 1:10])
#> Rows: 2
#> Columns: 11
#> $ input_id    <int> 1, 1
#> $ result_id   <int> NA, NA
#> $ loc_name    <chr> NA, NA
#> $ status      <chr> "T", "T"
#> $ score       <dbl> 78, 78
#> $ match_addr  <chr> "ASHEVILLE", "ASHEVILLE"
#> $ long_label  <chr> "ASHEVILLE", "ASHEVILLE"
#> $ short_label <chr> "ASHEVILLE", "ASHEVILLE"
#> $ addr_type   <chr> "Locality", "Locality"
#> $ type_field  <chr> "City", "City"
#> $ geometry    <POINT [US_survey_foot]> POINT (943428.1 681596.4), POINT (948500.3 631973.4)…
```
