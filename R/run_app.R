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
 
 map_data <- fread("/usr/local/data/DataForMaps.csv", colClasses = c(GEOID10 = "character"))
 print(map_data[1])
 
 mapbox_token = "pk.eyJ1IjoicGxvdGx5bWFwYm94IiwiYSI6ImNqdnBvNDMyaTAxYzkzeW5ubWdpZ2VjbmMifQ.TXcBE-xg9BFdV2ocecc_7g"
 Sys.setenv('MAPBOX_TOKEN' = mapbox_token)
 
 shapefile <- st_read("/usr/local/data/shapes/COI20.shp")

 merged <- merge(map_data, shapefile, by="GEOID10")
 st_geometry(merged) <- merged$geometry
 st_crs(merged) <- 4326

 sequential_colorscale <- c("#013457", "#045781", "#2E74B5", "#52C1FA", "#B5E5FD")

 create_mapbox_plot <- function(state, stdmode, index, year){
 d <- merged[merged$StateName == state & merged$StdMode == stdmode & merged$IndexName == index & merged$Year == year, ] %>%
 ms_simplify()
 plot_mapbox(
 d,
 color = ~as.factor(coi_num),
 colors = rev(sequential_colorscale),
 text = ~coi_lbl,
 customdata = ~GEOID10,
 hovertemplate = paste(
 paste(index, "COI: %{text}<br>"),
 "GEOID: %{customdata}",
 "<extra></extra>"
 )
 ) %>%
 layout(
 height = 700,
 mapbox = list(
 accesstoken = mapbox_token,
 zoom = 5,
 style = "light"
 ),
 hoverdistance = 200
 )
 }

 state = "Vermont"
 stdmode = "National"
 index = "Overall"
 year = 2010
 
 app <- Dash$new()
 
 app$layout(
 htmlDiv(
 children = list(
 htmlDiv(
 dccLoading(
 children = dccGraph(
 id = "map"
 )
 ),
 style = list(width = "75vw")
 ),
 htmlDiv(
 children = list(
 htmlSpan(
 paste("Select", "State"),
 className = "control-label"
 ),
 dccDropdown(
 id = "state-dropdown",
 options = lapply(
 unique(merged$StateName),
 function(x){list(label = x, value = x)}
 ),
 value = "Vermont"
 ),
 htmlSpan(
 paste("Select", "Standardization Mode"),
 className = "control-label"
 ),
 dccDropdown(
 id = "stdmode-dropdown",
 options = lapply(
 unique(merged$StdMode),
 function(x){list(label = x, value = x)}
 ),
 value = "National"
 ),
 htmlSpan(
 paste("Select", "index"),
 className = "control-label"
 ),
 dccDropdown(
 id = "index-dropdown",
 options = lapply(
 unique(merged$IndexName),
 function(x){list(label = x, value = x)}
 ),
 value = "Education"
 ),
 htmlSpan(
 paste("Select", "year"),
 className = "control-label"
 ),
 dccDropdown(
 id = "year-dropdown",
 options = lapply(
 unique(merged$Year),
 function(x){list(label = x, value = x)}
 ),
 value = 2010
 )
 ),
 style = list(width = "20vw")
 )
 ),
 style = list(display = "flex")
 )
 )
 
 app$callback(
 output("map", "figure"),
 list(
 input("state-dropdown", "value"),
 input("stdmode-dropdown", "value"),
 input("index-dropdown", "value"),
 input("year-dropdown", "value")
 ),
 function(state, stdmode, index, year){
 create_mapbox_plot(state, stdmode, index, year)
 }
 )
 
 app$run_server(host = "0.0.0.0", port = 8050, block = TRUE, showcase = FALSE)
}
