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

To search a meteorological station from INMET we can use the data included in `inmetr` package and loaded as `bdmep_meta`.

``` r
head(bdmep_meta)
#>      id       lon        lat    alt            name   state uf
#> 1 83010 -68.73333 -11.016667 260.00       Brasiléia    Acre AC
#> 2 82704 -72.66667  -7.633333 170.00 Cruzeiro do Sul    Acre AC
#> 3 82915 -67.80000  -9.966667 160.00      Rio Branco    Acre AC
#> 4 82807 -70.76667  -8.166667 190.00        Tarauacá    Acre AC
#> 5 83098 -36.16667 -10.150000  56.13        Coruripe Alagoas AL
#> 6 82994 -35.70000  -9.666667  64.50          Maceió Alagoas AL
tail(bdmep_meta)
#>        id       lon        lat    alt           name     state uf
#> 389 83033 -48.30000 -10.183333 280.00         Palmas Tocantins TO
#> 390 83231 -47.83333 -12.550000 275.00         Paranã Tocantins TO
#> 391 82863 -48.18333  -8.966667 187.00   Pedro Afonso Tocantins TO
#> 392 83228 -48.35000 -12.016667 242.49          Peixe Tocantins TO
#> 393 83064 -48.41667 -10.716667 239.20 Porto Nacional Tocantins TO
#> 394 83235 -46.41667 -12.400000 603.59     Taguatinga Tocantins TO
```

`bdmep_meta` data provide the `id` of stations, a numeric code used by [OMM code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf). The `id` is a necessary argument to `bdmep_import()` function. This function download data from meteorological stations into the R.

Here, we show how to find the [OMM code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf) for meterological stations at two cities (randomly sampled).

``` r
#stations <- c("SANTA MARIA", "PORTO ALEGRE")
# random sample of two stations names 
stations <- sample(bdmep_meta$name,2)
stations_rows <- pmatch(stations, bdmep_meta$name)
bdmep_meta[stations_rows, ]
#>        id       lon       lat     alt                  name        state
#> 220 82887 -38.56667  -8.60000  309.73              Floresta   Pernambuco
#> 120 83681 -46.38333 -21.91667 1150.00 Caldas (P. de Caldas) Minas Gerais
#>     uf
#> 220 PE
#> 120 MG
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
#> [1] "82887" "83681"
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
    #> station: 82887
    #> OK (HTTP 200).
    #> 
    #> -.-.-.-.-.-.-.-.-.-.-.-.
    #> station: 83681
    #> OK (HTTP 200).

``` r
# check de start date
head(met_data)
#>                  date    id prec tair   tw tmax tmin urmax  patm pnmm wd
#> 1 1961-01-01 00:00:00 82887   NA   NA   NA 37.5   NA    NA    NA   NA NA
#> 2 1961-01-01 12:00:00 82887   NA 28.9 21.6   NA 23.0    51 973.9   NA 14
#> 3 1961-01-01 18:00:00 82887   NA 36.3 24.1   NA   NA    34 970.0   NA  0
#> 4 1961-01-02 00:00:00 82887   NA 29.4 21.8 37.6   NA    50 972.4   NA 14
#> 5 1961-01-02 12:00:00 82887    0 28.8 22.6   NA 21.7    58 975.4   NA  5
#> 6 1961-01-02 18:00:00 82887   NA 35.9 23.2   NA   NA    32 969.6   NA 14
#>   wsmax    n cc evap    ur       ws    request_status
#> 1    NA 11.7 NA 11.9 46.25 3.333333 Success: (200) OK
#> 2     2   NA  1   NA    NA       NA Success: (200) OK
#> 3     0   NA  5   NA    NA       NA Success: (200) OK
#> 4     8 11.9  0 13.6 42.00 1.333333 Success: (200) OK
#> 5     1   NA  1   NA    NA       NA Success: (200) OK
#> 6     2   NA  4   NA    NA       NA Success: (200) OK
```

``` r
# check de end date
tail(met_data)
#>                      date    id prec tair   tw tmax tmin urmax patm pnmm
#> 72248 2015-06-29 12:00:00 83681    0 16.5 13.2   NA  4.1    68   NA   NA
#> 72249 2015-06-29 18:00:00 83681   NA 20.9 14.6   NA   NA    48   NA   NA
#> 72250 2015-06-30 00:00:00 83681   NA 13.7 12.6 21.6   NA    88   NA   NA
#> 72251 2015-06-30 12:00:00 83681    0 16.5 14.6   NA  9.3    80   NA   NA
#> 72252 2015-06-30 18:00:00 83681   NA 21.3 16.6   NA   NA    60   NA   NA
#> 72253 2015-07-01 00:00:00 83681   NA 15.7 13.6   NA   NA    78   NA   NA
#>       wd wsmax   n cc evap ur ws    request_status
#> 72248 NA    NA  NA  0   NA NA NA Success: (200) OK
#> 72249 NA    NA  NA  5   NA NA NA Success: (200) OK
#> 72250 NA    NA 3.4  9  2.6 74 NA Success: (200) OK
#> 72251 NA    NA  NA  9   NA NA NA Success: (200) OK
#> 72252 NA    NA  NA  8   NA NA NA Success: (200) OK
#> 72253 NA    NA  NA  8   NA NA NA Success: (200) OK
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
    station: 82887
    Bad Gateway (HTTP 502).
    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 83681
    Bad Gateway (HTTP 502).

In this case the outcome data frame will be filled with `NA`, except for `request_status` which will return information on the request status.

    #>   date    id prec tair tw tmax tmin urmax patm pnmm wd wsmax  n cc evap ur
    #> 1   NA 82887   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 83681   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
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
