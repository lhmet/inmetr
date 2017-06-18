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
<<<<<<< HEAD
#>        id       lon        lat     alt             name     state uf
#> 358 83714 -45.60000 -22.750000 1642.00 Campos do Jordão São Paulo SP
#> 72  82588 -38.36667  -5.116667   43.62      Morada Nova     Ceará CE
#>             time_zone offset_utc
#> 358 America/Sao_Paulo         -3
#> 72  America/Fortaleza         -3
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
#> [1] "83714" "82588"
=======
#>        id       lon        lat alt      name state uf     time_zone
#> 196 82191 -48.43333  -1.433333  10     Belém  Pará PA America/Belem
#> 54  83238 -43.20000 -12.683333 422 Paratinga Bahia BA America/Bahia
#>     offset_utc
#> 196         -3
#> 54          -3
stns_codes <- bdmep_meta[stations_rows, "id"] 
stns_codes
#> [1] "82191" "83238"
>>>>>>> fa13e0f6850509a5cec84bd28353bf1c8fa32c7c
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
<<<<<<< HEAD
    #> station: 83714
    #> OK (HTTP 200).
    #> 
    #> ------------------------------
    #> station: 82588
=======
    #> station: 82191
    #> OK (HTTP 200).
    #> 
    #> ------------------------------
    #> station: 83238
>>>>>>> fa13e0f6850509a5cec84bd28353bf1c8fa32c7c
    #> OK (HTTP 200).

``` r
# check de start date
head(met_data)
<<<<<<< HEAD
#>                  date    id prec tair   tw tmax tmin urmax  patm pnmm wd
#> 1 1961-01-01 00:00:00 83714   NA   NA   NA 20.2   NA    NA    NA   NA NA
#> 2 1961-01-01 12:00:00 83714   NA 14.8 14.2   NA 14.8    94 841.8   NA 27
#> 3 1961-01-01 18:00:00 83714   NA 18.5 17.3   NA   NA    89 839.9   NA 27
#> 4 1961-01-02 00:00:00 83714   NA 17.9 17.7 20.3   NA    98 841.0   NA 27
#> 5 1961-01-02 12:00:00 83714 16.3 16.8 16.6   NA 15.0    98 840.4   NA 36
#> 6 1961-01-02 18:00:00 83714   NA 17.0 17.0   NA   NA   100 838.7   NA 32
#>   wsmax  n cc evap    ur       ws    request_status
#> 1    NA  0 NA   NA 94.75 3.000000 Success: (200) OK
#> 2     3 NA 10   NA    NA       NA Success: (200) OK
#> 3     3 NA 10   NA    NA       NA Success: (200) OK
#> 4     3  0 10  0.2 99.50 3.666667 Success: (200) OK
#> 5     1 NA 10   NA    NA       NA Success: (200) OK
#> 6     7 NA 10   NA    NA       NA Success: (200) OK
=======
#>                  date    id prec tair   tw tmax tmin urmax   patm pnmm wd
#> 1 1961-01-01 00:00:00 82191   NA 24.3   NA 32.4   NA    NA 1007.8   NA NA
#> 2 1961-01-01 12:00:00 82191   NA 27.4 24.4   NA 22.4    77 1007.5   NA  5
#> 3 1961-01-01 18:00:00 82191   NA 32.0 26.2   NA   NA    62 1005.0   NA  0
#> 4 1961-01-02 00:00:00 82191   NA 26.4 24.5 31.7   NA    85 1008.0   NA  0
#> 5 1961-01-02 12:00:00 82191    0 27.6 24.2   NA 22.7    75 1009.4   NA  5
#> 6 1961-01-02 18:00:00 82191   NA 31.0 26.0   NA   NA    66 1006.6   NA 36
#>   wsmax    n  cc evap    ur  ws    request_status
#> 1   0.0  8.5 0.4  4.8 77.25 1.1 Success: (200) OK
#> 2   3.3   NA 4.0   NA    NA  NA Success: (200) OK
#> 3   0.0   NA 5.0   NA    NA  NA Success: (200) OK
#> 4   0.0 10.8 8.0  4.0 81.75 1.8 Success: (200) OK
#> 5   2.3   NA 6.0   NA    NA  NA Success: (200) OK
#> 6   3.1   NA 5.0   NA    NA  NA Success: (200) OK
>>>>>>> fa13e0f6850509a5cec84bd28353bf1c8fa32c7c
```

``` r
# check de end date
tail(met_data)
<<<<<<< HEAD
#>                       date    id prec tair tw tmax tmin urmax   patm
#> 103781 2017-05-27 12:00:00 82588  1.5 28.8 NA   NA 21.3    80 1009.8
#> 103782 2017-05-28 00:00:00 82588   NA 27.4 NA 33.8   NA    90 1008.7
#> 103783 2017-05-28 12:00:00 82588 11.4 26.4 NA   NA 21.5    89 1010.1
#> 103784 2017-05-29 00:00:00 82588   NA 26.1 NA 34.8   NA    95 1009.0
#> 103785 2017-05-29 12:00:00 82588 36.0 25.1 NA   NA 20.3    91 1011.1
#> 103786 2017-05-30 00:00:00 82588   NA 25.8 NA   NA   NA    91 1009.7
#>          pnmm wd   wsmax   n    cc evap ur      ws    request_status
#> 103781 1014.8 14 3.08664  NA  7.50   NA NA      NA Success: (200) OK
#> 103782 1013.7  5 1.54332 4.1  7.50   NA 94 2.31498 Success: (200) OK
#> 103783 1015.1 14 3.08664  NA  8.75   NA NA      NA Success: (200) OK
#> 103784 1014.0  5 1.54332 0.0 10.00   NA 91 1.54332 Success: (200) OK
#> 103785 1016.2 14 1.54332  NA 10.00   NA NA      NA Success: (200) OK
#> 103786 1014.7  5 1.54332  NA  7.50   NA NA      NA Success: (200) OK
=======
#>                      date    id prec tair   tw tmax tmin urmax patm pnmm
#> 62981 1964-06-29 12:00:00 83238    0 24.0 19.1   NA 17.1    62   NA   NA
#> 62982 1964-06-29 18:00:00 83238   NA 33.6 22.1   NA   NA    34   NA   NA
#> 62983 1964-06-30 00:00:00 83238   NA 23.6 18.3   32   NA    58   NA   NA
#> 62984 1964-06-30 12:00:00 83238    0 21.8 18.3   NA 15.1    71   NA   NA
#> 62985 1964-06-30 18:00:00 83238   NA 31.8 21.1   NA   NA    36   NA   NA
#> 62986 1964-07-01 00:00:00 83238   NA 24.6 18.7   NA   NA    55   NA   NA
#>       wd wsmax    n cc evap    ur       ws    request_status
#> 62981 14     3   NA  0   NA    NA       NA Success: (200) OK
#> 62982 14     3   NA  3   NA    NA       NA Success: (200) OK
#> 62983  0     0 10.1  0  2.2 54.25 1.333333 Success: (200) OK
#> 62984  0     0   NA  0   NA    NA       NA Success: (200) OK
#> 62985 18     4   NA  2   NA    NA       NA Success: (200) OK
#> 62986  0     0   NA  0   NA    NA       NA Success: (200) OK
>>>>>>> fa13e0f6850509a5cec84bd28353bf1c8fa32c7c
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

<<<<<<< HEAD
    ------------------------
    station: 83714
    Bad Gateway (HTTP 502).
    ------------------------
    station: 82588
=======
    --------------------------
    station: 82191
    Bad Gateway (HTTP 502).
    --------------------------
    station: 83238
>>>>>>> fa13e0f6850509a5cec84bd28353bf1c8fa32c7c
    Bad Gateway (HTTP 502).

In this case the outcome data frame will be filled with `NA`, except for `request_status` which will return information on the request status.

    #>   date    id prec tair tw tmax tmin urmax patm pnmm wd wsmax  n cc evap ur
<<<<<<< HEAD
    #> 1   NA 83714   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 82588   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
=======
    #> 1   NA 82191   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
    #> 2   NA 83238   NA   NA NA   NA   NA    NA   NA   NA NA    NA NA NA   NA NA
>>>>>>> fa13e0f6850509a5cec84bd28353bf1c8fa32c7c
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
