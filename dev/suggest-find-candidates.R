library(sf)

# identify a search point
location <- st_sfc(st_point(c(-84.34, 33.74)), crs = 4326)

# create a search extent from it
search_extent <- st_bbox(st_buffer(location, 10))

# find suggestions from it
suggestions <- suggest_places(
  "bellwood",
  c(-84.34, 33.74),
  search_extent = search_extent
)

# get address candidate information
# using the text and the magic key
find_address_candidates(
  suggestions$text,
  magic_key = suggestions$magic_key
)
