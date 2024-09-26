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
