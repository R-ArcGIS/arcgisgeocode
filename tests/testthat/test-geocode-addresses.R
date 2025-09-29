test_that("geocode_addresses() functions", {
  skip_on_cran()
  skip_on_ci()
  library(arcgisutils)
  set_arc_token(auth_user())
  res <- geocode_addresses(c(
    "esri",
    "esri, redlands",
    "ny street esri redlands ca"
  ))
  expect_snapshot(res)
})
