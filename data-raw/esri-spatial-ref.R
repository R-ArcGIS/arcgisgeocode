## code to prepare `esri-spatial-ref` dataset goes here
esri_wkids <- arcgeocoder::arc_spatial_references |>
  dplyr::filter(
    authority == "Esri"
  ) |>
  dplyr::pull(wkid)

usethis::use_data(esri_wkids, overwrite = TRUE)
