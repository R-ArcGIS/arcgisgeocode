test_that("check_points() handles inputs correctly", {
  expected <- sf::st_sfc(sf::st_point(c(-117.172, 34.052)), crs = 4326)

  expect_identical(
    obj_as_points(c(-117.172, 34.052)),
    expected
  )

  expect_equal(
    obj_as_points(matrix(c(-117.172, 34.052), ncol = 2)),
    expected,
    ignore_attr = TRUE
  )

  expect_no_error(
    obj_as_points(
      matrix(
        rep(c(-117.172, 34.052), 3),
        ncol = 2, byrow = TRUE
      )
    )
  )

  expect_identical(
    obj_as_points(sf::st_point(c(-117.172, 34.052))),
    expected
  )

  # error when a list is provided
  expect_error(obj_as_points(list()))

  # error when values are out of bounds
  expect_error(obj_as_points(c(-181, 90)))
  expect_error(obj_as_points(c(-180, 91)))

  # error when allow_null = FALSE
  expect_error(obj_as_points(NULL, allow_null = FALSE))
})
