library(arcgis)
library(arcgisgeocode)

# read in the dataset
boston_restaurants <- readr::read_csv(
  "boston-yelp-restaurants.csv"
)

# preview the addresses
boston_restaurants$restaurant_address

# authorize to AGOL
set_arc_token(auth_user())

# start a timer
tictoc::tic()

# geocode the addresses
yelp_geocoded <- geocode_addresses(
  single_line = boston_restaurants$restaurant_address,
)

# end the timer
tictoc::toc()

# preview the results
dplyr::glimpse(yelp_geocoded)

plot(yelp_geocoded$geometry)
