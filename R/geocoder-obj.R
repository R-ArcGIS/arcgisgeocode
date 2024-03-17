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
