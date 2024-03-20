# res <- arc_base_req("https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer") |>
#   httr2::req_url_query(f = "json") |>
#   httr2::req_perform() |>
#   httr2::resp_body_string()
#
# geocoder <- RcppSimdJson::fparse(res)
#
#
# str(geocoder, 1)
#
# geocoder$candidateFields |> str(1)
#
# library(httr2)
#
# burl <- "https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode"
#
# request(burl) |>
#   req_body_json(
#     f = "json",
#     location = "-119.286297,34.280853"
#   ) |>
#   req_perform() |>
#   resp_body_string()
# # https://geocode.arcgis.com/arcgis/rest/services/World/GeocodeServer/reverseGeocode?f=json&featureTypes=Postal&location=-119.286297,34.280853
