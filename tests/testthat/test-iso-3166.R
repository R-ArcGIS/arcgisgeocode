test_that("ISO 3166 alpha-2 and alpha-3 codes are accepted", {
  expect_true(all(is_iso3166(c("US", "USA", "GB", "GBR", "DE", "DEU"))))
})

test_that("codes are case insensitive", {
  expect_true(all(is_iso3166(c("usa", "Usa", "uSA"))))
})

test_that("documented non-ISO country codes are accepted", {
  # https://developers.arcgis.com/rest/geocode/geocode-coverage/#supported-country-codes
  expect_true(all(is_iso3166(c("EUR", "UAE", "KSA", "RSA", "ROC"))))
})

test_that("the official code for those countries still works", {
  expect_true(all(is_iso3166(c("ARE", "SAU", "ZAF", "TWN"))))
})

test_that("unknown codes are rejected", {
  expect_false(any(is_iso3166(c("ZZZ", "QQ", "NotACode"))))
})

test_that("NA propagates", {
  expect_identical(is_iso3166(NA_character_), NA)
})
