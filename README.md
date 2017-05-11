inmetr: Historical Data from Brazilian Meteorological Stations in R
================

[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.59652.svg)](http://dx.doi.org/10.5281/zenodo.59652) [![Version](https://img.shields.io/badge/Version-0.0.2-orange.svg)](https://img.shields.io/badge/Version-0.0.2-orange.svg) [![Build Status](https://travis-ci.org/lhmet/inmetr.svg?branch=master)](https://travis-ci.org/lhmet/inmetr)

Overview
--------

`inmetr` provide access to historical data measured by meteorological stations available in the Meteorological Database for Education and Research ([BDMEP](http://www.inmet.gov.br/projetos/rede/pesquisa/)) from National Institute of Meteorology (Instituto Nacional de Meteorologia - [INMET](http://www.inmet.gov.br)), Brazil.

Installation
------------

`inmetr` is easy to install from GitHub using the `devtools` package.

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

Stations ID
-----------

To search a meteorological station from INMET we can use `bdmep_stations()` function.

``` r
info <- bdmep_stations()
```

``` r
head(info)
#>            name state    id
#> 1        ACARAU    CE 82294
#> 2   AGUA BRANCA    AL 82989
#> 3       AIMORES    MG 83595
#> 4    ALAGOINHAS    BA 83249
#> 5      ALTAMIRA    PA 82353
#> 6 ALTO PARNAIBA    MA 82970
```

This function returns a data frame with: station name, brazilian state, and OMM code. OMM code is a necessary argument to `bdmep_import()` function. This function download data from meteorological stations into the R.

Here, we show how to find the [OMM code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf) for the meterological stations at two cities (Santa Maria and Porto Alegre), both in Rio Grande do Sul state.

``` r
#stations <- c("SANTA MARIA", "PORTO ALEGRE")
# randon sample of two stations names 
stations <- sample(info$name,2)
stations_rows <- pmatch(stations, info$name)
info[stations_rows, ]
#>               name state    id
#> 32 BENTO GONCALVES    RS 83941
#> 53        CANARANA    MT 83270
stns_codes <- info[stations_rows, "id"] 
stns_codes
#> [1] "83941" "83270"
```

Import data
-----------

Now we can get data for the two cities from 1961 to the current day.

``` r
start_date <- "01/01/1961"
end_date <- format(Sys.Date(), "%d/%m/%Y")
met_data <- bdmep_import(ids = stns_codes,
                         sdate = start_date, 
                         edate = end_date, 
                         email = "your-email",
                         passwd = "your-password",
                         verbose = TRUE)
```

    #> 
    #> -.-.-.-.-.-.-.-.-.-.-.-.
    #> station: 83941
    #> OK (HTTP 200).
    #> 
    #> -.-.-.-.-.-.-.-.-.-.-.-.
    #> station: 83270
    #> OK (HTTP 200).

``` r
# check de start date
head(met_data)
#>                  date    id prec tair   tw tmax tmin urmax patm pnmm wd
#> 1 1961-01-01 00:00:00 83941   NA   NA   NA 29.0   NA    NA   NA   NA NA
#> 2 1961-01-01 12:00:00 83941   NA 22.5 20.0   NA 17.0    78   NA   NA  9
#> 3 1961-01-01 18:00:00 83941   NA 28.0 23.5   NA   NA    67   NA   NA 14
#> 4 1961-01-02 00:00:00 83941   NA 23.0 20.5 31.5   NA    79   NA   NA 14
#> 5 1961-01-02 12:00:00 83941    0 23.5 20.0   NA 18.5    72   NA   NA 36
#> 6 1961-01-02 18:00:00 83941   NA 30.0 22.0   NA   NA    48   NA   NA 23
#>   wsmax  n cc evap    ur ws    request_status
#> 1    NA NA NA   NA 75.75  1 Success: (200) OK
#> 2     1 NA  2   NA    NA NA Success: (200) OK
#> 3     1 NA  0   NA    NA NA Success: (200) OK
#> 4     1 NA  2   NA 78.00  1 Success: (200) OK
#> 5     1 NA  0   NA    NA NA Success: (200) OK
#> 6     1 NA  2   NA    NA NA Success: (200) OK
```

``` r
# check de end date
tail(met_data)
#>                      date    id prec tair tw tmax tmin urmax  patm   pnmm
#> 69253 2016-12-30 00:00:00 83270   NA 24.2 NA 31.4   NA    90 966.0 1014.3
#> 69254 2016-12-30 12:00:00 83270  0.0 26.0 NA   NA 19.9    82 966.5 1014.6
#> 69255 2016-12-30 18:00:00 83270   NA 29.0 NA   NA   NA    62 964.8 1012.9
#> 69256 2016-12-31 00:00:00 83270   NA 25.0 NA 31.7   NA    86 965.9 1013.9
#> 69257 2016-12-31 12:00:00 83270 25.3 23.8 NA   NA 19.5    90 967.3 1015.5
#> 69258 2016-12-31 18:00:00 83270   NA 25.4 NA   NA   NA    83 964.4 1012.7
#>       wd wsmax   n   cc evap    ur ws    request_status
#> 69253  0     0 4.9  5.0   NA 79.00  0 Success: (200) OK
#> 69254  0     0  NA  5.0   NA    NA NA Success: (200) OK
#> 69255  0     0  NA  7.5   NA    NA NA Success: (200) OK
#> 69256  0     0 2.1  7.5   NA 89.75  0 Success: (200) OK
#> 69257  0     0  NA 10.0   NA    NA NA Success: (200) OK
#> 69258  0     0  NA  7.5   NA    NA NA Success: (200) OK
```

A description of meteorological variables can be obtained by `bdmep_description()`.

``` r
bdmep_description()
#>           varname                            description  unit
#> 1            date              date and time information     -
#> 2              id                             station ID     -
#> 3            prec                          precipitation    mm
#> 4            tair                        air temperature deg C
#> 5              tw                   wet bulb temperature deg C
#> 6            tmax                maximum air temperature deg C
#> 7            tmin                minimum air temperature deg C
#> 8           urmax              maximum relative humidity     %
#> 9            patm                   atmospheric pressure   hPa
#> 10           pnmm    mean sea level atmospheric pressure   hPa
#> 11             wd                         wind direction   deg
#> 12          wsmax                              wind gust   m/s
#> 13              n                         sunshine hours     h
#> 14             cc                            cloud cover     -
#> 15           evap                            evaporation    mm
#> 16             ur                      relative humidity     %
#> 17             ws                             wind speed   m/s
#> 18 request_status Information on the status of a request  <NA>
```

Eventually, if the request failed a message will be promped with the [HTTP status code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes), for example:

    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 83941
    Bad Gateway (HTTP 502).
    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 83270
    Bad Gateway (HTTP 502).

In this case the outcome data frame will be filled with `NA`, except for `request_status` which will return information on the request status.

    #>   date    id prec tair tw tmax tmin urmax patm pnmm wd wsmax  n cc evap ur
    #> 1   NA 83941   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 83270   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #>   ws          request_status
    #> 1 NA Bad Gateway (HTTP 502).
    #> 2 NA Bad Gateway (HTTP 502).

To cite this software
---------------------

``` r
citation("inmetr")

To cite package 'inmetr' in publications use:

  Tatsch, J.D. 2017. inmetr: A Package to Import Historical Data
  from Brazilian Meteorological Stations. Zenodo,
  doi:10.5281/zenodo.59652.

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {inmetr: A Package to Import Historical Data from Brazilian Meteorological
Stations},
    author = {Jonatan Tatsch},
    year = {2017},
    note = {R package version 0.0.2.9000},
    doi = {http://doi.org/10.5281/ZENODO.59652},
    institution = {Universidade Federal de Santa Maria-UFSM},
    url = {https://github.com/lhmet/inmetr},
    address = {Santa Maria-RS, Brazil},
  }
```
