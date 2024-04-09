library(magrittr)
# library(arcgisgeocode)

fp <- "https://urban-data-catalog.s3.amazonaws.com/drupal-root-live/2020/02/25/geocoding_test_data.csv"

addresses <- readr::read_csv(fp)
# set_arc_token(auth_user())

addresses %$% 
  geocode_addresses(
    address = address,
    city = city,
    region = state,
    postal = zip
  ) -> geocoded

attr(geocoded, "error_messages")[[1]] |> 


warns <- attr(geocoded, "error_requests")[[1]] |> 
  httr2::req_perform() |> 
  httr2::resp_body_string() |> 
  RcppSimdJson::fparse() |>
  arcgisutils:::report_errors() 


warns <- attr(geocoded, "error_requests")[[1]] |> 
    httr2::req_perform() |> 
    httr2::resp_body_string() |> 
    RcppSimdJson::fparse() |>
    arcgisutils:::report_errors() 
# system.time(
#   addresses %$%
#     geocode_addresses(
#       address = address,
#       city = city,
#       region = state,
#       postal = zip
#     ) -> geocoded
# )


# Real geocoding ------------------------------------------------------

boston_restaurants <- readr::read_csv("/Users/josiahparry/Downloads/boston-yelp-restaurants.csv")

system.time({
  yelp_geocoded <- geocode_addresses(
    single_line = boston_restaurants$restaurant_address,
  )  Í
})


# using public geocoder
system.time({
yelp_candidates <- find_address_candidates(
  single_line = boston_restaurants$restaurant_address,
  max_locations = 1
)
})


bos_311 <- readr::read_csv("/Users/josiahparry/Downloads/boston-311-2024.csv") |> 
  dplyr::filter(!is.na(longitude), !is.na(latitude)) |> 
  sf::st_as_sf(coords = c("longitude", "latitude"), crs = 4326)


open_cases <- dplyr::filter(bos_311, case_status == "Open")

system.time({
  open_case_addresses <- reverse_geocode(
    open_cases$geometry
  )
})
