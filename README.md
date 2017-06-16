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
#>        id       lon       lat    alt        name          state uf
#> 384 83857 -45.55000 -22.96667  546.2    Tremembé      São Paulo SP
#> 347 83920 -49.93333 -28.30000 1415.0 São Joaquim Santa Catarina SC
#>             time_zone offset_utc
#> 384 America/Sao_Paulo         -3
#> 347 America/Sao_Paulo         -3
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
#> [1] "83857" "83920"
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
    #> station: 83857
    #> OK (HTTP 200).
    #> 
    #> ------------------------------
    #> station: 83920
    #> OK (HTTP 200).

``` r
# check de start date
head(met_data)
#>                  date    id prec tair   tw tmax tmin urmax  patm pnmm wd
#> 1 1961-01-01 00:00:00 83857   NA   NA   NA 30.8   NA    NA    NA   NA NA
#> 2 1961-01-01 12:00:00 83857   NA 23.8 22.2   NA 20.0    87 945.0   NA  0
#> 3 1961-01-01 18:00:00 83857   NA 29.0 23.8   NA   NA    64 943.0   NA 23
#> 4 1961-01-02 00:00:00 83857   NA 22.6 21.8 27.0   NA    93 945.4   NA  0
#> 5 1961-01-02 12:00:00 83857  4.4 23.2 22.1   NA 21.4    90 945.0   NA 36
#> 6 1961-01-02 18:00:00 83857   NA 25.4 23.6   NA   NA    86 942.7   NA  5
#>   wsmax   n cc evap    ur       ws    request_status
#> 1    NA 1.6 NA  1.7 84.25 1.000000 Success: (200) OK
#> 2     0  NA  9   NA    NA       NA Success: (200) OK
#> 3     3  NA  8   NA    NA       NA Success: (200) OK
#> 4     0 0.2 10  2.0 91.00 1.333333 Success: (200) OK
#> 5     3  NA 10   NA    NA       NA Success: (200) OK
#> 6     1  NA 10   NA    NA       NA Success: (200) OK
```

``` r
# check de end date
tail(met_data)
#>                      date    id prec tair tw tmax tmin urmax  patm   pnmm
#> 68217 2017-05-28 12:00:00 83920 58.4 12.2 NA   NA  9.4    98 866.3 1020.7
#> 68218 2017-05-28 18:00:00 83920   NA 13.4 NA   NA   NA    96 864.6 1018.1
#> 68219 2017-05-29 00:00:00 83920   NA 13.4 NA   15   NA    98 865.2 1018.3
#> 68220 2017-05-29 12:00:00 83920 49.3 14.0 NA   NA 12.0   100 864.6 1017.4
#> 68221 2017-05-29 18:00:00 83920   NA 14.2 NA   NA   NA   100 863.8 1016.4
#> 68222 2017-05-30 00:00:00 83920   NA 11.8 NA   NA   NA   100 865.4 1018.5
#>       wd   wsmax  n cc evap  ur      ws    request_status
#> 68217  5 1.02888 NA 10   NA  NA      NA Success: (200) OK
#> 68218  5 1.02888 NA 10   NA  NA      NA Success: (200) OK
#> 68219 36 1.02888  0 10   NA 100 0.68592 Success: (200) OK
#> 68220 32 1.02888 NA 10   NA  NA      NA Success: (200) OK
#> 68221  0 0.00000 NA 10   NA  NA      NA Success: (200) OK
#> 68222 18 1.02888 NA 10   NA  NA      NA Success: (200) OK
```

You can save data in a CSV file setting `destdir = path/to/write/files` in `bdmep_import` function. Data will be save one file per station.

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
    station: 83857
    Bad Gateway (HTTP 502).
    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 83920
    Bad Gateway (HTTP 502).

In this case the outcome data frame will be filled with `NA`, except for `request_status` which will return information on the request status.

    #>   date    id prec tair tw tmax tmin urmax patm pnmm wd wsmax  n cc evap ur
    #> 1   NA 83857   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 83920   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
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
