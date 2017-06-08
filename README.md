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
#>        id       lon    lat    alt                 name        state uf
#> 136 83543 -41.93333 -18.85  148.0 Governador Valadares Minas Gerais MG
#> 248 83834 -51.46667 -25.40 1135.8           Guarapuava       Paraná PR
#>             time_zone offset_utc
#> 136 America/Sao_Paulo         -3
#> 248 America/Sao_Paulo         -3
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
#> [1] "83543" "83834"
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
    #> station: 83543
    #> OK (HTTP 200).
    #> 
    #> ------------------------------
    #> station: 83834
    #> OK (HTTP 200).

``` r
# check de start date
head(met_data)
#>                  date    id prec tair   tw tmax tmin urmax  patm pnmm wd
#> 1 1961-01-01 00:00:00 83543   NA   NA   NA 30.4   NA    NA    NA   NA NA
#> 2 1961-01-01 12:00:00 83543   NA 23.8 23.0   NA 20.6    93 993.2   NA  0
#> 3 1961-01-01 18:00:00 83543   NA 30.2 25.6   NA   NA    68 990.3   NA  5
#> 4 1961-01-02 00:00:00 83543   NA 22.2 21.3 27.8   NA    91 991.8   NA  0
#> 5 1961-01-02 12:00:00 83543 36.6 22.2 21.7   NA 20.4    95 993.1   NA  0
#> 6 1961-01-02 18:00:00 83543   NA 27.8 25.0   NA   NA    78 989.9   NA  0
#>   wsmax   n cc evap    ur       ws    request_status
#> 1    NA 2.5 NA  1.8 85.75 0.666667 Success: (200) OK
#> 2     0  NA 10   NA    NA       NA Success: (200) OK
#> 3     2  NA  9   NA    NA       NA Success: (200) OK
#> 4     0 0.0 10  1.4 90.75 0.000000 Success: (200) OK
#> 5     0  NA 10   NA    NA       NA Success: (200) OK
#> 6     0  NA 10   NA    NA       NA Success: (200) OK
```

``` r
# check de end date
tail(met_data)
#>                      date    id prec tair   tw tmax tmin urmax  patm pnmm
#> 54634 1977-01-30 12:00:00 83834  0.0 22.8 20.0   NA 16.4    77 892.7   NA
#> 54635 1977-01-30 18:00:00 83834   NA 28.2 22.4   NA   NA    59 890.8   NA
#> 54636 1977-01-31 00:00:00 83834   NA 21.6 19.4 26.3   NA    81 892.3   NA
#> 54637 1977-01-31 12:00:00 83834  2.3 20.0 19.2   NA 18.4    93 894.3   NA
#> 54638 1977-01-31 18:00:00 83834   NA 24.6 21.2   NA   NA    74 892.3   NA
#> 54639 1977-02-01 00:00:00 83834   NA 21.2 19.8   NA   NA    87 893.0   NA
#>       wd wsmax   n cc evap    ur  ws    request_status
#> 54634  0   0.0  NA  3   NA    NA  NA Success: (200) OK
#> 54635 27   3.5  NA  8   NA    NA  NA Success: (200) OK
#> 54636  0   0.0 1.1  8  1.1 85.25 3.2 Success: (200) OK
#> 54637  9   4.0  NA 10   NA    NA  NA Success: (200) OK
#> 54638  9   2.0  NA  9   NA    NA  NA Success: (200) OK
#> 54639 14   3.6  NA 10   NA    NA  NA Success: (200) OK
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
    station: 83543
    Bad Gateway (HTTP 502).
    -.-.-.-.-.-.-.-.-.-.-.-.
    station: 83834
    Bad Gateway (HTTP 502).

In this case the outcome data frame will be filled with `NA`, except for `request_status` which will return information on the request status.

    #>   date    id prec tair tw tmax tmin urmax patm pnmm wd wsmax  n cc evap ur
    #> 1   NA 83543   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 83834   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
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
