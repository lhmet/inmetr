inmetr: Historical Data from Brazilian Meteorological Stations in R
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.580813.svg)](https://doi.org/10.5281/zenodo.580813) [![Version](https://img.shields.io/badge/Version-0.0.3-orange.svg)](https://img.shields.io/badge/Version-0.0.3-orange.svg) [![Build Status](https://travis-ci.org/lhmet/inmetr.svg?branch=master)](https://travis-ci.org/lhmet/inmetr)

Overview
--------

`inmetr` provide access to historical data measured by meteorological stations available in the Meteorological Database for Education and Research ([BDMEP](http://www.inmet.gov.br/projetos/rede/pesquisa/)) from National Institute of Meteorology (Instituto Nacional de Meteorologia - [INMET](http://www.inmet.gov.br)), Brazil.

Installation
------------

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

`bdmep_meta` data provide the `id` of stations, a numeric code defined by [OMM](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf). This `id` is a necessary argument to `bdmep_import()` function which allows to download data from meteorological stations into the R.

Here, we show how to find the [OMM code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf) for meteorological stations at two cities (randomly sampled).

``` r
#stations <- c("SANTA MARIA", "PORTO ALEGRE")
# random sample of two stations names 
stations <- sample(bdmep_meta$name,2)
stations_rows <- pmatch(stations, bdmep_meta$name)
bdmep_meta[stations_rows, ]
#>        id       lon       lat    alt      name          state uf
#> 338 83883 -52.61667 -27.11667 679.01   Chapecó Santa Catarina SC
#> 353 83672 -50.43333 -21.20000 397.00 Araçatuba      São Paulo SP
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
#> [1] "83883" "83672"
```

Import data
-----------

Now we can get data for the two cities from 1961 to the current date.

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

    #> 
    #> -.-.-.-.-.-.-.-.-.-.-.-.
    #> station: 83883
    #> OK (HTTP 200).
    #> 
    #> -.-.-.-.-.-.-.-.-.-.-.-.
    #> station: 83672
    #> OK (HTTP 200).

``` r
# check de start date
head(met_data)
#>                  date    id prec tair   tw tmax tmin urmax  patm pnmm wd
#> 1 1973-07-01 00:00:00 83883   NA   NA   NA 20.2   NA    NA    NA   NA NA
#> 2 1973-07-01 12:00:00 83883   NA 15.0 14.8   NA 14.2    98 941.6   NA 32
#> 3 1973-07-01 18:00:00 83883   NA 16.0 15.4   NA   NA    94 938.2   NA 27
#> 4 1973-07-02 00:00:00 83883   NA 14.5 14.2 16.2   NA    96 940.2   NA  9
#> 5 1973-07-02 12:00:00 83883 20.8 12.4 12.2   NA 11.8    97 943.1   NA  9
#> 6 1973-07-02 18:00:00 83883   NA 16.2 14.4   NA   NA    81 942.4   NA  9
#>   wsmax   n cc evap   ur       ws    request_status
#> 1    NA 0.0 NA  0.1 96.0 2.333333 Success: (200) OK
#> 2     3  NA 10   NA   NA       NA Success: (200) OK
#> 3     3  NA 10   NA   NA       NA Success: (200) OK
#> 4     1 1.8 10  0.1 94.5 1.000000 Success: (200) OK
#> 5     1  NA 10   NA   NA       NA Success: (200) OK
#> 6     1  NA  9   NA   NA       NA Success: (200) OK
```

``` r
# check de end date
tail(met_data)
#>                      date    id prec tair tw tmax tmin urmax  patm pnmm wd
#> 59549 1979-08-29 00:00:00 83672   NA   NA NA 31.4   NA    NA    NA   NA NA
#> 59550 1979-08-29 12:00:00 83672    0   NA NA   NA 17.0    NA 967.0   NA  5
#> 59551 1979-08-29 18:00:00 83672   NA   NA NA   NA   NA    NA 964.4   NA  5
#> 59552 1979-08-30 00:00:00 83672   NA   NA NA 32.0   NA    NA    NA   NA NA
#> 59553 1979-08-30 12:00:00 83672    0   NA NA   NA 17.2    NA 966.7   NA  5
#> 59554 1979-08-30 18:00:00 83672   NA   NA NA   NA   NA    NA 962.3   NA 36
#>       wsmax   n cc evap ur ws    request_status
#> 59549    NA 0.0 NA  4.3 NA  1 Success: (200) OK
#> 59550     1  NA 10   NA NA NA Success: (200) OK
#> 59551     1  NA 10   NA NA NA Success: (200) OK
#> 59552    NA 5.9 NA  4.4 NA  2 Success: (200) OK
#> 59553     1  NA 10   NA NA NA Success: (200) OK
#> 59554     3  NA 10   NA NA NA Success: (200) OK
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

Eventually, if the request failed a message will be prompted with the [HTTP status code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes), for example:

    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 83883
    Bad Gateway (HTTP 502).
    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 83672
    Bad Gateway (HTTP 502).

In this case the outcome data frame will be filled with `NA`, except for `request_status` which will return information on the request status.

    #>   date    id prec tair tw tmax tmin urmax patm pnmm wd wsmax  n cc evap ur
    #> 1   NA 83883   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 83672   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #>   ws          request_status
    #> 1 NA Bad Gateway (HTTP 502).
    #> 2 NA Bad Gateway (HTTP 502).

To cite this software
---------------------

``` r
citation("inmetr")

To cite package 'inmetr' in publications use:

  Tatsch, J.D. 2017. inmetr R package (v 0.0.3): Historical Data
  from Brazilian Meteorological Stations in R. Zenodo.
  https://doi.org/10.5281/zenodo.580813.

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {inmetr: Historical Data from Brazilian Meteorological Stations in R},
    author = {Jonatan Tatsch},
    year = {2017},
    note = {R package version 0.0.3},
    doi = {https://doi.org/10.5281/zenodo.580813},
    institution = {Universidade Federal de Santa Maria-UFSM},
    url = {https://github.com/lhmet/inmetr},
  }
```
