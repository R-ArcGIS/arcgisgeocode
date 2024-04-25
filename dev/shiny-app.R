library(shiny)
library(bslib)
library(leaflet)
library(htmltools)
library(arcgisgeocode)

ui <- page_sidebar(
  card(
    leafletOutput("map", width = "100%", height = "100%"),
  ),
  sidebar = sidebar(
    textInput(
      "search_value",
      label = "Search",
    ),
    uiOutput("suggests")
  )
)

server <- function(input, output, session) {
  # This reactive expression represents the palette function,
  # which changes as the user makes selections in UI.
  bounds <- reactive({
    loc <- input$map_center
    if (
      !is.null(loc)
    ) {
      c(loc[[1]], loc[[2]])
    }
  })

  search_text <- reactive({
    input$search_value
  })

  observeEvent(search_text(), {
    # extract search text
    txt <- search_text()

    # get extent bounds
    bnds <- bounds()

    # as long as search text and bounds aren't null
    if (nzchar(txt) && !is.null(bnds)) {
      places <- suggest_places(
        search_text(),
        location = bnds
      )

      output$suggests <- renderUI({
        make_suggestion_list(places)
      })

      if (nrow(places) > 0) {
        # then pass the suggestions to find_address_candidates
        search_results <- find_address_candidates(
          places$text,
          magic_key = places$magic_key,
          max_locations = 1,
          for_storage = FALSE
        )

        # update map
        leafletProxy(
          "map",
          data = sf::st_geometry(search_results)
        ) |>
          clearMarkers() |>
          addMarkers()
      }
    }

    # clear the gt table
    if (!nzchar(txt)) {
      output$suggests <- NULL

      leafletProxy("map") |>
        clearMarkers()
    }
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

# helper function
make_suggestion_list <- function(suggestions) {
  ul <- tag("ul", c("class" = "list-group shadow-lg"))
  lis <- lapply(suggestions$text, \(.x) {
    htmltools::tag(
      "li",
      c("class" = "list-group-item list-group-item-action border-light text-sm", .x)
    )
  })

  tagSetChildren(ul, lis)
}


shinyApp(ui, server)
