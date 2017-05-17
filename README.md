inmetr: Historical Data from Brazilian Meteorological Stations in R
================

<!-- README.md is generated from README.Rmd. Please edit that file -->
[![DOI](https://zenodo.org/badge/doi/10.5281/zenodo.59652.svg)](http://dx.doi.org/10.5281/zenodo.59652) [![Version](https://img.shields.io/badge/Version-0.0.3-orange.svg)](https://img.shields.io/badge/Version-0.0.3-orange.svg) [![Build Status](https://travis-ci.org/lhmet/inmetr.svg?branch=master)](https://travis-ci.org/lhmet/inmetr)

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
#>        id       lon        lat    alt   name          state uf
#> 281 83757 -43.90000 -22.633333 388.15  Piraí Rio de Janeiro RJ
#> 108 82568 -46.46667  -5.816667 163.07 Grajaú       Maranhão MA
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
#> [1] "83757" "82568"
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
    #> station: 83757
    #> OK (HTTP 200).
    #> 
    #> -.-.-.-.-.-.-.-.-.-.-.-.
    #> station: 82568
    #> OK (HTTP 200).

``` r
# check de start date
head(met_data)
#>                  date    id prec tair   tw tmax tmin urmax  patm pnmm wd
#> 1 1961-01-01 00:00:00 83757   NA   NA   NA 28.9   NA    NA    NA   NA NA
#> 2 1961-01-01 12:00:00 83757   NA 24.4 23.0   NA 19.8    88 968.4   NA  0
#> 3 1961-01-01 18:00:00 83757   NA 25.4 23.2   NA   NA    83 967.2   NA 18
#> 4 1961-01-02 00:00:00 83757   NA 21.9 21.8 27.5   NA    99 968.6   NA  0
#> 5 1961-01-02 12:00:00 83757  7.7 24.9 23.0   NA 20.8    85 966.8   NA 32
#> 6 1961-01-02 18:00:00 83757   NA 25.9 24.8   NA   NA    91 965.2   NA  0
#>   wsmax  n cc evap    ur       ws    request_status
#> 1    NA NA NA   NA 92.25 0.333333 Success: (200) OK
#> 2     0 NA 10   NA    NA       NA Success: (200) OK
#> 3     1 NA 10   NA    NA       NA Success: (200) OK
#> 4     0 NA 10   NA 92.50 0.666667 Success: (200) OK
#> 5     2 NA 10   NA    NA       NA Success: (200) OK
#> 6     0 NA 10   NA    NA       NA Success: (200) OK
```

``` r
# check de end date
tail(met_data)
#>                      date    id prec tair   tw tmax tmin urmax  patm pnmm
#> 67498 1995-10-30 12:00:00 82568  0.0 27.5 23.2   NA 23.8    70 991.8   NA
#> 67499 1995-10-30 18:00:00 82568   NA 31.2 24.5   NA   NA    58 988.2   NA
#> 67500 1995-10-31 00:00:00 82568   NA 24.7 21.5 31.3   NA    76 991.5   NA
#> 67501 1995-10-31 12:00:00 82568  3.1 25.9 23.3   NA 22.0    80 992.9   NA
#> 67502 1995-10-31 18:00:00 82568   NA 25.7 24.6   NA   NA    91 989.0   NA
#> 67503 1995-11-01 00:00:00 82568   NA 23.7 22.8   NA   NA    93 992.8   NA
#>       wd wsmax   n cc evap    ur       ws    request_status
#> 67498 32     1  NA 10   NA    NA       NA Success: (200) OK
#> 67499 36     1  NA  7   NA    NA       NA Success: (200) OK
#> 67500  0     0 0.9 10  3.9 89.25 0.333333 Success: (200) OK
#> 67501  0     0  NA 10   NA    NA       NA Success: (200) OK
#> 67502  5     1  NA 10   NA    NA       NA Success: (200) OK
#> 67503  0     0  NA  6   NA    NA       NA Success: (200) OK
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
    station: 83757
    Bad Gateway (HTTP 502).
    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 82568
    Bad Gateway (HTTP 502).

In this case the outcome data frame will be filled with `NA`, except for `request_status` which will return information on the request status.

    #>   date    id prec tair tw tmax tmin urmax patm pnmm wd wsmax  n cc evap ur
    #> 1   NA 83757   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 82568   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #>   ws          request_status
    #> 1 NA Bad Gateway (HTTP 502).
    #> 2 NA Bad Gateway (HTTP 502).

To cite this software
---------------------

``` r
citation("inmetr")

To cite package 'inmetr' in publications use:

  Tatsch, J.D. 2017. inmetr: Historical Data from Brazilian
  Meteorological Stations in R Zenodo, doi:10.5281/zenodo.59652.

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {inmetr: A Package to Import Historical Data from Brazilian Meteorological
Stations},
    author = {Jonatan Tatsch},
    year = {2017},
    note = {R package version 0.0.3},
    doi = {http://doi.org/10.5281/ZENODO.59652},
    institution = {Universidade Federal de Santa Maria-UFSM},
    url = {https://github.com/lhmet/inmetr},
    address = {Santa Maria-RS, Brazil},
  }
```
