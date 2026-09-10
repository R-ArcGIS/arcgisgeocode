test_that("search_within must be a character vector", {
  expect_error(find_address_candidates("Redlands", search_within = 1))
  expect_error(find_address_candidates("Redlands", search_within = list("POI")))
})

test_that("search_within is omitted when NULL", {
  skip_on_cran()

  geocoder <- world_geocoder()
  sent <- NULL

  httr2::local_mocked_responses(function(req) {
    if (grepl("findAddressCandidates", req[["url"]], fixed = TRUE)) {
      sent <<- req[["body"]][["data"]]
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

  expect_false("searchWithin" %in% names(sent))
})

test_that("search_within is collapsed and not vectorized over", {
  skip_on_cran()

  geocoder <- world_geocoder()
  sent <- NULL
  n <- 0L

  httr2::local_mocked_responses(function(req) {
    if (grepl("findAddressCandidates", req[["url"]], fixed = TRUE)) {
      n <<- n + 1L
      sent <<- req[["body"]][["data"]]
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
    find_address_candidates(
      "380 New York St",
      search_within = c("Subaddress", "POI"),
      geocoder = geocoder
    ),
    silent = TRUE
  ))

  expect_identical(n, 1L)
  expect_identical(
    URLdecode(as.character(sent[["searchWithin"]])),
    "Subaddress,POI"
  )
})

test_that("search_within returns the collection at a PointAddress", {
  skip_on_ci()
  skip_if(!interactive(), "Requires a token")

  set_arc_token(auth_user())

  res <- find_address_candidates(
    "380 New York St, Redlands, CA",
    search_within = "POI",
    out_fields = c("Match_addr", "Addr_type")
  )

  # candidate 1 is always the geocoded object itself
  expect_identical(res[["addr_type"]][1], "PointAddress")
  expect_gt(nrow(res), 1L)
  expect_true(all(res[["addr_type"]][-1] == "POI"))
})
