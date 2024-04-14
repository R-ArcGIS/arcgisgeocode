library(shiny)
library(bslib)
library(leaflet)
devtools::load_all()

ui <- page_sidebar(
  card(
    card_header("A leaflet map"),
    leafletOutput("map", width = "100%", height = "100%"),
  ),
  sidebar = sidebar(
    textInput("search_value", label = "Search..."),
  ),
)

server <- function(input, output, session) {
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.

  bounds <- reactive({
    # bnds <- input$map_bounds
    loc <- input$map_center
    if (
      # !is.null(bnds)
      !is.null(loc)
    ) {
      c(loc[[1]], loc[[2]])
    }
  })

  search_text <- reactive({
    input$search_value
  })

  observeEvent(search_text(), {
    txt <- search_text()
    bnds <- bounds()

    if (nzchar(txt) && !is.null(bnds)) {
      places <- suggest_places(
        search_text(),
        location = bnds
      )

      if (nrow(places) > 0) {
        # then pass the suggestions to find_address_candidates
        search_results <- find_address_candidates(
          places$text,
          magic_key = places$magic_key,
          max_locations = 1,
          for_storage = FALSE
        )


        leafletProxy("map", data = sf::st_geometry(search_results)) |>
          clearMarkers() |>
          addMarkers()
      }
    }
  })

  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet() |>
      addTiles()
  })
}

shinyApp(ui, server)
