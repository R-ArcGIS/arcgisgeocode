test_that("collapse_out_fields(): NULL requests everything", {
  expect_identical(collapse_out_fields(NULL), "*")
})

test_that("collapse_out_fields(): character vectors are comma separated", {
  expect_identical(collapse_out_fields("Match_addr"), "Match_addr")
  expect_identical(
    collapse_out_fields(c("Match_addr", "City", "Addr_type")),
    "Match_addr,City,Addr_type"
  )
})

test_that("out_fields must be a character vector", {
  expect_error(find_address_candidates("Redlands", out_fields = 1))
  expect_error(find_address_candidates("Redlands", out_fields = list("City")))
  expect_error(reverse_geocode(c(-117.172, 34.052), out_fields = 1))
})

test_that("find_address_candidates(): out_fields limits the fields returned", {
  skip_on_cran()

  res <- find_address_candidates(
    "380 New York St, Redlands CA",
    max_locations = 1,
    out_fields = c("Match_addr", "City")
  )

  expect_identical(res[["match_addr"]], "380 New York St, Redlands, California, 92373")
  expect_identical(res[["city"]], "Redlands")

  # fields that were not requested come back missing
  expect_true(is.na(res[["region"]]))
  expect_true(is.na(res[["postal"]]))
})

test_that("find_address_candidates(): out_fields is not vectorized over", {
  skip_on_cran()

  res <- find_address_candidates(
    "380 New York St, Redlands CA",
    max_locations = 1,
    out_fields = c("Match_addr", "City", "Addr_type")
  )

  expect_identical(nrow(res), 1L)
  expect_identical(res[["input_id"]], 1L)
})

test_that("find_address_candidates(): out_fields recycles across addresses", {
  skip_on_cran()

  res <- find_address_candidates(
    c("380 New York St, Redlands CA", "Buckingham Palace"),
    max_locations = 1,
    out_fields = "Match_addr"
  )

  expect_identical(nrow(res), 2L)
  expect_identical(res[["input_id"]], 1:2)
})

test_that("reverse_geocode(): out_fields limits the fields returned", {
  skip_on_cran()

  res <- reverse_geocode(
    c(-117.172, 34.052),
    out_fields = c("Match_addr", "City")
  )

  expect_identical(res[["city"]], "Redlands")
  expect_true(nzchar(res[["match_addr"]]))

  # fields that were not requested come back empty
  expect_identical(res[["region"]], "")
  expect_identical(res[["postal"]], "")
})

test_that("geocode_addresses(): out_fields limits the fields returned", {
  skip_on_ci()
  skip_if(!interactive(), "Must be done manually")

  set_arc_token(auth_user())

  res <- geocode_addresses(
    single_line = "380 New York St, Redlands CA",
    out_fields = c("Match_addr", "City")
  )

  expect_identical(res[["city"]], "Redlands")
  expect_true(is.na(res[["region"]]))
})
