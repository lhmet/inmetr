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
#>        id       lon        lat    alt       name        state uf
#> 121 83685 -45.30000 -21.850000 950.05 Cambuquira Minas Gerais MG
#> 234 82678 -43.01667  -6.766667 123.27   Floriano        Piauí PI
#>             time_zone offset_utc
#> 121 America/Sao_Paulo         -3
#> 234 America/Fortaleza         -3
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
#> [1] "83685" "82678"
```

Import data
-----------

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

    #> 
    #> ------------------------------
    #> station: 83685
    #> OK (HTTP 200).
    #> 
    #> ------------------------------
    #> station: 82678
    #> OK (HTTP 200).

``` r
# check de start date
head(met_data)
#>                  date    id prec tair   tw tmax tmin urmax  patm pnmm wd
#> 1 1961-01-31 00:00:00 83685   NA   NA   NA 25.8   NA    NA    NA   NA NA
#> 2 1961-01-31 12:00:00 83685    0 21.1 20.4   NA 18.0    93 909.1   NA  0
#> 3 1961-01-31 18:00:00 83685   NA 25.2 21.3   NA   NA    70 907.5   NA 36
#> 4 1961-02-01 00:00:00 83685   NA 18.6 17.6 27.2   NA    90 908.0   NA  5
#> 5 1961-02-01 12:00:00 83685    2 20.0 19.0   NA 17.5    91 909.8   NA  9
#> 6 1961-02-01 18:00:00 83685   NA 26.3 20.6   NA   NA    60 907.8   NA 36
#>   wsmax   n cc evap    ur       ws    request_status
#> 1    NA 0.1 NA   NA 85.75 0.666667 Success: (200) OK
#> 2     0  NA 10   NA    NA       NA Success: (200) OK
#> 3     1  NA 10   NA    NA       NA Success: (200) OK
#> 4     1 2.6 10  1.2 80.25 1.000000 Success: (200) OK
#> 5     1  NA 10   NA    NA       NA Success: (200) OK
#> 6     1  NA  9   NA    NA       NA Success: (200) OK
```

``` r
# check de end date
tail(met_data)
#>                      date    id prec tair tw tmax tmin urmax   patm   pnmm
#> 55933 2017-05-28 12:00:00 82678    0 28.6 NA   NA 21.4    64 1001.5 1015.5
#> 55934 2017-05-28 18:00:00 82678   NA 33.2 NA   NA   NA    46  997.5 1011.4
#> 55935 2017-05-29 00:00:00 82678   NA 28.2 NA 34.8   NA    69  998.7 1012.6
#> 55936 2017-05-29 12:00:00 82678    0 28.2 NA   NA 23.2    56 1002.8 1016.8
#> 55937 2017-05-29 18:00:00 82678   NA 34.3 NA   NA   NA    34  998.1 1012.0
#> 55938 2017-05-30 00:00:00 82678   NA 27.0 NA   NA   NA    72  999.4 1013.4
#>       wd   wsmax   n   cc evap   ur      ws    request_status
#> 55933 14 2.57220  NA 7.50   NA   NA      NA Success: (200) OK
#> 55934 14 1.54332  NA 7.50   NA   NA      NA Success: (200) OK
#> 55935 14 0.51444 9.4 0.00   NA 58.5 1.20036 Success: (200) OK
#> 55936 14 2.57220  NA 8.75   NA   NA      NA Success: (200) OK
#> 55937 14 1.02888  NA 6.25   NA   NA      NA Success: (200) OK
#> 55938  0 0.00000  NA 7.50   NA   NA      NA Success: (200) OK
```

You can save data in a CSV file setting `destdir = "path/to/write/files"` in `bdmep_import` function. Data will be save one file per station.

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

    ------------------------
    station: 83685
    Bad Gateway (HTTP 502).
    ------------------------
    station: 82678
    Bad Gateway (HTTP 502).

In this case the outcome data frame will be filled with `NA`, except for `request_status` which will return information on the request status.

    #>   date    id prec tair tw tmax tmin urmax patm pnmm wd wsmax  n cc evap ur
    #> 1   NA 83685   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 82678   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #>   ws          request_status
    #> 1 NA Bad Gateway (HTTP 502).
    #> 2 NA Bad Gateway (HTTP 502).

To cite this software
---------------------

``` r
citation("inmetr")

To cite package 'inmetr' in publications use:

  Tatsch, J.D. 2017. inmetr R package (v 0.2.5): Historical Data
  from Brazilian Meteorological Stations in R. Zenodo.
  https://doi.org/10.5281/zenodo.580813.

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {inmetr: Historical Data from Brazilian Meteorological Stations in R},
    author = {Jonatan Tatsch},
    year = {2017},
    note = {R package version 0.2.5},
    doi = {https://doi.org/10.5281/zenodo.580813},
    institution = {Universidade Federal de Santa Maria-UFSM},
    url = {https://github.com/lhmet/inmetr},
  }
```
