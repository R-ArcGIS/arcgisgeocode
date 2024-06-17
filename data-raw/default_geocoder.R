## code to prepare `default_geocoder` dataset goes here
world_geocoder <- geocode_server(world_geocoder_url)

remove_localized_names <- function(lst) {
  if (is.list(lst)) {
    lst <- lapply(lst, remove_localized_names)
    lst <- lst[!names(lst) %in% c("localizedNames", "recognizedNames")]
  }
  lst
}

# need to remove localized names because it bloats the package install size
# by 7mb. Changes object size to 51kb from 7mb
world_geocoder <- structure(
  remove_localized_names(world_geocoder),
  class = c("GeocodeServer", "list")
)

usethis::use_data(world_geocoder, overwrite = TRUE, internal = TRUE)
