FROM rocker/verse:3.6.1
RUN export DEBIAN_FRONTEND=noninteractive; apt-get -y update \
  && apt-get install -y git-core \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    gdal-bin \
    libgdal-dev \
    libudunits2-dev
RUN R -e 'remotes::install_github("r-spatial/sf")'
RUN R -e 'install.packages("remotes")'
RUN R -e 'remotes::install_github("r-lib/remotes", ref = "97bbf81")'
RUN R -e 'remotes::install_github("plotly/dashR")'
RUN R -e 'remotes::install_github("ThinkR-open/golem")'
RUN R -e 'remotes::install_cran("shiny")'
RUN R -e 'remotes::install_cran("pkgload")'
COPY appwithdash_*.tar.gz /app.tar.gz
RUN R -e 'remotes::install_local("/app.tar.gz", upgrade = "never")'
EXPOSE 8050
CMD R -e 'appwithdash::run_app()'
