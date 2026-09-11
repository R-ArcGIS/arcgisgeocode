# Read Batch Geocoding Results

Reads the CSV written by a batch geocoding job.

## Usage

``` r
read_geocode_result(path, crs = 4326)
```

## Arguments

- path:

  String. Path to the result CSV.

- crs:

  Coordinate reference system of the result. Passed to
  [`sf::st_crs()`](https://r-spatial.github.io/sf/reference/st_crs.html).

## Value

An `sf` object, or a `data.frame` when the result has no coordinates.

## Examples

``` r
if (FALSE) { # \dontrun{
read_geocode_result("geocoded.csv")
} # }
```
