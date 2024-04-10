library(readr)
library(arcgis)
library(arcgisgeocode)

customer_addresses <- readr::read_csv(
  "/Users/josiahparry/Downloads/Atlanta_customers.csv"
)

# preview
# dplyr::glimpse(customer_addresses)

# authorize
set_arc_token(auth_user())

# geocode by fields
geocoding_res <- customer_addresses |>
  dplyr::mutate(
    geocoded = geocode_addresses(
      address = ADDRESS,
      city = CITY,
      region = STATE,
      postal = as.character(ZIP)
    )
  ) |>
  tidyr::unnest(geocoded)

geocoding_res |>
  dplyr::glimpse()
