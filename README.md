inmetr: Historical Data from Brazilian Meteorological Stations in R
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.580813.svg)](https://doi.org/10.5281/zenodo.580813) [![Build Status](https://travis-ci.org/lhmet/inmetr.svg?branch=master)](https://travis-ci.org/lhmet/inmetr)

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

To search a meteorological station from INMET we can use metadata of INMET stations included in `inmetr` package as `bdmep_meta`.

``` r
head(bdmep_meta)
#>      id       lon        lat    alt            name   state uf
#> 1 83010 -68.73333 -11.016667 260.00       Brasiléia    Acre AC
#> 2 82704 -72.66667  -7.633333 170.00 Cruzeiro do Sul    Acre AC
#> 3 82915 -67.80000  -9.966667 160.00      Rio Branco    Acre AC
#> 4 82807 -70.76667  -8.166667 190.00        Tarauacá    Acre AC
#> 5 83098 -36.16667 -10.150000  56.13        Coruripe Alagoas AL
#> 6 82994 -35.70000  -9.666667  64.50          Maceió Alagoas AL
#>            time_zone offset_utc
#> 1 America/Rio_Branco         -5
#> 2 America/Rio_Branco         -5
#> 3 America/Rio_Branco         -5
#> 4 America/Rio_Branco         -5
#> 5     America/Maceio         -3
#> 6     America/Maceio         -3
tail(bdmep_meta)
#>        id       lon        lat    alt           name     state uf
#> 389 83033 -48.30000 -10.183333 280.00         Palmas Tocantins TO
#> 390 83231 -47.83333 -12.550000 275.00         Paranã Tocantins TO
#> 391 82863 -48.18333  -8.966667 187.00   Pedro Afonso Tocantins TO
#> 392 83228 -48.35000 -12.016667 242.49          Peixe Tocantins TO
#> 393 83064 -48.41667 -10.716667 239.20 Porto Nacional Tocantins TO
#> 394 83235 -46.41667 -12.400000 603.59     Taguatinga Tocantins TO
#>             time_zone offset_utc
#> 389 America/Araguaina         -3
#> 390 America/Araguaina         -3
#> 391 America/Araguaina         -3
#> 392 America/Araguaina         -3
#> 393 America/Araguaina         -3
#> 394 America/Araguaina         -3
```

`bdmep_meta` data provide the `id` of stations, a numeric code defined by [OMM](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf). This `id` is a necessary argument to `bdmep_import()` function which allows to download data from meteorological stations into the R.

Here, we show how to find the [OMM code](http://www.wmo.int/pages/prog/www/ois/volume-a/StationIDs_Global_1509.pdf) for meteorological stations at two cities (randomly sampled).

``` r
#stations <- c("SANTA MARIA", "PORTO ALEGRE")
# random sample of two stations names 
stations <- sample(bdmep_meta$name,2)
stations_rows <- pmatch(stations, bdmep_meta$name)
bdmep_meta[stations_rows, ]
#>        id       lon    lat    alt                         name state uf
#> 230 82605 -42.25000  -5.20 150.00 Alto Longa (Piloto do Longa) Piauí PI
#> 48  83295 -40.11667 -13.35 755.61         Itiruçu (Jaguaquara) Bahia BA
#>             time_zone offset_utc
#> 230 America/Fortaleza         -3
#> 48      America/Bahia         -3
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
#> [1] "82605" "83295"
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
    #> station: 82605
    #> OK (HTTP 200).
    #> 
    #> -.-.-.-.-.-.-.-.-.-.-.-.
    #> station: 83295
    #> OK (HTTP 200).

``` r
# check de start date
head(met_data)
#>                  date    id prec tair   tw tmax tmin urmax patm pnmm wd
#> 1 1979-01-01 00:00:00 82605   NA   NA   NA 31.9   NA    NA   NA   NA NA
#> 2 1979-01-01 12:00:00 82605    0 27.3 24.1   NA 23.2    76   NA   NA NA
#> 3 1979-01-01 18:00:00 82605   NA 31.1 25.6   NA   NA    63   NA   NA NA
#> 4 1979-01-02 00:00:00 82605   NA 26.0 24.0 33.8   NA    84   NA   NA NA
#> 5 1979-01-02 12:00:00 82605    0 28.7 23.1   NA 22.8    60   NA   NA NA
#> 6 1979-01-02 18:00:00 82605   NA 33.2 26.8   NA   NA    59   NA   NA NA
#>   wsmax  n cc evap    ur ws    request_status
#> 1    NA NA NA  5.7 76.75 NA Success: (200) OK
#> 2    NA NA  5   NA    NA NA Success: (200) OK
#> 3    NA NA  8   NA    NA NA Success: (200) OK
#> 4    NA NA  6  5.7 70.25 NA Success: (200) OK
#> 5    NA NA  5   NA    NA NA Success: (200) OK
#> 6    NA NA  5   NA    NA NA Success: (200) OK
```

``` r
# check de end date
tail(met_data)
#>                      date    id prec tair tw tmax tmin urmax  patm   pnmm
#> 38051 2016-01-28 00:00:00 83295   NA 21.3 NA 28.7   NA    95 929.9 1013.1
#> 38052 2016-01-28 12:00:00 83295 13.2 23.7 NA   NA 19.7    79 931.5 1014.7
#> 38053 2016-01-29 00:00:00 83295   NA 20.7 NA 26.7   NA    89 931.0 1014.3
#> 38054 2016-01-29 12:00:00 83295  0.6 23.6 NA   NA 18.6    80 932.9 1016.4
#> 38055 2016-01-30 00:00:00 83295   NA 21.1 NA   NA   NA    87 931.7 1015.5
#> 38056 2016-01-30 12:00:00 83295  0.0 23.6 NA   NA 18.2    72 932.9 1016.7
#>       wd   wsmax    n    cc evap ur      ws    request_status
#> 38051  9 1.54332  8.7 10.00   NA NA 2.05776 Success: (200) OK
#> 38052  5 2.57220   NA 10.00   NA NA      NA Success: (200) OK
#> 38053  9 1.54332 11.1  0.00   NA NA 1.02888 Success: (200) OK
#> 38054  9 1.54332   NA  6.25   NA NA      NA Success: (200) OK
#> 38055 14 0.51444   NA  0.00   NA NA 0.51444 Success: (200) OK
#> 38056 14 0.51444   NA 10.00   NA NA      NA Success: (200) OK
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
    station: 82605
    Bad Gateway (HTTP 502).
    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 83295
    Bad Gateway (HTTP 502).

In this case the outcome data frame will be filled with `NA`, except for `request_status` which will return information on the request status.

    #>   date    id prec tair tw tmax tmin urmax patm pnmm wd wsmax  n cc evap ur
    #> 1   NA 82605   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 83295   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
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
