# Batch Geocode Job

A
[`arcgisutils::arc_gp_job`](https://rdrr.io/pkg/arcgisutils/man/gp_job.html)
for the `BatchGeocode` endpoint, which takes a JSON body and reports
status over `POST`.

## Super class

[`arcgisutils::arc_gp_job`](https://rdrr.io/pkg/arcgisutils/man/gp_job.html)
-\> `BatchGeocodeJob`

## Public fields

- `item_id`:

  the portal item holding the uploaded addresses.

## Active bindings

- `status`:

  the job status as an
  [`arcgisutils::arc_job_status()`](https://rdrr.io/pkg/arcgisutils/man/arc_job_status.html).

- `results`:

  the URL of the geocoded file.

## Methods

### Public methods

- [`BatchGeocodeJob$new()`](#method-BatchGeocodeJob-initialize)

- [`BatchGeocodeJob$start()`](#method-BatchGeocodeJob-start)

- [`BatchGeocodeJob$write()`](#method-BatchGeocodeJob-write)

- [`BatchGeocodeJob$clone()`](#method-BatchGeocodeJob-clone)

Inherited methods

- [`arcgisutils::arc_gp_job$await()`](https://developers.arcgis.com/r-bridge/api-reference/arcgisutils/html/arc_gp_job.html#method-arc_gp_job-await)
- [`arcgisutils::arc_gp_job$cancel()`](https://developers.arcgis.com/r-bridge/api-reference/arcgisutils/html/arc_gp_job.html#method-arc_gp_job-cancel)
- [`arcgisutils::arc_gp_job$messages()`](https://developers.arcgis.com/r-bridge/api-reference/arcgisutils/html/arc_gp_job.html#method-arc_gp_job-messages)

------------------------------------------------------------------------

### `BatchGeocodeJob$new()`

#### Usage

    BatchGeocodeJob$new(base_url, item_id, field_mapping, token = arc_token())

#### Arguments

- `base_url`:

  the URL of the job service, without `/submitJob`.

- `item_id`:

  the id of the portal item holding the addresses.

- `field_mapping`:

  a named character vector of geocoder field to column.

- `token`:

  an
  [`arcgisutils::arc_token()`](https://rdrr.io/pkg/arcgisutils/man/token.html).

------------------------------------------------------------------------

### `BatchGeocodeJob$start()`

Submits the job. The endpoint requires a JSON body.

#### Usage

    BatchGeocodeJob$start()

------------------------------------------------------------------------

### `BatchGeocodeJob$write()`

Downloads the geocoded file.

#### Usage

    BatchGeocodeJob$write(path)

#### Arguments

- `path`:

  where to write the result CSV.

------------------------------------------------------------------------

### `BatchGeocodeJob$clone()`

The objects of this class are cloneable with this method.

#### Usage

    BatchGeocodeJob$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
