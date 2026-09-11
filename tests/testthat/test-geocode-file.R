fixture <- function() test_path("fixtures", "batch-geocode-result.csv")

test_that("read_geocode_result() returns an sf object", {
  res <- read_geocode_result(fixture())

  expect_s3_class(res, "sf")
  expect_identical(sf::st_crs(res), sf::st_crs(4326))
  expect_gt(nrow(res), 0L)
})

test_that("read_geocode_result() returns the core geocoding fields", {
  res <- read_geocode_result(fixture())

  expect_true(
    all(c("match_addr", "score", "addr_type", "x", "y") %in% names(res))
  )
})

test_that("read_geocode_result() strips the LOC_ prefix from every field", {
  res <- read_geocode_result(fixture())

  expect_false(any(startsWith(names(res), "LOC_")))
})

test_that("read_geocode_result() leaves input columns alone", {
  res <- read_geocode_result(fixture())

  expect_true("full_address" %in% names(res))
})

test_that("read_geocode_result() renames known fields and passes the rest through", {
  path <- tempfile(fileext = ".csv")
  writeLines(c("LOC_Match_addr,LOC_SomeNewField,my_input", "a,b,c"), path)

  res <- read_geocode_result(path)

  expect_true(all(c("match_addr", "some_new_field", "my_input") %in% names(res)))
})

test_that("read_geocode_result() returns a data.frame without coordinates", {
  path <- tempfile(fileext = ".csv")
  writeLines(c("LOC_Match_addr", "380 New York St"), path)

  res <- read_geocode_result(path)

  expect_s3_class(res, "data.frame")
  expect_false(inherits(res, "sf"))
})

test_that("read_geocode_result() validates its arguments", {
  expect_error(read_geocode_result("nope.csv"), "does not exist")
  expect_error(read_geocode_result(1))
})
