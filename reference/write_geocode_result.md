# Write Batch Geocoding Results

Downloads the result of a completed
[`geocode_file_job()`](https://developers.arcgis.com/r-bridge/api-reference/arcgisgeocode/reference/geocode_file_job.md).

## Usage

``` r
write_geocode_result(job, path)
```

## Arguments

- job:

  A `BatchGeocodeJob`.

- path:

  String. Where to write the result CSV.

## Value

`path`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
write_geocode_result(job, "geocoded.csv")
} # }
```
