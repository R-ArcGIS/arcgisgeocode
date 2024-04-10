library(shiny)
library(bslib)
library(leaflet)
library(arcgisgeocode)

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
  # Reactive expression for the data subsetted to what the user selected
  filteredData <- reactive({
    quakes[quakes$mag >= input$range[1] & quakes$mag <= input$range[2], ]
  })

  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.

  bounds <- reactive({
    bnds <- input$map_bounds

    if (!is.null(bnds)) {
      sf::st_bbox(
        c(
          xmin = bnds$west,
          xmax = bnds$east,
          ymin = bnds$south,
          ymax = bnds$north
        )
      )
    }
  })

  search_text <- reactive({
    input$search_value
  })

  observeEvent(search_text(), {
    txt <- search_text()
    bnds <- bounds()

    if (nzchar(txt) && !is.null(bnds)) {
      print(bnds)
      print(txt)
      # search places
      places <- suggest_places(search_text(), search_extent = bounds())

      # then pass the suggestions to find_address_candidates
      search_results <- find_address_candidates(
        places$text,
        magic_key = places$magic_key,
        max_locations = 1,
        for_storage = FALSE
      )

      print(search_results)
    }
  })

  output$map <- renderLeaflet({
    # Use leaflet() here, and only include aspects of the map that
    # won't need to change dynamically (at least, not unless the
    # entire map is being torn down and recreated).
    leaflet(quakes) |>
      addTiles() |>
      fitBounds(~ min(long), ~ min(lat), ~ max(long), ~ max(lat))
  })

  # Incremental changes to the map (in this case, replacing the
  # circles when a new color is chosen) should be performed in
  # an observer. Each independent set of things that can change
  # should be managed in its own observer.
  observe({
    leafletProxy("map", data = filteredData())
  })

  # Use a separate observer to recreate the legend as needed.
  observe({
    proxy <- leafletProxy("map", data = quakes)
  })
}

shinyApp(ui, server)
