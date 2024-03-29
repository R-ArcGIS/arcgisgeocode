
<!-- README.md is generated from README.Rmd. Please edit that file -->



# arcgisgeocode

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN status](https://www.r-pkg.org/badges/version/arcgisgeocode)](https://CRAN.R-project.org/package=arcgisgeocode)
[![R-CMD-check](https://github.com/R-ArcGIS/arcgisgeocode/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/R-ArcGIS/arcgisgeocode/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of arcgisgeocode is to provide access to ArcGIS geocoding services from R. Enables address canddiate identification, batch geocoding, reverse geocoding, autocomplete suggestions. 

## Installation

arcgisgeocode uses [`extendr`](https://extendr.github.io/) and requires Rust to be available to install the development version of arcgisgeocode. Follow the  [rustup instructions](https://rustup.rs/) to install Rust and verify your installation is compatible using [`rextendr::rust_sitrep()`](https://extendr.github.io/rextendr/dev/#sitrep).

If you do not have Rust installed, you can install a binary for Mac, Windows, or Ubuntu from r-universe.

You can install the package like so: 

``` r
# install pak if not available
if (!requireNamespace("pak")) install.packages("pak")

# install development version of {arcgisgeocode}
pak::pak("r-arcgis/arcgisgeocode")

# install from R-universe
install.packages("arcgisgeocode", repos = c("https://r-arcgis.r-universe.dev", "https://cran.r-project.org"))
```

## Usage

By default, the public [ArcGIS World Geocoder](https://www.esri.com/en-us/arcgis/products/arcgis-world-geocoder) will be used. The public face geocoding server provides public access to the `/findAddressCandidates`, `reverseGeocode`, and `/suggest` endpoints made available va the `find_address_candidates()`, `reverse_geocode()`, and `suggest_places()` functions respectively. 

The batch geocoding endpoint `/geocodeAddresses` is available via `geocode_addresses(). However, this requires the use of an authorization token and may consume credits. 

### Reverse geocoding

Reverse geocoding takes a location and finds the associated address. 




```r
library(arcgisgeocode)

# create a point
x <- sf::st_sfc(sf::st_point(c(-117.172, 34.052)), crs = 4326)

# Find addresses from locations
reverse_geocode(x)
#> Simple feature collection with 1 feature and 22 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -117.172 ymin: 34.05204 xmax: -117.172 ymax: 34.05204
#> Geodetic CRS:  WGS 84
#>                                     Match_addr
#> 1 600-620 Home Pl, Redlands, California, 92374
#>                                   LongLabel      ShortLabel
#> 1 600-620 Home Pl, Redlands, CA, 92374, USA 600-620 Home Pl
#>       Addr_type Type PlaceName AddNum     Address Block Sector
#> 1 StreetAddress                   608 608 Home Pl             
#>     Neighborhood District     City MetroArea             Subregion
#> 1 South Redlands          Redlands           San Bernardino County
#>       Region RegionAbbr Territory Postal PostalExt     CntryName
#> 1 California         CA            92374           United States
#>   CountryCode                  geometry
#> 1         USA POINT (-117.172 34.05204)
```

### Address search

The `find_address_candidates()` function returns geocoding candidate results. The function is vectorized over the input and will perform multiple requests in parallel. Each request geocodes one location at a time. 

One or more candidates are returned from the endpoint. You can limit the number of candidates using the `max_locations` argument (with a maximum of 50).


```r
# Find addresses from address search
candidates <- find_address_candidates(
  address = "esri",
  address2 = "380 new york street",
  city = "redlands",
  country_code = "usa",
  max_locations = 2
)

dplyr::glimpse(candidates[,1:10])
#> Rows: 2
#> Columns: 11
#> $ input_id    <int> 1, 1
#> $ loc_name    <chr> "World", "World"
#> $ status      <chr> "M", "M"
#> $ score       <dbl> 100.00, 98.57
#> $ match_addr  <chr> "Esri", "380 New York St, Redlands, California, 92…
#> $ long_label  <chr> "Esri, 380 New York St, Redlands, CA, 92373, USA",…
#> $ short_label <chr> "Esri", "380 New York St"
#> $ addr_type   <chr> "POI", "PointAddress"
#> $ type_field  <chr> "Business Facility", NA
#> $ place_name  <chr> "Esri", NA
#> $ geometry    <POINT [°]> POINT (-117.1957 34.05609), POINT (-117.1948 34.05…
```

### Suggest locations 

Geocoding services can also provide a location suggestion based on a search term and, optionally, a location or extent. The `suggest_places()` (`/suggest` endpoint) is intended to be used as part of a client facing application that provides autocomplete suggestions. 

In this example we create a search extent around a single point and find suggestions based on the search term `"bellwood"`. 


```r
# identify a search point as a simple feature column
location <- sf::st_sfc(
  sf::st_point(c(-84.34, 33.74)),
   crs = 4326
)

# buffer and create a bbox object 
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
#>   text                                           magic_key is_collection
#> * <chr>                                          <chr>     <lgl>        
#> 1 Bellwood Coffee, 1366 Glenwood Ave SE, Atlant… dHA9MCN0… FALSE        
#> 2 Bellwood, Atlanta, GA, USA                     dHA9MCN0… FALSE        
#> 3 Bellwood Church, Atlanta, GA, USA              dHA9MCN0… FALSE        
#> 4 Bellwood Yard, Atlanta, GA, USA                dHA9MCN0… FALSE        
#> 5 Bellwood, IL, USA                              dHA9NCN0… FALSE
```

The result is intended to be provided to `find_address_candidates()` to complete the geocoding process. The columns `text` contains the address to geocode. The column `magic_key` is a special identifier that make it much faster to fetch results. Pass this into the argument `magic_key`


```r
# get address candidate information
# using the text and the magic key
find_address_candidates(
  suggestions$text,
  magic_key = suggestions$magic_key
)
#> Simple feature collection with 7 features and 60 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -84.34273 ymin: 33.74034 xmax: -84.34273 ymax: 33.74034
#> Geodetic CRS:  WGS 84
#>   input_id loc_name status score                 match_addr
#> 1        1     <NA>      M   100            Bellwood Coffee
#> 2        2     <NA>      M   100 Bellwood, Atlanta, Georgia
#> 3        3     <NA>      M   100            Bellwood Church
#> 4        4     <NA>      M   100              Bellwood Yard
#> 5        5     <NA>      T   100         Bellwood, Illinois
#> 6        5     <NA>      T   100         Bellwood, Illinois
#> 7        5     <NA>      T   100         Bellwood, Illinois
#>                                                       long_label
#> 1 Bellwood Coffee, 1366 Glenwood Ave SE, Atlanta, GA, 30316, USA
#> 2                                     Bellwood, Atlanta, GA, USA
#> 3                              Bellwood Church, Atlanta, GA, USA
#> 4                                Bellwood Yard, Atlanta, GA, USA
#> 5                                              Bellwood, IL, USA
#> 6                                              Bellwood, IL, USA
#> 7                                              Bellwood, IL, USA
#>       short_label addr_type type_field      place_name
#> 1 Bellwood Coffee       POI     Snacks Bellwood Coffee
#> 2        Bellwood  Locality       City        Bellwood
#> 3 Bellwood Church       POI     Church Bellwood Church
#> 4   Bellwood Yard       POI   Building   Bellwood Yard
#> 5        Bellwood  Locality       City        Bellwood
#> 6        Bellwood  Locality       City        Bellwood
#> 7        Bellwood  Locality       City        Bellwood
#>                                      place_addr phone  url  rank
#> 1 1366 Glenwood Ave SE, Atlanta, Georgia, 30316  <NA> <NA> 19.00
#> 2                              Atlanta, Georgia  <NA> <NA> 20.00
#> 3                              Atlanta, Georgia  <NA> <NA> 24.00
#> 4                              Atlanta, Georgia  <NA> <NA> 24.00
#> 5                            Bellwood, Illinois  <NA> <NA> 10.50
#> 6                            Bellwood, Illinois  <NA> <NA> 16.04
#> 7                 Village of Bellwood, Illinois  <NA> <NA> 21.00
#>   add_bldg add_num add_num_from add_num_to add_range side st_pre_dir
#> 1     <NA>    1366         <NA>       <NA>      <NA> <NA>       <NA>
#> 2     <NA>    <NA>         <NA>       <NA>      <NA> <NA>       <NA>
#> 3     <NA>    <NA>         <NA>       <NA>      <NA> <NA>       <NA>
#> 4     <NA>    <NA>         <NA>       <NA>      <NA> <NA>       <NA>
#> 5     <NA>    <NA>         <NA>       <NA>      <NA> <NA>       <NA>
#> 6     <NA>    <NA>         <NA>       <NA>      <NA> <NA>       <NA>
#> 7     <NA>    <NA>         <NA>       <NA>      <NA> <NA>       <NA>
#>   st_pre_type  st_name st_type st_dir bldg_type bldg_name level_type
#> 1        <NA> Glenwood     Ave     SE      <NA>      <NA>       <NA>
#> 2        <NA>     <NA>    <NA>   <NA>      <NA>      <NA>       <NA>
#> 3        <NA>     <NA>    <NA>   <NA>      <NA>      <NA>       <NA>
#> 4        <NA>     <NA>    <NA>   <NA>      <NA>      <NA>       <NA>
#> 5        <NA>     <NA>    <NA>   <NA>      <NA>      <NA>       <NA>
#> 6        <NA>     <NA>    <NA>   <NA>      <NA>      <NA>       <NA>
#> 7        <NA>     <NA>    <NA>   <NA>      <NA>      <NA>       <NA>
#>   level_name unit_type unit_name sub_addr              st_addr block
#> 1       <NA>      <NA>      <NA>     <NA> 1366 Glenwood Ave SE  <NA>
#> 2       <NA>      <NA>      <NA>     <NA>                 <NA>  <NA>
#> 3       <NA>      <NA>      <NA>     <NA>                 <NA>  <NA>
#> 4       <NA>      <NA>      <NA>     <NA>                 <NA>  <NA>
#> 5       <NA>      <NA>      <NA>     <NA>                 <NA>  <NA>
#> 6       <NA>      <NA>      <NA>     <NA>                 <NA>  <NA>
#> 7       <NA>      <NA>      <NA>     <NA>                 <NA>  <NA>
#>   sector nbrhd district                city metro_area     subregion
#> 1   <NA>  <NA>     <NA>             Atlanta       <NA> DeKalb County
#> 2   <NA>  <NA> Bellwood             Atlanta       <NA> Fulton County
#> 3   <NA>  <NA>     <NA>             Atlanta       <NA> Fulton County
#> 4   <NA>  <NA>     <NA>             Atlanta       <NA> Fulton County
#> 5   <NA>  <NA>     <NA>            Bellwood       <NA>   Cook County
#> 6   <NA>  <NA>     <NA>            Bellwood       <NA>   Cook County
#> 7   <NA>  <NA>     <NA> Village of Bellwood       <NA>   Cook County
#>     region region_abbr territory zone postal postal_ext country
#> 1  Georgia          GA      <NA> <NA>  30316       <NA>     USA
#> 2  Georgia          GA      <NA> <NA>   <NA>       <NA>     USA
#> 3  Georgia          GA      <NA> <NA>   <NA>       <NA>     USA
#> 4  Georgia          GA      <NA> <NA>   <NA>       <NA>     USA
#> 5 Illinois          IL      <NA> <NA>   <NA>       <NA>     USA
#> 6 Illinois          IL      <NA> <NA>   <NA>       <NA>     USA
#> 7 Illinois          IL      <NA> <NA>   <NA>       <NA>     USA
#>      cntry_name lang_code distance         x        y display_x
#> 1 United States       ENG      0.0 -84.34273 33.74034 -84.34273
#> 2 United States       ENG      0.0 -84.41243 33.77455 -84.41243
#> 3 United States       ENG      0.0 -84.41521 33.77288 -84.41521
#> 4 United States       ENG      0.0 -84.41798 33.77927 -84.41798
#> 5 United States       ENG 956972.0 -87.87345 41.88325 -87.87345
#> 6 United States       ENG 957055.1 -87.88312 41.88142 -87.88312
#> 7 United States       ENG 957012.3 -87.87617 41.88290 -87.87617
#>   display_y      xmin      xmax     ymin     ymax ex_info
#> 1  33.74034 -84.34373 -84.34173 33.73934 33.74134    <NA>
#> 2  33.77455 -84.42343 -84.40143 33.76355 33.78555    <NA>
#> 3  33.77288 -84.42021 -84.41021 33.76788 33.77788    <NA>
#> 4  33.77927 -84.42298 -84.41298 33.77427 33.78427    <NA>
#> 5  41.88325 -87.88945 -87.85745 41.86725 41.89925    <NA>
#> 6  41.88142 -87.90012 -87.86612 41.86442 41.89842    <NA>
#> 7  41.88290 -87.89317 -87.85917 41.86590 41.89990    <NA>
#>                                    extents                   geometry
#> 1 -84.34373, 33.73934, -84.34173, 33.74134 POINT (-84.34273 33.74034)
#> 2 -84.42343, 33.76355, -84.40143, 33.78555 POINT (-84.41243 33.77455)
#> 3 -84.42021, 33.76788, -84.41021, 33.77788 POINT (-84.41521 33.77288)
#> 4 -84.42298, 33.77427, -84.41298, 33.78427 POINT (-84.41798 33.77927)
#> 5 -87.88945, 41.86725, -87.85745, 41.89925 POINT (-87.87345 41.88325)
#> 6 -87.90012, 41.86442, -87.86612, 41.89842 POINT (-87.88312 41.88142)
#> 7 -87.89317, 41.86590, -87.85917, 41.89990  POINT (-87.87617 41.8829)
```

## *Important*: Storing results

By default, the argument `for_storage = FALSE` meaning that the results of the geocoding operation cannot be persisted. If you intend to persist the results of the geocoding operation, you must set `for_storage = TRUE`. 

To learn more about free and paid geocoding operations refer to the [storage parameter documentation](https://developers.arcgis.com/documentation/mapping-apis-and-services/geocoding/services/geocoding-service/#storage-parameter). 

## Batch geocoding

Many addresses can be geocoded very fast using the `geocode_addresses()` function which calls the `/geocodeAddresses` endpoint. Note that this function requires an authorization token. `geocode_addresses()` sends the input addresses in chunks as parallel requests. 

Batch geocoding requires a signed in user. Load the [`{arcgisutils}`](https://github.com/r-arcgis/arcgisutils) to authorize and set your token. This example uses the [Geocoding Test Dataset](# https://datacatalog.urban.org/node/6158/revisions/14192/view) from the [Urban Institute](https://www.urban.org/).


```r
library(arcgisutils)
library(arcgisgeocode)
set_arc_token(auth_user())

# Example dataset from the Urban Institute 
fp <- "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2020/02/25/geocoding_test_data.csv"

to_geocode <- readr::read_csv(fp)
#> Rows: 120 Columns: 8
#> ── Column specification ────────────────────────────────────────────────
#> Delimiter: ","
#> chr (5): full_address, address, city, state, zip
#> dbl (3): lat_true, lon_true, diff_level
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

geocoded <- to_geocode |>
  dplyr::reframe(
    geocode_addresses(
      address = address,
      city = city,
      region = state,
      postal = zip
    )
  )

geocoded
#> # A tibble: 120 × 59
#>    loc_name status score match_addr     long_label short_label addr_type
#>    <chr>    <chr>  <dbl> <chr>          <chr>      <chr>       <chr>    
#>  1 World    M      100   500 L'Enfant … 500 L'Enf… 500 L'Enfa… PointAdd…
#>  2 World    M      100   200 K St NE, … 200 K St … 200 K St NE PointAdd…
#>  3 World    M      100   500 L'Enfant … 500 L'Enf… 500 L'Enfa… PointAdd…
#>  4 World    M      100   2197 Plumleig… 2197 Plum… 2197 Pluml… PointAdd…
#>  5 World    U        0   <NA>           <NA>       <NA>        <NA>     
#>  6 World    M       97.9 2197 Plumleig… 2197 Plum… 2197 Pluml… PointAdd…
#>  7 World    M      100   200 K St NE, … 200 K St … 200 K St NE PointAdd…
#>  8 World    M       97.0 5034 Curtis S… 5034 Curt… 5034 Curti… PointAdd…
#>  9 World    M       97.0 5034 Curtis S… 5034 Curt… 5034 Curti… PointAdd…
#> 10 World    U        0   <NA>           <NA>       <NA>        <NA>     
#> # ℹ 110 more rows
#> # ℹ 52 more variables: type_field <chr>, place_name <chr>,
#> #   place_addr <chr>, phone <chr>, url <chr>, rank <dbl>,
#> #   add_bldg <chr>, add_num <chr>, add_num_from <chr>,
#> #   add_num_to <chr>, add_range <chr>, side <chr>, st_pre_dir <chr>,
#> #   st_pre_type <chr>, st_name <chr>, st_type <chr>, st_dir <chr>,
#> #   bldg_type <chr>, bldg_name <chr>, level_type <chr>, …
```

## Using other locators 

`{arcgisgeocode}` can be used with any other geocoding service. For example, custom locators hosted on ArcGIS Online or Enterprise can be used. For example, we can use the [AddressNC](https://www.nconemap.gov/pages/addresses) geocoding service [available on ArcGIS Online](https://www.arcgis.com/home/item.html?id=247dfe30ec42476a96926ad9e35f725f).

Create a new `GeocodeServer` object using `geocode_server()`. The geocoder can to passed into the `geocoder` argument to any of the geocoding functions. 


```r
address_nc <- geocode_server(
  "https://services.nconemap.gov/secure/rest/services/AddressNC/AddressNC_geocoder/GeocodeServer",
  token = NULL
)

find_address_candidates(
  address = "rowan coffee",
  city = "asheville",
  geocoder = address_nc,
  token = NULL
)
#> Warning in CPL_crs_from_input(x): GDAL Error 1: PROJ:
#> proj_create_from_database: crs not found
#> Simple feature collection with 2 features and 60 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 943428.1 ymin: 631973.4 xmax: 948500.3 ymax: 681596.4
#> CRS:           NA
#>   input_id loc_name status score match_addr long_label short_label
#> 1        1     <NA>      T    78  ASHEVILLE  ASHEVILLE   ASHEVILLE
#> 2        1     <NA>      T    78  ASHEVILLE  ASHEVILLE   ASHEVILLE
#>   addr_type type_field place_name place_addr phone  url rank add_bldg
#> 1  Locality       City  ASHEVILLE  ASHEVILLE  <NA> <NA>   20     <NA>
#> 2  Locality       City  ASHEVILLE  ASHEVILLE  <NA> <NA>   20     <NA>
#>   add_num add_num_from add_num_to add_range side st_pre_dir st_pre_type
#> 1    <NA>         <NA>       <NA>      <NA> <NA>       <NA>        <NA>
#> 2    <NA>         <NA>       <NA>      <NA> <NA>       <NA>        <NA>
#>   st_name st_type st_dir bldg_type bldg_name level_type level_name
#> 1    <NA>    <NA>   <NA>      <NA>      <NA>       <NA>       <NA>
#> 2    <NA>    <NA>   <NA>      <NA>      <NA>       <NA>       <NA>
#>   unit_type unit_name sub_addr st_addr block sector nbrhd district
#> 1      <NA>      <NA>     <NA>    <NA>  <NA>   <NA>  <NA>     <NA>
#> 2      <NA>      <NA>     <NA>    <NA>  <NA>   <NA>  <NA>     <NA>
#>        city metro_area subregion region region_abbr territory zone
#> 1 ASHEVILLE       <NA>  BUNCOMBE   <NA>        <NA>      <NA> <NA>
#> 2 ASHEVILLE       <NA> HENDERSON   <NA>        <NA>      <NA> <NA>
#>   postal postal_ext country cntry_name lang_code distance        x
#> 1   <NA>       <NA>    <NA>        USA       ENG        0 943428.1
#> 2   <NA>       <NA>    <NA>        USA       ENG        0 948500.3
#>          y display_x display_y       xmin      xmax       ymin
#> 1 681596.4  943428.1  681596.4 -8530023.7 6181070.0 -6814694.2
#> 2 631973.4  948500.3  631973.4   908369.6  988510.8   586446.6
#>         ymax      ex_info                                extents
#> 1 10142730.7 ROWAN COFFEE  -8530024, -6814694, 6181070, 10142731
#> 2   677555.8 ROWAN COFFEE 908369.6, 586446.6, 988510.8, 677555.8
#>                    geometry
#> 1 POINT (943428.1 681596.4)
#> 2 POINT (948500.3 631973.4)
```
