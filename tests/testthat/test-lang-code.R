test_that("lang_code accepts language codes that are not country codes", {
  skip_on_cran()
  skip_on_ci()
  expect_false(is_iso3166("ENG"))

  expect_no_error(reverse_geocode(c(-117.195, 34.057), lang_code = "ENG"))
  expect_no_error(
    find_address_candidates("380 New York St, Redlands, CA", lang_code = "ENG")
  )
})

test_that("lang_code must be a non-empty character", {
  expect_error(reverse_geocode(c(-117.195, 34.057), lang_code = 1), "lang_code")
  expect_error(reverse_geocode(c(-117.195, 34.057), lang_code = ""), "lang_code")
  expect_error(find_address_candidates("380 New York St", lang_code = 1), "lang_code")
})
