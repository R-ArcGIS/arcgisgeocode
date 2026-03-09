# ISO 3166 Country Codes

Create a data.frame of ISO 3166 2 and 3 digit Country codes.

## Usage

``` r
iso_3166_codes()
```

## Value

a `data.frame` with columns `country`, `code_2`, `code_3`.

## Details

Country codes provided by
[`rust_iso3166`](https://docs.rs/rust_iso3166/latest/rust_iso3166/index.html).

## Examples

``` r
head(iso_3166_codes())
#> # A data frame: 6 × 3
#>   country        code_2 code_3
#> * <chr>          <chr>  <chr> 
#> 1 Afghanistan    AF     AFG   
#> 2 Åland Islands  AX     ALA   
#> 3 Albania        AL     ALB   
#> 4 Algeria        DZ     DZA   
#> 5 American Samoa AS     ASM   
#> 6 Andorra        AD     AND   
```
