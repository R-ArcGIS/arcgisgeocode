bbox <- sf::st_point(c(-122.307, 47.654)) |>
  sf::st_sfc(crs = 4326) |>
  sf::st_transform(3857) |>
  sf::st_buffer(5000) |>
  sf::st_transform(4326) |>
  sf::st_bbox()

test_that("find_address_candidate(): search_extent is respected", {
  expect_no_error(
    find_address_candidates(
      "4130 Roosevelt Way NE",
      search_extent = bbox
    )
  )
})

test_that("find_address_candidate(): search_extent must be a bbox", {
  expect_error(
    find_address_candidates(
      "4130 Roosevelt Way NE",
      search_extent = list(bbox)
    )
  )
})


test_that("geocode_addresses(): search_extent is respected", {
  skip_on_ci()
  skip_if(!interactive(), "Must be done manually")

  set_arc_token(auth_user())
  expect_no_error(
    geocode_addresses(
      "4130 Roosevelt Way NE",
      search_extent = bbox
    )
  )
})

test_that("geocode_addresses(): search_extent must be a bbox", {
  set_arc_token(auth_user())
  expect_error(
    geocode_addresses(
      "4130 Roosevelt Way NE",
      search_extent = list(bbox)
    )
  )
})

test_that("suggest_places(): search_extent is respected", {
  skip_on_ci()
  skip_if(!interactive(), "Must be done manually")

  set_arc_token(auth_user())
  expect_no_error(
    suggest_places(
      "espresso",
      search_extent = bbox
    )
  )
})

test_that("suggest_places(): search_extent must be a bbox", {
  set_arc_token(auth_user())
  expect_error(
    suggest_places(
      "4130 Roosevelt Way NE",
      search_extent = list(bbox)
    )
  )
})
