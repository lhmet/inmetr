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
stations <- c("Santa Maria", "Macapá")
# random sample of two stations names 
#stations <- sample(bdmep_meta$name,2)
stations_rows <- pmatch(stations, bdmep_meta$name)
bdmep_meta[stations_rows, ]
#>        id       lon    lat   alt        name             state uf
#> 325 83936 -53.70000 -29.70 95.00 Santa Maria Rio Grande do Sul RS
#> 32  82098 -51.11667  -0.05 14.46      Macapá             Amapá AP
#>             time_zone offset_utc
#> 325 America/Sao_Paulo         -3
#> 32      America/Belem         -3
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
#> [1] "83936" "82098"
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
    #> station: 83936
    #> OK (HTTP 200).
    #> 
    #> ------------------------------
    #> station: 82098
    #> OK (HTTP 200).

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
#>   wsmax   n cc evap    ur       ws    request_status
#> 1    NA 7.7 NA  1.1 73.00 1.000000 Success: (200) OK
#> 2     0  NA  0   NA    NA       NA Success: (200) OK
#> 3     3  NA  9   NA    NA       NA Success: (200) OK
#> 4     0 6.0  0  2.7 74.25 0.666667 Success: (200) OK
#> 5     0  NA  4   NA    NA       NA Success: (200) OK
#> 6     1  NA 10   NA    NA       NA Success: (200) OK
```

``` r
# check de end date
tail(met_data)
#>                       date    id prec tair   tw tmax tmin urmax   patm
#> 108000 2017-12-28 12:00:00 82098  7.8 27.2 25.8   NA 24.9    89 1009.4
#> 108001 2017-12-28 18:00:00 82098   NA 31.4 26.1   NA   NA    64 1006.8
#> 108002 2017-12-29 00:00:00 82098   NA 27.8 26.0 31.8   NA    86 1008.1
#> 108003 2017-12-29 12:00:00 82098  0.0 27.2 25.4   NA 24.7    86 1008.7
#> 108004 2017-12-29 18:00:00 82098   NA 30.8 26.7   NA   NA    72 1005.5
#> 108005 2017-12-30 00:00:00 82098   NA 28.0 25.8   NA   NA    81 1007.5
#>          pnmm wd wsmax   n cc evap ur      ws    request_status
#> 108000 1011.1  0   0.0  NA  8   NA NA      NA Success: (200) OK
#> 108001 1008.5  9   2.3  NA  9   NA NA      NA Success: (200) OK
#> 108002 1009.8  0   0.0 8.2 10  2.4 81 1.02888 Success: (200) OK
#> 108003 1010.4  0   0.0  NA  9   NA NA      NA Success: (200) OK
#> 108004     NA  7   1.8  NA  5   NA NA      NA Success: (200) OK
#> 108005 1009.2  5   2.3  NA  6   NA NA      NA Success: (200) OK
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
    station: 83936
    Bad Gateway (HTTP 502).
    ------------------------
    station: 82098
    Bad Gateway (HTTP 502).

In this case the outcome data frame will be filled with `NA`, except for `request_status` which will return information on the request status.

    #>   date    id prec tair tw tmax tmin urmax patm pnmm wd wsmax  n cc evap ur
    #> 1   NA 83936   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 82098   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #>   ws          request_status
    #> 1 NA Bad Gateway (HTTP 502).
    #> 2 NA Bad Gateway (HTTP 502).

To cite this software
---------------------

``` r
citation("inmetr")

To cite package 'inmetr' in publications use:

  Tatsch, J.D. 2018. inmetr R package (v 0.2.5): Historical Data
  from Brazilian Meteorological Stations in R. Zenodo.
  https://doi.org/10.5281/zenodo.580813.

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {inmetr: Historical Data from Brazilian Meteorological Stations in R},
    author = {Jonatan Tatsch},
    year = {2018},
    note = {R package version 0.2.5},
    doi = {https://doi.org/10.5281/zenodo.580813},
    institution = {Universidade Federal de Santa Maria-UFSM},
    url = {https://github.com/lhmet/inmetr},
  }
```
