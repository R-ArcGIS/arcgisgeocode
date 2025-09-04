# arcgisgeocode (development version)

- The `world_geocoder` object has been deprecated in favor of `world_geocoder()` function
- Resolves an issue parsing geocoding results with fields that are not present in the world geocoder. Fixes [#41](https://github.com/R-ArcGIS/arcgisgeocode/issues/41) <https://github.com/R-ArcGIS/arcgisgeocode/pull/42>

# arcgisgeocode 0.3.0

- Adds new fields `bldg_comp`, `struct_type`, `struct_det` to output to address newly added fields in the world geocoding service
- Bumps version of httr2 due to breaking change [#40](https://github.com/R-ArcGIS/arcgisgeocode/pull/40/)

# arcgisgeocode 0.2.3

- Bumps version of extendr-api to address CRAN checks.

# arcgisgeocode 0.2.2

- Bumps version of extendr-api to address CRAN checks 
- Bumps version of httr2 due to regression [#34](https://github.com/R-ArcGIS/arcgisgeocode/issues/34)
- Bug fixes with unexported objects and NA handling by [@elipousson] [#37](https://github.com/R-ArcGIS/arcgisgeocode/pull/37)

# arcgisgeocode 0.2.1 

- Address CRAN error on MacOS oldrel

# arcgisgeocode 0.2.0

- The minimum version of R supported is R `4.2` 
- [#22](https://github.com/R-ArcGIS/arcgisgeocode/pull/22) Fixed a bug where the `default_geocoder()` would not work without attaching the entire package. See <https://github.com/R-ArcGIS/arcgisgeocode/issues/23>.
- [#21](https://github.com/R-ArcGIS/arcgisgeocode/pull/21) Fixed a bug where custom locators did not parse and sort the results appropriately. 

# arcgisgeocode 0.1.0

- Initial CRAN release
