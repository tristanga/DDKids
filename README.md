
<!-- README.md is generated from README.Rmd. Please edit that file -->

# appwithdash

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of {appwithdash} is to test in which conditions {golem} can be
used with Dash.  
This comes with a blog article on ThinkR website: [Dash with golem: The
beginning](http://rtask.thinkr.fr/dash-with-golem-the-beginning)

## Installation

You can install the released version of appwithdash from GitHub with:

``` r
remotes::install_github("ThinkR-open/appwithdash")
```

## Use {golem} with {Dash}

  - Create a golem: `golem::create_golem(path = "appwithdash")`
  - Remove all calls to `@import shiny`
  - Modify run\_app:

<!-- end list -->

``` r
run_app <- function() {
  # Packages need to be loaded for Dash to work
  # import is not enough. 
  # Add here temporary but in DESCRIPTION > Depends at the end
  library(dash)
  library(dashCoreComponents)
  library(dashHtmlComponents)
  
  # Init app
  app <- Dash$new()
  # UI
  app$layout(app_ui())
  # Use host 0.0.0.0 to embed in Docker later
  app$run_server(host = "0.0.0.0", port = 8050, block = TRUE, showcase = FALSE)
}
```

  - Fill app\_ui
  - Document: `attachment::att_to_description()`
  - Reload: `golem::document_and_reload()`
  - Run the app: `appwithdash::run_app()`

## Deploy inside a Docker

``` r
# Build package inside and hide ----
devtools::build(path = ".")
usethis::use_build_ignore(".*\.tar\.gz$", escape = FALSE)
usethis::use_git_ignore("*.tar.gz")

# Add golem Dockerfile skeleton ---
golem::add_dockerfile()
# Modify dockerfile to include 'remotes::install_github("plotly/dashR")'
# Modify dockerfile to include 'remotes::install_github("ThinkR-open/golem")'
# Modify dockerfile to expose to EXPOSE 8050

# Build docker ----
system("docker build -t appwithdash .")

# Run docker ----
# future allows to keep the R console free
library(future)
plan(multisession)
future({
  system(paste0("docker run --rm --name app -p 8050:8050 appwithdash"), intern = TRUE)
})
browseURL("http://127.0.0.1:8050")

# Stop docker ----
system("docker kill app")
system("docker rm app")
```

Please note that the ‘appwithdash’ project is released with a
[Contributor Code of Conduct](CODE_OF_CONDUCT.md). By contributing to
this project, you agree to abide by its terms.
