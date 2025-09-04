

<!-- README.md is generated from README.Rmd. Please edit that file -->

# arcgisgeocode

<!-- badges: start -->

[![extendr](https://img.shields.io/badge/extendr-%5E0.8.0-276DC2)](https://extendr.github.io/extendr/extendr_api/)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![CRAN
status](https://www.r-pkg.org/badges/version/arcgisgeocode.png)](https://CRAN.R-project.org/package=arcgisgeocode)
[![Downloads](https://cranlogs.r-pkg.org/badges/arcgisgeocode.png)](https://cran.r-project.org/package=arcgisgeocode)
<!-- badges: end -->

arcgisgeocode is a high-performance R package providing comprehensive
access to ArcGIS geocoding services. Built with Rust and designed for
both interactive applications and enterprise workflows, it offers the
complete suite of ArcGIS geocoding capabilities.

## Key Capabilities

**🌍 Complete Geocoding Suite**:

- **Address suggestion**: Suggest addresses candidates with
  `find_address_candidates()`
- **Reverse geocoding**: Coordinates to addresses with
  `reverse_geocode()`
- **Batch geocoding**: Bulk processing with `geocode_addresses()`
- **Interactive suggestions**: Real-time autocomplete with
  `suggest_places()`

**Integrations**:

- ArcGIS Online
- ArcGIS Enterprise
- Custom locators (e.g. StreetMap Premium) note—does not support locator
  files

**🚀 High—Performance**:

- Vectorized operations across all geocoding functions
- Rust-powered JSON processing
- Parallel HTTP requests using `httr2` for concurrent geocoding
  operations
- Configurable batching for large datasets

## Installation

`{arcgisgeocode}` is part of the `{arcgis}` metapackage, which provides
the complete R-ArcGIS Bridge toolkit. For most users, installing the
metapackage is recommended:

``` r
# install from CRAN 
install.packages("arcgis")
```

You can also install {arcgislayers} individually from CRAN:

``` r
install.packages("arcgisgeocode")
```

To install the development version:

``` r
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
#> $ add_num      <chr> "604"
#> $ address      <chr> "604 Home Pl"
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
#> $ geometry    <POINT [°]> POINT (-117.1957 34.05609), POINT (-117.1954 34.0561)
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
#> 2 Bellwood Homes, 736 Jefferson St NW, Atlanta, GA, 303… dHA9MCN0… FALSE        
#> 3 Bellwood, Atlanta, GA, USA                             dHA9MCN0… FALSE        
#> 4 Bellwood Coffee, 1776 Peachtree St NW, Atlanta, GA, 3… dHA9MCN0… FALSE        
#> 5 Bellwood Church, Atlanta, GA, USA                      dHA9MCN0… FALSE
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
#> Rows: 5
#> Columns: 11
#> $ input_id    <int> 1, 2, 3, 4, 5
#> $ result_id   <int> NA, NA, NA, NA, NA
#> $ loc_name    <chr> NA, NA, NA, NA, NA
#> $ status      <chr> "M", "M", "M", "M", "M"
#> $ score       <dbl> 100, 100, 100, 100, 100
#> $ match_addr  <chr> "Bellwood Coffee", "Bellwood Homes", "Bellwood, Atlanta, G…
#> $ long_label  <chr> "Bellwood Coffee, 1366 Glenwood Ave SE, Atlanta, GA, 30316…
#> $ short_label <chr> "Bellwood Coffee", "Bellwood Homes", "Bellwood", "Bellwood…
#> $ addr_type   <chr> "POI", "POI", "Locality", "POI", "POI"
#> $ type_field  <chr> "Snacks", "Other Shops and Service", "City", "Snacks", "Ch…
#> $ geometry    <POINT [°]> POINT (-84.34272 33.74034), POINT (-84.41127 33.77591), PO…
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
and set your token. This example uses the Geocoding Test Dataset from
the [Urban Institute](https://www.urban.org/).

> [!TIP]
>
> A token *is required* to use this function with the World Geocoding
> Service. It may not be necessary if you are using a private ArcGIS
> Enterprise service.

``` r
set_arc_token(auth_user())

# Example dataset from the Urban Institute
fp <- "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2020/02/25/geocoding_test_data.csv"

to_geocode <- readr::read_csv(fp, show_col_types = FALSE)

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
#> Rows: 5
#> Columns: 11
#> $ input_id    <int> 1, 2, 3, 4, 5
#> $ result_id   <int> NA, NA, NA, NA, NA
#> $ loc_name    <chr> NA, NA, NA, NA, NA
#> $ status      <chr> "M", "M", "M", "M", "M"
#> $ score       <dbl> 100, 100, 100, 100, 100
#> $ match_addr  <chr> "Bellwood Coffee", "Bellwood Homes", "Bellwood, Atlanta, G…
#> $ long_label  <chr> "Bellwood Coffee, 1366 Glenwood Ave SE, Atlanta, GA, 30316…
#> $ short_label <chr> "Bellwood Coffee", "Bellwood Homes", "Bellwood", "Bellwood…
#> $ addr_type   <chr> "POI", "POI", "Locality", "POI", "POI"
#> $ type_field  <chr> "Snacks", "Other Shops and Service", "City", "Snacks", "Ch…
#> $ geometry    <POINT [°]> POINT (-84.34272 33.74034), POINT (-84.41127 33.77591), PO…
```

## Using other locators

You can use `list_geocoders()` to find all of the geocoders available to
you by your organization.

``` r
list_geocoders()
#> # A data frame: 1 × 10
#>   url     northLat southLat eastLon westLon name  suggest zoomScale placefinding
#> * <chr>   <chr>    <chr>    <chr>   <chr>   <chr> <lgl>       <int> <lgl>       
#> 1 https:… Ymax     Ymin     Xmax    Xmin    ArcG… TRUE        10000 TRUE        
#> # ℹ 1 more variable: batch <lgl>
```

`{arcgisgeocode}` can be used with other geocoding services, including
custom locators hosted on ArcGIS Online or Enterprise. You can search
for geocoding services that may be useful for you with
`arcgisutils::search_items()`.

``` r
search_items(item_type = "Geocoding Service", max_pages = 1)
#> # A data frame: 50 × 45
#>    id      owner created             modified            guid  name  title type 
#>  * <chr>   <chr> <dttm>              <dttm>              <lgl> <chr> <chr> <chr>
#>  1 62e6d8… jstr… 2017-09-21 20:46:45 2017-09-21 20:54:15 NA    <NA>  Brev… Geoc…
#>  2 495c4d… AdmB… 2020-01-13 08:21:34 2020-07-01 07:07:25 NA    <NA>  Sted… Geoc…
#>  3 b3f732… Clar… 2019-10-24 21:01:47 2019-10-24 21:02:35 NA    <NA>  Clar… Geoc…
#>  4 11f1b5… Erik… 2015-10-20 17:36:20 2017-11-28 17:24:30 NA    <NA>  COMP… Geoc…
#>  5 e2e52a… mari… 2017-02-09 12:20:33 2017-02-09 12:20:38 NA    <NA>  Topo… Geoc…
#>  6 c10754… balt… 2019-12-06 15:47:03 2019-12-06 15:47:06 NA    <NA>  EGIS… Geoc…
#>  7 2fde30… cbat… 2015-10-29 17:49:15 2015-10-29 17:49:15 NA    <NA>  Addr… Geoc…
#>  8 0983b4… dili… 2016-05-04 15:59:35 2016-05-04 15:59:35 NA    <NA>  what… Geoc…
#>  9 893e0b… gis_… 2017-11-15 09:19:05 2017-11-15 11:44:58 NA    <NA>  PKC   Geoc…
#> 10 b8bcbe… 3918  2014-03-21 13:00:08 2014-03-21 13:00:08 NA    <NA>  Indy… Geoc…
#> # ℹ 40 more rows
#> # ℹ 37 more variables: typeKeywords <list>, description <chr>, tags <list>,
#> #   snippet <chr>, thumbnail <chr>, documentation <lgl>, extent <list>,
#> #   categories <list>, spatialReference <chr>, accessInformation <chr>,
#> #   classification <lgl>, licenseInfo <chr>, culture <chr>, properties <list>,
#> #   advancedSettings <lgl>, url <chr>, sourceUrl <chr>, proxyFilter <lgl>,
#> #   access <chr>, size <int>, subInfo <int>, appCategories <list>, …
```

## Learn more

To learn more about geocoding with the R-ArcGIS Bridge visit the
[developers
site](https://developers.arcgis.com/r-bridge/geocoding/overview/).
