library(shiny)
library(bslib)
library(leaflet)
library(arcgisgeocode)

ui <- page_fillable(
  card(
    card_title(textOutput("rev_result")),
    leafletOutput("map", width = "100%", height = "100%"),
  )
)

server <- function(input, output, session) {
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.

  observeEvent(input$map_click, {
    # get the click location
    click <- input$map_click

    # extract the x and y coordinate
    x <- click$lng
    y <- click$lat
    loc <- c(x, y)
    dput(loc) # print to console

    geocoded <- reverse_geocode(loc)

    output$rev_result <- renderText(geocoded$long_label)

    leafletProxy("map", data = sf::st_geometry(geocoded)) |>
      clearMarkers() |>
      addMarkers()
  })

  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet() |>
      # use esri canvas
      addProviderTiles(providers$Esri.WorldGrayCanvas) |>
      setView(lat = 42.3601, lng = -71.0589, zoom = 14)
  })
}

shinyApp(ui, server)

make_label <- function(geocoded) {
  name <- geocoded$place_name

  if (!nzchar(name)) {
    return(geocoded$long_label)
  } else {
    label <- paste0(
      name,
      "\n",
      geocoded$long_label
    )
  }
}
