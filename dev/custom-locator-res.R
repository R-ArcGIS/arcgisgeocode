custom_json <- brio::read_file("tests/testdata/custom-locator.json")
known_json <- brio::read_file("tests/testdata/public-locator-res.json")

known_res <- RcppSimdJson::fparse(known_json)

cur <- parse_location_json(jsn) |>
  dplyr::glimpse()
