test_that("find_address_candidates() performs each request once", {
  skip_on_cran()

  # built outside the mock so the service definition is real
  geocoder <- world_geocoder()

  n <- 0L

  httr2::local_mocked_responses(function(req) {
    if (grepl("findAddressCandidates", req[["url"]], fixed = TRUE)) {
      n <<- n + 1L
    }

    httr2::response(
      status_code = 200L,
      headers = list(`Content-Type` = "application/json"),
      body = charToRaw(
        '{"spatialReference":{"wkid":4326,"latestWkid":4326},"candidates":[]}'
      )
    )
  })

  suppressWarnings(try(
    find_address_candidates("380 New York St", geocoder = geocoder),
    silent = TRUE
  ))

  expect_identical(n, 1L)
})
