app_ui <- function() {
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
}

#' @importFrom shiny addResourcePath tags
golem_add_external_resources <- function(){
  
  addResourcePath(
    'www', system.file('app/www', package = 'appwithdash')
  )
 
  tags$head(
    golem::activate_js(),
    golem::favicon()
    # Add here all the external resources
    # If you have a custom.css in the inst/app/www
    # Or for example, you can add shinyalert::useShinyalert() here
    #tags$link(rel="stylesheet", type="text/css", href="www/custom.css")
  )
}
