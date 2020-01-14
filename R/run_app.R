#' Run the Shiny Application
#'
#' @param ... not used
#'
#' @export
#' @importFrom dash Dash
#' @import dash
#' @import dashCoreComponents
#' @import dashHtmlComponents

run_app <- function(...) {
  library(dash)
  library(dashCoreComponents)
  library(dashHtmlComponents)
  library(sf)
  library(data.table)
  library(plotly)
  library(dashHtmlComponents)
  library(dashCoreComponents)
  library(rmapshaper)
  
  mapbox_token = "pk.eyJ1IjoicGxvdGx5bWFwYm94IiwiYSI6ImNqdnBvNDMyaTAxYzkzeW5ubWdpZ2VjbmMifQ.TXcBE-xg9BFdV2ocecc_7g"
  Sys.setenv('MAPBOX_TOKEN' = mapbox_token)
  
  DT <- st_read("/usr/local/data/merged.shp")
  levels(DT$coi_lbl) <- c("Very low","Low","Moderate","High","Very high")
  
  neighbouring_states <- fread("/usr/local/data/neighbouring_states.csv")
  sequential_colorscale <- c("#013457", "#045781", "#2E74B5", "#52C1FA", "#B5E5FD")
  
  default_state <- "Vermont"
  
  help_text <- dccMarkdown(
    "This map shows the nationally normed, overall Child
  Opportunity Levels for all neighborhoods in a selected state
  and its neighboring states.
  
  **Choose a state:** Select from the drop-down list or type the
  state name in the box.
  
  **Zoom:** Use the mouse wheel or trackpad to zoom in and out of
  the map.
  
  **Pan:** Click and drag to pan around the map.
  "
  )
  
  filter.dt <- function(state){
    neighbours <- neighbouring_states[StateCode == state, NeighborStateCode]
    DT <- DT[(DT$StateName == state | DT$StateName %in% neighbours),]
    DT
  }
  
  create_mapbox_plot <- function(state){
    DT <- filter.dt(state)
    plot_mapbox() %>%
      add_sf(
        inherit = FALSE,
        data = DT,
        color = ~coi_lbl,
        colors = rev(sequential_colorscale),
        text = ~coi_lbl,
        customdata = ~GEOID10,
        hovertemplate = paste(
          paste("Child Opportunity Level: %{text}<br>"),
          "GEOID: %{customdata}",
          "<extra></extra>"
        ),
        alpha = 1, 
        below = ""
      ) %>%
      layout(
        mapbox = list(
          accesstoken = mapbox_token,
          zoom = ifelse(state == "Hawaii", 4, 5),
          style = "light"
        ),
        hoverdistance = 200,
        legend = list(x = 0.01, y = 0.97)
      )
  }
  
  
  app <- Dash$new()
  
  app$layout(
    htmlDiv(
      children = list(
        htmlDiv(
          children = list(
            htmlDiv(
              className = "modal-close-outer",
              children = htmlA(
                children = "X", 
                id = "modal-close-button", 
                n_clicks = 0,
              )
            ),
            htmlDiv(
              className = "modal-content",
              children = help_text
            )
          ),
          id = "modal",
          className = "modal",
          style = list(display= "none")
        ),
        htmlDiv(
          children = list(
            htmlDiv(
              className = "chart-title",
              id = "chart-title"
            ),
            dccLoading(
              children = dccGraph(
                id = "map",
                config = list(
                  modeBarButtonsToRemove = list(
                    'zoom2d', 'pan2d', 'select2d', 'lasso2d',
                    'zoomIn2d', 'zoomOut2d', 'autoScale2d', 'hoverClosestCartesian',
                    'hoverCompareCartesian', 'toggleSpikelines', 'resetScale2d', 
                    'resetViewMapbox', 'toggleHover'
                  )
                ),
                style = list(width = "95vw", height = "700px")
              ),
              style = list(width = "95vw", height = "700px")
            )
          )
        ),
        htmlDiv(
          id = "controls",
          children = list(
            htmlSpan(
              paste("Select a state"),
              className = "control-label"
            ),
            dccDropdown(
              id = "state-dropdown",
              options = lapply(
                unique(DT$StateName),
                function(x){list(label = x, value = x)}
              ),
              value = default_state
            ),
            htmlA(
              id = "instructions-button", 
              n_clicks = 0,
              children = "How to use this map (?)",
              style = list(cursor = "pointer", float = "right")
            )
          ),
          style = list(
            width="20vw", 
            transform="translateX(-200px) translateY(100px)",
            background="white",
            height="max-content",
            border="solid black 1px",
            padding="10px"
          )
        )
      ),
      style = list(display = "flex")
    ),
    htmlImg(src = "https://github.com/tristanga/DDKids/raw/master/R/assets/ddkids_Logo.png", width=300, style = list(paddingLeft = "25px"))
  )
  
  app$callback(
    output("map", "figure"),
    list(
      input("state-dropdown", "value")
    ),
    function(state){
      create_mapbox_plot(state)
    }
  )
  
  app$callback(
    output("chart-title", "children"),
    list(input("state-dropdown", "value")),
    function(state){
      sprintf("Child Opportunity Levels for %s and neighbouring states", state)
    }
  )
  
  app$run_server(host = "0.0.0.0", port = 8050, block = TRUE, showcase = FALSE)
}
