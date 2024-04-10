find_address_candidates(
  single_line = "Bellwood Coffee, 1366 Glenwood Ave SE, Atlanta, GA, 30316, USA"
)
# TODO: `magic_key` should only be provided when single line is
# all other arguments should be ignored
find_address_candidates(magic_key = "123")


# this should create an error for having different lengths
find_address_candidates(
  single_line = "Bellwood Coffee, 1366 Glenwood Ave SE, Atlanta, GA, 30316, USA",
  postal = c("30312", "30000"),
  region = c("CA", "GA", "TX")
)

find_address_candidates(
  "Bellwood Coffee, 1366 Glenwood Ave SE, Atlanta, GA, 30316, USA",
  category = "billy joe armstrong"
)


# suggests ---------------------------------------------------------------
library(sf)

# identify a search point
location <- st_sfc(st_point(c(-84.34, 33.74)), crs = 4326)

# create a search extent from it
search_extent <- st_bbox(st_buffer(location, 10))


# too many values for the search location
suggestions <- suggest_places(
  "bellwood",
  c(-84.34, 33.74, 3.14159, 1, 0),
  search_extent = search_extent
)


suggest_places(
  "bellwood",
  c(-84.34, 33.74),
  search_extent = list(search_extent, search_extent)
)


suggest_places("m", category = "!!!!^&*(&%(%fastest of food vroom vroom")


# reverse geocode --------------------------------------------------------

reverse_geocode(c(-84.34, 33.74), location_type = "sdfouhw23495ghfadsofhv")
reverse_geocode(c(-84.34, 33.74), location_type = c("street", "rooftop", "rooftop"), crs = 3857)
