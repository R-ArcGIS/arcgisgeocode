library(shiny)
library(bslib)
library(leaflet)
library(htmltools)
library(arcgisgeocode)

# Define the UI layout using {bslib}
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
  # this reactively gets the center of the map thats in screen
  bounds <- reactive({
    loc <- input$map_center
    if (
      !is.null(loc)
    ) {
      c(loc[[1]], loc[[2]])
    }
  })

  # extract the search text
  search_text <- reactive({
    input$search_value
  })

  # whenever the search text changes
  observeEvent(search_text(), {
    # extract search text
    txt <- search_text()

    # get map center
    bnds <- bounds()

    # as long as search text and bounds aren't null
    if (nzchar(txt) && !is.null(bnds)) {
      places <- suggest_places(
        search_text(),
        location = bnds
      )

      # add the suggestions as a fake-drop down
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

        # update map with new markers
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

      # remove the markers
      leafletProxy("map") |>
        clearMarkers()
    }
  })

  output$map <- renderLeaflet({
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
