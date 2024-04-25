library(arcgisutils)
library(arcgisgeocode)

# read in the dataset
boston_restaurants <- readr::read_csv(
  "~/downloads/boston-yelp-restaurants.csv"
)

# extract the addresses
addresses <- boston_restaurants$restaurant_address
head(addresses) # preview them

# authorize to AGOL using arcgisutils
set_arc_token(auth_user())

# time both geocoding capabilities
r_arcgis_bm <- bench::mark(
  "R-ArcGIS Bulk Address" = geocode_addresses(addresses),
  "R-ArcGIS Single Address" = find_address_candidates(addresses, max_locations = 1),
  iterations = 1,
  check = FALSE
)
readr::write_csv(r_arcgis_bm[, 1:9], "dev/arcgisgeocode-yelp-timing.csv")


# Community Packages -----------------------------------------------------

# read in the dataset
boston_restaurants <- readr::read_csv(
  "~/downloads/boston-yelp-restaurants.csv"
)

addresses <- boston_restaurants$restaurant_address

bm <- bench::mark(
  tidygeocoder::geo(addresses, method = "arcgis"),
  arcgeocoder::arc_geo(addresses),
  check = FALSE,
  iterations = 1
)

readr::write_csv(bm[, 1:9], "dev/yelp-timing.csv")
