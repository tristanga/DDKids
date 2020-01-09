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
  
  map_data <- fread("../data/DataForMaps.csv", colClasses = c(GEOID10 = "character"))
  app <- Dash$new()
  
  app$layout(app_ui())
  # with_golem_options(
  #   app = shinyApp(ui = app_ui, server = app_server), 
  #   golem_opts = list(...)
  # )
  app$run_server(host = "0.0.0.0", port = 8050, block = TRUE, showcase = FALSE)
}
