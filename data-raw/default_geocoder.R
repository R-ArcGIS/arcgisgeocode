## code to prepare `default_geocoder` dataset goes here
world_geocoder <- geocode_server(world_geocoder_url)

usethis::use_data(world_geocoder, overwrite = TRUE)
