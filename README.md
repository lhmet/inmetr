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
install_github('jdtatsch/inmetr')
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

This function return a data frame with: station name, brazilian state, and OMM code. OMM code is a necessary argument to `import_bdmep()` function. This function download data from meteorological stations into the R.

Here, we show how to find the [OMM code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf) for the meterological stations at two cities (Santa Maria and Porto Alegre), both in Rio Grande do Sul state.

``` r
stations <- c("SANTA MARIA", "PORTO ALEGRE")
stations_rows <- pmatch(stations, info$name)
info[stations_rows, ]
#>             name state    id
#> 221  SANTA MARIA    RS 83936
#> 199 PORTO ALEGRE    RS 83967
stns_codes <- info[stations_rows, "id"] 
stns_codes
#> [1] "83936" "83967"
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
    #> station: 83936
    #> Request data ok.
    #> 
    #> -.-.-.-.-.-.-.-.-.-.-.-.
    #> station: 83967
    #> Request data ok.

``` r
# check de start date
head(met_data)
#>                  date    id prec tair   tw tmax tmin urmax  patm pnmm wd
#> 1 1961-01-01 00:00:00 83936   NA   NA   NA 31.9   NA    NA    NA   NA NA
#> 2 1961-01-01 12:00:00 83936   NA 23.9 21.4   NA 18.1    79 990.3   NA NA
#> 3 1961-01-01 18:00:00 83936   NA 30.6 25.1   NA   NA    63 988.2   NA NA
#> 4 1961-01-02 00:00:00 83936   NA 27.7 24.4 34.0   NA    75 986.4   NA NA
#> 5 1961-01-02 12:00:00 83936    0 26.4 23.8   NA 23.5    79 989.4   NA NA
#> 6 1961-01-02 18:00:00 83936   NA 30.8 25.2   NA   NA    62 989.0   NA NA
#>   wsmax   n cc evap    ur       ws
#> 1    NA 7.7 NA  1.1 73.00 1.000000
#> 2     0  NA  0   NA    NA       NA
#> 3     3  NA  9   NA    NA       NA
#> 4     0 6.0  0  2.7 74.25 0.666667
#> 5     0  NA  4   NA    NA       NA
#> 6     1  NA 10   NA    NA       NA
```

``` r
# check de end date
tail(met_data)
#>                       date    id prec tair tw tmax tmin urmax   patm
#> 109264 2016-12-30 00:00:00 83967   NA 22.5 NA 33.5   NA    96 1005.5
#> 109265 2016-12-30 12:00:00 83967 10.5 25.1 NA   NA 21.4    89 1005.8
#> 109266 2016-12-30 18:00:00 83967   NA 33.3 NA   NA   NA    64 1003.2
#> 109267 2016-12-31 00:00:00 83967   NA 25.6 NA 30.2   NA    89 1003.4
#> 109268 2016-12-31 12:00:00 83967 23.2 25.0 NA   NA 22.8    94 1004.8
#> 109269 2016-12-31 18:00:00 83967   NA 30.0 NA   NA   NA    68 1002.7
#>          pnmm wd   wsmax   n    cc evap    ur      ws
#> 109264 1011.1 14 1.54332 6.7 10.00   NA 82.75 1.02888
#> 109265 1011.4  0 0.00000  NA  7.50   NA    NA      NA
#> 109266 1008.7 14 1.54332  NA  6.25   NA    NA      NA
#> 109267 1009.0 14 1.54332 2.6  7.50   NA 78.50 1.02888
#> 109268 1010.4  0 0.00000  NA  7.50   NA    NA      NA
#> 109269 1008.2 32 0.51444  NA  8.75   NA    NA      NA
```

The units of meteorological variables can be viewed with `bdmep_units()`.

``` r
bdmep_units()
#>    varname                         description  unit
#> 1     date           date and time information     -
#> 2       id                          station ID     -
#> 3     prec                       precipitation    mm
#> 4     tair                     air temperature deg C
#> 5       tw                wet bulb temperature deg C
#> 6     tmax             maximum air temperature deg C
#> 7     tmin             minimum air temperature deg C
#> 8    urmax           maximum relative humidity     %
#> 9     patm                atmospheric pressure   hPa
#> 10    pnmm mean sea level atmospheric pressure   hPa
#> 11      wd                      wind direction   deg
#> 12   wsmax                           wind gust   m/s
#> 13       n                      sunshine hours     h
#> 14      cc                         cloud cover     -
#> 15    evap                         evaporation    mm
#> 16      ur                   relative humidity     %
#> 17      ws                          wind speed   m/s
```

Eventually, the request to INMET server failed and a message will be promped with the [HTTP status code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes):

    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 83936
    Bad Gateway (HTTP 502).
    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 83967
    Bad Gateway (HTTP 502).

The output data will be a dataframe filled with `NA` and the `request_status` variable return the HTTP status code.

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
    url = {https://github.com/jdtatsch/inmetr},
    address = {Santa Maria-RS, Brazil},
  }
```
