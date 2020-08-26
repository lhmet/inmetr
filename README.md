DEPRECATED - no longer actively maintained
================

> Due to changes in access to the BDMEP-INMET data acquisition system,
> {inmetr} is no longer supported. See
> <https://portal.inmet.gov.br/noticias/inmet-lan%C3%A7a-novo-portal>
> and consider using <https://bdmep.inmet.gov.br/> instead.

## inmetr: Historical Data from Brazilian Meteorological Stations in R

<!-- README.md is generated from README.Rmd. Please edit that file -->

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.580813.svg)](https://doi.org/10.5281/zenodo.580813)
[![Build
Status](https://travis-ci.org/lhmet/inmetr.svg?branch=master)](https://travis-ci.org/lhmet/inmetr)

### Overview

`inmetr` provide access to historical data measured by meteorological
stations available in the Meteorological Database for Education and
Research ([BDMEP](http://www.inmet.gov.br/projetos/rede/pesquisa/)) from
National Institute of Meteorology (Instituto Nacional de Meteorologia -
[INMET](http://www.inmet.gov.br)), Brazil.

### Installation

`inmetr` is easy to install from Git Hub using the `devtools` package.

``` r
library(devtools)
```

``` r
install_github('lhmet/inmetr')
```

Load package

``` r
library(inmetr)
```

### Stations ID

To search a meteorological station from INMET we can use metadata of
INMET stations included in `inmetr` package as `bdmep_meta`.

``` r
head(bdmep_meta)
tail(bdmep_meta)
```

`bdmep_meta` is a data frame providing the `id` of stations, a numeric
code defined by
[OMM](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf).
This `id` is a necessary argument to `bdmep_import()` function which
allows to download data from meteorological stations into R.

Here, we show how to find the [OMM
code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf)
for meteorological stations at two cities (randomly sampled).

``` r
#stations <- c("Santa Maria", "Macapá")
stations <- c("Rio de Janeiro", "Goiás")
# random sample of two stations names 
#stations <- sample(bdmep_meta$name, 2)
stations_rows <- pmatch(stations, bdmep_meta$name)
bdmep_meta[stations_rows, ]
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
```

### Import data

Now we can import data for the two cities from 1961 to the current date.

``` r
start_date <- "01/01/1961"
end_date <- format(Sys.Date(), "%d/%m/%Y")
met_data <- bdmep_import(id = stns_codes,
                         sdate = start_date, 
                         edate = end_date, 
                         email = "your-email",
                         passwd = "your-password",
                         verbose = TRUE)
```

``` r
# check de start date
head(met_data)
```

``` r
# check de end date
tail(met_data)
```

You can save data in a CSV file setting argument `destdir =
"path/to/write/files"` in `bdmep_import` function. Data will be save one
file per station.

A description of meteorological variables can be obtained by:

``` r
bdmep_description()
```

Eventually, if the request failed a message will be prompted with the
[HTTP status
code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes), for
example:

``` shell
------------------------
station: `r stns_codes[1]`
Bad Gateway (HTTP 502).
------------------------
station: `r stns_codes[2]`
Bad Gateway (HTTP 502).
```

In this case the outcome data frame will be filled with `NA`, except for
`request_status` which will return information on the request status.

### To cite this software

``` r
citation("inmetr")

To cite package 'inmetr' in publications use:

  Tatsch, J.D. 2020. inmetr R package (v 0.2.5): Historical Data from
  Brazilian Meteorological Stations in R. Zenodo.
  https://doi.org/10.5281/zenodo.580813.

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {inmetr: Historical Data from Brazilian Meteorological Stations in R},
    author = {Jonatan Tatsch},
    year = {2020},
    note = {R package version 0.2.5},
    doi = {https://doi.org/10.5281/zenodo.580813},
    institution = {Universidade Federal de Santa Maria-UFSM},
    url = {https://github.com/lhmet/inmetr},
  }
```
